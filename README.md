# Shotgun Metagenomics Tutorial for a SLURM HPC

This repository contains a simple teaching workflow for shotgun metagenomics on a SLURM-based HPC.

## Overview

The tutorial covers:

1. Installing Miniforge and mamba in `/data/analysis`
2. Creating a `qc` environment with `fastp` and `hostile`
3. Running `fastp` and `hostile` on a single paired-end sample
4. Creating a `metaphlan` environment and installing the MetaPhlAn database in `/data/analysis/databases/metaphlan`
5. Running MetaPhlAn on the cleaned sample
6. Creating a `humann` environment and installing the HUMAnN databases in `/data/analysis/databases/humann`
7. Running HUMAnN on the cleaned sample
8. Submitting jobs with SLURM batch scripts

## Suggested directory structure

```bash
/data/analysis/
├── miniforge3/
├── databases/
│   ├── metaphlan/
│   └── humann/
├── logs/
├── raw_reads/
├── qc/
├── metaphlan/
├── humann/
└── scripts/
```

Create the directories:

```bash
mkdir -p /data/analysis/{databases,logs,raw_reads,qc,metaphlan,humann,scripts}
```

## 1. Install Miniforge and mamba

```bash
cd /data/analysis

wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash Miniforge3-Linux-x86_64.sh -b -p /data/analysis/miniforge3

source /data/analysis/miniforge3/bin/activate
conda install -y -n base -c conda-forge mamba
```

## 2. Create the QC environment

```bash
source /data/analysis/miniforge3/bin/activate
mamba create -y -n qc -c conda-forge -c bioconda fastp hostile
```

## 3. Run QC on a single paired-end sample

Assume the raw reads are:

- `/data/analysis/raw_reads/sample_R1.fastq.gz`
- `/data/analysis/raw_reads/sample_R2.fastq.gz`

```bash
wget https://raw.githubusercontent.com/biobakery/kneaddata/refs/heads/master/examples/demoR_1.fastq -O reads/raw/sample_R1.fastq

wget https://raw.githubusercontent.com/biobakery/kneaddata/refs/heads/master/examples/demoR_2.fastq -O reads/raw/sample_R2.fastq

gzip reads/raw/*


```

Activate the environment:

```bash
source /data/analysis/miniforge3/bin/activate
conda activate qc
```

Run `fastp`:

```bash
fastp \
  -i reads/raw/sample_R1.fastq.gz \
  -I reads/raw/sample_R2.fastq.gz \
  -o reads/qc/sample_trimmed_R1.fastq.gz \
  -O reads/qc/sample_trimmed_R2.fastq.gz \
  --html reads/qc/sample_fastp.html \
  --json reads/qc/sample_fastp.json \
  --thread 8
```

Run `hostile`:

```bash
hostile clean \
  --input1 /data/analysis/qc/sample_trimmed_R1.fastq.gz \
  --input2 /data/analysis/qc/sample_trimmed_R2.fastq.gz \
  --output1 /data/analysis/qc/sample_clean_R1.fastq.gz \
  --output2 /data/analysis/qc/sample_clean_R2.fastq.gz \
  --threads 8
```

## 4. Create the MetaPhlAn environment and install the database

```bash
source /data/analysis/miniforge3/bin/activate
mamba create -y -n metaphlan -c bioconda -c conda-forge metaphlan
conda activate metaphlan

mkdir -p /data/analysis/databases/metaphlan
metaphlan --install --bowtie2db /data/analysis/databases/metaphlan
```

## 5. Run MetaPhlAn

```bash
metaphlan /data/analysis/qc/sample_clean_R1.fastq.gz,/data/analysis/qc/sample_clean_R2.fastq.gz \
  --input_type fastq \
  --bowtie2db /data/analysis/databases/metaphlan \
  --nproc 8 \
  -o /data/analysis/metaphlan/sample_profile.txt
```

## 6. Create the HUMAnN environment and install the databases

```bash
source /data/analysis/miniforge3/bin/activate
mamba create -y -n humann -c biobakery -c bioconda -c conda-forge humann
conda activate humann

mkdir -p /data/analysis/databases/humann
humann_databases --download chocophlan full /data/analysis/databases/humann
humann_databases --download uniref uniref90_diamond /data/analysis/databases/humann
```

## 7. Run HUMAnN

HUMAnN expects a single input file. For paired-end reads, concatenate the cleaned reads first:

```bash
cat /data/analysis/qc/sample_clean_R1.fastq.gz /data/analysis/qc/sample_clean_R2.fastq.gz > /data/analysis/humann/sample_merged.fastq.gz
```

Then run HUMAnN:

```bash
humann \
  --input /data/analysis/humann/sample_merged.fastq.gz \
  --output /data/analysis/humann \
  --threads 8 \
  --nucleotide-database /data/analysis/databases/humann/chocophlan \
  --protein-database /data/analysis/databases/humann/uniref
```

## 8. Running on a SLURM HPC

On most HPC systems, large jobs should be submitted with `sbatch` rather than run on the login node.

Useful commands:

```bash
sbatch scripts/run_qc.slurm
sbatch scripts/run_metaphlan.slurm
sbatch scripts/run_humann.slurm

squeue -u $USER
scancel JOBID
sacct -j JOBID
```

## Notes

- Some clusters require extra SLURM options such as `--partition` or `--account`
- The memory and walltime values in the example scripts are sensible starting points for one sample
- Always test on one sample before scaling to many
- Check the cluster documentation for local policies
