process STATS_SUMMARY {
    label 'process_medium'
    conda (params.enable_conda ? 'conda-forge::python=3.10.0 conda-forge::pandas=1.5.1 conda-forge::matplotlib=3.6.1 conda-forge::more-itertools=8.12.0' : null )
    
    input:
    file multiqc_data
    file mirdeep2_samples
    file mirdeep2_data

    output:
    path "summary_stats.csv", emit: report
    path "percent_reads.png", emit: png
    path "versions.yml"     , emit: versions


    """
    complete_report.py --fastqc ${multiqc_data}/multiqc_fastqc.txt \\
        --cutadapt ${multiqc_data}/multiqc_cutadapt.txt \\
        --mirdeep2_config $mirdeep2_samples \\
        --mirdeep2_mapper $mirdeep2_data
    

    # version
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$( python --version | awk '{print \$2}' )
    END_VERSIONS
    """
}