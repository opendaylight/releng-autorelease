# @License EPL-1.0 <http://spdx.org/licenses/EPL-1.0>
##############################################################################
# Copyright (c) 2016 Cisco Systems, Inc. and others.
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License v1.0 which accompanies this distribution,
# and is available at http://www.eclipse.org/legal/epl-v10.html
##############################################################################

import xml.etree.ElementTree as ET


class MavenProperty(object):
    def __init__(self, pom, key, value):
        self.pom = pom
        self.key = key
        self.value = value

    def __str__(self):
        return self.value


class MavenCoordinates(object):
    namespaces = {'x': 'http://maven.apache.org/POM/4.0.0'}

    def __init__(self, element):
        self.root = element
        if element is not None:
            self.artifactId = self._find("artifactId")
            self.groupId = self._find("groupId")
            self.version = self._find("version")
        else:
            self.artifactId = None
            self.groupId = None
            self.version = None

    def _find(self, select):
        match = "./x:%s" % select
        found = self.root.find(match, self.namespaces)
        if found is not None:
            return found.text
        else:
            return None

    def __str__(self):
        return "%s:%s:%s" % (self.groupId, self.artifactId, self.version)


class POM(object):
    namespaces = {'x': 'http://maven.apache.org/POM/4.0.0'}

    def __init__(self, filename, pomdict={}):
        self.pomdict = pomdict
        self.filename = filename
        self.root = ET.parse(filename)
        self.parent = self.root.find('./x:parent', self.namespaces)
        self.parentMavenCoordinates = MavenCoordinates(self.parent)
        self.mavenCoordinates = MavenCoordinates(self.root)
        self.effectiveMavenCoordinates = self.calculateEffectiveMavenCoordinates()
        self.properties = self._findProperties()

    def __str__(self):
        return str(self.effectiveMavenCoordinates)

    def calculateEffectiveMavenCoordinates(self):
        self.effectiveMavenCoordinates = MavenCoordinates(self.root)
        if self.mavenCoordinates is not None and self.mavenCoordinates.version is None:
            if self.parentMavenCoordinates is not None and self.parentMavenCoordinates.version is not None:
                self.effectiveMavenCoordinates.version = self.parentMavenCoordinates.version
            else:
                raise Exception("filename: %s is missing version." % (self.filename))
        if self.mavenCoordinates is not None and self.mavenCoordinates.groupId is None:
            if self.parentMavenCoordinates is not None and self.parentMavenCoordinates.groupId is not None:
                self.effectiveMavenCoordinates.groupId = self.parentMavenCoordinates.groupId
            else:
                raise Exception("filename: %s is missing version." % (self.filename))
        if ("${" in str(self.effectiveMavenCoordinates.version)):
            self.effectiveMavenCoordinates.version = self.findPropertiesFromParent(
                self.effectiveMavenCoordinates.version)
        return self.effectiveMavenCoordinates

    def _findProperties(self):
        match = "./x:properties"
        found = self.root.find(match, self.namespaces)
        rv = dict()
        if found is not None:
            for element in found:
                key = element.tag.replace("{http://maven.apache.org/POM/4.0.0}", "")
                value = MavenProperty(self, key, element.text)
                rv[key] = value
        return rv

    def findPropertiesFromParent(self, property):
        version = property
        parentpom = self.pomdict.get(str(self.parentMavenCoordinates))
        if parentpom is not None:
            key = str(property).replace("${", "").replace("}", "")
            value = parentpom.properties.get(key)
            if value is None:
                value = parentpom.findPropertiesFromParent(property)
            if value is not None:
                version = value
        return version
