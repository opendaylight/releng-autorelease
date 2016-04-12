#!/bin/bash

# @License EPL-1.0 <http://spdx.org/licenses/EPL-1.0>
##############################################################################
# Copyright (c) 2016 Huawei, Inc and Others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
##############################################################################

##############################################################################
# Define Defaults
##############################################################################

##############################################################################
# Define Variables
##############################################################################
BUILD_PHASE=${1-package}

##############################################################################
# Show Usage
##############################################################################
usage () {
  echo "AutoNotes Build Commend"
  echo "usage: build.sh [<phase>]"
  echo "Phases:"
  echo "    help    Display command line usage information."
  echo "    clean   Clean project release notes."
  echo "    package Build project release notes."
}

##############################################################################
# Clean Autochecker
##############################################################################
clean () {
  rm -rf projects
  mvn clean
}

##############################################################################
# Package Autochecker
##############################################################################
package () {
  mvn package
  java -jar target/autonotes.jar
}

if [ "${BUILD_PHASE}" = "help" ]; then
  usage
elif [ "${BUILD_PHASE}" = "clean" ]; then
  clean
elif [ "${BUILD_PHASE}" = "package" ]; then
  package
else
  usage
fi
