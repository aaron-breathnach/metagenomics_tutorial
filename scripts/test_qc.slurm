#!/bin/bash
#SBATCH --job-name=qc_sample
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --output=/data/analysis/logs/qc_%j.out
#SBATCH --error=/data/analysis/logs/qc_%j.err

eval "$(conda shell.bash hook)"
conda activate qc

fastp \
  -i reads/raw/sample_R1.fastq.gz \
  -I reads/raw/sample_R2.fastq.gz \
  -o reads/qc/sample_trimmed_R1.fastq.gz \
  -O reads/qc/sample_trimmed_R2.fastq.gz \
  --html reads/qc/sample_fastp.html \
  --json reads/qc/sample_fastp.json \
  --thread 8

hostile clean \
  --fastq1 reads/qc/sample_trimmed_R1.fastq.gz \
  --fastq2 reads/qc/sample_trimmed_R2.fastq.gz \
  --threads 8
