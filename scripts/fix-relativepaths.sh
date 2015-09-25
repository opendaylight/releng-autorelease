#!/bin/bash
##############################################################################
# Copyright (c) 2015 The Linux Foundation.  All rights reserved.
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License v1.0 which accompanies this distribution,
# and is available at http://www.eclipse.org/legal/epl-v10.html
##############################################################################

# MAP of path to a parent pom from the perspective of hosting directory
# starting from the repo root.
#
# Format:  <groupId>:<artifactId>:<path>
PARENT_MAP=("org.opendaylight.odlparent:odlparent:odlparent"
            "org.opendaylight.odlparent:features-parent:features-parent"
            "org.opendaylight.odlparent:bundle-parent:bundle-parent"
            # Yangtools
            "org.opendaylight.yangtools:binding-parent:code-generator/binding-parent"
            # Controller
            "org.opendaylight.controller:releasepom:"
            "org.opendaylight.controller:commons.opendaylight:opendaylight/commons/opendaylight"
            "org.opendaylight.controller:commons.integrationtest:opendaylight/adsal/commons/integrationtest"
            "org.opendaylight.controller:sal-parent:opendaylight/md-sal"
            "org.opendaylight.controller:mdsal-it-parent:opendaylight/md-sal/mdsal-it-parent"
            "org.opendaylight.controller:config-parent:opendaylight/config/config-parent"
            "org.opendaylight.controller:config-plugin-parent:opendaylight/config/config-plugin-parent"
            "org.opendaylight.controller:karaf-parent:karaf/karaf-parent"
            "org.opendaylight.controller.archetypes:archetypes-parent:opendaylight/archetypes"
            # MD-SAL
            "org.opendaylight.mdsal:binding-parent:binding/binding-parent")

# Find all project poms ignoring the /src/ paths (We don't want to scan code)
for pom in `find . -name pom.xml -not -path "*/src/*"`; do
    echo -e "\nScanning $pom"
    pomPath=`dirname $pom`
    count=`echo $pomPath | awk -F'/' '{ print NF-1 }'`

    # Calculate the path to autorelease root directory
    basePath=""
    i=0
    while [[ $i -le $count-1 ]]; do
        basePath="../$basePath"
        ((i = i + 1))
    done

    # Find and replace parent poms
    for parent in "${PARENT_MAP[@]}"; do
        map=${parent#*:}       #

        groupId=${parent%%:*}  # Maven groupId
        artifactId=${map%%:*}  # Maven artifactId
        projectPath=${map#*:}  # Path to pom file from the perspective of hosting repo

        projectShortName=${groupId##*.}  # Short name of a ODL project (repo name)
        relativePath="$basePath$projectShortName/$projectPath"  # Calculated relative path to parent pom

        # Update any existing relativePath values
        xmlstarlet ed -P -N x=http://maven.apache.org/POM/4.0.0 \
            -u "//x:parent[x:artifactId=\"$artifactId\" and x:groupId=\"$groupId\"]/x:relativePath" \
            -v "$relativePath" "$pom" > "${pom}.new" && \
        mv "${pom}.new" "${pom}"

        # Add missing ones
        xmlstarlet ed -P -N x=http://maven.apache.org/POM/4.0.0 \
            -s "//x:parent[x:artifactId=\"$artifactId\" and x:groupId=\"$groupId\" and count(x:relativePath)=0]" \
            -t elem -n relativePath -v "$relativePath" "$pom" > "${pom}.new" && \
        mv "${pom}.new" "${pom}"
    done
done

