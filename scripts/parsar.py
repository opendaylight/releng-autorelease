"""This python script is used for parsing the various project directories
for pom.xml files and creating a database of module dependencies.
Location of the directory is taken as input.

@Author : Abhishek Mittal aka Darkdragon
@Email  : abhishekmittaliiit@gmail.com
"""

import sys
import os
import json
import re
import xml.etree.ElementTree as ET
from StringIO import StringIO


def systemCallMvnEffectivePom(directoryLocation):
    """Calls the system function to generate effective-pom files"""
    os.system('/opt/jenkins/tools/hudson.tasks.Maven_MavenInstallation/' +
              'Maven_3.3.3/bin/mvn -gs $GSFILE -f ' + directoryLocation +
              ' help:effective-pom -Doutput=epom.xml')


def removeNameSpace(it):
    """Removes the namespaces from pom file
    Eg. '{http://maven.apache.org/POM/4.0.0}id' is changed to 'id'
    '{http://maven.apache.org/POM/4.0.0}property' is changed to 'property'
    """
    for _, el in it:
        if '}' in el.tag:
            el.tag = el.tag.split('}', 1)[1]  # strip all namespaces
    return it


def removeSetHash(content):
    """Removes #set tags (if any) from pom file"""
    index = 0
    while content[index] != '<':
        index = index + 1
    return content[index:]


def initXML(dirName, fileName):
    """Init XML file for parsing, returns the head tag of the XML file"""
    xml = ''
    with open(os.path.join(dirName, fileName), "r") as xmlFile:
        xml = xmlFile.read().replace('\n', '')
    xml = removeSetHash(xml)
    it = ET.iterparse(StringIO(xml))
    it = removeNameSpace(it)
    return it.root


def getUniqueId(dirName, filename):
    """Returns the dictionary {groupId : ,artifactId : ,version :}"""
    root = initXML(dirName, filename)
    groupId = ''
    artifactId = ''
    version = ''
    # makes project as the root tag
    if not root.tag == "project":
        root = root.find('project')

    if root is None:
        return {}

    for child in root:
        if child.tag == 'groupId':
            groupId = child.text
        if child.tag == 'artifactId':
            artifactId = child.text
        if child.tag == 'version':
            version = child.text

    temp = {}
    temp['groupId'] = groupId
    temp['artifactId'] = artifactId
    temp['version'] = version
    return temp


def getModuleNames(dirName, filename):
    """Returns the names of the major modules in the pom file found under the
    first <modules> tag of pom file """
    root = initXML(dirName, filename)

    modules = []

    # makes modules as the root tag
    if not root.tag == "modules":
        root = root.find('modules')

    if root is None:
        return modules

    for child in root:
        if child.tag == "module":
            modules.append(child.text)

    return modules


def getDependencyNames(dirName, filename):
    """Returns the names of the major modules dependency in the pom file under
    the first <dependencies> tag of pom file"""
    root = initXML(dirName, filename)
    dependency = []
    dependencyTag = None
    if root.tag == "dependencies":
        dependencyTag = root
    else:
        dependencyTag = root.find('dependencies')

    if dependencyTag is not None:
        for child in dependencyTag:
            if child.tag == "dependency":
                dependencyInfo = {}
                dependencyInfo["groupId"] = ""
                dependencyInfo["artifactId"] = ""
                dependencyInfo["version"] = ""
                dependencyInfo["scope"] = ""
                for subchild in child:
                    if subchild.tag == "groupId":
                        dependencyInfo["groupId"] = subchild.text
                    if subchild.tag == "artifactId":
                        dependencyInfo["artifactId"] = subchild.text
                    if subchild.tag == "version":
                        dependencyInfo["version"] = subchild.text
                    if subchild.tag == "scope":
                        dependencyInfo["scope"] = subchild.text

                dependency.append(dependencyInfo)

    # find dependencies from the pluginmanagement tag
    buildTag = None
    if root.tag == "build":
        buildTag = root
    else:
        buildTag = root.find('build')

    if buildTag is None:
        return dependency

    for dependenciesTags in buildTag.findall('.//pluginmanagement/plugins/plugin/dependencies'):
        for child in dependenciesTags:
            if child.tag == "dependency":
                dependencyInfo = {}
                dependencyInfo["groupId"] = ""
                dependencyInfo["artifactId"] = ""
                dependencyInfo["version"] = ""
                dependencyInfo["scope"] = ""
                for subchild in child:
                    if subchild.tag == "groupId":
                        dependencyInfo["groupId"] = subchild.text
                    if subchild.tag == "artifactId":
                        dependencyInfo["artifactId"] = subchild.text
                    if subchild.tag == "version":
                        dependencyInfo["version"] = subchild.text
                    if subchild.tag == "scope":
                        dependencyInfo["scope"] = subchild.text
                dependency.append(dependencyInfo)

    return dependency


def getParentNames(dirName, filename):
    """Returns the names of the major modules/projects parents in the pom file
    under the first <parent> tag of the pom file"""
    root = initXML(dirName, filename)
    parent = []
    # makes modules as the root tag
    if not root.tag == "parent":
        root = root.find('parent')

    if root is None:
        return parent

    parentInfo = {}

    for child in root:
        if child.tag == 'groupId':
            parentInfo["groupId"] = child.text
        if child.tag == 'artifactId':
            parentInfo["artifactId"] = child.text
        if child.tag == 'version':
            parentInfo["version"] = child.text
    parent.append(parentInfo)

    return parent


def getPomName(dirName, filename):
    """Returns the names of the major modules/projects parents in the pom
    file"""
    root = initXML(dirName, filename)
    if not root.tag == "name":
        root = root.find('name')
    if root is None:
        return ""
    else:
        return root.text


def recursePom(directoryName):
    """Recurse over all pom files of the module in the autorelease"""
    recursePomInfo = []
    for dirName, subdirList, fileList in os.walk(directoryName):
        # skipping all src and target directories
        # if dirName=="src" or dirName=="target" or dirName==directoryName:
        #   continue;
        for fname in fileList:
            if fname == 'pom.xml':
                systemCallMvnEffectivePom(dirName)
                fname = 'epom.xml'
                if not os.path.isfile(os.path.join(dirName, fname)):
                    continue
                pomExtractedInfo = {}
                pomExtractedInfo['path'] = dirName + '/' + fname
                pomExtractedInfo['name'] = getPomName(dirName, fname)
                pomExtractedInfo['id'] = getUniqueId(dirName, fname)
                pomExtractedInfo['modules'] = getModuleNames(dirName, fname)
                pomExtractedInfo['dependencies'] = getDependencyNames(dirName, fname)
                pomExtractedInfo['parent'] = getParentNames(dirName, fname)
                recursePomInfo.append(pomExtractedInfo)
    return recursePomInfo


def getID(node):
    groupId = node['id']['groupId']
    artifactId = node['id']['artifactId']
    version = node['id']['version']
    return "%s:%s:%s" % (groupId, artifactId, version)


def getDependencyGroupID(node):
    return node['groupId']


def getDependencyVersion(node):
    return node['version']


def checkValidModule(moduleName):
    """Checks whether a module is valid opendaylight module or not"""
    if re.search("^org\.opendaylight", moduleName):
        return True
    else:
        return False


def findProjectOfModule(projectMapping, module):
    """Return the project in which the module is found"""
    module = re.sub('org.opendaylight.', '', module)
    module = re.sub('\..*$', '', module)
    return module


def helperExtendDependencyInformation(projectMappedToAllModules,
                                      anticipatedNodes, anticipatedEdges,
                                      distinctIdLabelFromEdges, dependency,
                                      project):
    if not checkValidModule(getDependencyGroupID(dependency)):
        return

    distinctIdLabelFromEdges.append(project)
    distinctIdLabelFromEdges.append(
        findProjectOfModule(projectMappedToAllModules,
                            getDependencyGroupID(dependency))
    )

    anticipatedEdges.append({
        'from': project,
        'to': findProjectOfModule(projectMappedToAllModules, getDependencyGroupID(dependency)),
        'arrows': 'to'
    })


def extendDependencyInformation(projectMappedToAllModules,
                                anticipatedNodes, anticipatedEdges,
                                distinctIdLabelFromEdges, submodule, project):
    for dependency in submodule['dependencies']:
        helperExtendDependencyInformation(projectMappedToAllModules,
                                          anticipatedNodes, anticipatedEdges,
                                          distinctIdLabelFromEdges,
                                          dependency, project)
    for dependency in submodule['parent']:
        helperExtendDependencyInformation(projectMappedToAllModules,
                                          anticipatedNodes, anticipatedEdges,
                                          distinctIdLabelFromEdges,
                                          dependency, project)


def extendModulesMappedToProjects(dependency, modulesMappedToProjects,
                                  submodule, project):
    moduleName = '(' + dependency['groupId'] + ", " + dependency['artifactId'] + ')'
    pomFile = submodule['path']
    dependencyVersion = getDependencyVersion(dependency)
    dependencyProject = project  # the project that's dependant on the concerned module
    if moduleName in modulesMappedToProjects.keys():
        if dependencyProject in modulesMappedToProjects[moduleName].keys():
            modulesMappedToProjects[moduleName][dependencyProject].append((dependencyVersion, pomFile))
        else:
            modulesMappedToProjects[moduleName][dependencyProject] = []
            modulesMappedToProjects[moduleName][dependencyProject].append((dependencyVersion, pomFile))
    else:
        modulesMappedToProjects[moduleName] = {}
        modulesMappedToProjects[moduleName][dependencyProject] = []
        modulesMappedToProjects[moduleName][dependencyProject].append((dependencyVersion, pomFile))


def main():
    DIR_LOC = sys.argv[1]
    systemCallMvnEffectivePom(DIR_LOC)
    rootPomFile = "epom.xml"
    dependencies = {}
    dependencies['path'] = DIR_LOC + '/' + rootPomFile
    dependencies['id'] = getUniqueId(DIR_LOC, rootPomFile)
    dependencies['name'] = getPomName(DIR_LOC, rootPomFile)
    dependencies['dependencies'] = getDependencyNames(DIR_LOC, rootPomFile)
    dependencies['parent'] = getParentNames(DIR_LOC, rootPomFile)
    dependencies['modules'] = getModuleNames(DIR_LOC, rootPomFile)
    dependencies['moduleInfo'] = {}
    actualModules = []

    for module in dependencies['modules']:
        moduleDir = DIR_LOC+'/'+module
        rootPomFile = "pom.xml"
        if not os.path.isfile(os.path.join(moduleDir, rootPomFile)):
            continue
        systemCallMvnEffectivePom(moduleDir)
        rootPomFile = "epom.xml"
        if not os.path.isfile(os.path.join(moduleDir, rootPomFile)):
            continue
        actualModules.append(module)
        dependencies['moduleInfo'][module] = {}
        dependencies['moduleInfo'][module]['id'] = getUniqueId(moduleDir, rootPomFile)
        dependencies['moduleInfo'][module]['name'] = getPomName(moduleDir, rootPomFile)
        dependencies['moduleInfo'][module]['modules'] = getModuleNames(moduleDir, rootPomFile)
        dependencies['moduleInfo'][module]['dependencies'] = getDependencyNames(moduleDir, rootPomFile)
        dependencies['moduleInfo'][module]['parent'] = getParentNames(moduleDir, rootPomFile)
        dependencies['moduleInfo'][module]["recursePomInfo"] = recursePom(moduleDir)

    dependencies['modules'] = actualModules
    projectMappedToAllModules = {}
    for project in actualModules:
        allModules = []
        allModules.extend(dependencies['moduleInfo'][project]['modules'])
        for data in dependencies['moduleInfo'][project]['recursePomInfo']:
            allModules.extend(data['modules'])
            allModules.append(getID(data))
        projectMappedToAllModules[project] = allModules

    distinctIdLabel = []
    distinctIdLabel.append(getID(dependencies))

    for module in dependencies['modules']:
        distinctIdLabel.append(getID(dependencies['moduleInfo'][module]))

        for submodule in dependencies['moduleInfo'][module]['recursePomInfo']:
            distinctIdLabel.append(getID(submodule))

    distinctIdLabel = set(distinctIdLabel)
    anticipatedEdges = []
    anticipatedNodes = []
    distinctIdLabelFromEdges = []
    extendDependencyInformation(projectMappedToAllModules, anticipatedNodes,
                                anticipatedEdges, distinctIdLabelFromEdges,
                                dependencies, dependencies['name'])

    for project in dependencies['modules']:
        for submodule in dependencies['moduleInfo'][project]['recursePomInfo']:
            extendDependencyInformation(projectMappedToAllModules,
                                        anticipatedNodes, anticipatedEdges,
                                        distinctIdLabelFromEdges, submodule,
                                        project)

    distinctIdLabelFromEdges = set(distinctIdLabelFromEdges)

    for idLabel in distinctIdLabelFromEdges:
        anticipatedNodes.append({
            'id': idLabel,
            'label': idLabel
        })

    # set of unique edges
    anticipatedEdges = [dict(t) for t in set([tuple(d.items()) for d in anticipatedEdges])]
    modulesMappedToProjects = {}

    for dependency in dependencies['dependencies']:
        extendModulesMappedToProjects(dependency, modulesMappedToProjects,
                                      dependencies, dependencies['name'])

    for project in dependencies['modules']:
        for submodule in dependencies['moduleInfo'][project]['recursePomInfo']:
            for dependency in submodule['dependencies']:
                extendModulesMappedToProjects(dependency,
                                              modulesMappedToProjects,
                                              submodule, project)
            for dependency in submodule['parent']:
                extendModulesMappedToProjects(dependency,
                                              modulesMappedToProjects,
                                              submodule, project)

    stringEdges = 'var edges=' + json.dumps(anticipatedEdges) + '\n'
    stringNodes = 'var nodes=' + json.dumps(anticipatedNodes) + '\n'
    stringModulesMappedToProjects = ('var modulesMappedToProjects=' +
                                     json.dumps(modulesMappedToProjects) +
                                     '\n')
    f = open("dependencyInfo.json", "w")
    f.write(stringNodes)
    f.write(stringEdges)
    f.write(stringModulesMappedToProjects)


if __name__ == "__main__":
    main()
