#' # Projection model work
#' Projection model work for demonstrating application of controls and input data

library(tidyverse)
library(ggplot2)
library(ggthemes)
library(gtable)
dir = "C:/WORKING_FOLDER/Model19.14.48c_T"
Model_Name = "Model19.14.48c_T"

source("../R/readData.R")

#' ## Set initial "setup" parameters
thisyr=2019
setup<-list(
  Run_name     = noquote("Std"),
  Tier         = 3    ,
  nalts        = 7    ,
  alts         = c(1,2,3,4,5,6,7),
  tac_abc      = 1,    #' Flag to set TAC equal to ABC (1 means true, otherwise false)
  srr          = 1 ,   #' Stock-recruitment type (1=Ricker, 2=Bholt)
  rec_proj     = 1,    #' projection rec form (default: 1 = use observed mean and std, option 2 = use estimated SRR and estimated sigma R)
  srr_cond     = 0 ,   #' SR-Conditioning (0 means no, 1 means use Fmsy == F35%?, 2 means Fmsy == F35% and Bmsy=B35%  condition (affects SRR fits)
  srr_prior    = 0.0,  #' Condition that there is a prior that mean historical recruitment is similar to expected recruitment at half mean SSB and double mean SSB 0 means don't use, otherwise specify CV
  write_big    = 1,    #' Flag to write big file (of all simulations rather than a summary, 0 means don't do it, otherwise do it) Write_Big
  nyrs_proj    = 14,   #' Number of projection years
  nsims        = 1000, #' Number of simulations
  beg_yr_label = thisyr  #' Begin Year
)

#' ## Set up the species specific run file
config<-list(
  nFixCatchYrs = 1,
  nSpecies     = 1,
  OYMin        = .1343248,
  OYMax        = 1943248,
  dataFiles    = noquote(paste0("data/",Model_Name,".dat")),
  ABCMult      = 1,
  PoplnScalar  = 1000,
  AltFabcSPR   = 0.75,
  nTAC         = 1,
  TACIndices   = 1,
  Catch        = c(2019,15000.)
)


##

write_proj<-function(data_file="Model19.14.48c_T_Proj.dat",
                    data = mod1,
                    FY=1977,
                    LY=2019,
                    RY=2,
                    fleets=3,
                    sexes=1,
                    NAGES=10,
                    SSL=0, 
                    Dorn = 0, 
                    AUTHOR_F = 1, 
                    SPR_ABC = 0.4,
                    SPR_MSY = 0.35,
                    SPAWN_M = 1,
                    FRATIO=noquote("0.3 0.2 0.5"))
                    {
## writing projection file
## mean 5 year F
Y5<-LY-5
F_5<-mean(data$sprseries$Tot_Exploit[data$sprseries$Yr>Y5&data$sprseries$Yr<=LY])
## population weight at age for females
WGT<-vector("list",length=sexes)
Nage_LY<-vector("list",length=sexes)
M1<-vector("list",length=sexes)
for(i in 1:sexes){
  WGT[[i]]<-(data.table(data$endgrowth)[Sex==i]$Wt_Beg*data.table(data$endgrowth)[Sex==i]$Mat_F_Natage)[2:(NAGES+1)]
  Nage_LY[[i]]<-subset(data$natage,data$natage[,11]=="B"&data$natage$Yr==LY&data$natage$Sex==i)
  M1[[i]]<-as.numeric(subset(data$M_at_age,data$M_at_age$Yr==(LY-10)&data$M_at_age$Sex==i)[,4:(NAGES+3)]) ## pulling array of Ms at age by sex for LY-10
}

## selectivity at age for fishery
sel_LY<-vector("list",length=fleets)
wt_LY<-vector("list",length=fleets)
for(i in 1:fleets){
  sel_LY[[i]]<-subset(data$ageselex,data$ageselex$Fleet==i&data$ageselex$Yr==LY-RY&data$ageselex$Factor=="Asel2")
  wt_LY[[i]]<-subset(data$ageselex,data$ageselex$Fleet==i&data$ageselex$Yr==LY-RY&data$ageselex$Factor=="bodywt")
}

## numbers at age
Rec_1<-as.numeric(data$natage[,14][data$natage$Yr<=LY&data$natage$Yr>=FY&data$natage$Sex==1&data$natage[,11]=="B"])
N_rec<-length(Rec_1)

SSB<-as.numeric(data$sprseries$SSB[data$sprseries$Yr<=LY&data$sprseries$Yr>=FY])
#SSB<-SSB[1:(LY-FY)]
T1<-noquote(paste(data_file))
write(T1,paste(data_file),ncolumns =  1 )
T1<-noquote(paste0(SSL," # SSL Species???"))
  write(T1,paste(data_file),ncolumns = 1,append=T)
T1<-noquote(paste0(Dorn," # Constant Buffer Dorn?"))
  write(T1,paste(data_file),append = T)
T1<-noquote(paste0(fleets," # Number of fisheries"))
  write(T1,paste(data_file),append = T)
T1<-noquote(paste0(sexes," # Number of Sexes"))
  write(T1,paste(data_file),append = T)
T1<-noquote(paste(F_5,"# Average 5 year F"))
  write(T1,paste(data_file),append = T)
T1<-noquote(paste0(AUTHOR_F," # Author f"))
  write(T1,paste(data_file),append = T)
T1<-noquote(paste0(SPR_ABC," # SPR ABC"))
  write(T1,paste(data_file),append = T)
T1<-noquote(paste0(SPR_MSY," # SPR MSY"))
  write(T1,paste(data_file),append = T)
T1<-noquote(paste0(SPAWN_M," # Spawning month"))
  write(T1,paste(data_file),append = T)
T1<-noquote(paste0(NAGES," # number of ages"))
  write(T1,paste(data_file),append = T)
T1<-noquote(paste0(FRATIO," # Fratio"))
  write(T1,paste(data_file),append = T)
T1<-noquote("# natural mortality")
  write(T1,paste(data_file),append = T)
  for (i in 1:sexes){
    write(M1[[i]],paste(data_file),append = T,ncolumns =  45)
  }
T1<-noquote("# Maturity ")
  write(T1,paste(data_file),append = T)
  write(rep(1,NAGES),paste(data_file),append = T,ncolumns = 45) ## Female maturity??
T1<-noquote("# wt spawn females")
  write(T1,paste(data_file),append = T)
  for(i in 1: sexes){
    write(round(as.numeric(WGT[[i]]),4),paste(data_file),append = T,ncolumns =  45)
  }
T1<-noquote("# WtAge females by fishery")
  write(T1,paste(data_file),append = T)
  for(i in 1: fleets){
    write(round(as.numeric(wt_LY[[i]][1,9:(NAGES+8)]),4),paste(data_file),append = T,ncolumns =  45)
  }
T1<-noquote("# Selectivity females by fishery")
  write(T1,paste(data_file),append = T)
  for(i in 1: fleets){
    write(round(as.numeric(sel_LY[[i]][1,9:(NAGES+8)]),4),paste(data_file),append = T,ncolumns =  45)
  }

T1<-noquote(paste0("# Numbers at age females males in ",LY))
  write(T1,paste(data_file),append = T)
  for (i in 1:sexes){
    write(as.numeric(Nage_LY[[i]][1,14:ncol(Nage_LY[[i]])]),paste(data_file),append = T,ncolumns =  45)
  }
T1<-noquote(paste0("# No Recruitments for ",FY, " to ",LY-RY))
  write(T1,paste(data_file),append = T)
  write((N_rec-RY),paste(data_file),append = T,ncolumns =  45)
T1<-noquote("# Recruitment")
  write(T1,paste(data_file),append = T)
  write(round(Rec_1[1:(length(Rec_1)-RY)],1),paste(data_file),append = T,ncolumns =  45)
T1<-noquote(paste("# SSB ", FY,"-",LY,sep=""))
  write(T1,paste(data_file),append = T)
  write(SSB,paste(data_file),append = T,ncolumns =  45)
}
  

mod1<-SS_output(dir)  

write_proj(data_file=paste0("data/",Model_Name,".dat"),data=mod1,
                    FY=1977,
                    LY=2020,
                    RY=2,
                    fleets=3,
                    sexes=1,
                    NAGES=10,
                    SSL=0, 
                    Dorn = 0, 
                    AUTHOR_F = 1, 
                    SPR_ABC = 0.4,
                    SPR_MSY = 0.35,
                    SPAWN_M = 1,
                    FRATIO=noquote("0.3 0.2 0.5"))


#' ## Save lists for running model to files expected by projection model
library(gbm)
# Setup.dat
list2dat(setup,"setup.dat")
# spp_catch.dat
list2dat(config,paste0("data/",Model_Name,"_spcat.dat"))

file.copy(paste0("data/",Model_Name,"_spcat.dat"),"spp_catch.dat",overwrite=TRUE)

#' ## Run projection model
system("../src/main")
#' ## Read in projection model mainfiles
  .projdir= paste0(Model_Name,"/")
  dir.create(.projdir)
  file.copy(list.files(getwd(), pattern="out$"), .projdir,overwrite=TRUE)      
  file.remove(list.files(getwd(), pattern="out$"))
  bf <- data.frame(read.table(paste0(.projdir,"bigfile.out"),header=TRUE,as.is=TRUE))
  bfs <- bf %>% filter(Sim<=30)
  #write.csv(bfs,"data/proj.csv")
 # head(bfs)
  bfss <- bfs %>% filter(Alt==2) %>% select(Alt,Yr,Catch,SSB,Sim) 
  pf <- data.frame(read.table(paste0(.projdir,"percentdb.out"),header=F) )
  names(pf) <- c("stock","Alt","Yr","variable","value") 
#' ## Make plot of projection model simulations
  p1 <- pf %>% filter(substr(variable,1,1)=="C",variable!="CStdn",Alt==2) %>% select(Yr,variable,value) %>% spread(variable,value) %>%
    ggplot(aes(x=Yr,y=CMean),width=1.2) + geom_ribbon(aes(ymax=CUCI,ymin=CLCI),fill="goldenrod",alpha=.5) + theme_few() + geom_line() +
    scale_x_continuous(breaks=seq(thisyr,thisyr+14,2))  +  xlab("Year") + ylab("Tier 3 ABC (kt)") + geom_point() + 
    expand_limits(y=0) +
    geom_line(aes(y=Cabc)) + geom_line(aes(y=Cofl),linetype="dashed") + geom_line(data=bfss,aes(x=Yr,y=Catch,col=as.factor(Sim)))+ guides(size=FALSE,fill=FALSE,alpha=FALSE,col=FALSE) 
  p2 <- pf %>% filter(substr(variable,1,1)=="S",variable!="SSBStdn",Alt==2) %>% select(Yr,variable,value) %>% spread(variable,value) %>%
    ggplot(aes(x=Yr,y=SSBMean),width=1.2) + geom_ribbon(aes(ymax=SSBUCI,ymin=SSBLCI),fill="coral",alpha=.5) + theme_few() + geom_line() +
    scale_x_continuous(breaks=seq(thisyr,thisyr+14,2))  +  xlab("Year") + ylab("Tier 3 Spawning biomass (kt)") + geom_point() + 
    expand_limits(y=0) +
    geom_line(aes(y=SSBFabc)) + geom_line(aes(y=SSBFofl),linetype="dashed")+ geom_line(data=bfss,aes(x=Yr,y=SSB,col=as.factor(Sim)))+ guides(size=FALSE,fill=FALSE,alpha=FALSE,col=FALSE) 
  t3 <- grid.arrange(p1, p2, nrow=2)
  ggsave(paste0(.projdir,"tier3_proj.pdf"),plot=t3,width=5.4,height=7,units="in")


#' ## Make tables
  library(xtable)
  # Stock Alt Sim Yr  SSB Rec Tot_biom SPR_Implied F Ntot Catch ABC OFL AvgAge AvgAgeTot SexRatio FABC FOFL
  bfsum <- bf %>% select(Alt,Yr,SSB,F,ABC ,Catch) %>% group_by(Alt,Yr) %>% summarise(Catch=mean(Catch),SSB=mean(SSB),F=mean(F),ABC=mean(ABC))
  t1 <- bfsum %>% select(Alt,Yr,Catch) %>% spread(Alt,Catch) 
  names(t1) <- c("Catch","Scenario 1","Scenario 2","Scenario 3","Scenario 4","Scenario 5","Scenario 6","Scenario 7")

  print_Tier3_tables(bf)

