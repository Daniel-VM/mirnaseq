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

    emit:
    versions            = ch_versions
    config_input        = ch_config_input
    collapsed_reads     = ch_mapper_collapsed
    arf                 = ch_mapper_arf
}