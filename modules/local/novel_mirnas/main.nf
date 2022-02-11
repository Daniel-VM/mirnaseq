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