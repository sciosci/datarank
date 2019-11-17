library(ggplot2)

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


r2_corr = read.csv("/home/tozeng/Downloads/datarank_r/tz/best_genbank_2012_corr.csv")
figshare_r2_corr = read.csv("/home/tozeng/Downloads/datarank_r/tz/best_figshare_corr.csv")
r2_corr_df = data.frame(r2_corr)
figshare_r2_corr_df = data.frame(figshare_r2_corr)

p1<-ggplot(r2_corr_df, aes(x=type, y=R2)) +
  geom_bar(stat="identity" , fill = "#00BFC4")+
  scale_x_discrete(limits=c("DataRank", "DataRank-FB", "NetworkFlow","PageRank","Modified PageRank"), labels=c("DataRank","DataRank-\nFB", "NetworkFlow","PageRank","Modified\nPageRank")) + 
  labs(title="GenBank",  x="", y = expression(R^2))+
  theme(plot.title = element_text(hjust = 0.5)) 

p2<-ggplot(figshare_r2_corr_df, aes(x=type, y=R2)) +
  geom_bar(stat="identity" , fill = "#00BFC4") +
  scale_x_discrete(limits=c("DataRank", "DataRank-FB", "NetworkFlow","PageRank","Modified PageRank"), labels=c("DataRank","DataRank-\nFB", "NetworkFlow","PageRank","Modified\nPageRank")) + 
  labs(title="FigShare",  x="", y = "")+
  theme(plot.title = element_text(hjust = 0.5)) 

multiplot(p1,p2, cols=2)



corr1<-ggplot(r2_corr_df, aes(x=type, y=corr)) +
  geom_bar(stat="identity" ,  width = 0.6, fill = "#00BFC4")+
  scale_x_discrete(limits=c("DataRank", "DataRank-FB", "NetworkFlow","PageRank","Modified PageRank"), labels=c("DataRank","DataRank-\nFB", "NetworkFlow","PageRank","Modified\nPageRank")) + 
  labs(title="GenBank",  x="", y = "Correlation coefficient")+
  theme(plot.title = element_text(hjust = 0.5)) 

corr2<-ggplot(figshare_r2_corr_df, aes(x=type, y=corr)) +
  geom_bar(stat="identity" ,width = 0.6, fill = "#00BFC4") +
  scale_fill_hue(c=45, l=80)+
  scale_x_discrete(limits=c("DataRank", "DataRank-FB", "NetworkFlow","PageRank","Modified PageRank"), labels=c("DataRank", "DataRank-\nFB", "NetworkFlow","PageRank","Modified\nPageRank")) + 
  labs(title="FigShare",  x="", y = "")+
  theme(plot.title = element_text(hjust = 0.5)) 


pdf('/home/tozeng/Downloads/datarank_r/tz/correlation.pdf', width = 9, height = 5)
multiplot(corr1,corr2, cols=2)
dev.off()



