#!/bin/sh

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
#   1.) take all x.y.z-Helium versions to x.y.(z+1)-SNAPSHOT and
#   2.) take all x.y.z-SNAPSHOT versions to x.(y+1).0-SNAPSHOT

RELEASE_TAG="Helium-SR1"
FILENAMES="pom.xml features.xml"

for name in $FILENAMES
do
	# Do the -SNAPSHOT conversion first so that we don't double bump versions
	# Changes x.y.z-SNAPSHOT to x.(y+1).0-SNAPSHOT in pom.xml files (if z is missing treat as 0)
	find . -type f -name "$name" -exec perl -i -pe "s/([^\d.]\d+)\.(\d+)\.(\d+)-SNAPSHOT/\$1.@{[1+\$2]}.0-SNAPSHOT/g" {} +
	find . -type f -name "$name" -exec perl -i -pe "s/([^\d.]\d+)\.(\d+)-SNAPSHOT/\$1.@{[1+\$2]}.0-SNAPSHOT/g" {} +

	# Changes YYYY.MM.DD.y.z-Helium to YYYY.MM.DD.7-SNAPSHOT in pom.xml files
	find . -type f -name "$name" -exec perl -i -pe "s/(\d\d\d\d\.\d\d\.\d\d)\.(\d+)\.(\d+)-SNAPSHOT/\$1.7-SNAPSHOT/g" {} +
	find . -type f -name "$name" -exec perl -i -pe "s/(\d\d\d\d\.\d\d\.\d\d)\.(\d+)-SNAPSHOT/\$1.7-SNAPSHOT/g" {} +

	# Changes x.y.z-Helium to x.y.(z+1)-SNAPSHOT in pom.xml files (if z is missing treat as 0)
	find . -type f -name "$name" -exec perl -i -pe "s/([^\d.]\d+)\.(\d+)\.(\d+)-$RELEASE_TAG/\$1.\$2.@{[1+\$3]}-SNAPSHOT/g" {} +
	find . -type f -name "$name" -exec perl -i -pe "s/([^\d.]\d+)\.(\d+)-$RELEASE_TAG/\$1.\$2.1-SNAPSHOT/g" {} +

	# Changes YYYY.MM.DD.y.z-Helium to YYMMDD.y.(z+1)-SNAPSHOT in pom.xml files (if z is missing treat as 0)
	find . -type f -name "$name" -exec perl -i -pe "s/(\d\d\d\d\.\d\d\.\d\d)\.(\d+)\.(\d+)-$RELEASE_TAG/\$1.\$2.@{[1+\$3]}-SNAPSHOT/g" {} +
	find . -type f -name "$name" -exec perl -i -pe "s/(\d\d\d\d\.\d\d\.\d\d)\.(\d+)-$RELEASE_TAG/\$1.\$2.1-SNAPSHOT/g" {} +
done
