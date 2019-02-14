# node-status-slurm
Simple scripts for node testing on a cluster with a slurm job scheduler.
Created to detect when nodes are producing errors.

This was made specifically for the coeus HPC at Portland State University and has some code in sinfo_parsing.py specific to this cluster. These sections are marked with comments containing "specific to coeus". 

#### list-nodes.py
'./list-nodes.py -h' will print options to standard out. Default behavior is to print all the nodes that are idle. It is possible to specify a different state, and a specific partition. Using the verbose option will print the name of the node followed by the partition it belongs to.

depends:
* sinfo_parsing.py

#### hostname-test.sh
Creates the directory specified by 'OUTPUT_DIR' (currently defined in script) then submits a job to all idle nodes that runs the command 'hostname'. All nodes that produced errors are printed. If an error file is produced it is saved in the output directory, all other output files are removed.

depends:
* list-nodes.py
* hostname.sh
