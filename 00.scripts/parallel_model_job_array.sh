#!/bin/bash
#SBATCH --account=you_account
#SBATCH --time=06:30:00
#SBATCH --job-name=abc
#SBATCH --output=abc-%J.out
#SBATCH --array=1-32%32
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32

# Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

# Folder to run simulations
MODEL=$1 #example: SC_2M_2N SI_2N "SC_1M_1N", "SC_1M_2N", "SC_2M_1N", "SC_2M_2N"
MIG=$2   #example: ACBD      #"A", "B", "C", "D", "AC", "BD", "ACBD"
SCRIPT=./00.scripts/models/model_parallel.sh
FOLDER=./01.results/"$MODEL"_"$MIG".$SLURM_ARRAY_TASK_ID

mkdir 01.results 2>/dev/null

NCPUS=32
seq $NCPUS |parallel -j $NCPUS $SCRIPT {} $FOLDER $MODEL $MIG

