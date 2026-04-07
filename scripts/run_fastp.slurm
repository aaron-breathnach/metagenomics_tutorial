#!/bin/bash
#SBATCH --job-name=fastp
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --output=fastp.out
#SBATCH --error=fastp.err

eval "$(conda shell.bash hook)"
conda activate qc

python scripts/run_fastp.py

sh scripts/run_fastp.sh
