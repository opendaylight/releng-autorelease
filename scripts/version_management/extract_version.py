#!/usr/bin/env python

import sys
from pom import POM

pomdict = dict()
unresolvepoms = sys.argv[1:]
parsedpoms = dict()
lastlen = len(unresolvepoms) + 1
while(len(unresolvepoms) > 0):
    if(not (lastlen > len(unresolvepoms))):
        break
    lastlen = len(unresolvepoms)
    for filename in unresolvepoms:
        pom = parsedpoms.get(filename)
        if(pom == None):
            pom = POM(filename,pomdict)
            parsedpoms[filename] = pom
        else:
            pom.calculateEffectiveMavenCoordinates()
        if(not ("${" in str(pom.effectiveMavenCoordinates.version))):
            pomdict[str(pom)] = pom
            unresolvepoms.remove(filename)

if(len(unresolvepoms) > 0):
    for item in unresolvepoms:
        pom = parsedpoms[item]
        version = pom.effectiveMavenCoordinates.version
        parent = pom.parentMavenCoordinates
        print "Could not resolve pom: %s looking for %s in parent %s" % (item,version,parent)
    raise Exception("Failure to resolve properties in all pom files")

for key in pomdict:
    print key

