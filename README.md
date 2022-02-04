## Introduction

<!-- TODO nf-core: Write a 1-2 sentence summary of what data the pipeline is for and what it does -->
**nf-core/mirnaseq** is a bioinformatic pipeline to process and to analyze microRNA sequencing data. The approach used in nf-core/mirnaseq allows not only the identification and quantification of known-microRNA but also the estimation and quantification of novel microRNAs. This method has been designed and developed in the Unit of Viral Infection and Immunity at the National Center for Microbiology (Institute of Health Carlos III).

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It uses Docker/Singularity containers making installation trivial and results highly reproducible. The [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) implementation of this pipeline uses one container per process which makes it much easier to maintain and update software dependencies. Where possible, these processes have been submitted to and installed from [nf-core/modules](https://github.com/nf-core/modules) in order to make them available to all nf-core pipelines, and to everyone within the Nextflow community!

<!-- TODO nf-core: Add full-sized test dataset and amend the paragraph below if applicable -->
On release, automated continuous integration tests run the pipeline on a full-sized dataset on the AWS cloud infrastructure. This ensures that the pipeline runs on AWS, has sensible resource allocation defaults set to run on real-world datasets, and permits the persistent storage of results to benchmark between pipeline releases and other analysis sources. The results obtained from the full-sized test can be viewed on the [nf-core website](https://nf-co.re/mirnaseq/results).

## Pipeline summary

<!-- TODO nf-core: Fill in short bullet-pointed list of the default steps in the pipeline -->
1. Quality Control (QC) of raw reads ([`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/))
2. Adapter trimming ([`Trim Galore`](https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/))
3. Present QC for trimmed reads ([`MultiQC`](http://multiqc.info/))
4. Identification of novel and known microRNAs ([`miRDeep2`](https://github.com/rajewsky-lab/mirdeep2))
    1. Mapping reads against reference genome with the mapper module.
    2. Novel and known miRNA identification.
    3. Parsing Novel microRNAs.
    4. Quantifying both novel and known microRNAs.
5. Report of microRNA analysis

## Quick Start

1. Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=21.10.3`)

2. Install [`Conda`](https://conda.io/miniconda.html) ; see [docs](https://nf-co.re/usage/configuration#basic-configuration-profiles))_

3. Download the pipeline
    ```console
    git clone https://github.com/Daniel-VM/mirnaseq.git
    ```

4. Test it on a minimal dataset with a single command:
    ```console
    nextflow run mirnaseq_main.nf -profile test,conda 
    ```

    > * The pipeline comes with config profile called `conda` which instruct the pipeline to use the named tool for software management. For example, `-profile test,conda`.

5. Start running your own analysis!

<!-- FIX IT
    ```console
    nextflow run nf-core/mirnaseq -profile <conda> --input 'path_to/*.fastq.gz' --genome GRCh38
    ```
-->
## Documentation

The nf-core/mirnaseq pipeline comes with documentation about the pipeline [usage](https://github.com/Daniel-VM/mirnaseq/blob/dev/docs/usage.md), [parameters] and [output](https://github.com/Daniel-VM/mirnaseq/blob/dev/docs/output.md).

## Credits

The mirnaseq pipeline was originally written by Daniel-VM.

We thank the following people for their extensive assistance in the development of this pipeline:
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