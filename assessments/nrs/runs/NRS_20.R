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
mod_names <- c("15.1","18.3","18.3 Downwt")
.MODELDIR = c( "c1/","c1mod4/","c2mod4/")

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
thismod <- 3 # the selected model
thismodname<-"c2mod4"
length(modlst)

# sex ratio
# probably want to make this a function w/ naming convention added...
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
  psex
  
# Fishing mortality
M<-modlst[[thismod]]
  df <-rbind(data.frame(Year=M$SSB[,1],M$F_m,sex="Male"), data.frame(Year=M$SSB[,1],M$F_f,sex="Female") )
  names(df) <- c("Year",1:20,"sex"); df.g <- gather(df,age,F,2:21,-Year)
  #matrix of Fs -----------------------------------
  p1 <- df.g %>% mutate(age=as.numeric(age)) %>% filter(age<26,age>4)%>% ggplot(aes(y=age,x=Year,fill=F)) + geom_tile() + 
            ylab("Age")+ geom_contour(aes(z=F),color="darkgrey",size=.5,alpha=.4) + theme_few() +
            scale_fill_gradient(low = "white", high = "red") + scale_x_continuous(breaks=seq(1975,2020,5)) + 
            scale_y_continuous(breaks=seq(5,20,5)) +facet_grid(sex~.);
  ggsave(paste0("figs/",thismodname,"_FatAge.pdf"),plot=p1,width=8,height=4.0,units="in")
  
    #mean of Fs -------------------------------------
  p2 <- df.g %>% filter(as.numeric(age)>9) %>% group_by(Year,sex) %>% summarise(Apical_F=max(F),Mean=mean(F))          %>%
             ggplot(aes(x=Year,y=Apical_F,color=sex)) + geom_line(size=1) + theme_few() #+ ggtitle("Age 10-20 Mean F")
  p1/p2
  p3 <-p1/p2
 ggsave(paste0("figs/",thismodname,"_F.pdf"),plot=p3,width=8,height=8,units="in")
             

  #Compare recruitment, ssb, and bts for all the models
  p1 <- plot_rec(modlst,xlim=c(1975.5,2020.5))
  ggsave(paste0("figs/",thismodname,"_rec.pdf"),plot=p1,width=8,height=4.0,units="in")
  p1 <- plot_ssb(modlst,xlim=c(1975.5,2020.5),alpha=.1)
  ggsave(paste0("figs/",thismodname,"_ssb.pdf"),plot=p1,width=8,height=4.5,units="in")
  p1<-plot_bts(modlst) + theme_few(base_size=11)
  ggsave(paste0("figs/",thismodname,"_bts.pdf"),plot=p1,width=8,height=4.0,units="in")
  

#Plotting just the preferred model (thismod) 
  #Single model plot fit to biomass index

  #Time-varying fishery selectivity
  p1 <- plot_sel(modlst[[thismod]],title = NULL, alpha = 0.3,styr= 1975,endyr = 1990,bysex = TRUE,sexoverlay = TRUE); p1
  ggsave(paste0("figs/",thismodname,"_fsh_sel_early.pdf"),plot=p1,width=4,height=8,units="in")
 
  p1 <- plot_sel(modlst[[thismod]],title = NULL, alpha = 0.3,styr= 1991,endyr = 2005,bysex = TRUE,sexoverlay = TRUE); p1
  ggsave(paste0("figs/",thismodname,"_fsh_sel_mid.pdf"),plot=p1,width=4,height=8,units="in")
 
  p1 <- plot_sel(modlst[[thismod]],title = NULL, alpha = 0.3,styr= 2006,endyr = 2020,bysex = TRUE,sexoverlay = TRUE); p1
  ggsave(paste0("figs/",thismodname,"_fsh_sel_recent.pdf"),plot=p1,width=4,height=8,units="in")
 

  #plot survey selectivity
  p1 <- plot_srv_sel(modlst,themod=thismod, title="Survey selectivity",bysex=TRUE,maxage = 20); p1
  ggsave(paste0("figs/",thismodname,"_bts_sel.pdf"),plot=p1) #,width=4,height=8,units="in")
  
  #plot survey age comps 
  # These two work - they make really small plots though - come back to this 
  p1<-plot_age_comps(modlst[thismod],title="Survey age compositions",type="survey",styr=1979,endyr=2000)
  ggsave(paste0("figs/",thismodname,"_survey_age_comps_1.pdf"),plot=p1,width=11,height=8.5,units="in")

  p1<-plot_age_comps(modlst[thismod],title="Survey age compositions",type="survey",styr=2001,endyr=2019)
  ggsave(paste0("figs/",thismodname,"_survey_age_comps_2.pdf"),plot=p1,width=11,height=8.5,units="in")
  
  #plot fishery age comps
  p1<-plot_age_comps(modlst[thismod],title="Fishery age compositions",type="fishery",styr = 1975,endyr = 1999)
  ggsave(paste0("figs/",thismodname,"_fish_age_comps_1.pdf"),plot=p1,width=11,height=8.5,units="in")

  p1<-plot_age_comps(modlst[thismod],title="Fishery age compositions",type="fishery",styr = 2000,endyr = 2019)
  ggsave(paste0("figs/",thismodname,"_fish_age_comps_2.pdf"),plot=p1,width=11,height=8.5,units="in")
  
 #plot catches
  p1<-plot_catch(modlst,themod = thismod,obspred= TRUE); p1
  ggsave(paste0("figs/",thismodname,"total_catches_w_pred.pdf"),plot=p1,width=11,height=8.5,units="in")

  p1<-plot_catch(modlst,themod = thismod,obspred= FALSE); p1
  ggsave(paste0("figs/",thismodname,"total_catches.pdf"),plot=p1,width=11,height=8.5,units="in")
  
  thenames<-cbind("Likelihood Component","15.1","18.3","18.3 Downwt")
  like<-cbind("Total",modlst[[1]]$obj_fun,modlst[[2]]$obj_fun,modlst[[3]]$obj_fun)
  surv_like<-cbind("Survey Biomass",modlst[[1]]$survey_likelihood,modlst[[2]]$survey_likelihood,modlst[[3]]$survey_likelihood)
  surv_age_like<-cbind("Survey Age",modlst[[1]]$age_likeihood_for_survey,modlst[[2]]$age_likeihood_for_survey,modlst[[3]]$age_likeihood_for_survey)
  fsh_age_like<-cbind("Fishery Age",modlst[[1]]$age_likelihood_for_fishery,modlst[[2]]$age_likelihood_for_fishery,modlst[[3]]$age_likelihood_for_fishery)
  
  like_table<-as.data.frame(rbind(thenames,like,surv_like,surv_age_like,fsh_age_like))
  write.csv(like_table,paste0(getwd(),"/tables/likelihood_table.csv"),row.names = FALSE,col.names = FALSE)

  
  params<- read.table(file.path(mydir,thismodname,"fm.std"),header = TRUE)  
  
  p.table<-params[params$name=="ln_q_srv" | 
                    params$name=="natmort_m" |
                    params$name=="mean_log_rec" |
                    params$name=="mean_log_init" |
                    params$name=="log_avg_fmort" |
                    params$name=="sel_slope_fsh_f" |
                    params$name=="sel50_fsh_f" |
                    params$name=="sel_slope_fsh_m" |
                    params$name=="male_sel_offset" |
                    params$name=="sel_slope_srv" |
                    params$name=="sel_slope_srv_m" |
                    params$name=="sel50_srv" |
                    params$name=="sel50_srv_m" |
                    params$name=="R_logalpha" |
                    params$name=="R_logbeta" |
                    params$name=="msy" |
                    params$name=="Fmsy" |
                    params$name=="logFmsy" |
                    params$name=="Fmsyr" |
                    params$name=="logFmsyr" |
                    params$name=="Bmsy" |
                    params$name=="Bmsyr",]
  
  write.csv(p.table,paste0(getwd(),"/tables/",thismodname,"_params.csv"))
 

  #For FOCI appendix (send to Lauren Rogers and Dan Cooper)
  Rec.df<-as.data.frame(modlst[[thismod]]$R) %>% rename(year="V1",rec = "V2", lowerbound = "V4", upperbound = "V5") %>% select(-V3)
  SSB.df<-as.data.frame(modlst[[thismod]]$R) %>% rename(year="V1",ssb = "V2", lowerbound = "V4", upperbound = "V5") %>% select(-V3)
  write.csv(Rec.df,paste0(getwd(),"/tables/",thismodname,"_nrs_recruitment.csv"))
  write.csv(SSB.df,paste0(getwd(),"/tables/",thismodname,"_nrs_ssb.csv"))
  
  
  #For Executive Summary table:
  tier1.df<-read.table(file.path(mydir,thismodname,"ABC_OFL.rep"),header = TRUE)
  endyr<-max(modlst[[thismod]]$Yr)
Mstuff<-paste0(round(modlst[[thismod]]$natmort_f,2)," (f), ",round(modlst[[thismod]]$natmort_m,2)," (m)   ",round(modlst[[thismod]]$natmort_f,2)," (f), ",round(modlst[[thismod]]$natmort_m,2)," (m)")
Tier<-"1a  1a"  
GMBio<-paste0(1000*tier1.df$GM_Biom[tier1.df$Year==endyr+1],"   ",1000*tier1.df$GM_Biom[tier1.df$Year==endyr+2])
SSB<-paste0(1000*tier1.df$SSB[tier1.df$Year==endyr+1],"   ",1000*tier1.df$SSB[tier1.df$Year==endyr+2])
B0<-paste0(1000*modlst[[thismod]]$Bzero,"   ",1000*modlst[[thismod]]$Bzero)
Bmsy<-paste0(1000*tier1.df$Bmsy[tier1.df$Year==endyr+1],"   ",1000*tier1.df$Bmsy[tier1.df$Year==endyr+2])
Fofl<-paste0(round(tier1.df$AM_Fmsyr[tier1.df$Year==endyr+1],3),"   ",round(tier1.df$AM_Fmsyr[tier1.df$Year==endyr+2],3))
maxFabc<-paste0("?   ?")
Fabc<-paste0(round(tier1.df$HM_Fmsyr[tier1.df$Year==endyr+1],3),"   ",round(tier1.df$HM_Fmsyr[tier1.df$Year==endyr+2],3))
OFL<-paste0(1000*tier1.df$OFL_AM[tier1.df$Year==endyr+1],"   ",1000*tier1.df$OFL_AM[tier1.df$Year==endyr+2])
maxABC<-paste0(1000*tier1.df$ABC_HM[tier1.df$Year==endyr+1],"   ",1000*tier1.df$ABC_HM[tier1.df$Year==endyr+2])
ABC<-maxABC

exec.df<-rbind(Mstuff,
               Tier,
               GMBio,
               SSB,
               B0,
               Bmsy,
               Fofl,
               maxFabc,
               Fabc,
               OFL,
               maxABC,
               ABC)