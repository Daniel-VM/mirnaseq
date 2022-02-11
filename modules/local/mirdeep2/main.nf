process MIRDEEP2 {
    label 'process_low'
    conda (params.enable_conda ? "bioconda::mirdeep2=2.0.1.2" : null )

    input:
    file collapsed_reads
    file genome
    file reads_vs_genome
    file mature
    file mature_related
    file hairpin

    output:
    path ('result*.{bed,html}') , emit: results
    path ('result*.csv')        , emit: results_toNovelext
    path ('versions.yml')       , emit: versions
    
    script:
    """
    miRDeep2.pl $collapsed_reads \\
                $genome \\
	            $reads_vs_genome \\
	            $mature \\
	            $mature_related \\
	            $hairpin \\
	            -q miRBase.mrd

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        miRDeep2: \$( miRDeep2.pl -h | sed -nE '/^# miRDeep[0-9].[0-9].[0-9].[0-9]/p' |  tr -cd '[[:digit:]].' )
    END_VERSIONS 
    """

}