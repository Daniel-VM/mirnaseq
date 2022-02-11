#!/bin/bash

# Parsing novel miRNAs identified with mirdeep2.pl as reference sequences.
# Goal: Filtering out novel mirnas predicted by miRDeep and make them accessible for quantification.
#
# Steps:
#       1- Isolation/filtering of novel miRNAs from mirdeep2.pl output. 
#       2- Build a multifasta file by extracting both novel miRNA ID, mature and precursor sequences. 
#       3- RNA to DNA conversion
#       4- Concatenate: miRBase references (mature or precursors) + novel miRNA sequences (mature or precursror)
# 
# Thus, not only mature and known sequences will be quantified but also novel microRNAs.

# PARSING ARGUMENTS

POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--input)
            MIRDEEP_TAB="$2"
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

# STEP 1 - DENOVO PREDICTED MIRNAS
#   Filteirng miRNA_denovo matrix from the mirdeep2.pl output, and remove non-essential tables
#   Only those miRNAs that fulfill the following criteria will be save for subsequent analysis (Bonnet E et. al. 2004):
#       (1) A miRDeep2 score cut-off of >4;
#       (2) An estimated probability that the miRNA candidate is a true positive > 0;
#       (3) The total read counts of the predicted mature are >100;
#       (4) A significant randfold p-value of the excised potential miRNA hairpin.
cat $MIRDEEP_TAB | \
	 	sed -n '/novel miRNAs predicted by miRDeep2/,$p' | \
        sed '/mature miRBase miRNAs detected by miRDeep2/,$d' | \
        head -n -3 | \
        sed '1d' | \
        awk -F"\t" '($2>4) && ($5 > 100) && ($9=="yes")' | \
        awk -F"\t"  '! ( $3 ~ /^0/)' > denovo_miRNAs_filtered.txt

# STEP 2 - CONVERTING MIRDEEP DENOVO SEQUENCES INTO MULTIFASA FILE
# mature
while read m; do
	NID_MATURE="$(echo "${m}" | cut -f1)"
	NSEQ_MATURE="$(echo "${m}" | cut -f14)"
	echo ">hsa-${NID_MATURE}"
	printf '%s\n' "${NSEQ_MATURE}" | awk '{print toupper($0)}'
done < denovo_miRNAs_filtered.txt > mature_de_novo.fa

# hairpin/precursor
while read p; do
    NID_PRECURSOR="$(echo "${p}" | cut -f1)"
    NSEQ_PRECURSOR="$(echo "${p}" | cut -f16)"
    echo ">hsa-${NID_PRECURSOR}"
    printf '%s\n' "${NSEQ_PRECURSOR}" | awk '{print toupper($0)}'
done < denovo_miRNAs_filtered.txt > precursor_de_novo.fa

# STEP 3 -  CONVERT ARN SEQUENCES INTO DNA ACCORDING TO MIRDEEP2 BEST PRACTICES
rna2dna.pl mature_de_novo.fa > DNA_mature_de_novo.fa
rna2dna.pl precursor_de_novo.fa > DNA_precursor_de_novo.fa

# STEP 4 - CONCATENATE ORIGINAL REFERENCE SEQUENCES WITH NEW DE_NOVO SEQS (DNA format)
cat $MIRBASE_MATURE DNA_mature_de_novo.fa > mature_ref_plusDenovo.fa
cat $MIRBASE_PRECURSOR DNA_precursor_de_novo.fa > hairpin_ref_plusDenovo.fa
