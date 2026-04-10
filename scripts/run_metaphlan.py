import os

## note: run this from your data directory

## make sure the output directory exists
output_dirs = ['output/metaphlan/bt2', 'output/metaphlan/txt', 'output/metaphlan/sam']
for output_dir in output_dirs:  
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)

## list the sample IDs
prefixes = [x.replace('_L001_R1_001.clean_1.fastq.gz', '') for x in os.listdir('reads/hostile') if '_R1_' in x]

## prefix = 'MGB_1084_04_01_S151'

metaphlan = '''
metaphlan reads/hostile/{prefix}_L001_R1_001.clean_1.fastq.gz,reads/hostile/{prefix}_L001_R2_001.clean_2.fastq.gz  
--input_type fastq 
--db_dir /data/Food/analysis/R2560_prepop/klara/databases/metaphlan/mpa_vJan25_CHOCOPhlAnSGB_202503 
--mapout output/metaphlan/bt2/{prefix}.profiled_metagenome.bt2 
-o output/metaphlan/txt/{prefix}.profiled_metagenome.txt 
-s output/metaphlan/sam/{prefix}.profiled_metagenome.sam 
--nproc 8
'''.replace('\n', '')

## write the shell script
with open('scripts/run_metaphlan.sh', 'w') as f:
  for prefix in prefixes:
    cmd = metaphlan.format(prefix=prefix)
    f.write(cmd + '\n')
