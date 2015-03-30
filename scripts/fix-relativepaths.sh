#!/bin/bash

PARENT_MAP=("org.opendaylight.odlparent:odlparent:odlparent/pom.xml")

for pom in `find . -name pom.xml`; do
    echo -e "\nScanning $pom"

    for parent in "${PARENT_MAP[@]}"; do
        map=${parent#*:}

        groupId=${parent%%:*}
        artifactId=${map%%:*}
        path=${map#*:}

        xmlstarlet sel -N x=http://maven.apache.org/POM/4.0.0 -t -m '//x:parent' --if "x:artifactId=\"$artifactId\"" --if "x:groupId=\"$groupId\"" -o "Found $artifactId" "$pom"
        if [ 0 -eq $? ]; then
            sed -i -e "s#<relativePath/>#<relativePath>$path</relativePath>#" \
                   -e "s#<relativePath>.*</relativePath>#<relativePath>$path</relativePath>#" \
                   "$pom"
        fi
    done
done

