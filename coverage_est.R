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
p <- add_argument(p, "--bases", help="The number of bases in the sample",type="numeric")
p <- add_argument(p, "--coverage", help="The coverage depth to evaluate, a vector of positive integers >= 2",nargs=Inf, type="numeric")


# Parse the command line arguments
args <- parse_args(p)

## Functions ##

# create log spaced points
logspace <- function( d1, d2, n){
  exp(log(10)*seq(log10(d1), log10(d2), length.out=n)) 
}

# create a list of log spaced points around the sequencing depth of the sample (in bases)
create.size<- function(bases,points){
  min=bases/10000
  points=logspace(min,bases*100,points)
  return(points)
}

#calulate the fraction of the genome sequenced as a function of the bases sequenced
frac.curve <-function (n, N, seq.size, r = 2, mt = 100) 
{
  f <- preseqR.kmer.frac(n, r = r, mt = mt)
  if (is.null(f)) 
    return(NULL)
  seq.effort <- seq.size /N
  kmer.frac <- t(sapply(seq.effort, function(x) f(x)))
  curves <- cbind(seq.size, kmer.frac)
  colnames(curves) <- c("Bases", paste(r, "x", sep = ""))
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
  a <- longdf(curves)
  p<-ggplot(a,aes(BasesOfData,ProportionCoveredAtDepth, color=factor(CoverageDepth)))
  p + geom_line() + scale_x_log10("Bases sequenced") + ylab("Fraction of data > or = depth") + 
    geom_vline(xintercept= N) + annotation_logticks(sides="b")
  }

longdf <- function(curves){
  a <- melt(as.data.frame(curves),id="Bases")
  names(a)<-c("BasesOfData","CoverageDepth","ProportionCoveredAtDepth")
  a$CoverageDepth <- as.numeric(gsub("x","",a$CoverageDepth))
  a$Type <-rep("PreseqR", dim(a)[1])
  return(a)
  }
# Test run #
#setwd("~/Documents/kmercoverage")
#files <- "data/MC04.hist.txt"
#N <- 22328668534
#r <- c(2,3,5,10,30)

n <- read.table(args$input, sep="\t")

size <- create.size(bases=args$bases,points=args$points)
curves <-frac.curve(n=n, N=args$bases, seq.size=size, r=as.vector(args$coverage))
if(args$json==TRUE){
  library(jsonlite)
  a <- longdf(curves)
  jdat <- toJSON(as.data.frame(a))
  print(jdat)
}

if (args$plot==TRUE){
  library(ggplot2)
  plotkmerwrap(curves, args$plotname , filetype=args$plottype , N=args$bases)
}
