#!/bin/bash

# @License EPL-1.0 <http://spdx.org/licenses/EPL-1.0>
##############################################################################
# Copyright (c) 2015 The Linux Foundation and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#   Thanh Ha - Initial implementation
##############################################################################

# The purpose of this patch is to:
#
#   1) Apply autorelease patches for a ODL Release
#   2) Create version bump commit for post-release dev cycle

USAGE="USAGE: patch-odl-release <path-to-patches> <tag>\n\
\n\
path-to-patches - The path to the directory containing ODL Release patches\n\
tag  - example: Lithium-SR1"

if [ -z "$2" ]
then
    echo -e "$USAGE"
    exit 1
fi

PATCH_DIR=$1
RELEASE_TAG=$2

project=${PWD##*/}
scriptdir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

git am ${PATCH_DIR}/${project}.patch
find . -name pom.xml | xargs grep SNAPSHOT
$scriptdir/version.sh bump $RELEASE_TAG
git commit -asm "Bumping versions by 0.0.1 for next dev cycle"
find . -name pom.xml | xargs grep $RELEASE_TAG
