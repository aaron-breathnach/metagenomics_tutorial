import json
import os
import subprocess

def count_reads_fastq_gz(prefix):
    file_path = f'reads/hostile/{prefix}_L001_R1_001.clean_1.fastq.gz'
    cmd = f'zcat {file_path} | wc -l'
    result = subprocess.check_output(cmd, shell=True, text=True)
    return int(result.strip()) // 4

def get_read_summary(prefix):
    with open(f'reads/fastp/{prefix}.json', 'r', encoding='utf-8') as file:
        data = json.load(file)
        before_filtering = data['summary']['before_filtering']['total_reads']
        after_filtering = data['summary']['after_filtering']['total_reads']
        after_hostile = count_reads_fastq_gz(prefix)
        return {
            'sample_id': prefix,
            'before_filtering': before_filtering,
            'after_filtering': after_filtering,
            'after_hostile': after_hostile
        }


prefixes = [x.replace('_L001_R1_001.fastq.gz', '') for x in os.listdir('reads/raw') if '_R1_' in x]