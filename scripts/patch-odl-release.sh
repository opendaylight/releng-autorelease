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
STABLE_BRANCH="stable/$( cut -d '-' -f1 <<< ${RELEASE_TAG,,})"

project=${PWD##*/}
scriptdir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Validate that we're patching at the same commit level as when autorelease
# built the release. Basically ensuring that no new patches snuck into the
# project during code freeze.
EXPECTED_HASH=`grep "^${project} " $PATCH_DIR/taglist.log | awk '{ print $2 }'`
if [ "$EXPECTED_HASH" == "" ]; then
    parent_dir="$(dirname "$(pwd)")"
    project="${parent_dir##*/}/$project"
    EXPECTED_HASH=`grep "^${project} " $PATCH_DIR/taglist.log | awk '{ print $2 }'`
fi

git checkout "$EXPECTED_HASH"
CURRENT_HASH=`git rev-parse HEAD`

echo "Current Hash: $CURRENT_HASH"
echo "Expected Hash: $EXPECTED_HASH"
if [ "$CURRENT_HASH" != "$EXPECTED_HASH" ]
then
    echo "ERROR: Current project hash does not match expected hash"
    exit 1
fi


#######################
# Start apply patches #
#######################
git fetch ${PATCH_DIR}/${project/\//-}.bundle
git merge FETCH_HEAD
git tag -asm "OpenDaylight $RELEASE_TAG release" release/${RELEASE_TAG,,}
find . -name pom.xml -print0 | xargs -0 grep SNAPSHOT

git checkout ${STABLE_BRANCH}
# Release and then Bump so that the version.sh script creates the right patches
$scriptdir/version.sh release $RELEASE_TAG
$scriptdir/version.sh bump $RELEASE_TAG
git commit -asm "Bumping versions by 0.0.1 for next dev cycle"
find . -name pom.xml -print0 | xargs -0 grep $RELEASE_TAG

echo "Tagging and version bumping complete"
