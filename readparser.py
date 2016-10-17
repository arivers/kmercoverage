#/env/bin/python
import argparse
import os
import re

parser = argparse.ArgumentParser(description='parse out coverage from bbtools kmer counting logs')
parser.add_argument('--input', help="the input direcory containing log files", default = "logs_k31count_20160721")
parser.add_argument('--out', help="the output report file", type=argparse.FileType('w'), default = '-')
args = parser.parse_args()
    
abspath=os.path.abspath(args.input)
args.out.write("name" + "\t" + "reads" + "\t" + "bases" + "\t" + "unique kmers" + "\n")
for file in os.listdir(abspath):
	with open(os.path.join(abspath,file), 'r') as file:
		for line in file:
			nameline = re.search("khist",line)
			if nameline:
				name = nameline.string.split()[3][3:-1]
				continue
			else:
				inputline = re.search("Input", line)
				if inputline:
					reads = inputline.string.split()[1]
					bases = inputline.string.split()[3]
					continue
				else:
					uniqueline = re.search("Unique Kmers:",line)
					if uniqueline:
						unique = uniqueline.string.split()[2]
						break
		args.out.write(name + "\t" + reads + "\t" + bases + "\t" + unique + "\n")
		
