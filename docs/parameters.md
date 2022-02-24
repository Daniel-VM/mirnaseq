# PARAMETERS

## >_ Input / output options
* `--input`: input fastq files.
```console
--input './path_toSamples/{1,2,3}_samples.fastq.gz'

``` 
* `--ourdir`: path to directory in which you want to place the results.
```console
--outdir './results'
``` 
## >_ Reference genome options
* `--genome`: name of iGenomes reference (see conf/igenomes.config).
```console
--genome GRCh38
``` 

* `--bt_indices`: path to bowtie index files.
```console
--bt_indices './ref_indices/genome.*.ebwt'
``` 

* `--mature`: fasta gziped file containing miRBAse mature microRNAs (fasta sequences).
Default: 
```console
--mature "https://www.mirbase.org/ftp/CURRENT/mature.fa.gz"
``` 

* `--hairpin`: fasta gziped file containing miRBAse precursor microRNAs (fasta sequences).
Default: 
```console
--hairpin "https://www.mirbase.org/ftp/CURRENT/hairpin.fa.gz"
``` 

## >_ QC and read trimming options

* `three_prime_adapter`: Adapter sequence to be removed from the 3'end of reads (default: 'AGATCGGAAGAGC').
```console
--three_prime_adapter 'AGATCGGAAGAGC'

Illumina:   AGATCGGAAGAGC
Small RNA:  TGGAATTCTCGG
Nextera:    CTGTCTCTTATA
```

* `min_length`: discard reads thar are shorter than *integer* (default: 17)
```console
--min_length 17
```
* `max_length`: discard reads that are longer than *integer* (default: 50)
```console
--max_length 50
```

* `quality_cutoff`: trim low-quality (based on PHRED SCORE) ends from reads. (default: 20 )
```console
--quality_cutoff 20
```

## >_ miRDeep2 options
* `target_sp`: key target specie for microRNA analysis with miRDeep2.
```console
--target_sp hsa
```

* `related_sp`: dentifiers of reletated species separated by commas:
```console
--related_sp ggo,ppy,ptr,ppa
```
