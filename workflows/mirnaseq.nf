/*
========================================================================================
    VALIDATE INPUTS
========================================================================================
*/
// Check mandatory parameters
if ( params.input ) { raw_input = Channel.fromPath( params.input ) } else { exit 1, 'Input fastqc files not defined!' }

/*
========================================================================================
    CONFIG FILES
========================================================================================
*/
// Stage multiqc files
// Check if genome exists in the config file
if ( params.genomes && params.genome && !params.genomes.containsKey(params.genome) ) { exit 1, "The provided genome '${params.genome}' is not available in the iGenomes file. Currently the available genomes are ${params.genomes.keySet().join(', ')}" }
ch_multiqc_config = file("$projectDir/assets/multiqc_config.yaml", checkIfExists: true)
ch_multiqc_custom_config = params.multiqc_config ? Channel.fromPath(params.multiqc_config, checkIfExists: true) : Channel.empty()

// Stage reference files
if ( params.genome_file ){
    //params.fasta = Channel.from(params.genome_file, checkIfExists: true)
    params.fasta = params.genome_file
    
}else{
    params.fasta = params.genome ? params.genomes[ params.genome ].fasta ?: false : false
}
if ( !params.fasta )   { exit 1, "Reference genome Fasta file not found: ${params.fasta}" }
if ( !params.mature )  { exit 1, "Mature miRNA fasta file not found: ${params.mature}" }
if ( !params.hairpin ) { exit 1, "Hairpin miRNA fasta file not found: ${params.hairpin}" }

/*
========================================================================================
    IMPORT LOCAL MODULES/SUBWORKFLOWS
========================================================================================
*/
include { PREPARE_REFERENCES            } from '../subworkflows/local/prepare_references'
include { BOWTIE_BUILD_CUSTOM           } from '../modules/local/bowtie_build_custom/main'
include { MIRDEEP                       } from '../subworkflows/local/mirdeep'
include { STATS_SUMMARY                 } from '../modules/local/stats_summary/main'

/*
========================================================================================
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
========================================================================================
*/
include { INPUT_CHECK                   } from '../subworkflows/local/input_check'
include { FASTQC                        } from '../modules/nf-core/fastqc/main'
include { TRIMGALORE                    } from '../modules/nf-core/trimgalore/main'
include { MULTIQC                       } from '../modules/nf-core/multiqc/main'
include { CUSTOM_DUMPSOFTWAREVERSIONS   } from '../modules/nf-core/custom/dumpsoftwareversions/main'

/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/
// Info required for completion email and summary
// def multiqc_report = []

workflow MIRNASEQ {

    ch_versions         = Channel.empty()
    ch_multiqc_files    = Channel.empty()
    ch_multiqc_files    = ch_multiqc_files.mix(Channel.from(ch_multiqc_config))
    ch_multiqc_files    = ch_multiqc_files.mix(ch_multiqc_custom_config.collect().ifEmpty([]))
    
    //
    // SUBWORKFLOW: Read samplesheet, validate and stage input files
    //
    INPUT_CHECK (
        raw_input
        )
    ch_versions = ch_versions.mix( INPUT_CHECK.out.versions )
    reads       = INPUT_CHECK.out.reads

    //
    // SUBWORKFLOW: PREPARE REFERENCE FILES (GENOME & MIRBASE)
    //
/*
    PREPARE_REFERENCES ()
    ch_genome_edited    = PREPARE_REFERENCES.out.genome_edited
    ch_genome_nowhite   = PREPARE_REFERENCES.out.genome_nowhite
    ch_mirbase_mature   = PREPARE_REFERENCES.out.mature
    ch_mirbase_hairpin  = PREPARE_REFERENCES.out.hairpin
    ch_mirbase_related  = PREPARE_REFERENCES.out.related
    ch_versions         = ch_versions.mix(PREPARE_REFERENCES.out.versions)

    //
    // MODULE: BUILD GENOME INDEX
    //

    // Get indices if required
// <--! IVI TODO: bowtie-build takes so long to be completed in HPC. Seems that some parameters should be adjusted -->
    if ( params.bt_indices ) {
        ch_genome_indices = Channel.fromPath( params.bt_indices )
    } else {
        BOWTIE_BUILD_CUSTOM ( ch_genome_edited )
        ch_genome_indices   = BOWTIE_BUILD_CUSTOM.out.index
        ch_versions         = ch_versions.mix( BOWTIE_BUILD_CUSTOM.out.versions ) 
    }
*/
    //
    // MODULE: Run FastQC
    //
    FASTQC (
        reads
        )
    ch_versions             = ch_versions.mix(FASTQC.out.versions)

    //
    // MODULE: Adapter trimming with TRIMGALORE
    //
    TRIMGALORE ( 
        reads
        )
    ch_multiqc_files    = ch_multiqc_files.mix(TRIMGALORE.out.log.collect{it[1]})
    ch_multiqc_files    = ch_multiqc_files.mix(TRIMGALORE.out.html.collect{it[1]})
    ch_multiqc_files    = ch_multiqc_files.mix(TRIMGALORE.out.zip.collect{it[1]})
    ch_versions         = ch_versions.mix(TRIMGALORE.out.versions)
    
    //
    // MODULE: Run MULTIQC
    //
    MULTIQC ( 
        ch_multiqc_files.collect()
        )
    ch_versions = ch_versions.mix( MULTIQC.out.versions )
/*    
    //
    // SUBWORKFLOW: MIRNASEQ ANALYSIS WITH MIRDEEP
    //
    MIRDEEP ( 
        TRIMGALORE.out.reads,   // [val, path]
        ch_genome_indices,      // [path]
        ch_genome_nowhite,      // [path]
        ch_mirbase_mature,      // [path]
        ch_mirbase_related,     // [path]
        ch_mirbase_hairpin      // [path]
        )
    ch_versions = ch_versions.mix(MIRDEEP.out.versions)

    //
    // MODULE: Unify program versions
    //
    STATS_SUMMARY(
        MULTIQC.out.data,
        MIRDEEP.out.samples,
        MIRDEEP.out.mapper_stats
    )

    //
    // MODULE: Unify program versions
    //
    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
        )
*/
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
