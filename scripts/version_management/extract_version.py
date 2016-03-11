#!/usr/bin/env python
# @License EPL-1.0 <http://spdx.org/licenses/EPL-1.0>
##############################################################################
# Copyright (c) 2016 Cisco Systems, Inc. and others.
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License v1.0 which accompanies this distribution,
# and is available at http://www.eclipse.org/legal/epl-v10.html
##############################################################################

import sys
from pom import POM

pomdict = dict()
unresolvepoms = sys.argv[1:]
parsedpoms = dict()
lastlen = len(unresolvepoms) + 1

while len(unresolvepoms) > 0:
    if not (lastlen > len(unresolvepoms)):
        break
    lastlen = len(unresolvepoms)
    for filename in unresolvepoms:
        pom = parsedpoms.get(filename)
        if pom is None:
            pom = POM(filename, pomdict)
            parsedpoms[filename] = pom
        else:
            pom.calculateEffectiveMavenCoordinates()
        if not ("${" in str(pom.effectiveMavenCoordinates.version)):
            pomdict[str(pom)] = pom
            unresolvepoms.remove(filename)

if len(unresolvepoms) > 0:
    for item in unresolvepoms:
        pom = parsedpoms[item]
        version = pom.effectiveMavenCoordinates.version
        parent = pom.parentMavenCoordinates
        print("Could not resolve pom: %s looking for %s in parent %s" % (item, version, parent))

    raise Exception("Failure to resolve properties in all pom files")

for key in pomdict:
    print(key)
