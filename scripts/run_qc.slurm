#!/bin/bash
#SBATCH --job-name=qc_sample
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=/data/analysis/logs/qc_%j.out
#SBATCH --error=/data/analysis/logs/qc_%j.err
##SBATCH --partition=your_partition
##SBATCH --account=your_account

set -euo pipefail

source /data/analysis/miniforge3/bin/activate
conda activate qc

R1=/data/analysis/raw_reads/sample_R1.fastq.gz
R2=/data/analysis/raw_reads/sample_R2.fastq.gz
OUTDIR=/data/analysis/qc
PREFIX=sample

mkdir -p "${OUTDIR}" /data/analysis/logs

echo "Starting fastp at $(date)"

fastp \
  -i "${R1}" \
  -I "${R2}" \
  -o "${OUTDIR}/${PREFIX}_trimmed_R1.fastq.gz" \
  -O "${OUTDIR}/${PREFIX}_trimmed_R2.fastq.gz" \
  --html "${OUTDIR}/${PREFIX}_fastp.html" \
  --json "${OUTDIR}/${PREFIX}_fastp.json" \
  --thread "${SLURM_CPUS_PER_TASK}"

echo "Starting hostile at $(date)"

hostile clean \
  --input1 "${OUTDIR}/${PREFIX}_trimmed_R1.fastq.gz" \
  --input2 "${OUTDIR}/${PREFIX}_trimmed_R2.fastq.gz" \
  --output1 "${OUTDIR}/${PREFIX}_clean_R1.fastq.gz" \
  --output2 "${OUTDIR}/${PREFIX}_clean_R2.fastq.gz" \
  --threads "${SLURM_CPUS_PER_TASK}"

echo "Finished at $(date)"
