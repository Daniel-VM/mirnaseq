## Introduction

<!-- TODO nf-core: Write a 1-2 sentence summary of what data the pipeline is for and what it does -->
**mirnaseq** is a bioinformatic pipeline to process and to analyze microRNA sequencing data. The approach used in *mirnaseq* allows not only the identification and quantification of known-microRNA but also the estimation and quantification of novel microRNAs. All this together, the pipeline returns a global expression matrix that gathers all your samples and thus facilitates downstream analysis. This method has been designed and developed in the Unit of Viral Infection and Immunity at the National Center for Microbiology (Institute of Health Carlos III). However, basic functionalities and processes have been included by using as references other pipelines that already exist such as [nf-core/smrnaseq](https://github.com/nf-core/smrnaseq/) and [nf-core/mrnaseq](https://github.com/nf-core/rnaseq).

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. The [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) implementation of this pipeline uses one container per process which makes it much easier to maintain and update software dependencies.

## Pipeline summary
<!-- TODO nf-core: Fill in short bullet-pointed list of the default steps in the pipeline -->
1. Quality Control (QC) of raw reads ([`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/))
2. Adapter trimming ([`Trim Galore`](https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/))
3. Present QC for trimmed reads ([`MultiQC`](http://multiqc.info/))
4. Identification of known and novel microRNAs ([`miRDeep2`](https://github.com/rajewsky-lab/mirdeep2))
    1. Mapping reads against reference genome with the mapper module.
    2. Novel and known miRNA identification.
    3. Parsing Novel microRNAs.
    4. Quantifying both known and novel microRNAs.
5. Report of microRNA analysis and microRNA expression matrix for downstream analysis

## Quick Start

1. Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=21.10.3`)

2. Install [`Conda`](https://conda.io/miniconda.html) ; see [docs](https://nf-co.re/usage/configuration#basic-configuration-profiles))_

3. Download the pipeline
    ```console
    git clone -b dev https://github.com/Daniel-VM/mirnaseq.git
    ```

4. Test it on a minimal dataset with a single command:
    ```console
    nextflow run main.nf -profile test,conda 
    ```

    > * The pipeline comes with config profile called `conda` which instruct the pipeline to use the named tool for software management. For example, `-profile test,conda`.

5. Start running your own analysis!

     ```console
    nextflow run main.nf -profile conda \
                        --input 'path_to/*.fastq.gz' \
                        --genome GRCh38 \
                        --target_sp hsa 
    ```
> **NB:** The parameter *-target_sp* attemps to process human miRNAs as the main target specie for the analysis with miRDeep2. 

## Documentation
The *mirnaseq* pipeline comes with documentation about the pipeline [usage](https://github.com/Daniel-VM/mirnaseq/blob/dev/docs/usage.md), [parameters](https://github.com/Daniel-VM/mirnaseq/blob/dev/docs/parameters.md) and [output](https://github.com/Daniel-VM/mirnaseq/blob/dev/docs/output.md).

## Credits
This pipeline has been written by Daniel-VM.

We want to thank the nf-core community, but specially to [nf-core/smrnaseq](https://github.com/nf-core/smrnaseq/) and [nf-core/mrnaseq](https://github.com/nf-core/rnaseq) contributors and developers for the great effort they made to provide high-qualty tools for RNA-seq and small-RNAseq analysis. 

In addition, we thank the following people for their extensive assistance in the development of this pipeline:
1. Amanda Fernández-Rodríguez
2. Óscar Brochado-Kith
3. nf-core community

<!-- TODO nf-core: If applicable, make list of people who have also contributed -->

## Citations
<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use  nf-core/mirnaseq for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) -->

<!-- TODO nf-core: Add bibliography of tools and data used in your pipeline -->
An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).