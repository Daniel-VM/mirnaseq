process TRIM_GALORE {
    label 'process_low'
    conda (params.enable_conda ? "bioconda::trim-galore=0.6.7" : null)

    input:
    file reads

    output:
    path('*.gz'), emit: reads
    path('*trimming_report.txt'), emit: trimgalore_results
    path("*_fastqc.{zip,html}"), emit: trimgalore_fastqc_reports

    script: 
    """
    trim_galore --adapter ${params.three_prime_adapter} \
                --length ${params.min_length} \
                --max_length ${params.max_length} \
                --quality ${params.quality_cutoff} \
                --gzip $reads --fastqc
    """
}