// Parsing reference genome and build indices with bowtie
process PREPARE_GENOME {
    label 'process_low'
    conda (params.enable_conda ? "conda-forge::sed=4.7 bioconda::bowtie=1.3.1" : null)

    input:
    file genome_fasta

    script:
    """
    # parsing reference
    sed '/^[^>]/s/[^ATGCatgc]/N/g' $genome_fasta > genome.edited.fa
    sed 's/ .*//' genome.edited.fa > genome.edited.nowhite.fa

    # build bowtie indices
    bowtie-build genome.edited.fa genome --threads ${task.cpus}
    """
    output:
    path ('*.edited.fa'), emit: edited 
    path ('*nowhite.fa'), emit: nowhite
    path ('*.ebwt'), emit: indices
}

// Process and filter miRBase referecnes. 
process PREPARE_MIRBASE_TARGET {
    label 'process_low'
    conda (params.enable_conda ? "bioconda::mirdeep2=2.0.1.2" : null)

    input:
    file mature_fasta
    file hairpin_fasta
    val(target_sp)

    script:
    """
    extract_miRNAs.pl $mature_fasta $target_sp > mature_ref.fa
    extract_miRNAs.pl $hairpin_fasta $target_sp > hairpin_ref.fa
    """

    output:
    path ('mature_ref.fa')      , emit: mature
    path ('hairpin_ref.fa')     , emit: hairpin
}
// Get mature related species from miRBase mature sequences
process PREPARE_MIRBASE_RELATED {
    label 'process_low'
    conda (params.enable_conda ? "bioconda::mirdeep2=2.0.1.2" : null)

    input:
    file mature_fasta
    val(related_sp)

    script:
    """
    extract_miRNAs.pl $mature_fasta $related_sp > mature_related_ref.fa
    """

    output:
    path ('*_related_ref.fa')   , emit: related
}
