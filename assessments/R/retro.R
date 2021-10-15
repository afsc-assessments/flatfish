###########1. Required packages ##########
if(!require("devtools")) install.packages("devtools"); library(devtools)
if(!require("dplyr")) install.packages("dplyr"); library(dplyr)
library(ggplot2)
library(ggthemes)
# Set your local directory--------
	mydir <- "/Users/ingridspies/admbmodels/flatfish/assessments/yfs/runs"  #change to mine.
	#mydir <- "~/_mymods/afsc-assessments/flatfish/assessments/yfs/runs"  #change to mine.
# Get tools to read-write control file
source(paste0(mydir,"/../../R/read-admb.R"))
master <-(paste0(mydir,"/retro"))

assess_LY=2021					#assessment terminal year
endyrvec <-1:10 		    #retrospective peels (Subtracted from endyr in tpl)

# Values used to downweight survey data when invoked written to retro.dat
#Specify values here
CV_inc=100	#CPUE CV used to downweight 
comp_n=.001	#input sample size  for length and age composition data used to downweight

do_run <- TRUE  #very important to make the runs go!
df_res <- NULL
for(i in 0:length(endyrvec)){
	# Start in "retro" directory (runs/retro)
	  setwd(master)
	# get new run location and copy files from orig
	  rundir <- 	paste0(master,"/retro_",i )
	  fc <- paste0("mkdir -p ",rundir," ; cp orig/* ",rundir)
	  system(fc)
	# Go to that directory, update mod.ctl to this model's configuration
	  setwd(rundir)
	  ctl <- read_ctl("mod.ctl")
	  ctl$n_retro     <- i
	  #ctl$surv_dwnwt  <- j-1
	  write_dat(ctl,"mod.ctl")
	# run model
	  if (do_run) system("rm fm.std; make") 
	# Save results
	  dftmp        <- data.frame(read.table("ABC_OFL.rep",header=TRUE))
	  dftmp$peel   <- -i
	  df_res       <- rbind(df_res,dftmp)
}	

#6. save results
write.csv(df_res,"yfs_results.csv")
names(df_res)

# Pool up retro results------------------
df_retro <- data.frame(matrix(ncol=9,nrow=0, dimnames=list(NULL, c("Year","Peel","SSB","SSB_sd","Totbio","Totbio_sd","Rec","Rec_sd","run"))))
j=1; i=4
for(i in 0:length(endyrvec)){
	  retro_dir <- 	paste0(master,"/retro_",i )
	  rep <- read.rep(paste0(retro_dir,"/fm.rep"))
	  df_tmp <- data.frame(
	  	Year      = rep$SSB[,1],
	  	Peel      = i,
	  	SSB       = rep$SSB[,2],
	  	SSB_sd    = rep$SSB[,3],
	  	Totbio    = rep$TotBiom[,2],
	  	Totbio_sd = rep$TotBiom[,3],
	  	Rec       = rep$R[,2],
	  	Rec_sd    = rep$R[,3]
	  )
	  # Append run results
	  # "Year Peel SSB ssb_stdev Tot_bio  totbio_stdev Rec rec_stdev run"
	  df_retro <- rbind(df_retro,df_tmp)
}
setwd(master)
write.csv(df_retro,"yfs_retros.csv")

###--jim stopped here...-------------------------------------