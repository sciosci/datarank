library(ggplot2)
library(effects)
library(tidyverse)
library(dplyr)
library(data.table)
library(lattice)
library(stargazer)
library(ggthemes)

figshare <- read.csv('../data/histgraph_data/figshare_hits_datarank_value.csv')
genbank <- read.csv('../data/histgraph_data/genbank_hits_datarank_value.csv')

df_figshare <- (figshare %>% group_by(age, downloads) %>% count()) %>% 
  ungroup() %>% group_by(age) %>%
  mutate(cdf=cumsum(n)/sum(n))
df_figshare <- subset(df_figshare, age>=4 & age<=8)
df_figshare$age <- factor(df_figshare$age)

df_genbank <- (genbank %>% group_by(age, hits) %>% count()) %>% 
  ungroup() %>% group_by(age) %>%
  mutate(cdf=cumsum(n)/sum(n))

df_genbank <- subset(df_genbank, age>=4 & age<=8)
df_genbank$age <- factor(df_genbank$age)

pdf('figshare_downloads.pdf', width = 6, height = 4)
ggplot(df_figshare,
       aes(x = downloads, y = cdf, color=age)) + 
  geom_point() + 
  geom_line() +
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) +
  scale_color_brewer(type = 'qual', palette = 1) +
  ggtitle('figshare downloads') +
  theme_few() + annotation_logticks()
dev.off()

pdf('genbank_hits.pdf', width = 6, height = 4)
ggplot(df_genbank,
       aes(x = hits, y = cdf, color=age)) + 
  geom_point() + 
  geom_line() +
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) +
  scale_color_brewer(type = 'qual', palette = 1) +
  ggtitle('genbank downloads') +
  theme_few() + annotation_logticks()
dev.off()