#!/bin/bash
##############################################################################
# Copyright (c) 2015 The Linux Foundation.  All rights reserved.
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

wget -O git-bundle.zip "$GIT_BUNDLE_URL"
unzip -d /tmp git-bundle.zip

git submodule foreach "lftools version patch $RELEASE_TAG $PATCH_DIR"
git submodule foreach "git push gerrit release/${RELEASE_TAG,,}"

# Also tag autorelease
git tag -asm "Commit" "release/${RELEASE_TAG,,}"
git push gerrit "release/${RELEASE_TAG,,}"
