#!/bin/bash
#$ -cwd
#$ -l high.c
####$ -l ram.c=7.5G,h_rt=03:00:00
#$ -pe pe_slots 8
#


module load bbtools
module load pigz

# /global/dna/shared/data/functests/assembly/Metagenome/Natalia_mock/for_metaquast
REFERENCES="/global/projectb/scratch/arrivers/kmercoverage/refs/*"
READS=$1

FRAC=(0.000 0.483293024 0.695192796 1.000000000)

basefilename=`basename $READS .fastq.gz`
#cat $REFERENCES | bbmap.sh ref=stdin.fasta


				samp=$(echo ${FRAC[$SGE_TASK_ID]} | bc)
 				bbmap.sh in=$READS samplerate=$samp usejni=t pigz=t threads=8 covhist=${basefilename}.${FRAC[$SGE_TASK_ID]}.$counter.cov.txt ambiguous=random

	
