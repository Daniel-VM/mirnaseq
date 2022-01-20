#!/usr/bin/env nextflow
/*
========================================================================================
    nf-core/mirnaseq
========================================================================================
    Github : https://github.com/nf-core/mirnaseq
    Website: https://nf-co.re/mirnaseq
    Slack  : https://nfcore.slack.com/channels/mirnaseq
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
========================================================================================
    GENOME PARAMETER VALUES
========================================================================================
*/

params.fasta = WorkflowMain.getGenomeAttribute(params, 'fasta')

/*
========================================================================================
    VALIDATE & PRINT PARAMETER SUMMARY
========================================================================================
*/

WorkflowMain.initialise(workflow, params, log)

/*
========================================================================================
    NAMED WORKFLOW FOR PIPELINE
========================================================================================
*/

include { MIRNASEQ } from './workflows/mirnaseq'

//
// WORKFLOW: Run main nf-core/mirnaseq analysis pipeline
//
workflow NFCORE_MIRNASEQ {
    MIRNASEQ ()
}

/*
========================================================================================
    RUN ALL WORKFLOWS
========================================================================================
*/

//
// WORKFLOW: Execute a single named workflow for the pipeline
// See: https://github.com/nf-core/rnaseq/issues/619
//
workflow {
    NFCORE_MIRNASEQ ()
}

/*
========================================================================================
    THE END
========================================================================================
*/
