#!/bin/bash
##############################################################################
# Copyright (c) 2015, 2016 The Linux Foundation.  All rights reserved.
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License v1.0 which accompanies this distribution,
# and is available at http://www.eclipse.org/legal/epl-v10.html
##############################################################################

# MAP of path to a parent pom from the perspective of hosting directory
# starting from the autorelease repo root.
#
# Format:  <groupId>:<artifactId>:<path>

fix_relative_paths() {
    PARENT_MAP=(
        # Odlparent
        "org.opendaylight.odlparent:odlparent:odlparent/odlparent"
        "org.opendaylight.odlparent:odlparent-lite:odlparent/odlparent-lite"
        "org.opendaylight.odlparent:features-parent:odlparent/features-parent"
        "org.opendaylight.odlparent:single-feature-parent:odlparent/single-feature-parent"
        "org.opendaylight.odlparent:feature-repo-parent:odlparent/feature-repo-parent"
        "org.opendaylight.odlparent:bundle-parent:odlparent/bundle-parent"
        "org.opendaylight.odlparent:karaf-parent:odlparent/karaf/karaf-parent"
        "org.opendaylight.odlparent:opendaylight-karaf-empty:odlparent/karaf/opendaylight-karaf-empty"
        "org.opendaylight.odlparent:karaf4-parent:odlparent/karaf/karaf4-parent"
        "org.opendaylight.odlparent:opendaylight-karaf4-empty:odlparent/karaf/opendaylight-karaf4-empty"
        # Yangtools
        "org.opendaylight.yangtools:binding-parent:yangtools/code-generator/binding-parent"
        # Controller
        "org.opendaylight.controller:releasepom:controller"
        "org.opendaylight.controller:commons.opendaylight:controller/opendaylight/commons/opendaylight"
        "org.opendaylight.controller:commons.integrationtest:controller/opendaylight/adsal/commons/integrationtest"
        "org.opendaylight.controller:sal-parent:controller/opendaylight/md-sal"
        "org.opendaylight.controller:mdsal-it-parent:controller/opendaylight/md-sal/mdsal-it-parent"
        "org.opendaylight.controller:config-parent:controller/opendaylight/config/config-parent"
        "org.opendaylight.controller:config-filtering-parent:controller/opendaylight/config/config-filtering-parent"
        "org.opendaylight.controller:config-feature-parent:controller/features/config-feature-parent"
        "org.opendaylight.controller:config-plugin-parent:controller/opendaylight/config/config-plugin-parent"
        "org.opendaylight.controller:karaf-parent:controller/karaf/karaf-parent"
        # Controller - Workaround since script is not able to detect 'controller' group name for archetypes
        "org.opendaylight.controller.archetypes:archetypes-parent:controller/opendaylight/archetypes"
        # MD-SAL
        "org.opendaylight.mdsal:binding-parent:mdsal/binding/binding-parent"
        # OpenFlowJava
        "org.opendaylight.openflowjava:openflowjava-parent:openflowjava/parent"
    )

    pom=$1
    echo "Scanning $pom"
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

        relativePath="$basePath/$projectPath"  # Calculated relative path to parent pom

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
}

# Find all project poms ignoring the /src/ paths (We don't want to scan code)
find . -name pom.xml -not -path "*/src/*" -print0 | xargs -0 -I^ -P8 bash -c "$(declare -f fix_relative_paths); fix_relative_paths ^"
