#!/usr/bin/R


library("optparse")

option_list = list(make_option(c("-f", "--file"), type="character", default=NULL, help="grouping file name, tab-delimited", metavar="character"),
                   make_option(c("-m", "--motifs"), type="character", default=NULL, help="Pfam motifs name file list, from the same version of Pfam you used", metavar="character"), 
                   make_option(c("-s", "--siglevel"), type="numeric", default=0.01, help="significance level, 0.01, 0.05 [default=0.01]", metavar="numeric"),
                   make_option(c("-n", "--norm"), type="character", default="raw", help="normalization type, raw, rel or log-rel, default='raw'", metavar="character")
);

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

if (is.null(opt$file)){
    print_help(opt_parser)
    stop("At least two arguments are needed, grouping file with species name and group in a tab-separated file", call.=FALSE)}

opt


patts = "*.pfams"
patts
file_list <- list.files(pattern="*.pfams")
print("file")
file_list
motifs <- read.delim(opt$motifs, header=FALSE, sep="")
motifs
motifs <- motifs$V1
motifs
dataset <- do.call("cbind", lapply(file_list, FUN=function(files){read.table(files, header=TRUE, sep="\t")}))
length(rownames(dataset))
length(motifs)
#create file list from all of the pfam counts and join into the full dataset
rownames(dataset) <- motifs

head(dataset)
dataset <- t(dataset)
library(reshape2)
library(ggplot2)

#create groups from the provided file

grouping_data <- read.delim(opt$file, header=FALSE, sep="")

head(grouping_data)

rownames(grouping_data) <- grouping_data[,1]

grouping_data[rownames(dataset),]
groups <- as.character(grouping_data$V2)
groups <- as.factor(groups)

## Adapted here from some code from Torodel et al., 2016 Microbiol.Biotechnology.  Assessment of the influence of intrinsic environmental and geographical factors on the bacterial ecology of pit latrines.

#carry out the significance testing and choose the significant Pfam domains for further study

dataset <- as.data.frame(dataset)

dataset <- dataset[,(colSums(dataset)!=0)]
dataset <- Filter(var, dataset)
#dataset <- dataset[!duplicated(dataset[,colnames(dataset)]),]
head(dataset)
dataset <- dataset[complete.cases(dataset),]
head(dataset)

write.table(dataset, "dataset.txt", quote=FALSE, row.names=TRUE, col.names=TRUE, sep="\t")

transf = opt$norm
if (transf == "rel") dataset <- dataset/rowSums(dataset)
if (transf == "log-rel") dataset <- (log(dataset+1))/(rowSums(dataset)+dim(dataset)[2])
head(dataset)

#remove columns with all values identical or 0 as they cannot be significantly different across the groups

kruskal.wallis.alpha=opt$siglevel

kruskal.wallis.table <- data.frame()

for(i in 1:dim(dataset)[2]){
   kw.test <- kruskal.test(dataset[,i],g = groups)
   kruskal.wallis.table <- rbind(kruskal.wallis.table, data.frame(id=names(dataset)[i],p.value=kw.test$p.value))
   cat(paste("Kruskal wallis test for ", names(dataset)[i], " ", i, "/", dim(dataset)[2], "; p=value=", kw.test$p.value, "\n", sep=""))}


kruskal.wallis.table$E.value <- kruskal.wallis.table$p.value * dim(kruskal.wallis.table[1])
kruskal.wallis.table$FWER <- pnbinom(q=0, p=kruskal.wallis.table$p.value,size=dim(kruskal.wallis.table)[1],lower.tail=FALSE)
kruskal.wallis.table <- kruskal.wallis.table[order(kruskal.wallis.table$p.value,decreasing=FALSE), ]
kruskal.wallis.table$q.value.factor <- dim(kruskal.wallis.table)[1]/1:dim(kruskal.wallis.table)[1]
kruskal.wallis.table$q.value <- kruskal.wallis.table$p.value * kruskal.wallis.table$q.value.factor
kruskal.wallis.table <- kruskal.wallis.table[complete.cases(kruskal.wallis.table),]

kruskal.wallis.table
if is.finite(max(which(kruskal.wallis.table$q.value <= kruskal.wallis.alpha))) {
     last.significant.element <- max(which(kruskal.wallis.table$q.value <= kruskal.wallis.alpha))
     selected <- 1:last.significant.element
     diff.cat.factor <- kruskal.wallis.table$id[selected]
     diff.cat <- as.vector(diff.cat.factor)

     kruskal.wallis.table[selected,]
     selct <- kruskal.wallis.table[selected,]
     dat <- dataset[(rownames(dataset) %in% selct$id),]
     write.table(dat, "dataset_signi_counts.txt", quote=FALSE, row.names=TRUE, col.names=FALSE, sep="\t")

     write.table(selct, "kruskal_wallis_selected.txt", quote=FALSE, row.names=TRUE, col.names=TRUE, sep="\t")
     ifelse(length(diff.cat)>120,dc <- diff.cat[1:120], dc <- diff.cat)

     df<-NULL
     for(i in dc){
       tmp<-data.frame(dataset[,i],groups,rep(paste(i," q = ",round(kruskal.wallis.table[kruskal.wallis.table$id==i,"q.value"],5),sep=""),dim(dataset)[1]))
       tmp
       if(is.null(df)){df<-tmp} else { df<-rbind(df,tmp)} 
     }
     colnames(df)<-c("Value","Type","Pfam")
 
     p<-ggplot(df,aes(Type,Value,colour=Type))+ylab("Pfam domain counts")
     p<-p+geom_boxplot()+geom_jitter()+theme_bw()+
       facet_wrap( ~ Pfam , scales="free", ncol=3)
     p<-p+theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))
     pdf("Kruskal_wallis_tests.pdf", height=0.1*length(rownames(df)), width=15)
     p
     dev.off()
     }
     else {
     print("Sorry, nothing tested as significant between the groups provided, sometimes the correction for multiple testing can be quite conservative so it's worth looking at the whole dataset table testing values")
     write.table(kruskal_wallis.table, "kruskal.wallis.table.txt", quote=FALSE, row.names=TRUE, col.names=TRUE, sep="\t") 
     }
print(end)
