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

process PREPARE_MIRBASE {
    label 'process_low'
    conda (params.enable_conda ? "bioconda::mirdeep2=2.0.1.2" : null)

    input:
    file mature_fasta
    file hairpin_fasta

    script:
    """
    extract_miRNAs.pl $mature_fasta hsa > mature_ref.fa
    extract_miRNAs.pl $hairpin_fasta hsa > hairpin_ref.fa
    extract_miRNAs.pl $mature_fasta ggo,ppy,ptr,ppa > mature_related_ref.fa
    """

    output:
    path ('mature_ref.fa')      , emit: mature
    path ('hairpin_ref.fa')     , emit: hairpin
    path ('*_related_ref.fa')   , emit: related
}
