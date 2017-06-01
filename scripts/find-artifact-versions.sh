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

print_gav() {
    # Prints the Group, Artifact ID, and Version (GAV) of a Maven artifact to a file versions.csv
    #
    # For group_id and version this script will fallback and use the declared
    # parent pom's group_id and version if it is not provided in the pom.xml
    #
    # Usage: print_gav POM_XML
    #
    #     POM_XML : The path to a pom.xml file to parse for GAV information.

    file=$1

    artifact_id=$(xmlstarlet sel -N x=http://maven.apache.org/POM/4.0.0 \
      -t -m '/x:project' \
      -v "/x:project/x:artifactId" \
      $file)

    group_id=$(xmlstarlet sel -N x=http://maven.apache.org/POM/4.0.0 \
        -t -m '/x:project' \
        --if "/x:project/x:groupId" \
        -v "/x:project/x:groupId" \
        --elif "/x:project/x:parent/x:groupId" \
        -v "/x:project/x:parent/x:groupId" \
        --else -o "" \
        $file)

    version=$(xmlstarlet sel -N x=http://maven.apache.org/POM/4.0.0 \
        -t -m '/x:project' \
        --if "/x:project/x:version" \
        -v "/x:project/x:version" \
        --elif "/x:project/x:parent/x:version" \
        -v "/x:project/x:parent/x:version" \
        --else -o "" \
        $file)

    echo "$group_id,$artifact_id,$version" | tee -a versions.csv
}

# Finds all pom.xml files in a directory and then spawns a bash shell to run
# the print_gav function to parse GAV information from pom file.
export -f print_gav
find . -name pom.xml -exec bash -c 'print_gav "$0"' {} \;
