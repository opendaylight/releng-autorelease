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

LOG_FILE=dependencies.log

modules=`xmlstarlet sel -N x=http://maven.apache.org/POM/4.0.0 -t -m '//x:modules' -v '//x:module' pom.xml`

for module in $modules; do
    module_dependencies=""
    for pom in `find $module -name pom.xml -not -path "*/src/*"`; do
        dependencies=`xmlstarlet sel -N x=http://maven.apache.org/POM/4.0.0 \
                                     -t \
                                     -m '//x:dependencies' \
                                     -n -v "x:dependency/x:groupId" $pom | \
                      grep org.opendaylight | \
                      sed -e 's/org.opendaylight.//' \
                          -e 's/\..*$//' \
                          -e "s/$module//" | \
                      sort | uniq`
        module_dependencies=`echo $module_dependencies $dependencies | tr " " "\n" | sort | uniq`
    done
    module_dependencies=`echo $module_dependencies | tr " " ","`
    echo "$module:$module_dependencies" >> $LOG_FILE
done

