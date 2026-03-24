#!/bin/bash
#SBATCH --job-name=metaphlan_sample
#SBATCH --cpus-per-task=8
#SBATCH --mem=24G
#SBATCH --time=08:00:00
#SBATCH --output=/data/analysis/logs/metaphlan_%j.out
#SBATCH --error=/data/analysis/logs/metaphlan_%j.err
##SBATCH --partition=your_partition
##SBATCH --account=your_account

set -euo pipefail

source /data/analysis/miniforge3/bin/activate
conda activate metaphlan

R1=/data/analysis/qc/sample_clean_R1.fastq.gz
R2=/data/analysis/qc/sample_clean_R2.fastq.gz
OUTDIR=/data/analysis/metaphlan
DB=/data/analysis/databases/metaphlan

mkdir -p "${OUTDIR}" /data/analysis/logs

echo "Starting MetaPhlAn at $(date)"

metaphlan "${R1},${R2}" \
  --input_type fastq \
  --bowtie2db "${DB}" \
  --nproc "${SLURM_CPUS_PER_TASK}" \
  -o "${OUTDIR}/sample_profile.txt"

echo "Finished at $(date)"
