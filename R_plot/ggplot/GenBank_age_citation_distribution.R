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

na.zero <- function (x) {
  x[is.na(x)] <- 0
  return(x)
}

GenBank_df= read.csv("data/GenBank_doi_hits_age_citation_datarankvalue_693items.csv")
GenBank_df$citation = na.zero(GenBank_df$citation)

citation_hist = ggplot(GenBank_df, aes(x=GenBank_df$citation)) + 
  geom_histogram( binwidth=1,  fill="#00BFC4")+
  geom_vline(aes(xintercept=mean(citation)),
             color="#F9766E", linetype="dashed", size=0.5)+
  labs(  x="Received citations", y = "Frequency")+
  theme(plot.title = element_text(hjust = 0.5)) 

age_hist = ggplot(GenBank_df, aes(x=GenBank_df$age)) + 
  geom_histogram( binwidth=1,  fill="#00BFC4")+
  geom_vline(aes(xintercept=mean(age)),
             color="#F9766E", linetype="dashed", size=0.5)+
  labs( x="Dataset age", y = "Frequency")+
  theme(plot.title = element_text(hjust = 0.5)) 

pdf('output/GenBank_693_items_citation_hist.pdf', width = 5, height = 4)
citation_hist
dev.off()

pdf('output/GenBank_693_items_ages_hist.pdf',  width = 5, height = 4)
age_hist
dev.off()