process QUANTIFY_THEMALL {
    label 'process_low'
    label 'process_long'
    conda (params.enable_conda ? "bioconda::mirdeep2=2.0.1.2" : null )

    input:
    file maure_ref_plusDenovo
    file hairpin_ref_plusDenovo
    file collapsed_reads

    output:
    path ('*.csv')    , emit: mirnas_expMat
    path ('*pdf*')          , emit: pdfs
    path ('versions.yml')   , emit: versions
    
    script:
    """
    DATE=`date +"%Y%m%d_%H%M"`
    quantifier.pl -p $hairpin_ref_plusDenovo \\
        -m $maure_ref_plusDenovo \\
        -r $collapsed_reads \\
        -y \$DATE

    # Versions
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        miRDeep2: \$( miRDeep2.pl -h | sed -nE '/^# miRDeep[0-9].[0-9].[0-9].[0-9]/p' |  tr -cd '[[:digit:]].' )
    END_VERSIONS
    """
}