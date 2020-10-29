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
mod_names <- c("2020 no new", "2020 with time-varying fish wt-age","2020 all new data added","Update recyrs")
.MODELDIR = c( "j1/","j4/","c1/","c1mod2/")

# Read report files and create report object (a list):
fn       <- paste0(.MODELDIR, "fm")
modlst   <- lapply(fn, read_admb)
names(modlst) <- mod_names
thismod <- 4 # the selected model
thismodname<-"mod_evalc1mod2"
length(modlst)

  #Compare recruitment, ssb, and bts for all the models
  p1 <- plot_rec(modlst,xlim=c(1975.5,2020.5))
  ggsave(paste0("figs/",thismodname,"_rec.pdf"),plot=p1,width=8,height=4.0,units="in")
  p1 <- plot_ssb(modlst,xlim=c(1975.5,2020.5),alpha=.1)
  ggsave(paste0("figs/",thismodname,"_ssb.pdf"),plot=p1,width=8,height=4.0,units="in")
  p1<-plot_bts(modlst) + theme_few(base_size=11)
  ggsave(paste0("figs/",thismodname,"_bts.pdf"),plot=p1,width=8,height=4.0,units="in")
  
#Plotting just the preferred model (thismod) 
  
  #Single model plot fit to biomass index
  p1 <- plot_bts(modlst[thismod]) 
  ggsave(paste0("figs/",thismodname,"_bts_biom_fit.pdf"),plot=p1,width=8,height=10,units="in")
  
  #Stock recruit curve:
  p1<-plot_srr(modlst[thismod]); p1
  ggsave(paste0("figs/",thismodname,"_srr.pdf"),plot=p1)

  #Time-varying fishery selectivity 1991 onward
  p1 <- plot_sel(modlst[[thismod]],title = NULL, alpha = 0.3,styr= 1975,endyr = 1990,bysex = TRUE,sexoverlay = TRUE); p1
  ggsave(paste0("figs/",thismodname,"_fsh_sel_early.pdf"),plot=p1,width=4,height=8,units="in")
 
  p1 <- plot_sel(modlst[[thismod]],title = NULL, alpha = 0.3,styr= 1991,endyr = 2005,bysex = TRUE,sexoverlay = TRUE); p1
  ggsave(paste0("figs/",thismodname,"_fsh_sel_mid.pdf"),plot=p1,width=4,height=8,units="in")
 
  p1 <- plot_sel(modlst[[thismod]],title = NULL, alpha = 0.3,styr= 2006,endyr = 2020,bysex = TRUE,sexoverlay = TRUE); p1
  ggsave(paste0("figs/",thismodname,"_fsh_sel_recent.pdf"),plot=p1,width=4,height=8,units="in")
 

  #plot survey selectivity
  p1 <- plot_srv_sel(modlst,themod=4, title="Survey selectivity",bysex=TRUE,maxage = 20)
  ggsave(paste0("figs/",thismodname,"_bts_sel.pdf"),plot=p1) #,width=4,height=8,units="in")
  
  #plot survey age comps 
  # These two work - they make really small plots though - come back to this 
  p1<-plot_age_comps(modlst[4],title="Survey age compositions",type="survey")
  ggsave(paste0("figs/",thismodname,"_survey_age_comps.pdf"),plot=p1,width=11,height=8.5,units="in")

  #plot fishery age comps
  p1<-plot_age_comps(modlst[thismod],title="Fishery age compositions",type="fishery")
  ggsave(paste0("figs/",thismodname,"_fish_age_comps.pdf"),plot=p1,width=11,height=8.5,units="in")

 #plot catches
  p1<-plot_catch(modlst,themod = thismod,obspred= TRUE); p1
  ggsave(paste0("figs/",thismodname,"total_catches_w_pred.pdf"),plot=p1,width=11,height=8.5,units="in")

  p1<-plot_catch(modlst,themod = thismod,obspred= FALSE); p1
  ggsave(paste0("figs/",thismodname,"total_catches.pdf"),plot=p1,width=11,height=8.5,units="in")
  
  #plot sex ratio (doesn't work right now; Jim fixing.):
  plot_sex_ratio(modlst,ylim=c(.2,.8),type = "Fishery")
  plot_sex_ratio(modlst,ylim=c(.2,.8),type="Population")
  plot_sex_ratio(modlst,ylim=c(.2,.8),type="Survey") 
  
  
  
  
  
  
  # #Plot survey selectivity (commented out because incorporated into R file function plot-srv-sel)
  #  M <- modlst[[4]]; names(M[]) #to see the names of what's in an object
  #  df <- rbind(data.frame(Age=1:20,sel=M$sel_srv_m,sex="Male"),data.frame(Age=1:20,sel=M$sel_srv_f,sex="Female"))
  #  p1 <- ggplot(df,aes(x=Age,y=sel,color=sex)) + geom_line(size=2) + theme_few() + ylab("Selectivity") + ggtitle(paste0("Survey selectivity; (Model ",names(modlst[4]),")")) ;p1
  #  ggsave(paste0("figs/",thismodname,"_bts_sel_alternative.pdf"),plot=p1,width=4,height=8,units="in")
  
 
 