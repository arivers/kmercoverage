#!/usr/bin/env python

import argparse
import json
import os
import subprocess
import numpy as np
import pandas as pd
from ggplot import *
import matplotlib.pyplot as plt


## Arguments ##
parser = argparse.ArgumentParser(description='Parse mapping data and kmer prediction data and plot the results')
parser.add_argument('--covdir', help='a directory containing covhist files from bbmap')
parser.add_argument('--bases', help='the number of bases in the fastq file user for creating kmer histogram',type=int)
parser.add_argument('--refbases', help='the number of bases in the reference genome',type=int)
parser.add_argument('--covlevel', nargs='+', help='The depth(s) at which to report coverage >= to',type=int, required=True)
parser.add_argument("--kmerfile", help="two column histogram input", type=str)
parser.add_argument("--plotfile", help="Name (and path) of output plot file, pdf or png", type=str)
args = parser.parse_args()


## Functions ##
def list2rvect(list):

    for i in list:
        vect = vect + str(i)
    vect = vect + ")"
    return vect

# total reference length 3252611882
# total MC04 dta length 22328668534

# initialize pandas dataframe

datadict = []
# Parse bbmap mapping files
for file in os.listdir(args.covdir):
    with open(os.path.join(args.covdir,file), 'r') as handle:
        pct = float(file.split(".")[1]+ "." + file.split(".")[2])
        basessamples = pct * args.bases
        depth = []
        coverage = []
        for line in handle:
            if not line.startswith('#'):
                ln = line.strip().split()
                depth.append(int(ln[0]))
                coverage.append(int(ln[1]))      
        for i in args.covlevel: 
            covnum = sum(coverage[i:])
            covprop = float(covnum)/float(args.refbases)
            datarow = {"Type":"mapped","CoverageDepth" :int(i),"BasesOfData":basessamples,"BasesCovered":covnum, "ProportionCoveredAtDepth":covprop}
            datadict.append(datarow)

# add mapping data to dataframe
df1 = pd.DataFrame(datadict)

# convert coverage list to string 
strcovlevel = [str(i) for i in args.covlevel]

# Run preseqR   
coverage_est_params = ["./coverage_est.R", "--plot", "--json", "--input", str(args.kmerfile), "--coverage", ",".join(strcovlevel), "--bases", str(args.bases)]
p1 = subprocess.Popen(coverage_est_params, stdout=subprocess.PIPE)
psout, pserr= p1.communicate()
if p1.returncode == 0:
    preseqdata = json.loads(str(psout))
    df2 = pd.DataFrame(preseqdata) # add preseq data to dataframe
    df1 = df1.append(df2) # combine data frames


g = ggplot(aes(x='BasesOfData',y='ProportionCoveredAtDepth', color='factor(CoverageDepth)',linetype='Type'), data=df1) +\
    geom_line() +\
    scale_x_log() +\
    xlab("Bases sampled") +\
    ylab("Fraction of data > or = depth") +\
    geom_vline(x= args.bases, color="black") 


g.save(filename = args.plotfile)
