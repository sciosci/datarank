fs_fit_data <-read.csv('data/pdf_downloads/figshare_log_process.csv')
gb_fit_data <-read.csv('data/pdf_downloads/genbank_log_process.csv')


m1 <- lm( fs_fit_data$label ~ fs_fit_data$log_x , data=fs_fit_data )  
summary(m1)
#-1.12473  -0.40203

m1 <- lm( gb_fit_data$label ~ gb_fit_data$log_x , data=gb_fit_data )  
summary(m1)
#-1.4159  0.6734



fs_orig_data <-read.csv('data/pdf_downloads/figshare_pdf.txt')
gb_orig_data <-read.csv('data/pdf_downloads/genbank_pdf.txt')

genbank_usage_fig<-ggplot(gb_orig_data,
           aes(x = hits, y = prodf)) + 
  geom_point(color = '#00BFC4') + 
  geom_abline(intercept=0.6734, slope=-1.4159, color = '#F9766E')+
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) +
  scale_color_brewer(type = 'qual', palette = 1) +
  xlab("Usage") + ylab("Probability") +
  ggtitle("GenBank") +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_y_log10(breaks = trans_breaks("log10", function(y) 10^y),
                labels = trans_format("log10", math_format(10^.x))) +
  annotation_logticks()

figureshare_usage_fig<-ggplot(fs_orig_data,
       aes(x = downloads, y = prodf)) + 
  geom_point(color = '#00BFC4') + 
  geom_abline(intercept=-0.40203, slope=-1.12473, color = '#F9766E')+
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) +
  scale_color_brewer(type = 'qual', palette = 1) +
  xlab("Usage") + ylab("Probability") +
  ggtitle("Figshare") +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_y_log10(breaks = trans_breaks("log10", function(y) 10^y),
                labels = trans_format("log10", math_format(10^.x))) +
  annotation_logticks()




pdf('output/genebank_usage.pdf', width = 6, height = 4)

genbank_usage_fig

dev.off()

pdf('output/figureshare_usage.pdf', width = 6, height = 4)

figureshare_usage_fig

dev.off()
