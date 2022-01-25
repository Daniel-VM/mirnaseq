process PREPARE_GENOME {
    label 'process_low'
    conda (params.enable_conda ? "conda-forge::sed=4.7" : null)

    input:
    file genome_fasta

    script:
    """
    sed '/^[^>]/s/[^ATGCatgc]/N/g' $genome_fasta > genome.edited.fa
    sed 's/ .*//' genome.edited.fa > genome.edited.nowhite.fa
    """
    output:
    path ('*.edited.fa'), emit: edited 
    path ('*nowhite.fa'), emit: nowhite 
}
//process PREPARE_MIRBASE {
//    label 'process_low'
//    conda (params.enable_conda ? "bioconda::mirdeep22.0.1.2" : null)
//    input:
//    script:
//    output:
//
//
//}
