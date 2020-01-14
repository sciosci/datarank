  genbank_corr<-read.csv('data/datarank_corr_2012.csv')
  
  
  library(ggplot2)
  genbank_corr$pub_decay_time = factor(genbank_corr$pub_decay_time)
  genbank_corr$alpha = factor(genbank_corr$alpha)
  
  genbank_fig <- ggplot(genbank_corr, aes(x=genbank_corr$data_decay_time, y=genbank_corr$corr, shape=alpha, color = pub_decay_time )) + 
    theme(panel.grid.minor = element_line(colour="white", size=0.25,  linetype = 'solid'))+
    geom_point( ) +
  scale_shape_manual(values=c(4,2))+geom_line()+
  #  scale_color_viridis(discrete = TRUE,direction = -1, option = "inferno")+
  #scale_colour_brewer(type = "qual", palette=8, direction = -1, aesthetics = "colour")+
  #scale_color_manual(values=(c('#8BC34A','#CDDC39','#FFEB3B','#FFC107','#FFC107','#FF5722','#E64A19','#F44336')))+
    labs(title="DataRank performance on GenBank",x="Dataset decay time (year)", y="Correlation coefficient",shape="alpha", color=expr("publication \ndecay time"))+
    theme(plot.title = element_text(hjust = 0.5)) 
  
  pdf('output/genebank_parameter_search.pdf', width = 6, height = 4)
  genbank_fig
  dev.off()
  
  
  #display.brewer.all()
  
