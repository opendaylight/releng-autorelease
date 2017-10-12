#!/bin/bash
##############################################################################
# Copyright (c) 2015 The Linux Foundation.  All rights reserved.
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License v1.0 which accompanies this distribution,
# and is available at http://www.eclipse.org/legal/epl-v10.html
##############################################################################

# This script searches all projects that autorelease builds and outputs the
# dependencies it detects for each project into a log file.

USAGE="ARGS: [dot]\n\
\n\
dot - produces a dependencies.dot in graphviz dot format instead"

LOG_FILE=dependencies.log

modules=$(xmlstarlet sel -N x=http://maven.apache.org/POM/4.0.0 -t -m '//x:modules' -v '//x:module' pom.xml)

if [[ "$2" != "" || "$1" != "" && "$1" != "dot" ]]; then
    echo -e "$USAGE"
    exit
fi

if [ "$1" == "dot" ]; then
    LOG_FILE=dependencies.dot
    echo "digraph G {" >> $LOG_FILE
fi

rm -f $LOG_FILE

for module in $modules; do
    echo "entering module: $module"
    module_dependencies=""
    # shellcheck disable=SC2044
    for pom in $(find "$module" -name pom.xml ! -path "*/src/*" ! -path "*/target/*"); do
        echo "examining pom: $pom"
        # Find ODL projects that are dependencies of a module and list them in a sorted list.
        dependencies=$(xmlstarlet sel -N x=http://maven.apache.org/POM/4.0.0 \
                                      -t \
                                      -m '//x:project/x:dependencies/x:dependency' \
                                      -n -v "x:groupId" "$pom" | \
                       grep org.opendaylight | \
                       sed -e 's@org.opendaylight.@@' | sort | uniq)
        echo "got dependencies: $dependencies"
        # Include parent poms as dependencies
        dependencies_parentpoms=$(xmlstarlet sel -N x=http://maven.apache.org/POM/4.0.0 \
                                      -t \
                                      -m '//x:project/x:parent' \
                                      -n -v "x:groupId" "$pom" | \
                                  grep org.opendaylight | \
                                  sed -e 's@org.opendaylight.@@' | sort -u)
        echo "got parentpoms: $dependencies_parentpoms"
        module_dependencies=$(echo "$module_dependencies" "$dependencies_parentpoms" "$dependencies" | tr " " "\n" | sort -u)
        echo "current list: $module_dependencies"
    done

    module_dependencies=$(echo "$module_dependencies" | sed 's#\.#/#g')
    echo "slashed list: $module_dependencies"
    for search_module in $module_dependencies; do
        echo "processing module $search_module"
        if [[ $search_module =~ .*/.* ]]; then
            echo "slashed module detected"
            if [[ ! $modules =~ .*$search_module.* ]]; then
                echo "splittable module detected"
                splitted_module=$(echo "$search_module" | sed 's/\/.*//')
                echo "splitted: $splitted_module"
                if [[ $modules =~ .*$splitted_module.* ]]; then
                    module_dependencies=$(echo "$module_dependencies" | tr ' ' '\n' | sed -e "s@$search_module@$splitted_module@" | sort -u)
                    echo "list after replacing with one splitted: $module_dependencies"
                else
                    module_dependencies=$(echo "$module_dependencies" | tr ' ' '\n' | sed -e "s@$search_module.*@@" | sort -u)
                    echo "list after removing module: $module_dependencies"
                fi
            fi
        fi
    done
    module_dependencies=$(echo "$module_dependencies" | tr ' ' '\n' | sed -e "s@$module@@" | sort -u)
    echo "after newlining: $module_dependencies"

    if [ "$1" == "dot" ]; then
        for dependency in $(echo "$module_dependencies" | tr "\n" " "); do
            echo "$module -> $dependency" >> $LOG_FILE
        done
    else
        module_dependencies=$(echo "$module_dependencies" | tr "\n" ",")
        echo "$module:$module_dependencies" >> $LOG_FILE
        sed -i 's/,$//; s/:,/:/' $LOG_FILE
    fi
done

if [ "$1" == "dot" ]; then
    echo "}" >> $LOG_FILE
fi
