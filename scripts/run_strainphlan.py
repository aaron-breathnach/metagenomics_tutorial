
import os
from pathlib import Path

sample2markers = '''sample2markers.py \
-i {sam} \
-o {consensus_markers} \
-d {pkl} \
-f sam \
--nproc {threads}'''

extract_markers = '''extract_markers.py \
-d {pkl} \
-c {clade} \
-o {clade_markers}'''

strainphlan = '''strainphlan \
-s output/metaphlan/consensus_markers/* \
-m {clade_markers}/{clade}.fna \
-o {output} \
-c {clade} \
--phylophlan_mode fast \
--nproc {threads} \
-d {pkl}'''

pkl = '/data/Food/analysis/R2560_prepop/klara/databases/metaphlan/mpa_vJan25_CHOCOPhlAnSGB_202503/mpa_vJan25_CHOCOPhlAnSGB_202503.pkl'
clade = 't__SGB7044'
threads = 8

out_dirs = ['output/metaphlan/consensus_markers', 'output/metaphlan/clade_markers', 'output/metaphlan/strainphlan']
for out_dir in out_dirs:
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)

sams = [x.as_posix() for x in Path('output/metaphlan/sam').rglob('*.sam')]

cmds = []
for sam in sams:
    cmd = sample2markers.format(sam=sam, consensus_markers=out_dirs[0], pkl=pkl, threads=threads)
    cmds.append(cmd)

cmds.append(extract_markers.format(pkl=pkl, clade=clade, clade_markers=out_dirs[1]))
cmds.append(strainphlan.format(clade_markers=out_dirs[1], clade=clade, output=out_dirs[2], threads=threads, pkl=pkl))

for cmd in cmds:
    with open(f'scripts/run_strainphlan_{clade}.sh', 'w') as f:
        f.write(cmd + '\n')
