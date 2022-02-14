/*
========================================================================================
    VALIDATE INPUTS
========================================================================================
*/
// Check mandatory parameters
if ( params.input ) { raw_input = Channel.fromPath( params.input ) } else { exit 1, 'Input fastqc files not specified!' }

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
params.fasta = params.genome ? params.genomes[ params.genome ].fasta ?: false : false
if ( !params.fasta )   { exit 1, "Reference genome Fasta file not found: ${params.fasta}" }
if ( !params.mature )  { exit 1, "Mature miRNA fasta file not found: ${params.mature}" }
if ( !params.hairpin ) { exit 1, "Hairpin miRNA fasta file not found: ${params.hairpin}" }

/*
========================================================================================
    IMPORT LOCAL MODULES/SUBWORKFLOWS
========================================================================================
*/
include { PREPARE_REFERENCES        }   from '../subworkflows/local/prepare_references'
include { MIRDEEP                  }   from '../subworkflows/local/mirdeep'
include { FASTQC                    }   from '../modules/local/fastqc/main'
include { TRIM_GALORE               }   from '../modules/local/trim_galore/main'
include { MULTIQC_ONRAW; MULTIQC    }   from '../modules/local/multiqc/main'
include { GUNZIP_MIRDEEPIN          }   from '../modules/local/gzip_mirdeepin/main'
/*
========================================================================================
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
========================================================================================
*/
include { CUSTOM_DUMPSOFTWAREVERSIONS } from '../modules/nf-core/modules/custom/dumpsoftwareversions/main'
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
    ch_mirdeep_input    = Channel.empty()

    //
    // SUBWORKFLOW: PREPARE REFERENCE FILES (GENOME & MIRBASE)
    PREPARE_REFERENCES ()
    ch_genome_edited    = PREPARE_REFERENCES.out.genome
    ch_genome_nowhite   = PREPARE_REFERENCES.out.genome_nowhite
    ch_genome_indices   = PREPARE_REFERENCES.out.indices
    ch_mirbase_mature   = PREPARE_REFERENCES.out.mature
    ch_mirbase_hairpin  = PREPARE_REFERENCES.out.hairpin
    ch_mirbase_related  = PREPARE_REFERENCES.out.related
    

    //
    // MODULE: Run FastQC
    //
    FASTQC ( raw_input )  
    MULTIQC_ONRAW ( FASTQC.out.reports.collect() )

    //
    // MODULE: Run TRIM GALORE
    //
    TRIM_GALORE ( raw_input )
    
    //
    // MODULE: Run MULTIQC
    //
    ch_multiqc_files = ch_multiqc_files.mix(Channel.from(ch_multiqc_config))
    ch_multiqc_files = ch_multiqc_files.mix(ch_multiqc_custom_config.collect().ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(TRIM_GALORE.out.trim_reports)
    ch_multiqc_files = ch_multiqc_files.mix(TRIM_GALORE.out.fastqc_reports)
    
    MULTIQC ( ch_multiqc_files.collect() )

    //
    // SUBWORKFLOW: microRNA analysis
    //
    GUNZIP_MIRDEEPIN ( TRIM_GALORE.out.zipped_reads )
    ch_mirdeep_input = GUNZIP_MIRDEEPIN.out.unzipped_reads

    MIRDEEP ( 
        ch_mirdeep_input,
        ch_genome_indices,
        ch_genome_nowhite,
        ch_mirbase_mature,
        ch_mirbase_related,
        ch_mirbase_hairpin
        )

    //
    // Program Versions
    //
    ch_versions = ch_versions.mix(PREPARE_REFERENCES.out.versions)
    ch_versions = ch_versions.mix(FASTQC.out.versions)
    ch_versions = ch_versions.mix(MULTIQC.out.versions)
    ch_versions = ch_versions.mix(MIRDEEP.out.versions)

    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
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
