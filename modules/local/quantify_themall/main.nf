process QUANTIFY_THEMALL {
    label 'process_highLong'

    conda (params.enable_conda ? "bioconda::mirdeep2=2.0.1.2" : null )
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mirdeep2:2.0.1.2--0' :
        'quay.io/biocontainers/mirdeep2:2.0.1.2--0' }"

    input:
    file maure_ref_plusDenovo
    file hairpin_ref_plusDenovo
    file collapsed_reads

    output:
    path ('*.csv')          , emit: mirnas_expMat
    path ('*pdf*')          , emit: pdfs
    path ('versions.yml')   , emit: versions
    
    script:
    def args = task.ext.args ?: ''
    """
    DATE=`date +"%Y%m%d_%H%M"`
    quantifier.pl \\
        $args \\
        -p $hairpin_ref_plusDenovo \\
        -m $maure_ref_plusDenovo \\
        -r $collapsed_reads \\
        -y \$DATE

    # Versions
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        miRDeep2: \$( miRDeep2.pl -h | grep '[0-9].[0-9].[0-9].[0-9]' | head -n1 | tr -cd '[[:digit:]].' )
    END_VERSIONS
    """
}