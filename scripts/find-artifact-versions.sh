#!/bin/bash
##############################################################################
# Copyright (c) 2017 The Linux Foundation.  All rights reserved.
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License v1.0 which accompanies this distribution,
# and is available at http://www.eclipse.org/legal/epl-v10.html
##############################################################################

# This script finds all the artifact versions in a release and produces a csv

set -eu -o pipefail

file_list=($(find . -name pom.xml))

for file in "${file_list[@]}"; do
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

    echo "$group_id,$artifact_id,$version" >> project-versions.csv
done
