#!/bin/bash
# SPDX-License-Identifier: EPL-1.0
##############################################################################
# Copyright (c) 2017 The Linux Foundation and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
##############################################################################

outfile="$(pwd)/release-notes.rst"
projects=($(xmlstarlet sel -N x=http://maven.apache.org/POM/4.0.0 -t -m '//x:modules' -v '//x:module' pom.xml))
echo ${projects[@]}

{
    echo "Carbon-SR1 Release Notes"
    echo "------------------------"
    echo
    echo "This page details changes and bug fixes between the Boron Stability Release 3 (Boron-SR3)"
    echo "and the Boron Stability Release 4 (Boron-SR4) of OpenDaylight."
    echo
} 2>&1 | tee "$outfile"

{
    echo "Projects with No Noteworthy Changes"
    echo "-----------------------------------"
    echo
} 2>&1 | tee -a "$outfile"

noteworthy_projects=()
for project in "${projects[@]}"; do
    pushd "$project"
    commits="$(git --no-pager log --no-merges --pretty=format:"%h%x09%s" --perl-regexp --author='^((?!jenkins-releng).*)$' release/carbon..origin/stable/carbon)"
    if [ -z "$commits" ];
    then  # Project has no noteworthy changes so record them and pass
        echo "* $project" | tee -a "$outfile"
    else  # Project has noteworthy changes so save it to array to scan later
        noteworthy_projects+=("$project")
    fi
    popd
done

echo "Projects remaining:"
for project in "${noteworthy_projects[@]}"; do
    echo | tee -a "$outfile"
    pushd "$project"
    {
        echo "$project"
        echo "---"
        git --no-pager log --no-merges --pretty=format:"%h%x09%s" --perl-regexp --author='^((?!jenkins-releng).*)$' release/carbon..origin/stable/carbon
        echo
    } 2>&1 | tee -a "$outfile"
    popd
done
