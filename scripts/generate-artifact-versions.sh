#!/bin/bash
##############################################################################
# Copyright (c) 2017 The Linux Foundation.  All rights reserved.
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License v1.0 which accompanies this distribution,
# and is available at http://www.eclipse.org/legal/epl-v10.html
##############################################################################

# This script finds all the artifact versions in a release and produces a file
# called versions.csv in the present working directory.

set -eu -o pipefail

VERSION_FILE="$(pwd)/versions.csv"

if [ -e "$VERSION_FILE" ]; then
    rm "$VERSION_FILE"
fi

print_gav() {
    # Prints the Group, Artifact ID, and Version (GAV) of a Maven artifact to a file versions.csv
    #
    # For group_id and version this script will fallback and use the declared
    # parent pom's group_id and version if it is not provided in the pom.xml
    #
    # Usage: print_gav POM_XML
    #
    #     POM_XML : The path to a pom.xml file to parse for GAV information.

    version_file=$1
    pom_file=$2

    artifact_id=$(xmlstarlet sel -N x=http://maven.apache.org/POM/4.0.0 \
      -t -m '/x:project' \
      -v "/x:project/x:artifactId" \
      $pom_file)

    group_id=$(xmlstarlet sel -N x=http://maven.apache.org/POM/4.0.0 \
        -t -m '/x:project' \
        --if "/x:project/x:groupId" \
        -v "/x:project/x:groupId" \
        --elif "/x:project/x:parent/x:groupId" \
        -v "/x:project/x:parent/x:groupId" \
        --else -o "" \
        $pom_file)

    version=$(xmlstarlet sel -N x=http://maven.apache.org/POM/4.0.0 \
        -t -m '/x:project' \
        --if "/x:project/x:version" \
        -v "/x:project/x:version" \
        --elif "/x:project/x:parent/x:version" \
        -v "/x:project/x:parent/x:version" \
        --else -o "" \
        $pom_file)

    echo "$group_id,$artifact_id,$version" | tee -a "$version_file"
}

# Finds all pom.xml files in a directory and then spawns a bash shell to run
# the print_gav function to parse GAV information from pom file.
poms=($(find . -name pom.xml -not -path "./scripts/*" -not -path "*/src/*"))

if hash parallel 2>/dev/null; then
    export -f print_gav
    parallel --jobs 200% --halt now,fail=1 "print_gav $VERSION_FILE {}" ::: ${poms[*]}
else
    for pom in "${poms[@]}"; do
        print_gav "$VERSION_FILE" "$pom"
    done
fi

sort -o "$VERSION_FILE" "$VERSION_FILE"
