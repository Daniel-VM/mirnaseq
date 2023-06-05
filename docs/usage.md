# mirnaseq: Usage

## Running the pipeline
The typical command for running the pipeline is as follows:

```console
nextflow run main.nf --input './path_to/sample_sheet.csv' --genome 'GRCh38' -profile conda --target_sp 'hsa'
```

This will launch the pipeline with the `conda` configuration profile. See below for more information about profiles.

Note that the pipeline will create the following files in your working directory:

```console
work            # Directory containing the nextflow working files
results         # Finished results (configurable, see below)
.nextflow_log   # Log file from Nextflow
# Other nextflow hidden files, eg. history of pipeline runs and old logs.
```

## Updating the pipeline
In order to be up to date with the latest version of the pipeline make sure you clone the *master* branch of mirnaseq:
```console
git clone -b master https://github.com/Daniel-VM/mirnaseq.git
```

## Stand-alone scripts

mirnaseq has two stand-alone scripts that allows to efficiently manipulate and process I/O files.
* `bin/check_samplesheet.py`: checks correctness of input file.
* `bin/create_configFile.R`: This converts your isolated input fastq files into a configuration file in accordance with the miRDeep2 guidelines (file_name + \t + three-letter code). For example: path_to/sample_name.fastq.gz   001. 
* `bin/mirdeep_novelProc.sh`: This script detect novel miRNAs identified by mirdeep2. These miRNAs will be filtered based on a specific condition and taken as reference sequence in order to be quanitfied.
* `bin/complete_report.py`: Gathers relevant statistics from each of the steps in the analysis.
