library(preseqR)
files <-  c("6558.7.47340.GTGAAA.hist.txt", "6735.7.52359.AGTTCC.hist.txt",
"8852.1.113741.GTAGAG.hist.txt", "mgm4477807.hist.txt",
"SRR061157.hist.txt", "SRR061189.hist.txt",
"SRR062429.hist.txt", "SRR062436.hist.txt",
"SRR062519.hist.txt", "SRR096386.hist.txt",
"SRR096387.hist.txt", "SRR346700.hist.txt",
"SRR512581.hist.txt", "SRR512766.hist.txt",
"SRR948155.hist.txt")
N <- c(3241688930, 52300765500, 14505930062, 920666200, 6639186400, 5088650400, 5281168200,
5386027600, 5834904000, 3241688930, 2985931882, 5280176600, 3358010378, 5030853790,
7331072200)
size.GB <- seq(0, 60, by=1)
for (j in 1:length(files)) {
    n <- read.table(paste("../k31counts/",files[j],sep="")
    r <- c(2,3,10,30)
    curves <- preseqR.kmer.frac.curve(n=n, N=N[j], seq.size.GB=size.GB, r=r)
    if (is.null(curves)) next
    pdf(paste(files[j], ".pdf", sep=""))
    plot(NULL, NULL, type="l", lty=1, xlim=c(0, 60), ylim=c(0, 1),log="x", ann=FALSE, xlab="bases (GB)", ylab="fraction")
    
    COL <- c("black", "red", "green", "blue")
    for (i in 1:length(r)) {
        lines(curves[, c(1, i+1)], col=COL[i], lwd=2)
    }
    abline(v = N[j] / 1e9, col="grey", lty=3, lwd=2)
    
    for (i in 1:4) {
        index <- n[, 1] >= r[i]
        points(N[j] / 1e9, n[index, 1] %*% n[index, 2] / (n[, 1] %*% n[, 2]), col=COL[i], cex=2, pch=1)
    }
    title(main = substr(files[j], 1, nchar(files[j]) - 8), xlab = "bases(GB)", ylab = "fraction")
    
    legend("topleft", c("2x", "3x", "10x", "30x", "initial"), lty=c(1,1,1,1,3),lwd=c(2,2,2,2,2), col=c(COL, "grey"), cex=1)
    
    dev.off()
}