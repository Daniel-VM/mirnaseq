// Parsing reference genome
process PREPARE_GENOME {
    label 'process_low'
    conda (params.enable_conda ? "conda-forge::sed=4.7" : null)

    input:
    file genome_fasta

    output:
    path ('*.edited.fa')    , emit: edited 
    path ('*.nowhite.fa')   , emit: nowhite
    path ("versions.yml")   , emit: versions

    script:
    """
    # parsing reference
    sed '/^[^>]/s/[^ATGCatgc]/N/g' $genome_fasta > genome.edited.fa
    sed 's/ .*//' genome.edited.fa > genome.edited.nowhite.fa
    
    # version
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sed: \$( sed --version | head -n 1 | awk '{print \$NF}')
    END_VERSIONS
    """
}

// Build indices with bowtie
process INDICES {
    label 'process_low'
    conda (params.enable_conda ? "bioconda::bowtie=1.3.1" : null)

    input:
    file genome_fasta

    output:
    path ('*.ebwt')         , emit: indices
    path ("versions.yml")   , emit: versions

    script:
    """
    # build bowtie indices
        bowtie-build $genome_fasta genome --threads ${task.cpus}

    # version
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bowtie: \$( bowtie --version | head -n 1 | awk '{print \$NF}' )
    END_VERSIONS
    """
}

// Process and filter miRBase referecnes. 
process PREPARE_MIRBASE_TARGET {
    label 'process_low'
    conda (params.enable_conda ? "bioconda::mirdeep2=2.0.1.2" : null)

    input:
    file mature_fasta
    file hairpin_fasta
    val(target_sp)

    output:
    path ('mature_ref.fa')      , emit: mature
    path ('hairpin_ref.fa')     , emit: hairpin  
    path ("versions.yml")       , emit: versions

    script:
    """
    extract_miRNAs.pl $mature_fasta $target_sp > mature_ref.fa
    extract_miRNAs.pl $hairpin_fasta $target_sp > hairpin_ref.fa

    # Version
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        miRDeep2: \$( miRDeep2.pl -h | sed -nE '/^# miRDeep[0-9].[0-9].[0-9].[0-9]/p' |  tr -cd '[[:digit:]].' )
    END_VERSIONS
    """
}

// Get mature related species from miRBase mature sequences
process PREPARE_MIRBASE_RELATED {
    label 'process_low'
    conda (params.enable_conda ? "bioconda::mirdeep2=2.0.1.2" : null)

    input:
    file mature_fasta
    val(related_sp)

    output:
    path ('*_related_ref.fa')   , emit: related
    
    script:
    """
    extract_miRNAs.pl $mature_fasta $related_sp > mature_related_ref.fa
    """
}
