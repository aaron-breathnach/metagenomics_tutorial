import os

## note: run this from your data directory

## make sure the output directory exists
if not os.path.exists('reads/fastp'):
  os.makedirs('reads/fastp')

## list the sample IDs
prefixes = [x.replace('_L001_R1_001.fastq.gz', '') for x in os.listdir('reads/raw') if '_R1_' in x]

fastp = 'fastp -i reads/raw/{prefix}_L001_R1_001.fastq.gz -I reads/raw/{prefix}_L001_R2_001.fastq.gz -o reads/fastp/{prefix}_L001_R1_001.fastq.gz -O reads/fastp/{prefix}_L001_R2_001.fastq.gz -j reads/fastp/{prefix}.json -h reads/fastp/{prefix}.html'

## write the shell script
with open('run_fastq.sh', 'w') as f:
  for prefix in prefixes:
    cmd = fastp.format(prefix=prefix)
    f.write(cmd + '\n')
