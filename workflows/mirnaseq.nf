/*
========================================================================================
    VALIDATE INPUTS
========================================================================================
*/
// Check mandatory parameters
if (params.input) { raw_input = Channel.fromPath(params.input) } else { exit 1, 'Input fastqc files not specified!' }

/*
========================================================================================
    CONFIG FILES
========================================================================================
*/
//ch_multiqc_config = file("$projectDir/assets/multiqc_config.yaml", checkIfExists: true)
//ch_multiqc_custom_config = params.multiqc_config ? Channel.fromPath(params.multiqc_config, checkIfExists: true) : Channel.empty()

/*
========================================================================================
    IMPORT LOCAL MODULES/SUBWORKFLOWS
========================================================================================
========================================================================================
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
========================================================================================
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { FASTQC                      } from '../modules/local/fastqc/main'
include { TRIM_GALORE                      } from '../modules/local/trim_galore/main'
include { MULTIQC                      } from '../modules/local/multiqc/main'

/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

// Info required for completion email and summary
// def multiqc_report = []

workflow MIRNASEQ {

    ch_versions = Channel.empty()

    //
    // (FIX)SUBWORKFLOW: Read in samplesheet, validate and stage input files
    //

    //
    // MODULE: Run FastQC
    //
    FASTQC (
        raw_input
    )

    //
    // MODULE: Run TRIM GALORE
    //
    TRIM_GALORE (
        raw_input
    )

    //
    // MODULE: Run MULTIQC
    //

    MULTIQC (
        TRIM_GALORE.out.zip.collect()
    )

    

}
/*
========================================================================================
    COMPLETION EMAIL AND SUMMARY
========================================================================================
*/

/*
========================================================================================
    THE END
========================================================================================
*/
