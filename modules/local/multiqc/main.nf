process MULTIQC {
    label 'process_low'
    conda (params.enable_conda ? "bioconda::multiqc=1.11" : null)

    input:
    path multiqc_files

    output:
    path "*multiqc_report.html", emit: report
    path "*_data"              , emit: data
    path "*_plots"             , optional:true, emit: plots
    path "versions.yml"        , emit: versions

    script:
    def args = task.ext.args ?: ''
    def custom_config = params.multiqc_config ? "--config $multiqc_custom_config" : ''

    """
    multiqc -f $args .

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        multiqc: \$( multiqc --version | sed -e "s/multiqc, version //g" )
    END_VERSIONS
    """
}

process MULTIQC_ONRAW {
    label 'process_low'
    conda (params.enable_conda ? "bioconda::multiqc=1.11" : null)

    input:
    path multiqc_files

    output:
    path "*multiqc_report.html", emit: report
    path "*_data"              , emit: data
    path "*_plots"             , optional:true, emit: plots

    script:
    def args = task.ext.args ?: ''
    //def custom_config = params.multiqc_config ? "--config $multiqc_custom_config" : ''

    """
    multiqc -f $args .
    """
}