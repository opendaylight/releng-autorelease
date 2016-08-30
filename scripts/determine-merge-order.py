#!/usr/bin/env python
# @License EPL-1.0 <http://spdx.org/licenses/EPL-1.0>
##############################################################################
# Copyright (c) 2016 The Linux Foundation.  All rights reserved.
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License v1.0 which accompanies this distribution,
# and is available at http://www.eclipse.org/legal/epl-v10.html
##############################################################################

""" This python script is used to determine the order of module dependencies
to be followed while performing merge operation during version bumping process
for a new release.

The order is computed be building a directed graph (dependency tree) from
the list of jobs and performing a topological sort on the graph starting from
the root node. The output is ordered list of jobs.

The script requires 'networkx' module installed within the virtualenv.

Usage: ./determine-merge-order.py

    input-file:     dependency.log
    output-file:    merge-order.log

"""

import re
import sys
import networkx as nx

def determine_merge_order(input_file='dependencies.log',
                          output_file='merge-order.log'):
    try:
        with open(input_file, 'r') as rhandle:
            raw = rhandle.read()
    except IOError:
        print("Error on opening file: {0}".format(input_file))
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

    # traverse the graph to compute order
    deps_order = nx.topological_sort(G)

    try:
        with open(output_file, 'w+') as whandle:
            for d in deps_order:
                if d == "honeycomb" or d == "integration":
                    continue
                whandle.write(d + "\n")
    except IOError:
        print("Error on opening file: {0}".format(output_file))
        sys.exit(1)

    rhandle.close()
    whandle.close()

if __name__ == '__main__':
    determine_merge_order()
