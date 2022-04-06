process MIRDEEP2 {
    label 'process_low'
    label 'process_long'
    conda (params.enable_conda ? "bioconda::mirdeep2=2.0.1.2" : null )

    input:
    file collapsed_reads
    file genome
    file reads_vs_genome
    file mature
    file mature_related
    file hairpin

    output:
    path ('result*.{bed,html}')     , emit: res_format
    path ('result*.csv')            , emit: toNovelproc
    path ('versions.yml')           , emit: versions
    
    script:
    if( params.related_sp){
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
    } else {
        """
        miRDeep2.pl $collapsed_reads \\
                    $genome \\
                    $reads_vs_genome \\
                    $mature \\
                    none \\
                    $hairpin \\
                    -q miRBase.mrd
                    
        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            miRDeep2: \$( miRDeep2.pl -h | sed -nE '/^# miRDeep[0-9].[0-9].[0-9].[0-9]/p' |  tr -cd '[[:digit:]].' )
        END_VERSIONS 
        """
        }
}

process NOVEL_MIRNAS {
    label 'prcoess_low'
    conda ( params.enable_conda ? "conda-forge::sed=4.8 bioconda::mirdeep2=2.0.1.2" : null)

    input:
    file mirdeep_tab
    file mature
    file hairpin

    output:
    path ('mature_ref_plusDenovo.fa')   , emit: matureRef_plusDenovo
    path ('hairpin_ref_plusDenovo.fa')  , emit: hairpinRef_plusDenovo
    path ('versions.yml')               , emit: versions

    script:
    """
    mirdeep_novelProc.sh -i $mirdeep_tab -m $mature -p $hairpin

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        miRDeep2: \$( miRDeep2.pl -h | sed -nE '/^# miRDeep[0-9].[0-9].[0-9].[0-9]/p' |  tr -cd '[[:digit:]].' )
    END_VERSIONS 
    """
}