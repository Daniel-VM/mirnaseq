process GUNZIP_MIRDEEPIN {
    tag "$meta.id"
    label 'process_medium'
    
    conda (params.enable_conda ? "conda-forge::sed=4.7" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/sed:4.7.0' :
        'quay.io/biocontainers/sed:4.7.0' }"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path ('*.{fq,fastq}') , emit: unzipped_reads
    path "versions.yml"                    , emit: versions

    script:
    def args = task.ext.args ?: ''
    archive = reads.toString() - '.gz'
    """
    gunzip \\
        -f \\
        $args \\
        $reads

    
    cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            gunzip: \$( gunzip --version | head -n1 |sed -e "s/gunzip (gzip) //g" )
    END_VERSIONS
    """
}