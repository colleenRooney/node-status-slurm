#!/bin/bash
#SBATCH --nodes	    1
#SBATCH --partition PARTITION
#SBATCH --nodelist=NODE
#SBATCH --job-name hostname
#SBATCH --output hostname-output/NODE-hostname.log
#SBATCH --error hostname-output/NODE-hostname.err

srun hostname
