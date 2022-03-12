library(tidyverse)
library(ggthemes)
df <- read_table("overlap.dat")
df
df %>% pivot_wider(values_from=Index,names_from=Type) %>%
df <- read_table("overlap2.dat")
df

df %>% ggplot(aes(x=TempAnomaly,y=Overlap,label=Year)) + geom_text() + geom_smooth(method="lm") + theme_few()