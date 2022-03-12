rm(list=ls())
ls()
#source(paste0(here::here("R"),"/prelims.R"))
source("../../R/prelims.R")
#-------------------------------------------------------------------------------
# Visual compare runs
#-------------------------------------------------------------------------------
library(ggridges)

source("../../R/compareRuns.r")
#--Projections---------
pdf("proj.pdf")
pfn <- "amak"
pfn <- "5yr"
pdt <- data.table(read.table(paste0(pfn,"_out/bigfile.out"),header=TRUE)) 
pdt <- data.table(read.table(paste0("bigfile.out"),header=TRUE)) 
pdt$Alternative <- as.factor(pdt$Alternative)

pt <- pdt[Yr>2018,.(Catch=mean(Catch),ABC=mean(ABC),OFL=mean(OFL),SSB=median(SSB) ,lb=quantile(SSB,.2) ,ub=quantile(SSB,.8) ),.(Yr,Alternative)]
pt
ggplot(pt,aes(x=Yr,y=SSB,fill=Alternative)) + geom_line() + mytheme + ylim(c(0,400)) + geom_ribbon(aes(ymin=lb,ymax=ub,fill=Alternative),alpha=0.25) + labs(y="Spawning biomass (kt)",x="Year") + scale_x_continuous(breaks=seq(2015,2032,2)) 
c1 <- ggplot(pt,aes(x=Yr,y=Catch,color=Alternative,size=1.)) + geom_line(size=1.5) + mytheme + labs(y="Catch (kt)",x="Year") + scale_x_continuous(breaks=seq(2015,2032,2)) 
c1 <- c1 + geom_line(aes(x=Yr,y=ABC),size=1)
#c1 <- c1 + geom_line(data=pt[as.numeric(Alternative)==2,.(Yr,ABC)],aes(x=Yr,y=ABC))
c1
pt[as.numeric(Alternative)==2,.(Yr,ABC)]
pt <- pdt[Yr>2018,.(Catch=mean(Catch),ABC=mean(ABC),OFL=mean(OFL)),.(Yr,Alternative)] 
pt
ggplot(pt,aes(x=Yr,y=OFL,color=Alternative)) + geom_line() + mytheme
pdt
pdx <-rbind(pdt)
setkey(pdx,Yr,Alternative)
pt <- pdx[.(Yr>2018,(Alternative)==1),.(Catch=mean(Catch),ABC=mean(ABC),OFL=mean(OFL),SSB=median(SSB)  ),.(Yr,config)]
pt <- pdx[Yr>2018&Alternative==1,.(Catch=mean(Catch),ABC=mean(ABC),OFL=mean(OFL),SSB=median(SSB) ,lb=quantile(Catch,.1) ,ub=quantile(Catch,.9)  ),.(Yr,config)]
ggplot(pt,aes(x=Yr,y=Catch,color=config,shape=config)) + geom_line() + geom_point() + mytheme + geom_ribbon(aes(ymin=lb,ymax=ub,fill=config),alpha=0.25) + labs(x="Year")+ scale_x_continuous(breaks=seq(2015,2032,2))  + ylim(c(0,130))
dev.off()

