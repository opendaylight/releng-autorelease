#!/bin/bash
##############################################################################
# Copyright (c) 2017 The Linux Foundation.  All rights reserved.
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License v1.0 which accompanies this distribution,
# and is available at http://www.eclipse.org/legal/epl-v10.html
##############################################################################

RELEASE_TAG=$1
PATCH_DIR=$2
GIT_BUNDLE_URL=$3

if [[ -z $3 ]]; then
    echo 'Missing arguments.'
    echo 'Usage: release-tags RELEASE_TAG PATCH_DIR GIT_BUNDLE_URL'
    exit 1
fi

# Ensure we fail the if any steps fail.
set -eu -o pipefail


mkdir -p $PATCH_DIR
pushd $PATCH_DIR
wget -nv -O- "$GIT_BUNDLE_URL" | gunzip | gunzip | tar xv --strip-components=1
popd

# Patch and tag
echo "Tagging release"
git submodule foreach "lftools version patch '$RELEASE_TAG' '$PATCH_DIR'"

# Validate that we're patching at the same commit level as when autorelease
# built the release. Basically ensuring that no new patches snuck into the
# project during code freeze.
EXPECTED_HASH=$(grep "^autorelease " "$PATCH_DIR/taglist.log" | awk '{ print $2 }')
git checkout "$EXPECTED_HASH"
CURRENT_HASH=$(git rev-parse HEAD)

echo "Current Hash: $CURRENT_HASH"
echo "Expected Hash: $EXPECTED_HASH"
if [ "$CURRENT_HASH" != "$EXPECTED_HASH" ]
then
    echo "ERROR: Current autorelease hash does not match expected hash"
    exit 1
fi
git commit -asm "OpenDaylight ${RELEASE_TAG} release"
git tag -asm "OpenDaylight ${RELEASE_TAG} release" "release/${RELEASE_TAG,,}"

# Push tags to Gerrit
echo "Pushing tags to Gerrit"
git submodule foreach "git push gerrit 'release/${RELEASE_TAG,,}'"
git push gerrit "release/${RELEASE_TAG,,}"
