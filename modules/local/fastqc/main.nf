process FASTQC {
    label 'process_low'
    conda (params.enable_conda ? "bioconda::fastqc=0.11.9" : null)

    input:
    file reads

    output:
    //path("*_fastqc.{zip,html}"), emit: fastqc_results
    path('*_fastqc.{zip,html}'), emit: fastqc_results
    
    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${reads.getSimpleName()}"// Add soft-links to original FastQs for consistent naming in pipeline
    
    """
    fastqc $args --threads $task.cpus ${prefix}.fastq.gz
    """
}

 