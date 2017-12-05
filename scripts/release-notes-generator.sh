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

JIRA_URL="https://jira.opendaylight.org"
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

########################
### HELPER FUNCTIONS ###
########################

array_contains() {
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

get_jira_from_bz() {
    # Get the equivalent Jira ID from a Bugzilla ID
    #
    # Uses a local cache if available to speed up lookups.
    #
    # Params:
    #     jira_url: URL of Jira to query
    #     item: Project and Bugzilla ID in the format PROJ:BUG_ID
    #         (eg. aaa:BUG-1234)
    # Return: Jira ID (eg. RELENG-1234)

    local jira_url="$1"
    local item="$2"

    local project=$(echo "$item" | awk -F: '{print $1}')
    local bug_id=$(echo "$item" | awk -F: '{print $2}')

    BZ_CACHE="$HOME/.bz_cache"
    if [ -e "$BZ_CACHE" ]; then
        cache=$(awk -F':' -v pattern="$bug_id" '$0 ~ pattern {print $2}' "$BZ_CACHE" | head -n1)
    fi

    if [ -n "$cache" ]; then
        >&2 echo "$bug_id found in cache."
        issue_id="$cache"
    else
        jira_query=${jira_url}/rest/api/2/search\?jql\=project\=${project}%20and%20\"External%20issue%20ID\"\~${bug_id}
        >&2 echo "Querying ${jira_query}" >&2
        resp=$(curl -s -w "\n\n%{http_code}" --header "Accept: application/json" \
            "$jira_query")

        status=$(echo "$resp" | awk 'END {print $NF}')
        if [ "$status" != "200" ]; then
            echo "ERROR: Failed to query "$jira_query"."
            exit "$status"
        fi

        json_data=$(echo "$resp" | head -n1)
        issue_id=$(echo "$json_data" | jq -r '.issues[].key')

        echo "$bug_id:$issue_id" >> "$BZ_CACHE"
    fi

    echo "$issue_id"
}

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

echo
echo "Preloading Bugzilla to Jira ID mapping..."
bug_list=()
for project in "${noteworthy_projects[@]}"; do
    pushd "$project" > /dev/null

    commits="$(git --no-pager log --no-merges --pretty=format:"%h%x09%s" --perl-regexp --author='^((?!jenkins-releng).*)$' release/${previous_release,,}..release/${release,,})"
    SAVEIFS=$IFS
    IFS=$'\n'
    commits=($commits)
    IFS=$SAVEIFS

    for commit in "${commits[@]}"; do
        commit_hash="$(echo $commit | awk '{print $1}')"
        subject="$(echo $commit | cut -d' ' -f2-)"
        bug_id="$(git --no-pager show --quiet $commit_hash | sed '/^.*[Bb][Uu][Gg][ -]\([0-9]\+\).*$/!d;s//\1/' | head -1)"

        if [ -n "$bug_id" ]; then
            if ! array_contains bug_list "$bug_id"; then
                bug_list+=("$project:$bug_id")
            fi
        fi
    done

    popd > /dev/null
done

if hash parallel 2>/dev/null; then
    export -f get_jira_from_bz
    parallel --jobs 200% --halt now,fail=1 \
        "get_jira_from_bz $JIRA_URL {} > /dev/null" ::: ${bug_list[*]}
else
    for bug_id in "${bug_list[@]}"; do
        get_jira_from_bz "$JIRA_URL" "$bug_id" > /dev/null
    done
fi

echo
echo "Process remaing noteworthy projects:"
for project in "${noteworthy_projects[@]}"; do
    echo | tee -a "$outfile"
    echo "Project: $project"
    pushd "$project" > /dev/null
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
        # 2. If the Bug-ID is only available on the commit message, then retrive
        #    the Jira issue-id using Bug-ID./sc.

        for commit in "${commits[@]}"; do
            commit_hash="$(echo $commit | awk '{print $1}')"
            subject="$(echo $commit | cut -d' ' -f2-)"
            bug_id="$(git --no-pager show --quiet $commit_hash | sed '/^.*[Bb][Uu][Gg][ -]\([0-9]\+\).*$/!d;s//\1/' | head -1)"
            echo "* \`$commit_hash <https://git.opendaylight.org/gerrit/#/q/$commit_hash>\`_"
            issue_id="$(git --no-pager show --quiet $commit_hash | grep -Po '((?![BUG])[A-Z][A-Z0-9]{1,9}-\d+)' | head -1)"

            if [ -n "$issue_id" ]; then
                echo "  \`$issue_id <${JIRA_URL}/browse/${issue_id}>\`_"
            elif [ -n "$bug_id" ] && [ -n "$project" ] && [ -z "$issue_id" ]; then
                [ -n "$project" ] && project=${project/\//-}

                issue_id=$(get_jira_from_bz "$JIRA_URL" "$project:$bug_id")
                if [ -n "$issue_id" ]; then
                    echo "  \`$issue_id <${JIRA_URL}/browse/${issue_id}>\`_"
                fi
            fi
            echo "  : $subject"
        done
        echo
    } >> "$outfile"
    popd > /dev/null
done
