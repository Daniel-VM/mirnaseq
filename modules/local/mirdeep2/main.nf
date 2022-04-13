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
    if(params.denovo_filter == true){
    /*
    Filteirng novel microRNAS in the mirdeep2.pl output
        Only those miRNAs that fulfill the following criteria will be saved for downstream analysis (Bonnet E et. al. 2004):
        (1) A miRDeep2 score cut-off of >4;
        (2) An estimated probability that the miRNA candidate is a true positive > 0;
        (3) The total read counts of the predicted mature are >100;
        (4) A significant randfold p-value of the excised potential miRNA hairpin.
    */
        """
        cat $MIRDEEP_TAB | \
            sed -n '/novel miRNAs predicted by miRDeep2/,\$p' | \
            sed '/mature miRBase miRNAs detected by miRDeep2/,\$d' | \
            head -n -3 | \
            sed '1d' | \
            awk -F"\t" '(\$2>4) && (\$5 > 100) && (\$9=="yes")' | \
            awk -F"\t"  '! ( \$3 ~ /^0/)' > denovo_miRNAs_filtered.tsv
        """
    }else if(params.denovo_filter == false){
        """
        cat $MIRDEEP_TAB | \
            sed -n '/novel miRNAs predicted by miRDeep2/,\$p' | \
            sed '/mature miRBase miRNAs detected by miRDeep2/,\$d' | \
            head -n -3 | \
            sed '1d' > denovo_miRNAs_filtered.tsv
        """
    } else {
        exit 1, "Invalid '${params.denovo_filter}' value. Set --denovo_filter true or --denovo_filter false"
    }
    """
    mirdeep_novelProc.sh -i denovo_miRNAs_filtered.tsv -m $mature -p $hairpin

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        miRDeep2: \$( miRDeep2.pl -h | sed -nE '/^# miRDeep[0-9].[0-9].[0-9].[0-9]/p' |  tr -cd '[[:digit:]].' )
    END_VERSIONS 
    """
}