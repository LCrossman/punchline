#!/usr/bin/R


args = commandArgs(trailingOnly=TRUE)

if (length(args)<2) {
   stop("At least two filenames must be supplied, the first containing the significant Pfam data and produced by the join_and_create_dataset_punchline.R script, the second file should be the grouping file provided to the join_and_create_dataset_punchline.R script", call.=FALSE)
} else if (length(args)==2) {
   significant = args[1]
   grouping_file = args[2]
  }


library(gplots)
library(corrplot)
library(RColorBrewer)

signi <- read.delim(significant, header=TRUE, sep="")

data <- as.matrix(signi)

groups <- read.delim(grouping_file, header=FALSE, sep="\t")

grups <- groups$V2
grups <- as.integer(grups)
grups <- as.factor(grups)
color_palette_function <- colorRampPalette(colors=brewer.pal(12,"Spectral"))
diamond_color_colors <- color_palette_function(nlevels(grups))
coler <- grups
group_colors <- diamond_color_colors[grups]
## create a vector of colours for group values
head(signi)
my_palette <- colorRampPalette(c("white", "blue", "red"))(n = 100)

col_breaks = c(seq(-1,0,length=100),seq(0.01,0.8,length=100),seq(0.81,1,length=100))


## And make sure you keep the dataframe columns that are significant only
group_colors
groups$V2
rownames(data)
pdf("heatmap_data.pdf", height=8, width=0.15*length(colnames(data)))
heatmap.2(as.matrix(data), trace="none", density.info="none", col=my_palette, margins=c(6,7), lhei=c(2,10), RowSideColors=group_colors)
dev.off()
##Now for the correlation plot

M <- cor(data)
siz <- length(rownames(M))

text_size = ifelse(siz < 20, 2, ifelse (siz >= 20 & siz < 50, 1, ifelse(siz >=50 & siz < 150, 0.3, ifelse(siz >= 150 & siz < 200,0.2, 0.1))))

pdf("correlation_plot.pdf", height=8, width=8)

corrplot(M, method="ellipse", tl.cex=text_size, order="hclust")

dev.off()
