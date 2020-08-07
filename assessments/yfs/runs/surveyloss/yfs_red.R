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
# Get tools to read-write control file
source("~/_mymods/afsc-assessments/flatfish/assessments/R/read-admb.R")

if(!require("dplyr")) install.packages("dplyr"); library(dplyr)

############2. DIRECTORIES ###############
# Directory with full assessment model results
	master="~/_mymods/afsc-assessments/flatfish/assessments/yfs/runs/surveyloss"
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

# Directories for proj_mod
# Subdirectory for projection model input files
# will be used to create this sub dir
	#JI proj_data_dir<-"data/"
	
############3. SOURCE R SCRIPTS ####################
# found in master dir's parent directory
#JI source("../get_proj_res.r")	 		#Get projection results from proj_mod

############4.VARIABLES ####################
`%notin%` <- Negate(`%in%`)
assess_LY=2019					#assessment terminal year
endyrvec <-1:8 		                #retrospective peels (Subtracted from endyr in tpl)

# Values used to downweight survey data when invoked written to retro.dat
#Specify values here
CV_inc=100	#CPUE CV used to downweight 
comp_n=.001	#input sample size  for length and age composition data used to downweight

#Values written to proj_var.dat
#
nsex=2						# number of sexes used in assessment model	
nfishery=1					# number of fisheries(fleets)
fleets=1					# fleet index number (only applicable for SS models)
rec_age=1					# assumed age at recruitment
max_age=20					# maximum age in model
NAGE=length(rec_age:max_age)			# number of ages
FY=1954						# first year used to subset SSB 
rec_FY=1954					# first year used to subset recruitment 
rec_LY_decrement=2				# value subtracted from assessment final year to subset recruitment vector
spawn_month=5					# spawning month
Fratios=noquote("1")				# Proportion F per fishery

#passed to write_proj_spcat
ct_yrs=1			#Number of future catch years given to projection model

# passed to setup function
nsims=100			# number of projection model simulations 
nproj=20			# number of projection years ALSO USED BY get_proj_res

#passed to get_proj_res
spp="yfs"

#5. Create proj_var.dat: contains variables needed to write projection model data files. 
#This is done in the REPORT_SECTION of the *.tpl
fp=file.path(master,"proj_var.dat")
	write(noquote("#Number of catch years to include in the projection model dat file"),fp)
	write(ct_yrs,fp,append=TRUE)

	write(noquote("#Number of projection years"),fp,append=TRUE)
	write(nproj,fp,append=TRUE)

	write(noquote("#Number of simulations"),fp,append=TRUE)
	write(nsims,fp,append=TRUE)

	write(noquote("#Number of fisheries"),fp,append=TRUE)
	write(nfishery,fp,append=TRUE)

	write(noquote("#Number of sexes"),fp,append=TRUE)
	write(nsex,fp,append=TRUE)

	write(noquote("#Spawning month"),fp,append=TRUE)
	write(spawn_month,fp,append=TRUE)

	write(noquote("#Fratio"),fp,append=TRUE)
	write(Fratios,fp,append=TRUE)

###############6. Psuedocode ################################################################################################################################
#6.1. Run Retrospectives (tpl has been modified to do this)
#6.2. Run projection
#6.3. Get projection results
############################################################################################################################################################
#files to copy to retrospective subfolders
	filestocopy=c("orig/*") ###CHANGE TO MATCH YOUR EXE AND DAT NAMES
	#JI filestocopy=c("kam.exe","kam.dat","proj_var.dat") ###CHANGE TO MATCH YOUR EXE AND DAT NAMES
#files to copy to the proj model data folder
	#JI projFilestocopy=c("bsai_kam.dat","bsai_kam_spcat.dat","setup.dat") ###CHANGE TO MATCH YOUR PROJ MOD FILE NAMES
j=1
#retro_sub = "retro" or "survRed_retro"
	#6.1. Run for full time series
	#Create main retrospective subfolder
	if(!dir.exists(file.path(main_dir,paste0(retros_sub[j],"0")))){
	dir.create(file.path(main_dir,paste0(retros_sub[j],"0")), showWarnings = TRUE)}
df_res <- NULL
for(j in 1:length(retros_sub)) {
	cpto <- 	paste0(main_dir,"/",retros_sub[j],"0" )
	fc <- paste0("mkdir -p ",cpto," ; cp orig/* ",cpto)
	system(fc)
	#Command line to run assessment model *.exe
	setwd(file.path(main_dir,paste0(retros_sub[j],"0")))
	system("make") #### CHANGE TO WHATEVER YOUR EXE IS CALLED 
	#6.2 Get tier one projections
	dftmp        <- data.frame(read.table("ABC_OFL.rep",header=TRUE))
	dftmp$peel   <- 0
	dftmp$retros <- retros_sub[j] 
	df_res       <- rbind(df_res,dftmp)
	setwd(master)
	for(i in 1:length(endyrvec)){
	  cpto <- 	paste0(main_dir,"/",retros_sub[j],i )
	  fc <- paste0("mkdir -p ",cpto," ; cp orig/* ",cpto)
	  system(fc)
	  setwd(file.path(main_dir,paste0(retros_sub[j],i)))
	  ctl <- read_ctl("mod.ctl")
	  ctl$n_retro     <- i
	  ctl$surv_dwnwt  <- j-1
	  write_dat(ctl,"mod.ctl")
	  system("make") #### CHANGE TO WHATEVER YOUR EXE IS CALLED 
	  dftmp        <- data.frame(read.table("ABC_OFL.rep",header=TRUE))
	  dftmp$peel   <- -i
	  dftmp$retros <- retros_sub[j] 
	  df_res       <- rbind(df_res,dftmp)
	  setwd(master)
	}	
}
setwd(master)


6. Summarize results
fn="proj_res_summ.out"
write.csv(df_res,"yfs_results.csv")
names(df_res)
library(ggplot2)
library(ggthemes)
names()
df_res %>% filter(Year==2020) %>% mutate(Endyr=2019-peel,buffer=1-ABC_HM/OFL_AM) %>% 
ggplot(aes(x=Endyr,y=SSB,color=retros)) + geom_line(size=2) + theme_few()

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
	

