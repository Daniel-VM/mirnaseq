process TRIM_GALORE {
    label 'process_low'
    conda (params.enable_conda ? "bioconda::trim-galore=0.6.7" : null)

    input:
    file reads

    output:
    path('*.gz')                , emit: zipped_reads
    path('*trimming_report.txt'), emit: trim_reports
    path("*_fastqc.{zip,html}") , emit: fastqc_reports
    path "versions.yml"         , emit: versions

    script: 
    """
    trim_galore --adapter ${params.three_prime_adapter} \\
                --length ${params.min_length} \\
                --max_length ${params.max_length} \\
                --quality ${params.quality_cutoff} \\
                --gzip $reads --fastqc
                
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        TrimGalore: \$( trim_galore --version | grep '[0-9].[0-9].[0-9]' | sed -e "s/version//g" | head -n1 )
    END_VERSIONS
    """
}