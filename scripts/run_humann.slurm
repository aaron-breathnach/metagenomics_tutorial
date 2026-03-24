#!/bin/bash
#SBATCH --job-name=humann_sample
#SBATCH --cpus-per-task=8
#SBATCH --mem=48G
#SBATCH --time=24:00:00
#SBATCH --output=/data/analysis/logs/humann_%j.out
#SBATCH --error=/data/analysis/logs/humann_%j.err
##SBATCH --partition=your_partition
##SBATCH --account=your_account

set -euo pipefail

source /data/analysis/miniforge3/bin/activate
conda activate humann

R1=/data/analysis/qc/sample_clean_R1.fastq.gz
R2=/data/analysis/qc/sample_clean_R2.fastq.gz
OUTDIR=/data/analysis/humann
DBROOT=/data/analysis/databases/humann
MERGED=/data/analysis/humann/sample_merged.fastq.gz

mkdir -p "${OUTDIR}" /data/analysis/logs

echo "Concatenating reads at $(date)"
cat "${R1}" "${R2}" > "${MERGED}"

echo "Starting HUMAnN at $(date)"

humann \
  --input "${MERGED}" \
  --output "${OUTDIR}" \
  --threads "${SLURM_CPUS_PER_TASK}" \
  --nucleotide-database "${DBROOT}/chocophlan" \
  --protein-database "${DBROOT}/uniref"

echo "Finished at $(date)"
