#R
rm(list=ls())
#Read in functions=========
source("prelims.R")
.THEME   <- theme_few()
.OVERLAY <- TRUE

#To compile fm and copy to working directory FIX UP for your machine...
#setwd("../../../src")
#system("make.bat")
#system("copy fm.exe ../assessments/nrs/runs")
setwd("/Users/ingridspies/admbmodels/flatfish/assessments/yfs/runs")

# Function to make a new directory and copy files for orig=========
setup_dir <- function(dirname="xx"){
  dir.create(dirname)
  file.copy(list.files('orig/',full.names = TRUE),dirname)
}
# apply to (new) run directories
.MODELDIR = c( "m1/", "m2/","m3/","m4/")
lapply(.MODELDIR, setup_dir)

# Assuming that latest fm.exe is in path...run models----
# m1 base case no change===============================
setwd("./m1"); system("./fm -nox -iprint 200",invisible=FALSE); setwd("..")

# m2 Estimate male m===============================
ctl <- read_ctl("orig/mod.ctl")
setwd("m2"); 
ctl$phase_m_m <- 7; file.remove("mod.ctl");write_dat(ctl,"mod.ctl")
shell("fm -nox -iprint 200",invisible=FALSE); setwd("..")

# m3 estimate male m, Use VAST EBS estimates===============================
ctl <- read_ctl("orig/mod.ctl")
setwd("m3"); 
ctl$phase_m_m <- 7; 
file.remove("mod.ctl");write_dat(ctl,"mod.ctl")
shell("fm -nox -iprint 200",invisible=FALSE); setwd("..")

# m4 Estimate male m, use VAST NBS and EBS estimates===============================
ctl <- read_ctl("orig/mod.ctl")
setwd("m4"); 
# Estimate male m
ctl$phase_m_m <- 7; 
file.remove("mod.ctl");write_dat(ctl,"mod.ctl")
shell("fm -nox -iprint 200",invisible=FALSE); setwd("..")

# Read in results -----------------------------------------------------------------
# The model names...
  mod_names <-  c("Base", "Est Male M","Est Male M, q","Est Male M, q, Msel")
# Read report files and create report object (a list):
fn       <- paste0(.MODELDIR, "fm")
modlst   <- lapply(fn, read_admb)
names(modlst) <- mod_names
M <- modlst[1]
#Plot runset-------------------------
# Reserved for a new function that plots everything for each model
do_plots <- function(M,dopdf=TRUE){
  if (dopdf) {  pdf(onefile=false) }
  plot_bts(M)
  plot_age_comps(M)
  plot_age_comps(M,type="Survey",title="Survey age compositions")
  plot_rec(M)
  plot_ssb(M)
  plot_sel(M[[1]])
  plot_srv_sel(M)
  # Still to fix error in plot: 
  # plot_srr(M,alpha=.2)
  #plot_sex_ratio(modlst[[1]],ylim=c(.2,.8))
  if (dopdf) {  dev.off() }
}

#Compare models
  modset=1:4
  #Print dataframe of likelihoods per model-----
 .get_like_df(modlst)


plot_age_comps(M[1],title="Survey age compositions",type="Survey")
plot_bts(M[1] ,alpha=.6) #Plot model one
plot_bts(M ,alpha=.6) #Plot model one
#make a table of likelihoods
plot_ssb(M,alpha=.26,xlim=c(1990,2018))
plot_ssb(M[c(1,3,5)],alpha=.26,xlim=c(1990,2018))
plot_rec(M,alpha=.26,xlim=c(1990,2018),ylim=c(0,5000))
plot_rec(M[1],alpha=.26)
plot_rec(M[c(1,5,8)],alpha=.26,xlim=c(1990,2014))
plot_srr(M[c(1,4)],alpha=.26)
plot_srr(M[c(1)],alpha=.26)


