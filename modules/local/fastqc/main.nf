process FASTQC {
    label 'process_low'
    conda (params.enable_conda ? "bioconda::fastqc=0.11.9" : null)

    input:
    file reads

    output:
    path("*_fastqc.{zip,html}"), emit: reports
    path("versions.yml")  , emit: versions
    
    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${reads.getSimpleName()}"
    
    """
    fastqc $args --threads $task.cpus ${prefix}.fastq.gz
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastqc: \$( fastqc --version | sed -e "s/FastQC v//g" )
    END_VERSIONS
    """
}

 