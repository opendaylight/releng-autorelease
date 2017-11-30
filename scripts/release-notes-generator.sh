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

process_commits() {
    # process commit and outputs commit summary, JIRA task, bug-Id
    #
    #
    # This function processes induvidual commits and outputs the string to be
    # updated in release notes. The function is designed to be invoked using GNU
    # parallel or sequentially in a for loop. The commit message is parsed for a
    # presence of a bugzilla Bug-ID and/or JIRA issue-id and processed with one
    # of the two steps below.
    # 1. If Jira issue-id is found on the commit message, use it.
    # 2. If only a Bugzilla Bug-ID is available on the commit message, then
    #    retrive the JIRA issue-id using Bug-ID, using REST API.

    local commit_hash="$1"
    local project="$2"

    local bug_id
    local commit_hash_short
    local issue_id
    local subject
    local status

    local prev_project
    local tmpfile
    local jira_query

    pushd "$project" > /dev/null
    {
        commit_hash_short="$(git log --format=%h%x09%s -n 1 ${commit_hash} | awk '{print $1}')"
        subject="$(git log --format=%h%x09%s -n 1 ${commit_hash} | awk '{$1=""; gsub(/^[[:space:]]+|[[:space:]]+$/,""); print}')"

        bug_id="$(git --no-pager show --quiet $commit_hash | sed '/^.*[Bb][Uu][Gg][ -]\([0-9]\+\).*$/!d;s//\1/' | head -1)"
        issue_id="$(git --no-pager show --quiet $commit_hash | grep -Po '((?![BUG])[A-Z][A-Z0-9]{1,9}-\d+)' | head -1)"

        # Handle project names with '/' ex: 'honeycomb/vbd'
        [[ -n "$project" ]] && project=${project/\//-}

        # store the previous project processed in file shared between processes
        touch "$static_file"
        if [ -n "$project" ]; then

          exec 5>"/tmp/lock"
          flock -w 1 -e 5
          prev_project=$(cat "$static_file")
          echo -n "$project" > "$static_file"
          flock -u 5
        fi

        project_output=$(mktemp /tmp/${project}-${commit_hash_short}-XXXX.out)
        {
            exec 200>"/tmp/lock1"
            lock_fd=200
            flock -w 3 -x "$lock_fd"

            if [[ "$prev_project" != "$project" ]] && [[ -n "$project" ]]; then
                    echo
                    echo
                    echo "${project}"
                    size="${#project}"
                    for i in $(seq 1 $size); do echo -n "-"; done
                    echo
            fi

            echo "* \`$commit_hash_short <https://git.opendaylight.org/gerrit/#/q/$commit_hash_short>\`_"
            if [ -n "$issue_id" ]; then
                echo "  \`$issue_id <${JIRA_URL}/browse/${issue_id}>\`_"
            elif [ -n "$bug_id" ] && [[ "$bug_id" != *$'\n'* ]] && [ -n "$project" ] && [ -z "$issue_id" ]; then

                tmpfile=$(mktemp /tmp/${project}-${bug_id}-XXXX.json)

                jira_query=${JIRA_URL}/rest/api/2/search\?jql\=project\=${project}%20and%20\\\"External%20issue%20ID\\\"\~${bug_id}
                echo  "${jira_query}" >&2

                resp=$(curl -sS -w %{http_code} \
                            --header "Accept: application/json" \
                            -o "$tmpfile" \
                            ${JIRA_URL}/rest/api/2/search\?jql\=project\=${project}%20and%20\"External%20issue%20ID\"\~${bug_id})

                status=$(echo "$resp" | awk 'END {print $NF}')
                if [ "$status" != "200" ]; then
                    echo "ERROR: Failed to run. Aborting..." >&2
                    exit "$status"
                fi

                issue_id=$(jq -r '.issues[].key' "$tmpfile")
                if [ -n "$issue_id" ]; then
                    echo "  \`$issue_id <${JIRA_URL}/browse/${issue_id}>\`_"
                fi
                rm "$tmpfile"
            fi
            echo "  : $subject"

        } >>"$project_output" >> "$outfile"
        flock -u 200
    }
    rm "$project_output"
    popd > /dev/null
}


release="$1"

if [ -z "$1" ]; then
    echo "ERROR: Insufficient parameters."
    echo "Usage: $0 RELEASE"
    echo "    Ex: $0 Carbon-SR1"
fi

JIRA_URL="https://jira.opendaylight.org"
outfile="$(pwd)/release-notes.rst"

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
echo
echo "Skipping projects with no changes ..."
for project in "${projects[@]}"; do
    pushd "$project" > /dev/null
    commits="$(git --no-pager log --no-merges --pretty=format:"%h%x09%s" --perl-regexp --author='^((?!jenkins-releng).*)$' release/${previous_release,,}..release/${release,,})"
    if [ -z "$commits" ];
    then  # Project has no noteworthy changes so record them and pass
        echo "* $project" | tee -a "$outfile"
    else  # Project has noteworthy changes so save it to array to scan later
        noteworthy_projects+=("$project")
    fi
    popd > /dev/null
done

unset commits
unset project
declare -a commits  # list of commits
declare -a projectslist
echo "Projects remaining:"
for project in "${noteworthy_projects[@]}"; do
    # echo | tee -a "$outfile"
    pushd "$project" > /dev/null
    {

        project_commits=($(git --no-pager log --no-merges \
                               --pretty=format:"%H" --perl-regexp \
                               --author='^((?!jenkins-releng).*)$' \
                               release/${previous_release,,}..release/${release,,}))

        commits+=(${project_commits[@]})
        length=${#project_commits[@]}
        for ((i=0; i<$length; i++)); do
            projectslist+=($project)
        done
    }
    popd > /dev/null
done

static_file="/tmp/project.prev"
[[ ! -f "$static_file" ]] && touch "$static_file"
[[ -f "$static_file" ]] && >"$static_file"

if hash parallel 2>/dev/null; then
    export JIRA_URL
    export outfile
    export static_file
    export -f process_commits
    parallel -k --xapply --halt now,fail=1 \
             --no-notice --jobs 4 \
             --joblog /tmp/parallel-log.txt \
             "process_commits {} {}" ::: ${commits[@]} ::: ${projectslist[@]}
else
    for index in ${!projectslist[@]}; do
        process_commits ${commits[$index]} ${projectslist[$index]}
    done
fi
echo
