#!bin/bash
#$ -cwd
#$-l ram.c=7.5G,h_rt=01:00:00
#$ -pe pe_slots 16


module load bbtools
module load pigz


REFERENCES=$2
READS=$1
reps=10
#frac=(0.01 0.03 0.1 0.1 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0)
#frac=( 0.001000000 0.002154435 0.004641589 0.010000000 0.021544347 0.046415888 0.100000000 0.215443469 0.464158883 1.000000000)
FRAC=(0.001000000 0.001438450 0.002069138 0.002976351 0.004281332 0.006158482 0.008858668 0.012742750 0.018329807 0.026366509 0.037926902 0.054555948 0.078475997 0.112883789 0.162377674 0.233572147 0.335981829 0.483293024 0.695192796 1.000000000)
$basefilename=`basename $READS .fastq.gz`
bbmap.sh ref=$REFERENCES

for i in "${frac[@]}"
	do 
		counter=0
		while  [ $counter -lt $reps ]
			do
 				bbmap.sh in=$READS samplerate=$FRAC[i] usejni=t pigz=t threads=16 covhist=${basefilename}.${frac[i]}.$counter.cov.txt ambiguous=random
 				counter=$((counter + 1))
			done
	done		