# read in specimen file
library(tidyverse)
spec<-read.csv("C:/Users/carey.mcgilliard/Work/FlatfishAssessments/2020/Northern Rock Sole/Data Updating/surveywtatage/ThreeYrAvg/race_specimen.csv",skip = 7)

spec<-spec%>%filter(Weight..gm. >0 & Age..years.>0 & Gear.Performance==0 & Year==2017) %>%
      rename(Weight=Weight..gm.) %>% rename(Age=Age..years.) %>% 
      select(Year, Weight, Age, Gear.Performance, Specimen.ID)

spec17<-spec %>% filter(Year==2017)

stuff<-spec17 %>% filter(Specimen.ID == 217)