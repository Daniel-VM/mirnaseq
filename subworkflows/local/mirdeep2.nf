//
// microRNA analysis with miRDeep2
//

/*
========================================================================================
    IMPORT LOCAL MODULES
========================================================================================
*/
include { CONFIG_FILE } from '../../modules/local/config_file/main'


workflow MIRDEEP2 {
    take:
    ch_mirdeep_input

    main:
    ch_versions = Channel.empty()

    // MODULE: CONFIG FILE - build a miRDeep2 configuration file
    CONFIG_FILE ( ch_mirdeep_input.collect() )
    ch_config_input = Channel.from(CONFIG_FILE.out.file)


    emit:
    versions        = ch_versions
    config_input    = ch_config_input

}