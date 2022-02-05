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


workflow MIRDEEP2 {
    take:
    ch_mirdeep_input
    ch_genome_indices

    main:
    ch_versions = Channel.empty()
    // Uncompress processed reads
    ch_mirdeep_input = GUNZIP_FASTA ( [ [:], ch_mirdeep_input ] ).gunzip.map { it[1] }
//    ch_mirdeep_input = ch_mirdeep_input.toSortedList()

    // MODULE: CONFIG FILE - build a miRDeep2 configuration file
    CONFIG_FILE ( ch_mirdeep_input.collect() )
    ch_config_input = Channel.from(CONFIG_FILE.out.file)

    // MODULE: MAPPER
    MAPPER ( 
        ch_config_input,
        ch_genome_indices
         )
    ch_mapper = MAPPER.out.reads_collapsed


    emit:
    versions        = ch_versions
    config_input    = ch_config_input
    mapper          = ch_mapper

}