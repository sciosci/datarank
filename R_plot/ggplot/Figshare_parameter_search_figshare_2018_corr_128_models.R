figshare_corr<-read.csv('/home/tozeng/Downloads/datarank_r/tz/figshare_2018_1k_128models_downloads_corr.csv')


library(ggplot2)
figshare_corr$data_decay_time = factor(figshare_corr$data_decay_time)
figshare_corr$alpha = factor(figshare_corr$alpha)genebank_parameter_search.pdfgenebank_parameter_search.pdf

figshare_fig <- ggplot(figshare_corr, aes(x=figshare_corr$pub_decay_time, y=figshare_corr$corr, shape=alpha, color = data_decay_time )) + 
  theme(panel.grid.minor = element_line(colour="white", size=0.5,  linetype = 'solid'))+
  geom_point( ) +
  scale_shape_manual(values=c(4,2))+geom_line()+
  #  scale_color_viridis(discrete = TRUE,direction = -1, option = "inferno")+
  #scale_colour_brewer(type = "qual", palette="Set2", direction = -1, aesthetics = "colour")+
  #scale_color_manual(values=(c('#8BC34A','#CDDC39','#FFEB3B','#FFC107','#FFC107','#FF5722','#E64A19','#F44336')))+
  labs(x="Publication decay time (year)", y="Correlation coefficient",shape="alpha", color=expr("dataset \ndecay time"))

pdf('/home/tozeng/Downloads/datarank_r/tz/figshare_parameter_search.pdf', width = 6, height = 4)
figshare_fig
dev.off()
#display.brewer.all()
