//
// microRNA analysis with miRDeep2
//

/*
========================================================================================
    IMPORT LOCAL MODULES
========================================================================================
*/
include { GUNZIP as GUNZIP_FASTA }  from '../../modules/nf-core/modules/gunzip/main'
include { CONFIG_FILE }             from '../../modules/local/config_file/main'
include { MAPPER }                  from '../../modules/local/mapper/main'
include { MIRDEEP2 }                from '../../modules/local/mirdeep2/main'
include { NOVEL_MIRNAS }            from '../../modules/local/novel_mirnas/main'
include { QUANTIFY_THEMALL }            from '../../modules/local/quantify_themall/main'
/*
========================================================================================
    RUN MAIN SUBWORKFLOW
========================================================================================
*/
workflow MIRDEEP {
    take:
    ch_mirdeep_input
    ch_genome_indices
    ch_genome_nowhite
    ch_mirbase_mature
    ch_mirbase_related
    ch_mirbase_hairpin

    main:
    ch_versions = Channel.empty()

    // MODULE: CONFIG FILE - build a miRDeep2 configuration file
    CONFIG_FILE ( ch_mirdeep_input.collect() )
    ch_config_input = CONFIG_FILE.out.file

    // MODULE: MAPPER
    MAPPER ( 
        ch_config_input,
        ch_genome_indices.collect()
        )
    ch_mapper_collapsed = MAPPER.out.collapsed_reads
    ch_mapper_arf       = MAPPER.out.reads_vs_genome

    // MODULE: MIRDEEP2
    MIRDEEP2 (
        ch_mapper_collapsed,
        ch_genome_nowhite,
        ch_mapper_arf,
        ch_mirbase_mature,
        ch_mirbase_related,
        ch_mirbase_hairpin       
    )
    // MODULE: Novel microRNAs processing
    NOVEL_MIRNAS ( 
        MIRDEEP2.out.toNovelproc,
        ch_mirbase_mature,
        ch_mirbase_hairpin
    )
    ch_mature_plusDenovo  = NOVEL_MIRNAS.out.matureRef_plusDenovo
    ch_hairpin_plusDenovo = NOVEL_MIRNAS.out.hairpinRef_plusDenovo

    // MODULE: Known and Novel microRNA quantification
    QUANTIFY_THEMALL (
        ch_mature_plusDenovo,
        ch_hairpin_plusDenovo,
        ch_mapper_collapsed
    )
    ch_expression_matrix = QUANTIFY_THEMALL.out.mirnas_expMat

    // Versions
    ch_versions = ch_versions.mix( CONFIG_FILE.out.versions )
//    ch_versions = ch_versions.mix( MAPPER.out.versions )
    ch_versions = ch_versions.mix( MIRDEEP2.out.versions )
    ch_versions = ch_versions.mix( NOVEL_MIRNAS.out.versions )
    ch_versions = ch_versions.mix( QUANTIFY_THEMALL.out.versions )



    emit:
    versions            = ch_versions
    config_input        = ch_config_input
    collapsed_reads     = ch_mapper_collapsed
    arf                 = ch_mapper_arf
    mature_plusDenovo   = ch_mature_plusDenovo
    hairpin_plusDenovo  = ch_hairpin_plusDenovo
    mirnas_expMat       = ch_expression_matrix
}