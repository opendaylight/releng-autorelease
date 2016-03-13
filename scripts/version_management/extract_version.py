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
from pom import POM,POMSystem

poms = POMSystem(sys.argv[1:])

for key in poms.groupIdartifactId2poms:
    print "key: %s version: %s filename: %s" % (key,str(poms.groupIdartifactId2poms[key].effectiveMavenCoordinates.version),poms.groupIdartifactId2poms[key].filename)
