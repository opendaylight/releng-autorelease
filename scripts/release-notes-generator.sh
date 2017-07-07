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

# This script generates the release-notes.rst file that can be submitted to the
# OpenDaylight documentation project's docs/getting-started-guide/release_notes.rst
# file to produce release notes for a Service Release.

release="$1"

if [ -z "$1" ]; then
    echo "ERROR: Insufficient parameters."
    echo "Usage: $0 RELEASE"
    echo "    Ex: $0 Carbon-SR1"
fi

release_major="$(echo ${release} | cut -f1 -d-)"  # The Release Code
release_minor="$(echo ${release} | cut -f2 -d-)"  # The Service Release

previous_release_num="$((${release_minor#SR}-1))"
previous_release_major="$release_major"
previous_release_minor="SR$previous_release_num"

# If SR0 then drop the minor number for previous release.
if [ "$previous_release_num" == "0" ]; then
    previous_release="$release_major"
else
    previous_release="$release_major-$release_minor"
fi

####################
### START SCRIPT ###
####################

outfile="$(pwd)/release-notes.rst"
projects=($(xmlstarlet sel -N x=http://maven.apache.org/POM/4.0.0 -t -m '//x:modules' -v '//x:module' pom.xml))
echo ${projects[@]}

{
    echo "$release_current Release Notes"
    echo "------------------------"
    echo
    if [ "$previous_release_num" == "0" ]; then
        release_msg="$previous_release_major Release"
    else
        release_msg="$previous_release_major Stability Release ${previous_release_minor#SR} ($previous_release)"
    fi
    echo "This page details changes and bug fixes between the $release_msg"
    echo "and the $release_major Stability Release ${release_minor#SR} ($release) of OpenDaylight."
    echo
} 2>&1 > "$outfile"

{
    echo "Projects with No Noteworthy Changes"
    echo "-----------------------------------"
    echo
} 2>&1 >> "$outfile"

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
        size="${#project}"
        echo "$project"
        for i in $(seq 1 $size); do echo -n "-"; done
        echo

        commits="$(git --no-pager log --no-merges --pretty=format:"%h%x09%s" --perl-regexp --author='^((?!jenkins-releng).*)$' release/${previous_release,,}..release/${release,,})"
        SAVEIFS=$IFS
        IFS=$'\n'
        commits=($commits)
        IFS=$SAVEIFS

        for commit in "${commits[@]}"; do
            commit_hash="$(echo $commit | awk '{print $1}')"
            subject="$(echo $commit | cut -d' ' -f2-)"
            bug_id="$(git --no-pager show --quiet $commit_hash | sed '/^.*[Bb][Uu][Gg][ -]\([0-9]\+\).*$/!d;s//\1/')"
            echo "* \`$commit_hash <https://git.opendaylight.org/gerrit/#/q/$commit_hash>\`_"

            if [ -n "$bug_id" ]; then
                echo "  \`BUG-$bug_id <https://bugs.opendaylight.org/show_bug.cgi?id=$bug_id>\`_"
            fi
            echo "  : $subject"
        done
        echo
    } 2>&1 >> "$outfile"
    popd
done
