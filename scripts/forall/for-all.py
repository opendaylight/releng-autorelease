#!/usr/bin/python
# @License EPL-1.0 <http://spdx.org/licenses/EPL-1.0>
##############################################################################
# Copyright (c) 2016 The Linux Foundation.  All rights reserved.
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License v1.0 which accompanies this distribution,
# and is available at http://www.eclipse.org/legal/epl-v10.html
##############################################################################

"""This python script enables you to run commands (e.g. git clone) for each
repository in a specific ODL release.  It was written as a more functional
replacement for Colin Dixon's 'for-all.pl' script.

Usage: ./for-all.py [-h] [-f] [-v] [-n / -f] [--pom path] [--list file] <cmd>
  by default runs 'cd (text after last '/' in <line>) && <cmd>' for each of:
    1) a <module> statement in the pom.xml file found at path (if using --pom)
    2) a line in the file specified (if using --list)
  any occurance of {} in <cmd> is replaced by text after last '/' in <line>
  any occurance of {f} in <cmd> will be replaced by <line>
  lines in the file with '#' as the first non-whitespace character are ignored

Args:
    -h:           Provide help
    -t/--test:    Do a test run (don't actually issue the command)
    -v/--verbose: Provide verbose logging
    -n/--no-cd:   Don't change directory before running command
    -f/--full-cd: Change to full subdirectory before running command
    --pom path:   Path to pom.xml for release
    --list file:  Location of file listing repositories
    cmd:          Command to run

@Author : Giles Heron
@Email  : giheron@cisco.com
"""
import sys
import re
import os
from argparse import ArgumentParser
import xml.etree.ElementTree as ET

# set up parser
parser = ArgumentParser()

parser.add_argument('--verbose', '-v', help="emit more noise",
                    action='store_true', default=False)

parser.add_argument('--test', '-t', help="verify but don't issue command",
                    action='store_true', default=False)

parser.add_argument('--no-cd', '-n', help="don't change directory",
                    action='store_true', default=False)

parser.add_argument('--full-cd', '-f', help="change to full subdirectory",
                    action='store_true', default=False)

parser.add_argument('--pom', '-p', help="specify path to pom.xml")

parser.add_argument('--list', '-l', help="specify file with list of projects")

parser.add_argument('cmd', help='command to be issued')

args = parser.parse_args()

# create list of projects from pom.xml, input file, or stdin
if args.pom is not None:
    # get values for all "<module>" items in pom.xml
    # could just search for lines with "<module>" and split on ">" and "<"
    root = ET.parse(args.pom+'/pom.xml').getroot()
    ns = root.attrib.values()[0].split()[0]
    modules = root.find("{" + ns + "}modules")
    module = modules.findall("{" + ns + "}module")
    projects = [m.text for m in module]
elif args.list is not None:
    with open(args.list) as myfile:
        projects = myfile.read().split('\n')
else:
    projects = sys.stdin.read().split('\n')

# now run the cmd across all projects
for project in projects:
    # remove all leading/trailing whitespace to get project name
    p = project.strip()

    if len(p) == 0:
        # this is an empty line
        break

    if p[0] == '#':
        # this is a comment
        break

    # perform string substitutions
    cmd = re.sub("{f}", p, args.cmd)
    cmd = re.sub("{}", p.split('/')[-1], cmd)
    print p

    # do cd if necessary
    if args.full_cd:
        # change to full subdir before running cmd
        cmd = "cd " + p + " && " + cmd
    elif not args.no_cd:
        # need to change dir before running command
        cmd = "cd " + p.split('/')[-1] + " && " + cmd

    if args.verbose:
        # want to print out the command
        print cmd

    if not args.test:
        # issue command to system
        os.system(cmd)
