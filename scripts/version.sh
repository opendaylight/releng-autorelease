#!/bin/bash

# @License EPL-1.0 <http://spdx.org/licenses/EPL-1.0>
##############################################################################
# Copyright (c) 2014 The Linux Foundation and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#   Colin Dixon - Initial implementation
##############################################################################

# In general, versions should be: <major>.<minor>.<micro>[-<human-readable-tag>]
# * Human readable tag should not have any dots in it
# * SNAPSHOT is used for development
#
# Master before release:        x.y.z-SNAPSHOT (or x.y-SNAPSHOT in which case we treat it as x.y.0-SNAPSHOT)
# at release:                   x.y.z-Helium
# stable/helium after release:  x.y.(z+1)-SNAPSHOT
# master after release:         x.(y+1).0-SNAPSHOT
# Autorelease on master:        <human-readable-tag> is "PreLithium-<date>"
# Autorelease on stable/helium: <human-readable-tag> is "PreHeliumSR1-<date>"
# Release job on master:        <human-readable-tag> is "Lithium"
# Release job on stable/helium: <human-readable-tag> is "HeliumSR1"
#
# Some things have a date for a version, e.g., 2014.09.24.4
# * We treat this as YYYY.MM.DD.<minor>
# * Note that all such dates currently in ODL are in YANG tools
# * They are all now YYYY.MM.DD.7 since 7 is the minor version for yangtools


# The goal of this script is to:
#   1.) take all x.y.z-SNAPSHOT to x.y.z-Helium
#   2.) take all x.y.z-Helium versions to x.y.(z+1)-SNAPSHOT and
#   3.) take all x.y.z-SNAPSHOT versions to x.(y+1).0-SNAPSHOT

USAGE="USAGE: versions <mode> <release-tag>\n\
\n\
mode - bump|release\n\
tag  - example: Helium-SR1"

if [ -z "$2" ]
then
    echo -e "$USAGE"
    exit 1
fi

MODE=$1
RELEASE_TAG=$2
FILENAMES="pom.xml features.xml"


if [ "$MODE" == "bump" ]
then
    echo "Bumping versions..."
    for name in $FILENAMES
    do
        # Notes:
        #   * bump date-based versions first to avoid date-only versions from being caught as x.y.z,
        #   * this assumes that a normal x.y.z version can't match YYYY.MM.DD, which is probably true
        #   * bump -SNAPSHOT versions first so that we don't double bump versions

        # Changes YYYY.MM.DD.y.z-SNAPSHOT to YYYY.MM.DD.(y+1).0-SNAPSHOT in pom.xml files (if y or z is missing treat as 0)
        find . -type f -name "$name" -exec perl -i -pe "s/(\d\d\d\d\.\d\d\.\d\d)\.(\d+)\.(\d+)-SNAPSHOT/\$1.@{[1+\$2]}.0-SNAPSHOT/g" {} +
        find . -type f -name "$name" -exec perl -i -pe "s/(\d\d\d\d\.\d\d\.\d\d)\.(\d+)-SNAPSHOT/\$1.@{[1+\$2]}.0-SNAPSHOT/g" {} +
        find . -type f -name "$name" -exec perl -i -pe "s/(\d\d\d\d\.\d\d\.\d\d)-SNAPSHOT/\$1.1.0-SNAPSHOT/g" {} +

        # Changes YYYY.MM.DD.y.z-Helium to YYMMDD.y.(z+1)-SNAPSHOT in pom.xml files (if y or z is missing treat as 0)
        find . -type f -name "$name" -exec perl -i -pe "s/(\d\d\d\d\.\d\d\.\d\d)\.(\d+)\.(\d+)-$RELEASE_TAG/\$1.\$2.@{[1+\$3]}-SNAPSHOT/g" {} +
        find . -type f -name "$name" -exec perl -i -pe "s/(\d\d\d\d\.\d\d\.\d\d)\.(\d+)-$RELEASE_TAG/\$1.\$2.1-SNAPSHOT/g" {} +
        find . -type f -name "$name" -exec perl -i -pe "s/(\d\d\d\d\.\d\d\.\d\d)-$RELEASE_TAG/\$1.0.1-SNAPSHOT/g" {} +

        # Changes x.y.z-SNAPSHOT to x.(y+1).0-SNAPSHOT in pom.xml files (if z is missing treat as 0)
        find . -type f -name "$name" -exec perl -i -pe "s/([^\d.]\d+)\.(\d+)\.(\d+)-SNAPSHOT/\$1.@{[1+\$2]}.0-SNAPSHOT/g" {} +
        find . -type f -name "$name" -exec perl -i -pe "s/([^\d.]\d+)\.(\d+)-SNAPSHOT/\$1.@{[1+\$2]}.0-SNAPSHOT/g" {} +

        # Changes x.y.z-Helium to x.y.(z+1)-SNAPSHOT in pom.xml files (if z is missing treat as 0)
        find . -type f -name "$name" -exec perl -i -pe "s/([^\d.]\d+)\.(\d+)\.(\d+)-$RELEASE_TAG/\$1.\$2.@{[1+\$3]}-SNAPSHOT/g" {} +
        find . -type f -name "$name" -exec perl -i -pe "s/([^\d.]\d+)\.(\d+)-$RELEASE_TAG/\$1.\$2.1-SNAPSHOT/g" {} +

    done
elif [ "$MODE" == "release" ]
then
    for name in $FILENAMES
    do
        find . -type f -name "$name" -exec perl -i -pe "s/SNAPSHOT/$RELEASE_TAG/g" {} +
    done
else
    echo -e "$USAGE"
    exit 1
fi
