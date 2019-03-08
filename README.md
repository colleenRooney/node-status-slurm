# node-status-slurm
###### Developed due to "slurmstepd: error: task/cgroup: unable to add task[pid=#] to memory cg '(null)'" errors
Simple scripts for node testing on a cluster with a slurm job scheduler.

This was made specifically for the coeus HPC at Portland State University and has some code in sinfo_parsing.py specific to this cluster. These sections are marked with comments containing "specific to coeus". 

#### list-nodes.py
'./list-nodes.py -h' will print options to standard out. Default behavior is to print all the nodes that are idle. It is possible to specify a different state, and a specific partition. Using the verbose option will print the name of the node followed by the partition it belongs to.

depends:
* sinfo_parsing.py

#### run-on-idle.sh
'./run-on-idle.sh -h' will print options to standard out. Runs a sbatch script on all idle nodes. Sbatch script is defined with '-s' or '--script' option. 'hostname.sh' is a simple example. Creates the directory specified by the 'o' or '--outdir' option, or the default directory of '/scratch/utils/test-nodes-output' then submits a job to all idle nodes. All nodes that produced errors are printed. If an error file is produced it is saved in the output directory, all other output files are removed.

depends:
* list-nodes.py
* sinfo_parsing.py
