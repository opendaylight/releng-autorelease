#!/bin/bash

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
            "org.opendaylight.controller:config-parent:opendaylight/config/config-parent"
            "org.opendaylight.controller:karaf-parent:karaf/karaf-parent")

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

        xmlstarlet sel -N x=http://maven.apache.org/POM/4.0.0 -t -m '//x:parent' --if "x:artifactId=\"$artifactId\"" --if "x:groupId=\"$groupId\"" -o "Found $artifactId" "$pom"
        if [ 0 -eq $? ]; then
            sed -i -e "s#<relativePath/>#<relativePath>$relativePath</relativePath>#" \
                   -e "s#<relativePath>.*</relativePath>#<relativePath>$relativePath</relativePath>#" \
                   "$pom"
        fi
    done
done

