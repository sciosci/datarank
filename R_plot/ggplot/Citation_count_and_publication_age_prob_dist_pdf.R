library(scales)

age_df <-read.csv('data/age_dist_prob.csv')
citation <-read.csv('data/citation_dist_prob.csv')

#00BFC4 : green
#new_citation <- citation[which(citation$cited_count< 50000), ]

citation_pdf <- ggplot(citation,
       aes(x = cited_count, y = prob)) + 
  geom_point(color = '#00BFC4') + 
  geom_abline(intercept=0.12536, slope=-2.16062, color = '#F9766E')+
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
               labels = trans_format("log10", math_format(10^.x))) +
			scale_color_brewer(type = 'qual', palette = 1) +
  xlab("Received citations") + ylab("Probability") +
  ggtitle("Probability density function of received citations") +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_y_log10(breaks = trans_breaks("log10", function(y) 10^y),
              labels = trans_format("log10", math_format(10^.x))) +
  annotation_logticks()


citation_log <- data.frame(log10(citation$cited_count),log10(citation$prob),)
m1 <- lm( log10.citation.prob. ~ log10.citation.cited_count., data=citation_log )  
summary(m1)







age_pdf <- ggplot(age_df,
       aes(x = age, y = prob)) + 
  geom_point(color="#00BFC4") +
  geom_abline(intercept=3.74, slope=-4.12, color = '#F9766E')+
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) +
  scale_color_brewer(type = 'qual', palette = 1) +
  xlab("Publication age") + ylab("Probability") +
  ggtitle('Probability density function of publication age') +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_y_log10(breaks = trans_breaks("log10", function(y) 10^y),
                labels = trans_format("log10", math_format(10^.x))) +
  annotation_logticks()

age_log <- data.frame(log10(age_df$age),log10(age_df$prob))
m1 <- lm( log10.age_df.prob. ~ log10.age_df.age., data=age_log[!is.infinite(age_log$log10.age_df.age.), ], na.action = na.omit)  
summary(m1)

pdf('output/citation_and_publication_age_prob_dist.pdf', width = 12, height = 4)

multiplot(age_pdf, citation_pdf, cols=2)

dev.off()
#ggsave('citation_age_prob_dist.pdf', plot = mp, device = NULL, path = '/home/tozeng/Downloads/datarank_r/tz/',
#       scale = 1, width = 10, height = 5, units = c("in"),
#       dpi = 300, limitsize = TRUE)



#new_age <- age[which(age$age< 100), ]
#ggplot(new_age,
#       aes(x= age, y = prob)) + 
#  geom_point(color = 4) + 
#  scale_color_brewer(type = 'qual', palette = 1) +
#  xlab("downloads") + ylab("pdf") +
#  ggtitle('genbank downloads') +
#  theme(plot.title = element_text(hjust = 0.5)) +
#  annotation_logticks()

