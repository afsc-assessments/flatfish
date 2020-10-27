##Retrospective analysis to evaluate uncertainty in assessment and projection model output 
## when there is a loss of survey data.
##Sections:
##1. Required packages
##2. Directories (define and create)
##3. Required Rscripts 
##4. Defining variables passed to functions
##5. Write data file that is read in tpl file and used to write projection model data file
##6. Psuedocode outlining analysis and analysis
###########1. Required packages ##########
if(!require("devtools")) install.packages("devtools"); library(devtools)
if(!require("dplyr")) install.packages("dplyr"); library(dplyr)
library(ggplot2)
library(ggthemes)
# Set your local directory--------
	mydir <- "/Users/ingridspies/admbmodels/flatfish/assessments"  #change to mine.
	mydir <- "~/_mymods/afsc-assessments/flatfish/assessments"  #change to mine.
# Get tools to read-write control file
source(paste0(mydir,"/R/read-admb.R"))


############2. DIRECTORIES ###############
# Directory with full assessment model results
# NOTE: this master directory must exist already and contain a subdirectory with base model configurations 
#       called "orig"
	master=paste0(mydir,"/yfs/runs/surveyloss")
	if(!dir.exists(file.path(mydir,master))) print(paste("NOTE: this master directory (",master,") must exist already and contain a subdirectory with base model configurations "))
	setwd(master)

# Directories and sub-directories needed for retrospectives
# Retrospective sub dir, created within master
	retros="retrospectives"
	#Create main retrospective folder
	if(!dir.exists(file.path(master, retros))){ 
		dir.create(file.path(master, retros), showWarnings = FALSE) 
	} 
	
	main_dir<-file.path(master,retros)	
	
# Used to create subfolders to store results from individual retrospective peels
	retros_sub=c("retro","survRed_retro")	#DO NOT CHANGE THIS

############3. SOURCE R SCRIPTS ####################

############4.VARIABLES ####################
`%notin%` <- Negate(`%in%`)
assess_LY=2020					#assessment terminal year
endyrvec <-1:10 		                #retrospective peels (Subtracted from endyr in tpl)

# Values used to downweight survey data when invoked written to retro.dat
#Specify values here
CV_inc=100	#CPUE CV used to downweight 
comp_n=.001	#input sample size  for length and age composition data used to downweight

#Values written to proj_var.dat
#
#passed to get_proj_res
spp="yfs"

#5. Create proj_var.dat: contains variables needed to write projection model data files. 
#This is done in the REPORT_SECTION of the *.tpl
###############6. Psuedocode ################################################################################################################################
#6.1. Run Retrospectives (tpl has been modified to do this)
#6.2. Run projection
#6.3. Get projection results
############################################################################################################################################################
#files to copy to retrospective subfolders
j=1
i=10
#retro_sub = "retro" or "survRed_retro"
	#6.1. Run for full time series
	#Create main retrospective subfolder
do_run <- TRUE  #very important to make the runs go!
df_res <- NULL
for(j in 1:length(retros_sub)) {
	setwd(master)
	cpto <- 	paste0(main_dir,"/",retros_sub[j],"0" )
	fc <- paste0("mkdir -p ",cpto," ; cp orig/* ",cpto)
	system(fc)  #IS added "fc"
	#Command line to run assessment model *.exe
	setwd(file.path(main_dir,paste0(retros_sub[j],"0")))
	if (do_run) system("rm fm.std; make") #### CHANGE TO WHATEVER YOUR EXE IS CALLED 
	#6.2 Get tier one projections
	dftmp        <- data.frame(read.table("ABC_OFL.rep",header=TRUE))
	dftmp$peel   <- 0
	dftmp$retros <- retros_sub[j] 
	df_res       <- rbind(df_res,dftmp)
	setwd(master)
	for(i in 0:length(endyrvec)){
	  setwd(master)
	  cpto <- 	paste0(main_dir,"/",retros_sub[j],i )
	  fc <- paste0("mkdir -p ",cpto," ; cp orig/* ",cpto)
	  system(fc)
	  setwd(file.path(main_dir,paste0(retros_sub[j],i)))
	  ctl <- read_ctl("mod.ctl")
	  ctl$n_retro     <- i
	  ctl$surv_dwnwt  <- j-1
	  write_dat(ctl,"mod.ctl")
	  if (do_run) system("rm fm.std; make") #### CHANGE TO WHATEVER YOUR EXE IS CALLED 
	  dftmp        <- data.frame(read.table("ABC_OFL.rep",header=TRUE))
	  dftmp$peel   <- -i
	  dftmp$retros <- retros_sub[j] 
	  df_res       <- rbind(df_res,dftmp)
	}	
}
setwd(master)

#6. Summarize results
write.csv(df_res,"yfs_results.csv")
names(df_res)
# Some dumb figure----------
df_res %>% filter(Year==2020) %>% mutate(Endyr=2019-peel,buffer=1-ABC_HM/OFL_AM) %>% 
ggplot(aes(x=Endyr,y=SSB,color=retros)) + geom_line(size=2) + theme_few()

# Pool up retro results------------------
df_retro <- data.frame(matrix(ncol=9,nrow=0, dimnames=list(NULL, c("Year","Peel","SSB","SSB_sd","Totbio","Totbio_sd","Rec","Rec_sd","run"))))
j=1; i=4
for(j in 1:length(retros_sub)) {
	for(i in 0:length(endyrvec)){
	  retro_dir <- 	paste0(main_dir,"/",retros_sub[j],i )
	  print(c(retros_sub[j],i ))
	  rep <- read_rep(paste0(retro_dir,"/fm.rep"))
	  df_tmp <- data.frame(
	  	Year      = rep$SSB[,1],
	  	Peel      = i,
	  	SSB       = rep$SSB[,2],
	  	SSB_sd    = rep$SSB[,3],
	  	Totbio    = rep$TotBiom[,2],
	  	Totbio_sd = rep$TotBiom[,3],
	  	Rec       = rep$R[,2],
	  	Rec_sd    = rep$R[,3],
	    	run       = paste0(spp,"_",retros_sub[j] )
	  )
	  # Append run results
	  # "Year Peel SSB ssb_stdev Tot_bio  totbio_stdev Rec rec_stdev run"
	  df_retro <- rbind(df_retro,df_tmp)
  }
}
setwd(master)
write.csv(df_retro,"yfs_retros.csv")

###--jim stopped here...-------------------------------------

res=read.table(file.path(main_dir,fn),header=TRUE)

folders=list.files(main_dir,pattern="retro")
ssb_endyr=lapply(folders,function(x) read.table(file.path(main_dir,x,"SSB_assessEndyr.out"))) #SSB_assessEndyr.out created in report section of tpl
ssb_endyr2=do.call(rbind,ssb_endyr)
ssb_endyr3=ssb_endyr2 %>% filter(row_number() %% 2==0) #select odd rows
names(ssb_endyr3)=c("Assess_endyr","retro","peel","SSB_assessEndyr")

ssb_endyr3$retro=gsub(0, "retr", gsub(1, "survRed_retr", ssb_endyr3$retro))
#as.numeric(as.character(ssb_endyr3$retro))
#ssb_endyr3 %>% mutate(retro=recode(retro,`0`="retr",`1`="survRed_retr"))
ssb_endyr3$peel=as.numeric(as.character(ssb_endyr3$peel))*-1

ssb_endyr3$SSB_assessEndyr=as.numeric(as.character(ssb_endyr3$SSB_assessEndyr))

res2=inner_join(res,ssb_endyr3,by=c("retro","peel"))
res2=res2[res2$peel %in% res2$peel[duplicated(res2$peel)],]

#Calculate year specific mean - in this case it is the mean of the normal and reduced survey retrospective models
	means=res2 %>% group_by(peel) %>% summarise_at(c("SSB_assessEndyr", "SSB","SSBofl","SSBabc","OFL","ABC"), ~ mean(log(.x), na.rm = TRUE))	
	names(means)=c(names(means)[1],paste0("mn_",names(means)[2:length(names(means))]))	

res3=full_join(res2,means,by="peel")

#Calculate squared difference	
	res3$diffSq_SSBassessEndyr=(log(res3$SSB_assessEndyr)-res3$mn_SSB_assessEndyr)^2
	res3$diffSq_SSB=(log(res3$SSB)-res3$mn_SSB)^2
	res3$diffSq_SSBofl=(log(res3$SSBofl)-res3$mn_SSBofl)^2
	res3$diffSq_SSBabc=(log(res3$SSBabc)-res3$mn_SSBabc)^2
	res3$diffSq_OFL=(log(res3$OFL)-res3$mn_OFL)^2
	res3$diffSq_ABC=(log(res3$ABC)-res3$mn_ABC)^2

#calculate sigma
	sigma=res3 %>% summarise_at(c("diffSq_SSBassessEndyr","diffSq_SSB","diffSq_SSBofl","diffSq_SSBabc","diffSq_OFL","diffSq_ABC"),
		~sqrt(sum(.x)*(1/(length(unique(Year)))))) 	
	names(sigma)=sub("diffSq","sig",names(sigma))
	
#calculate CV
	CV=sigma %>% summarise_all(~sqrt(exp(.x^2)-1))

#Proportional difference
	propDiff=res3 %>%group_by(peel,Year,Assess_endyr)%>% summarise_at(c("SSB_assessEndyr","SSB","SSBofl","SSBabc","OFL","ABC"),
		~(.x-.x[retro=="retr"])/.x[retro=="retr"])
	propDiff2=propDiff %>% filter(row_number() %% 2==0) #select odd rows
	propDiff2$Assess_endyr=as.numeric(as.character(propDiff2$Assess_endyr))
	
	par(mfcol=c(2,1),mai=c(0.8,0.82,0.5,0.42))
	leg=c("SSB","SSBofl","SSBabc","OFL","ABC")
	matplot(propDiff2$Year,propDiff2[5:ncol(propDiff2)],type="p",pch=19,col=1:5,xlab="Projection year",ylab="Proportional difference",xlim=c(min(propDiff2$Year,propDiff2$Assess_endyr),max(propDiff2$Year,propDiff2$Assess_endyr)),
		ylim=c(min(propDiff2[4:ncol(propDiff2)]),max(propDiff2[4:ncol(propDiff2)])))
	legend(2014,max(propDiff2[4:ncol(propDiff2)]),leg,col=1:5,pch=19,bty="n",ncol=3)
	abline(h=0,lty=2,col="black")	
	
	plot(propDiff2$Assess_endyr,propDiff2$SSB_assessEndyr,type="p",pch=19,col=1,xlab="Assessment terminal year",ylab="Proportional difference in SSB",xlim=c(min(propDiff2$Year,propDiff2$Assess_endyr),max(propDiff2$Year,propDiff2$Assess_endyr)),
		ylim=c(min(propDiff2[4:ncol(propDiff2)]),max(propDiff2[4:ncol(propDiff2)])))
	abline(h=0,lty=2,col="black")	
	

