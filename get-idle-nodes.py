#!/usr/bin/python
# Script that prints idle nodes to terminal
# uses SLURM sinfo command
# 2018 Colleen Rooney
from sinfo_parsing import *
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-p", "--partition", help="get idle nodes from specified partition")
parser.add_argument("-v", "--verbose", action="store_true", help="prints the name of the \
partition the node is in to stdout after the name of the node")
args = parser.parse_args()

partition = args.partition if args.partition else ''


idle_nodes = get_idle_nodes(partition=partition)

for node in idle_nodes:
    part = node['partition'] if args.verbose else ''
    print("%s %s" % (node['node'], part))
