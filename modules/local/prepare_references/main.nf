process PREPARE_GENOME {
    label 'process_low'
    conda (params.enable_conda ? "conda-forge::sed=4.7" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/sed:4.7.0' :
        'quay.io/biocontainers/sed:4.7.0' }"
        
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


process PREPARE_MICRORNAS {
    label 'process_low'
    
    conda (params.enable_conda ? "bioconda::mirdeep2=2.0.1.2" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mirdeep2:2.0.1.2--0' :
        'quay.io/biocontainers/mirdeep2:2.0.1.2--0' }"

    input:
    file mature_fasta
    file hairpin_fasta
    
    output:
    path ('mature_ref.fa')      , emit: mature
    path ('hairpin_ref.fa')     , emit: hairpin  
    
    script:
    """
    rna2dna.pl $mature_fasta | \
        sed '/[^>]/s/[[:blank:]].*//g' > mature_ref.fa
        
    rna2dna.pl $hairpin_fasta | \
        sed '/[^>]/s/[[:blank:]].*//g' | \
        sed '/^[^>]/s/[^ATGCatgc]/N/g' > hairpin_ref.fa
    """  
}

process PREPARE_MIRBASE_TARGET {
    label 'process_low'

    conda (params.enable_conda ? "bioconda::mirdeep2=2.0.1.2" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mirdeep2:2.0.1.2--0' :
        'quay.io/biocontainers/mirdeep2:2.0.1.2--0' }"

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
    # Filter target microRNAs and convert sequences into DNA format automatically
    extract_miRNAs.pl $mature_fasta $target_sp > mature_ref.fa
    extract_miRNAs.pl $hairpin_fasta $target_sp > hairpin_tmp.fa
    sed '/^[^>]/s/[^ATGCatgc]/N/g' hairpin_tmp.fa > hairpin_ref.fa

    # Version
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        miRDeep2: \$( miRDeep2.pl -h | sed -nE '/^# miRDeep[0-9].[0-9].[0-9].[0-9]/p' |  tr -cd '[[:digit:]].' )
    END_VERSIONS
    """
}

process PREPARE_MIRBASE_RELATED {
    label 'process_low'
    
    conda (params.enable_conda ? "bioconda::mirdeep2=2.0.1.2" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mirdeep2:2.0.1.2--0' :
        'quay.io/biocontainers/mirdeep2:2.0.1.2--0' }"
    
    input:
    file mature_fasta
    val(related_sp)

    output:
    path ('*_related_ref.fa')   , emit: related
    
    script:
    """
    # Filter related microRNAs and convert sequences into DNA format automatically
    extract_miRNAs.pl $mature_fasta $related_sp > mature_related_ref.fa
    """
}
