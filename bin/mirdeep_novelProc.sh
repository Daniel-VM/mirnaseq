#!/bin/bash

# Parsing novel miRNAs identified with mirdeep2.pl as reference sequences.
# Goal: Add novel microRNA sequences to reference files (mature.fa & hairpin.fa) thus making them accessible for quantification.
#
# Steps:
#       1- Build a multifasta file by extracting novel sequences. 
#       2- RNA to DNA conversion
#       3- Concatenate: miRBase references (mature or precursors) + novel miRNA sequences (mature or precursror)
# 

# PARSING ARGUMENTS

POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--input)
            NOVEL_TAB="$2"
            shift # past argument
            shift # past value
            ;;
        -m|--mature)
            MIRBASE_MATURE="$2"
            shift # past argument
            shift # past value
            ;;
        -p|--precursor)
            MIRBASE_PRECURSOR="$2"
            shift # past argument
            shift # past value
            ;;
        -*|--*)
            echo "Unknown option $1"
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1") # save positional arg
            shift # past argument
            ;;
    esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

# STEP 1 - CONVERTING MIRDEEP DENOVO SEQUENCES INTO MULTIFASA FILE
# mature
while read m; do
	NID_MATURE="$(echo "${m}" | cut -f1)"
	NSEQ_MATURE="$(echo "${m}" | cut -f14)"
	echo ">hsa-${NID_MATURE}"
	printf '%s\n' "${NSEQ_MATURE}" | awk '{print toupper($0)}'
done < $NOVEL_TAB > mature_de_novo.fa

# hairpin/precursor
while read p; do
    NID_PRECURSOR="$(echo "${p}" | cut -f1)"
    NSEQ_PRECURSOR="$(echo "${p}" | cut -f16)"
    echo ">hsa-${NID_PRECURSOR}"
    printf '%s\n' "${NSEQ_PRECURSOR}" | awk '{print toupper($0)}'
done < $NOVEL_TAB > precursor_de_novo.fa

# STEP 2 -  CONVERT ARN SEQUENCES INTO DNA ACCORDING TO MIRDEEP2 BEST PRACTICES
rna2dna.pl mature_de_novo.fa > DNA_mature_de_novo.fa
rna2dna.pl precursor_de_novo.fa > DNA_precursor_de_novo.fa

# STEP 3 - CONCATENATE ORIGINAL REFERENCE SEQUENCES WITH NEW DE_NOVO SEQS (DNA format)
cat $MIRBASE_MATURE DNA_mature_de_novo.fa > mature_ref_plusDenovo.fa
cat $MIRBASE_PRECURSOR DNA_precursor_de_novo.fa > hairpin_ref_plusDenovo.fa
