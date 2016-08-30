# @License EPL-1.0 <http://spdx.org/licenses/EPL-1.0>
##############################################################################
# Copyright (c) 2015 The Linux Foundation.  All rights reserved.
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License v1.0 which accompanies this distribution,
# and is available at http://www.eclipse.org/legal/epl-v10.html
##############################################################################

""" This python script is used for determine the order of module dependencies
to be followed while performing merge operation during version bumping process
for a new release. It creates an file merge_order.log which lists the order to
be followed.

The merge order is computed be building a directed graph (dependency tree) from
the jobs and performing a topological sort on the graph starting from the root, 
This returns a ordered list of jobs which is output to file `merge-order.log`.

Usage: ./determine-merge-order.py [input-file] [output-file]

Args:
    input-file:     Path to input file (default:dependency.log)
    output-file:    Path to output file (default: merge-order.log)

@Author : Anil Shashikumar Belur aka abelur
@Email  : askb23@gmail.com
"""

import networkx as nx
import re
import sys

if __name__ == '__main__':

    try:
        input_file = sys.argv[1]
        if not sys.argv[1]:
            input_file = "dependencies.log"
    except IndexError:
        print('Input file with dependencies unavailable')
        sys.exit(1)

    try:
        with open(input_file, 'r') as rhandle:
            raw = rhandle.read()
    except IOError:
        print("Error on opening file: {0}".format(input_file))
        sys.exit(1)

    try:
        output_file = sys.argv[2]
        if not output_file:
            output_file = "merge-order.log"
    except IndexError:
        print('Output file with dependencies unavailable')
        sys.exit(1)

    regex_node = re.compile(r':')
    regex_deps = re.compile(r',')

    # build a directed graph from the list of jobs
    G = nx.DiGraph()
    for l in raw.splitlines():
        if len(l):
            node, prereq = regex_node.split(l)
            deps = tuple(regex_deps.split(prereq))
            if not prereq:
                G.add_node(node)
            else:
                tups = [(a, node) for a in deps]
                G.add_edges_from(tups)

    deps_order = nx.topological_sort(G)

    try:
        with open(output_file, 'w+') as whandle:
            for d in deps_order:
                whandle.write(d + "\n")
    except IOError:
        print("Error on opening file: {0}".format(output_file))
        sys.exit(1)

    rhandle.close()
    whandle.close()
