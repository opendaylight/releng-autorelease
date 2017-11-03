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

release_major="$(echo ${release^} | cut -f1 -d-)"  # The Release Code
release_minor="$(echo ${release} | cut -f2 -d-)"  # The Service Release
release_num="${release_minor#SR}"

previous_release_num="$((release_num - 1))"
previous_release_major="$release_major"
previous_release_minor="SR$previous_release_num"

# If SR0 then drop the minor number for previous release.
if [ "$previous_release_num" == "0" ]; then
    previous_release="$release_major"
else
    previous_release="$release_major-$previous_release_minor"
fi

####################
### START SCRIPT ###
####################

outfile="$(pwd)/release-notes.rst"
projects=($(xmlstarlet sel -N x=http://maven.apache.org/POM/4.0.0 -t -m '//x:modules' -v '//x:module' pom.xml))
echo ${projects[@]}

{
    release_txt="${release^} Release Notes"
    echo "$release_txt"
    printf '=%.0s' $(eval "echo {1.."${#release_txt}"}")
    echo -e "\n"
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
    commits="$(git --no-pager log --no-merges --pretty=format:"%h%x09%s" --perl-regexp --author='^((?!jenkins-releng).*)$' release/${previous_release,,}..release/${release,,})"
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

        # Search and update bugzilla Bug-ID and JIRA issue-id from commit messages.
        # 1. If Jira issue-id is available on the commit message, use it.
        # 2. If the Bug-ID is only available on the commit message, retrive the Jira
        #    issue-id using Bug-ID using Jira REST API.

        for commit in "${commits[@]}"; do
            commit_hash="$(echo $commit | awk '{print $1}')"
            subject="$(echo $commit | cut -d' ' -f2-)"
            bug_id="$(git --no-pager show --quiet $commit_hash | sed '/^.*[Bb][Uu][Gg][ -]\([0-9]\+\).*$/!d;s//\1/')"
            echo "* \`$commit_hash <https://git.opendaylight.org/gerrit/#/q/$commit_hash>\`_"
            issue_id="$(git --no-pager show --quiet $commit_hash | sed -n '/\(^.* \)\([A-Z][A-Z0-9]\{1,20\}\)[-: ]\{1,2\}\([0-9]\{1,5\}\)\(.*$\)/!d;s//\2-\3/p')"

            if [ -n "$issue_id" ]; then
                echo "  \`$issue_id <https://jira.opendaylight.org/browse/${issue_id}>\`_"
            elif [ -n "$bug_id" ] && [ -n "$project" ] && [ ! -n "$issue_id" ]; then
                issue_id=$(curl https://jira.opendaylight.org/rest/api/2/search\?jql\=project\=${project}%20and%20\"External%20issue%20ID\"\~${bug_id} | jq -r '.issues[].key')
                if [ -n "$issue_id" ]; then
                    echo "  \`$issue_id <https://jira.opendaylight.org/browse/${issue_id}>\`_"
                fi
            fi
            echo "  : $subject"
        done
        echo
    } 2>&1 >> "$outfile"
    popd
done
