#!/usr/bin/env Rscript --vanilla

# A script to estimate genome coverage from a tabular, two column kmer histogram file  
# Adam Rivers Sept 9, 2016
library(preseqR)
library(reshape2)
library(argparser, quietly=TRUE)

# Create a parser
p <- arg_parser("A script to estimate genome coverage from a tabular, two column kmer histogram file, creating a Json data object and/or plot")

# Add command line arguments
p <- add_argument(p, "--plot", help="Create a plot?", flag=TRUE)
p <- add_argument(p, "--json", help="Should a JSON data object be passed to STDOUT", flag=TRUE)
p <- add_argument(p, "--input", help="two column histogram input", type="character")
p <- add_argument(p, "--plotname", help="Base filename for plot, no ending", default="kmercoverage")
p <- add_argument(p, "--plottype", help="format for plot", default="pdf")
p <- add_argument(p, "--points", help="The number of points to evaluate coverage over", default=100)
p <- add_argument(p, "--reads", help="The number of reads in the sample",type="numeric")
p <- add_argument(p, "--coverage", help="The coverage depth to evaluate, a vector of positive integers >= 2", nargs=Inf, default=c(2,3,10,30))

# Parse the command line arguments
args <- parse_args(p)

## Functions ##

# create log spaced points
logspace <- function( d1, d2, n){
  exp(log(10)*seq(log10(d1), log10(d2), length.out=n)) 
}

# create a list of log spaced points to evaluate
create.size.GB <- function(reads,points){
  min=reads/10000
  points=logspace(min,reads*100,points)/1E9
  return(points)
}

frac.curve <-function (n, N, seq.size.GB, r = 2, mt = 100) 
{
  f <- preseqR.kmer.frac(n, r = r, mt = mt)
  if (is.null(f)) 
    return(NULL)
  seq.effort <- seq.size.GB * 1e+09/N
  kmer.frac <- t(sapply(seq.effort, function(x) f(x)))
  curves <- cbind(seq.size.GB, kmer.frac)
  colnames(curves) <- c("Gigabases", paste("frac", r, "x", sep = ""))
  return(curves)
}

plotkmerwrap<- function(curves, filename, filetype, N){
  if(filetype=='pdf'){
    pdf(file=paste(filename,".pdf",sep=""), width = 7, height = 5)
    print(plotkmer(curves,N))
    #dev.off()
    }
  else if (filetype=='png'){
    png(file=paste(filename,".png",sep=""),  width = 1050 , height = 760)
    print(plotkmer(curves,N))
    #dev.off()
    }
  else{
    stop("Graphics filetype not supported")
  }
}

plotkmer <- function(curves, N){
  a <- melt(as.data.frame(curves),id="Gigabases")
  names(a)<-c("Gigabases","Coverage","Fraction")
  p<-ggplot(a,aes(Gigabases,Fraction, color=Coverage))
  p + geom_line() + scale_x_log10("Gigabases") + ylab("Fraction of data") + 
    geom_vline(xintercept= N/1E9) + annotation_logticks(sides="b")
  }


# Test run #
#setwd("~/Documents/kmercoverage")
#files <- "data/MC04.hist.txt"
#N <- 22328668534
#r <- c(2,3,5,10,30)

n <- read.table(args$input, sep="\t")

size.GB <- create.size.GB(reads=args$reads,points=args$points)
curves <-frac.curve(n=n, N=args$reads, seq.size.GB=size.GB, r=args$coverage)
if(args$json==TRUE){
  library(jsonlite)
  jdat <- toJSON(as.data.frame(curves))
  print(jdat)
}

if (args$plot==TRUE){
  library(ggplot2)
  plotkmerwrap(curves, args$plotname , filetype=args$plottype , N=args$reads)
}
