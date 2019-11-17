# data <-read.csv('data/accession_metion_results.csv')
data <-read.csv('data/genbank_decay_diff_corr.csv')
data <- data[which(data$alpha==0.05),]

#figshare_data <-read.csv('data/result_corr_figshare.csv')

figshare_data <-read.csv('data/figshare_decay_diff_corr.csv')
figshare_data <- figshare_data[which(figshare_data$alpha==0.15),]

multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}


#library(ggplot2)
#data$alpha<-as.factor(data$alpha)
#figshare_data$alpha<-as.factor(figshare_data$alpha)
#pdf('E:/WLF/research/datarank/graph/F6_decay_diff_coeff.pdf', width = 6, height = 4)
#xt <- expression(decay[dataset]-decay[pub])
#p1<-ggplot(data,aes(x=diff, y=corr, color=alpha))+geom_point() + xlab(xt) + ylab("Correlation coefficient") + ggtitle('GenBank') + theme(plot.title = element_text(hjust = 0.5))
#legend.position = "none", 
#p2<-ggplot(figshare_data,aes(x=diff, y=corr, color=alpha))+geom_point() + xlab(xt) + ylab("") + ggtitle('Figshare') + theme(plot.title = element_text(hjust = 0.5))

#pdf('/home/tozeng/Downloads/datarank_r/tz/correlation_decay_diff.pdf', width = 8, height = 4.9)
#multiplot(p1, p2, cols=2)
#dev.off()



library(ggplot2)
data$alpha<-as.factor(data$alpha)
#figshare_data$alpha<-as.factor(figshare_data$alpha)
#pdf('E:/WLF/research/datarank/graph/F6_decay_diff_coeff.pdf', width = 6, height = 4)
xt <- expression(decay[dataset]-decay[pub])
p1<-ggplot(data,aes(x=diff, y=corr))+geom_point(color = '#00BFC4') + xlab(xt) + ylab("Correlation coefficient") + ggtitle('GenBank') + theme(plot.title = element_text(hjust = 0.5))
#legend.position = "none", 
p2<-ggplot(figshare_data,aes(x=diff, y=corr))+geom_point(color = '#00BFC4') + xlab(xt) + ylab("") + ggtitle('Figshare') + theme(plot.title = element_text(hjust = 0.5))

pdf('output/GenBank_Figshare_decay_diff_corr.pdf', width = 8, height = 4.9)
multiplot(p1, p2, cols=2)
dev.off()
#p1
