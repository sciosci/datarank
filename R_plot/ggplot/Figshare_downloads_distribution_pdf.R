library(ggplot2)
library(scales)

fs_download_data <-subset(
  read.csv('data/Figshare_doi_downloads_age_citation_datarankvalue_all_355items_citation_prob.csv'),
  downloads>0
  )


summary( lm(prob ~ downloads, data=fs_download_data))


ggplot(fs_download_data,aes(x = downloads, y = prob)) + 
  geom_point(color = '#00BFC4') + 
  geom_abline(intercept=2.833e-03 , slope=-3.414e-08, color = '#F9766E')+
  scale_color_brewer(type = 'qual', palette = 1) +
  xlab("Usage") + ylab("Probability") +
  ggtitle("Figshare") +
  theme(plot.title = element_text(hjust = 0.5))
annotation_logticks()



fs_download_data_log <- data.frame(log10(fs_download_data$downloads),log10(fs_download_data$prob))

downloads_log_lm <- lm(log10.fs_download_data.prob. ~ log10.fs_download_data.downloads., data=fs_download_data_log)
summary(downloads_log_lm)


ggplot(fs_download_data_log,aes(x = log10.fs_download_data.downloads., y = log10.fs_download_data.prob.)) + 
  geom_point(color = '#00BFC4') + 
  geom_abline(intercept=-2.57798 , slope=-0.00883, color = '#F9766E')+
  scale_color_brewer(type = 'qual', palette = 1) +
  xlab("Usage") + ylab("Probability") +
  ggtitle("Figshare") +
  theme(plot.title = element_text(hjust = 0.5))+
  annotation_logticks()




figureshare_download_pdf <- ggplot(fs_download_data,
                       aes(x = downloads, y = prob)) + 
  geom_point(color = '#00BFC4') + 
  geom_abline(intercept=-2.57798, slope=-0.00883, color = '#F9766E')+
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) +
  scale_color_brewer(type = 'qual', palette = 1) +
  xlab("Usage") + ylab("Probability") +
  ggtitle("Figshare") +
  theme(plot.title = element_text(hjust = 0.5))+
  scale_y_log10(breaks = trans_breaks("log10", function(y) 10^y),
                labels = trans_format("log10", math_format(10^.x))) +
  annotation_logticks()


#pdf('output/figureshare_usage.pdf', width = 6, height = 4)

figureshare_download_pdf

#dev.off()
