#!/usr/bin/env python3
#
#   readsProcessing_report.py
#
import argparse
import os
import re
import collections
import pandas as pd
from itertools import chain
from radial_plot import *


# ===============================================
#               PARSING ARGUMENTS
# ===============================================
parser          = argparse.ArgumentParser(description="gather reads processing parameters")
requiredNamed   = parser.add_argument_group('mandatory parameters')
requiredNamed.add_argument('-q', '--fastqc', type = str,  help = 'fastqc data')
requiredNamed.add_argument('-c', '--cutadapt', type = str,  help = 'cutadapt data')
requiredNamed.add_argument('-F', '--mirdeep2_config', type = str,  help = 'Config file summarizing mirdeep2 3letters code equivalence on sample files')
requiredNamed.add_argument('-m', '--mirdeep2_mapper', type = str,  help = 'mapper.pl report')
#requiredNamed.add_argument('-M', '--mirdeep2_mirdeep', type = str,  help = 'mirdeep2 report')
#parser.parse_args(['-h'])

# mandatory: use this:
args = vars(parser.parse_args())

# ====================
# QC & TRIM  METRICS
# ====================
try:
    df_trimStats = pd.read_csv(args['cutadapt'], sep='\t', lineterminator='\n')
except FileNotFoundError:
    sys.exit("[ERROR]: File doesnt exist: " + args['cutadapt'])

try:
    df_qualityStats = pd.read_csv(args['fastqc'], sep='\t', lineterminator='\n')
except FileNotFoundError:
    sys.exit("[ERROR]: File doesnt exist: " + args['fastqc'])


df_qcTrim = pd.merge(df_trimStats, df_qualityStats, on=['Sample'])

# ====================
# MIRDEEP2  METRICS
# ====================

# CONFIG FILE
try:
    df_config = pd.read_csv(args['mirdeep2_config'], header = None, names= ['path', 'sample_code'], sep='\s+', lineterminator='\n', dtype = str, )
except FileNotFoundError:
    sys.exit("[ERROR]: File doesnt exist: " + args['mirdeep2_config'])


sample_list = list()
for i in range(0,len(df_config.index)):
    f_path = os.path.basename(df_config.loc[i,'path'])
    sample = os.path.splitext(f_path)[0].replace('_trimmed','')
    sample_list.append(sample)
df_config['Sample'] = sample_list


# MAPPER LOGS
with open(args['mirdeep2_mapper'],'r') as f_mapper:
    mapper_logs = [f.rstrip() for f in f_mapper]

mapper_stats = collections.defaultdict(list)
for l in mapper_logs:
    # Find target data in mapper logs
    data_pattern    = re.search(r'^[0-9]{3}', l)
    if data_pattern:
        data_decomposed= l.split(': ')
        sample_code = data_decomposed[0]
        mapper_data = data_decomposed[1].split('\t')
        
        # Popullate data collection
        mapper_stats['sample_code'].append(sample_code)
        mapper_stats['total'].append(mapper_data[0])
        mapper_stats['mapped'].append(mapper_data[1])
        mapper_stats['unmapped'].append(mapper_data[2])
        mapper_stats['%mapped'].append(mapper_data[3])
        mapper_stats['%unmapped'].append(mapper_data[4])

# from dic collections to pd
df_mapper = pd.DataFrame(mapper_stats) 

# MERGE MAPPER TO CONFIG
mapper_final = pd.merge(df_config,df_mapper, on=['sample_code']) # required to make connection between sample names and three leters code

# ===============================
# OUTPUT SUMMARIZING ALL METIRCS
# ===============================
df_final = pd.merge(df_qcTrim, mapper_final, on=['Sample'])
df_final.to_csv('merged.csv',sep=',')

# Create a radial piechart. Output is saved as ./percent_reads.png
radial_pie(df = df_final)