# functions for extraction information from sinfo
# 2018 Colleen Rooney
import subprocess
import re

def node_pretty(node_number, compute=True):
    """Given a string 'node_number' pads node number with 0s"""
    # this is because of how our nodes are named, need to change if nodes are
    # named differently compute nodes have 3 digits, phi and himem have 2
    length = 3 if compute else 2
    while len(node_number) < length:
        node_number = '0' + node_number
    return node_number


def sep_nodes(node_type, partition, node_range, node_list=[]):
    """Given a string 'node_type' (compute, phi, himem) a partition (medium,
    long, phi etc.) and a string 'node_range' (001-031, 095) appends a
    dictionary with the name stored under the key 'name' and the partition
    stored under the key 'partition' of all the nodes in the range, to a list
    (default empty list) and returns the list"""
    start_end = node_range.split('-')

    # janky fix... should really use regex incase name of default partition
    # changes
    if partition == "medium*": partition = "medium"

    if len(start_end) == 2:
        for node in range(int(start_end[0]), int(start_end[1]) + 1):
            # specific to our cluster 
            compute = False if node_type != "compute" else True
            node_number = node_pretty(str(node), compute)
            node_list.append({'node':node_type + node_number,
                                'partition':partition})

    elif len(start_end) == 1:
        node_number = node_pretty(str(start_end[0]))
        node_list.append(node_type + node_number)


def get_idle_nodes(partition='', state='idle'):
    """Returns the idle nodes using the SLURM sinfo command. If a partition
    is specified only idle nodes of that partition will be returned"""
    # get data from sinfo
    grep_string = partition + '.*' + state
    sinfo_out = subprocess.Popen(['sinfo'], stdout=subprocess.PIPE)

    # this could be fixed to work with other configurations, duplicates just
    # need to be removed
    if partition != 'allcpu':
        no_allcpu = subprocess.Popen(['grep', '-v', 'allcpu'], stdin=sinfo_out.stdout,
        stdout=subprocess.PIPE)
        sinfo_out = no_allcpu

    grep_out = subprocess.Popen(['grep', grep_string], stdin=sinfo_out.stdout,
    stdout=subprocess.PIPE).communicate()[0].split('\n')

    idle_lines = []
    for line in grep_out:
        if line != '':
            split_out = line.split()
            partition = split_out[0]
            partition_nodes = split_out[5]
            idle_lines.append({'nodes':partition_nodes, 'partition':partition})

    idle_nodes = []
    for line in idle_lines:
        # extract node type and numbers... specfic to our cluster
        match = re.match('((compute)|(himem)|(phi))\[(.*)\]', line['nodes'])
        partition = line['partition']

        node_list = match.group(5).split(',')
        node_type = match.group(1)
        for node_range in node_list:
            sep_nodes(node_type, partition, node_range, node_list=idle_nodes)

    return idle_nodes
