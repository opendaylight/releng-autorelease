#!/usr/bin/env python

import sys
import re
import os
import xml.etree.ElementTree as ET

# process arguments - removing each one from list
if "--f" in sys.argv:
	fake = True
	sys.argv.remove("--f")
else:
	fake = False

if "--v" in sys.argv:
	verbose = True
	sys.argv.remove("--v")
else:
	verbose = False

if "--no-cd" in sys.argv:
	cd = False
	sys.argv.remove("--no-cd")
else:
	cd = True

pom = False
file_in = False
if "--pom" in sys.argv:
	pom = True
	sys.argv.remove("--pom")
	filename = sys.argv[1] + '/pom.xml'
	del sys.argv[1] # remove path from args
elif len(sys.argv) == 3:
	# must have <path> parameter
	file_in = True
	filename = sys.argv[1]
	del sys.argv[1] # remove path from args

# check args length - once all named args and path deleted!
if (len(sys.argv) != 2):
	print "usage: %s [--f] [--v] [--no-cd] [--pom] [<path>] <command>" % sys.argv[0];
	print "   by default runs 'cd <line> && <command>' for each <line> in the file given by <path>"
	print "     to use a pom file as input then use the --pom flag, in which case the path is a directory"
	print "     to use stdin omit <path>"
	print "     if you would like to not cd first, use the --no-cd flag"
	print "   [--f] indicates a 'fake' run, so don't actually run the command"
	print "   [--v] indicates a 'verbose' run, so print the command being issued"
	print "   any occurance of {} in <command> will be replaced by the text after the last '/' in <line>"
	print "   any occurance of {f} in <command> will be replaced by <line>"
	print "   lines in the file with '#' as the first non-whitespace character are ignored"
	sys.exit(1)

# create list of projects from pom.xml, input file, or stdin
if pom:
	# get values for all "<module>" items in pom.xml
	# could just search for lines with "<module>" and split on ">" and "<"
	root = ET.parse(filename).getroot()
	ns = root.attrib.values()[0].split()[0]
	modules = root.find("{" + ns + "}modules")
	module = modules.findall("{" + ns + "}module")
	projects = [m.text for m in module]
elif file_in:
	with open(filename) as myfile:
		projects = myfile.read().split('\n')
else:
		projects = sys.stdin.read().split('\n')

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
	cmd = re.sub("{f}", p, sys.argv[1])
	cmd = re.sub("{}", p.split('/')[-1], cmd)

	if cd:
		# need to change dir before running command
		cmd = "cd " + p + " && " + cmd

	print p

	if verbose:
		# want to print out the command
		print cmd

	if not fake:
		# issue command to system
		os.system(cmd)
