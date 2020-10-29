#radian #Carey says what is this line about?
rm(list=ls())
library(tidyverse)
library(grid)
library(ggridges)
#-------------------------------------------------------------------------------
# Visual compare runs
#-------------------------------------------------------------------------------
#Read in functions=========
#setwd("C:/GitProjects/flatfish/assessments/nrs/runs")
mydir = getwd()
Rdir = "../../R"
setwd(Rdir)
source("prelims.R")
setwd(mydir)

#--------------------------------------
# Read in the output of the assessment
# The model specs
mod_names <- c("2020 Base Model","2020 Model 18.3")
.MODELDIR = c( "c1/","c1mod4/")

# Read report files and create report object (a list):
fn       <- paste0(.MODELDIR, "fm")
modlst   <- lapply(fn, read_admb)
srn      <- paste0(.MODELDIR, "sex_ratio.rep")
srn
sex_rat  <- lapply(srn, read.table,col.names=c("Year","Type","Ratio"))
nmods    <- length(modlst)
# To get sex ratio output
names(modlst) <- mod_names
names(sex_rat) <- mod_names
thismod <- 2 # the selected model
thismodname<-"c1mod4"
length(modlst)


# probably want to make this a function w/ naming convention added...

# sex ratio
library(patchwork) ## The best layout software I've seen...
p1 <- sex_rat[[thismod]] %>% filter(Type %in% c("Survey_est", "Survey_obs") ) %>% 
   ggplot(aes(y=Ratio,x=Year,color=Type)) + geom_line() + theme_few()+ ylim(c(.25,.75)) + ggtitle(names(sex_rat[thismod])) 

p2 <-sex_rat[[thismod]] %>% filter(Type %in% c("Fishery_est", "Fishery_obs") ) %>% 
   ggplot(aes(y=Ratio,x=Year,color=Type)) + geom_line() + theme_few()+ ylim(c(.15,.85))

p3 <- sex_rat[[thismod]] %>% filter(!Type %in% c("Survey_est", "Survey_obs", "Fishery_est", "Fishery_obs") ) %>% 
   ggplot(aes(y=Ratio,x=Year,color=Type)) + geom_line() + theme_few() + ylim(c(.25,.75))
# this layes them out stacked (/)
  psex <- p1/p2/p3
  ggsave(paste0("figs/",thismodname,"_sexratios.pdf"),plot=psex,width=6,height=4.0,units="in")
  

  #Compare recruitment, ssb, and bts for all the models
  p1 <- plot_rec(modlst,xlim=c(1975.5,2020.5))
  ggsave(paste0("figs/",thismodname,"_rec.pdf"),plot=p1,width=8,height=4.0,units="in")
  p1 <- plot_ssb(modlst,xlim=c(1975.5,2020.5),alpha=.1)
  ggsave(paste0("figs/",thismodname,"_ssb.pdf"),plot=p1,width=8,height=4.0,units="in")
  p1<-plot_bts(modlst) + theme_few(base_size=11)
  ggsave(paste0("figs/",thismodname,"_bts.pdf"),plot=p1,width=8,height=4.0,units="in")
  

#Plotting just the preferred model (thismod) 
  #Single model plot fit to biomass index

  #Time-varying fishery selectivity 1991 onward
  p1 <- plot_sel(modlst[[thismod]],title = NULL, alpha = 0.3,styr= 1975,endyr = 1990,bysex = TRUE,sexoverlay = TRUE); p1
  ggsave(paste0("figs/",thismodname,"_fsh_sel_early.pdf"),plot=p1,width=4,height=8,units="in")
 
  p1 <- plot_sel(modlst[[thismod]],title = NULL, alpha = 0.3,styr= 1991,endyr = 2005,bysex = TRUE,sexoverlay = TRUE); p1
  ggsave(paste0("figs/",thismodname,"_fsh_sel_mid.pdf"),plot=p1,width=4,height=8,units="in")
 
  p1 <- plot_sel(modlst[[thismod]],title = NULL, alpha = 0.3,styr= 2006,endyr = 2020,bysex = TRUE,sexoverlay = TRUE); p1
  ggsave(paste0("figs/",thismodname,"_fsh_sel_recent.pdf"),plot=p1,width=4,height=8,units="in")
 

  #plot survey selectivity
  p1 <- plot_srv_sel(modlst,themod=thismod, title="Survey selectivity",bysex=TRUE,maxage = 20)
  ggsave(paste0("figs/",thismodname,"_bts_sel.pdf"),plot=p1) #,width=4,height=8,units="in")
  
  #plot survey age comps 
  # These two work - they make really small plots though - come back to this 
  p1<-plot_age_comps(modlst[thismod],title="Survey age compositions",type="survey")
  ggsave(paste0("figs/",thismodname,"_survey_age_comps.pdf"),plot=p1,width=11,height=8.5,units="in")

  #plot fishery age comps
  p1<-plot_age_comps(modlst[thismod],title="Fishery age compositions",type="fishery")
  ggsave(paste0("figs/",thismodname,"_fish_age_comps.pdf"),plot=p1,width=11,height=8.5,units="in")

 #plot catches
  p1<-plot_catch(modlst,themod = thismod,obspred= TRUE); p1
  ggsave(paste0("figs/",thismodname,"total_catches_w_pred.pdf"),plot=p1,width=11,height=8.5,units="in")

  p1<-plot_catch(modlst,themod = thismod,obspred= FALSE); p1
  ggsave(paste0("figs/",thismodname,"total_catches.pdf"),plot=p1,width=11,height=8.5,units="in")
  

  
  
  
  
  
  
  # #Plot survey selectivity (commented out because incorporated into R file function plot-srv-sel)
  #  M <- modlst[[4]]; names(M[]) #to see the names of what's in an object
  #  df <- rbind(data.frame(Age=1:20,sel=M$sel_srv_m,sex="Male"),data.frame(Age=1:20,sel=M$sel_srv_f,sex="Female"))
  #  p1 <- ggplot(df,aes(x=Age,y=sel,color=sex)) + geom_line(size=2) + theme_few() + ylab("Selectivity") + ggtitle(paste0("Survey selectivity; (Model ",names(modlst[4]),")")) ;p1
  #  ggsave(paste0("figs/",thismodname,"_bts_sel_alternative.pdf"),plot=p1,width=4,height=8,units="in")
  
 
 