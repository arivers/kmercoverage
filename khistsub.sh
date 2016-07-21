#!/bin/bash 
#$ -l ram.c=15.5G,h_rt=02:00:00
#$ -cwd
#$ -pe pe_slots 16
#$ -m e -M arrivers@lbl.gov

module load bbtools

# file to select
input=$(head -n $SGE_TASK_ID $1 | tail -n 1)
#name of kmer histogram file
outfile=`basename $input .fastq.gz`".hist.txt"

#attempt exact count if that fails attempt approximate count

kmercountexact.sh threads=16 in=$input khist=k31counts/$outfile || (khist.sh threads=16 histcol=2 in=$input hist=k31counts/$outfile)
