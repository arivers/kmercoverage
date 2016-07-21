#!/bin/bash 
#$ -l ram.c=5G,h_rt=12:00:00
#$ -cwd
#$ -m e -M arrivers@lbl.gov

PATH=$PATH:~/lib/sratoolkit.2.7.0-centos_linux64/bin/

#Retrieve data used in Nonpariel

#Biosample SRS019087 Human anterior nares
time fastq-dump -A SRR062436 --gzip

#Biosample SRS019087 Human buccal mucosa
time fastq-dump -A SRR062429 --gzip

#Biosample SRS016335  Human stool
time fastq-dump -A SRR061157 --gzip

#biosample SRS015574 supragingival
time fastq-dump -A SRR062519 --gzip

#biosample SRS062540 Tounge Dorsum
time fastq-dump -A SRR346700 --gzip

#biosample SRS063417 Posterior fornix
time fastq-dump -A SRR061189 --gzip

#biosample SRP028408 Lake Lanier LL_1007B 
time fastq-dump -A SRR948155 --gzip

#biosample SRA029309.1 Lake Lanier LL_S1 
time fastq-dump -A SRR096386 --gzip

#biosample SRA029314.1  Lake Lanier LL_S2
time fastq-dump -A SRR096387 --gzip

#Biosample SRS345600 Permafrost layer day 2
time fastq-dump -A SRR512766 --gzip

#Biosample SRS345554 Active layer day 2
time fastq-dump SRR512581 --gzip

# Biosample PE6 Manu Park (Peru) Tropical Forest (downloaded manually)
# http://api.metagenomics.anl.gov/1/download/mgm4447943.3

#the paper did no provide enough information to identify the two samples 
# from Richmond Mine C751107 and C751107 1% so they were omitted