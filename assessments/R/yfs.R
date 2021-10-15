R
rm(list=ls())
source("../R/prelims.R")
source("../../R/prelims.R")
mytheme = .THEME
# Run model from last year

#mods <- c("Base","Base","Const. fish sel.","Short_dat","Sex specific M","Constant survey q","Est_Sex_M_G2","Temperature-growth","Sigma R estimated","Sigma R 1.0","Full SRR Series")
#---------------------------------------------------------------
#for (i in c(2,3,5:6,8:11)){
# Read in regular results
for (i in c(1:4)){
  rn=paste0("arc/mod",i,"_R.rep")
  mn=paste0("mod",i)
  A <-  readList(rn)
  sr <- read.table(paste0("arc/mod",i,"_sex_ratio.rep"))
  names(sr) <- c("Year","source","sex_ratio")
  A$sex_ratio <- sr %>% arrange(source,Year)
  assign(mn,A)
  print(rn)
	print(i)
}
#dim(mc.df)
#mods
#M <- list( mod2, mod3, mod5, mod6,mod8,mod9,mod10,mod11)
#M <- list( mod1,mod2,mod3,mod4,mod5,mod6)
M <- list( mod1,mod2,mod3,mod4)
names(M)
#names(M) <- mods[c(2,3,5,6,8,9,10,11)]
#names(M) <- c("2017 Base","2018","Fixed q","2018 full SRR series", "2018 Male M","2018 Male M, selectivity")
names(M) <- c("2017.Base","2018.Base","Fixed.q","2018.full.SRR.series")
#---------------------------------------------------------------
# Read in MCMC results
# Read in MCMC header and results
hdr <- read.table("hdr.dat",as.is=T,header=F)
mc.df <-tibble()
mods  <- c("Base","Model 18.1","FixQ", "Model 14.2")
i=2
for (i in c(2,4)){
  mctmp.df <-read_table2(paste0("arc/mod",i,"_evalout.rep"),col_names=FALSE) 
  names(mctmp.df) <- hdr
  mctmp.df$Model <- mods[i]
  mctmp.df$ModNum <- i
  mctmp.df <- mctmp.df %>% mutate(Recruit_NLL=rec_like_1+rec_like_2+rec_like_3+rec_like_4, Selectivity_NLL=sel_like1+sel_like2+sel_like3)
  mc.df <- rbind(mc.df,mctmp.df)
}
#mc.df<- mc.df %>% mutate(Obj=Obj-wt1)
#---------------------------------------------------------------

# Plot SSB 
library(ggridges)
plot_q(M[2])
plot_sel(mod2)
plot_fut_Fs(M[2],alpha=.7)
names(mod2)
plot_ssb(M[1:4],alpha=.2,xlim=c(1977,2018),ylim=c(0,1400))
plot_sex_ratio(M,ylim=c(.25,.75))
plot_sex_ratio(M,ylim=c(.25,.75),type="Population")
plot_sex_ratio(M,ylim=c(.25,.75),type="Survey")
# SRR stuff
plot_srr(M,alpha=.2)
plot_srr(M[c(1:4)],alpha=.2,xlim=c(0,1500),ylim=c(0,7.2))
plot_srr(M[c(2,4)],alpha=.2,xlim=c(0,1500),ylim=c(0,7.2))
plot_bts(M,alpha=.2)
plot_bts(M[c(1,2)],alpha=.2)
plot_rec(M[c(2,3)],alpha=.2)
# Print out likelihood table for this model set
.get_like_df(M[1:4])
tab     <- cbind(M[[1]]$Like_Comp_names,do.call(cbind,lapply(M,function(x){round(x[["Like_Comp"]],2)})))
tab
write.csv(tab,file=file.path(inputPath,"LikelihoodTable2015.csv"),row.names=F)
system(paste("open ",inputPath,"/LikelihoodTable2015.csv",sep=""))

plot_ssb(M[1:4],alpha=.2)
srr.df <- as.data.frame(list(R=NULL,B=NULL,Model=NULL))
names(srr.df)
srr.df
srr.df <- mc.df %>% select(Model,Alpha,Beta) %>% nest(-Model) %>% mutate(map2(data,mean)) #group_by(Model) %>% nest() #%>% mutate(test = map(SSB=seq(0,1.5e6,length.out=30),R=Alpha*SSB*(exp(-Beta*SSB))) )
srr.df <- mc.df %>% select(Model,Alpha,Beta) %>% mutate(sim=rep(1:2000,5))   %>% group_by(Model) %>% nest() #%>% mutate(test = map(SSB=seq(0,1.5e6,length.out=30),R=Alpha*SSB*(exp(-Beta*SSB))) )
head(srr.df)

#=====================
# ABC/OFL
#=====================
mc.df <- mcfull.df
abc.df <- tibble()
abc.df <- mc.df %>% group_by(Model) %>% select(Model,ModNum,Fmsyr,ABC_biom1) %>% 
  summarise(ModNum=mean(ModNum),FOFL=mean(Fmsyr),CV_Fmsy=sd(Fmsyr)/FOFL,FABC=1/mean(1/Fmsyr),Biomass=exp(mean(log(ABC_biom1))),CV_Biomass=sd(ABC_biom1)/mean(ABC_biom1), ABC=FABC*Biomass,OFL=FOFL*Biomass,Buffer=1-ABC/OFL) 
  #summarise(FOFL=mean(Fmsyr),FABC=1/mean(1/Fmsyr),Biomass=exp(mean(log(ABC_biom1))),ABC=FABC*Biomass,OFL=FOFL*Biomass,Buffer=1-ABC/OFL)
abc.df <- mc.df %>% select(Model,ModNum,Fmsyr,ABC_biom1) %>% 
  summarise(Model="All",ModNum=0,FOFL=mean(Fmsyr),CV_Fmsy=sd(Fmsyr)/FOFL,FABC=1/mean(1/Fmsyr),Biomass=exp(mean(log(ABC_biom1))),CV_Biomass=sd(ABC_biom1)/mean(ABC_biom1), ABC=FABC*Biomass,OFL=FOFL*Biomass,Buffer=1-ABC/OFL) %>% 
  bind_rows(abc.df)
abc.df
write_csv(abc.df,"abctab.csv")
ggplot(abc.df,aes(x=Model,y=Buffer))  + xlim(c(0.08,0.38)) +
        geom_text(aes(x = CV_Fmsy, y = Buffer, label=Model),color="red",size=4.5) + .THEME + ylab("Buffer") + xlab("CV Fmsy")
  #geom_point(size=3,color="blue") 


#----------------------------
# MCMC stuff
#----------------------------
names(mc.df)
mcfull.df <- mc.df
mc.df <- mcfull.df %>% filter(ModNum<=8)
 # All Likelihoods
 mc.df %>% select(Model,Obj) %>% 
  ggplot(aes(x=Obj,fill=Model)) + geom_density(alpha=.4) + mytheme
 #mc.df %>% select(Model,Obj) %>% ggplot(aes(x=Obj,color=Model)) + stat_ecdf(size=2) + mytheme + scale_y_continuous(breaks=NULL) + ylab("Cumulative distribution")
# Srvey likelihoods
 mc.df %>% select(Model,srv_like) %>% 
  ggplot(aes(x=srv_like,fill=Model)) + geom_density(alpha=.4) + mytheme + mytheme + scale_y_continuous(breaks=NULL) + xlab("Survey index NLL")
 #mc.df %>% select(Model,srv_like) %>% filter(Model!="Const_Sel") %>% ggplot(aes(x=srv_like,color=Model)) + stat_ecdf(size=2) + mytheme + scale_y_continuous(breaks=NULL) + ylab("Cumulative distribution")
# Srvey age likelihoods
 mc.df %>% select(Model,Age_like_srv) %>% 
  ggplot(aes(x=Age_like_srv,fill=Model)) + geom_density(alpha=.4) + mytheme+ scale_y_continuous(breaks=NULL)  + xlab("Survey age composition NLL")
  ## Compared with effective Ns
   mc.df %>% select(Model,Age_like_srv,Mean_eff_N_Survey) %>% 
    ggplot(aes(x=Age_like_srv,y=Mean_eff_N_Survey, color=Model)) + geom_point(size=2,alpha=.5) + mytheme +xlab("Survey age composition NLL") + ylab("Mean survey effective N")
# Fishery age likelihoods
 mc.df %>% select(Model,Age_like_fsh) %>% 
  ggplot(aes(x=Age_like_fsh,fill=Model)) + geom_density(alpha=.4) + mytheme+ scale_y_continuous(breaks=NULL)  + xlab("Fishery age composition NLL")
 mc.df %>% select(Model,Age_like_fsh) %>% filter(Model!="Const. fish sel.") %>%
  ggplot(aes(x=Age_like_fsh,fill=Model)) + geom_density(alpha=.4) + mytheme+ scale_y_continuous(breaks=NULL) + xlab("Age composition NLL")  + xlim(c(630,740))
 mc.df %>% select(Model,Age_like_fsh) %>% filter(Model!="Const. fish sel.") %>%
  ggplot(aes(x=Age_like_fsh,color=Model)) + stat_ecdf(size=2) + mytheme + scale_y_continuous(breaks=NULL) + ylab("Cumulative distribution")+ xlim(c(630,740))
  ## Compared with effective Ns
   mc.df %>% select(Model,Age_like_fsh,Mean_eff_N_Fishery) %>% 
    ggplot(aes(x=Age_like_fsh,y=Mean_eff_N_Fishery, color=Model)) + geom_point(alpha=.4) + mytheme+xlab("Fishery age composition NLL") + ylab("Mean fishery effective N")
# Recruit prior
 mc.df %>% select(Model,Recruit_NLL) %>% 
  ggplot(aes(x=Recruit_NLL,fill=Model)) + geom_density(alpha=.4) + mytheme + scale_y_continuous(breaks=NULL)
# selectivity prior
 mc.df %>% select(Model,Selectivity_NLL) %>% 
  ggplot(aes(x=Selectivity_NLL,fill=Model)) + geom_density(alpha=.4) + mytheme + scale_y_continuous(breaks=NULL) + xlim(c(80,150))
# M prior
 mc.df %>% select(Model,M_like) %>% 
  ggplot(aes(x=M_like,fill=Model)) + geom_density(alpha=.4) + mytheme + scale_y_continuous(breaks=NULL)
# q prior
 mc.df %>% select(Model,q_like) %>% 
  ggplot(aes(x=q_like,fill=Model)) + geom_density(alpha=.4) + mytheme + scale_y_continuous(breaks=NULL)
# M+q prior
 mc.df %>% select(Model,M_like,q_like) %>% mutate(M_q_NPD=M_like+q_like) %>%
  ggplot(aes(x=M_q_NPD,fill=Model)) + geom_density(alpha=.4) + mytheme + scale_y_continuous(breaks=NULL)

# All Fmsy
 mc.df %>% select(Model,Fmsyr) %>% 
  ggplot(aes(x=Fmsyr,fill=Model)) + geom_density(alpha=.4) + mytheme+ scale_y_continuous(breaks=NULL) + xlab("Fmsy") + xlim(c(0,.3))

# Biomass 
mc.df %>% select(Model,Fmsyr,ABC_biom1) %>% ggplot(aes(x=ABC_biom1,fill=Model)) + geom_density(alpha=.4) + mytheme+ scale_y_continuous(breaks=NULL) + xlab("Biomass (kt)") 

p 
mctmp <- mc.df %>% filter(ModNum==2)%>% select(Fmsyr,ABC_biom1,ABC_biom2,ABC_biom3,ABC_biom4)
names(mctmp) <- c("Fmsyr","2019","2020","2021","2022")
mctmp <- gather(mctmp,value=Fmsyr,Year)
names(mctmp) <- c("Year", "Biomass")
p <- ggplot(mctmp,aes(x=Biomass,fill=Year)) + geom_density(alpha=.4) + xlim(c(0,3300)) + mytheme+ scale_y_continuous(breaks=NULL) + xlab("Biomass (kt)") 
p

# Catch 
mc.df %>% select(Model,Fmsyr,ABC_biom1) %>% mutate(Catch = Fmsyr*ABC_biom1) %>% ggplot(aes(x=Catch,fill=Model)) + geom_density(alpha=.4) + mytheme+ scale_y_continuous(breaks=NULL) + xlab("2019 Fmsy x Biomass")
mc.df %>% filter(ModNum==2) %>% select(Model,Fmsyr,ABC_biom1) %>% summarise(FABC=1/mean(1/Fmsyr),Biomass=exp(mean(log(ABC_biom1))),ABC=FABC*Biomass)

# q vs biomass 
mc.df %>% select(Model,Fmsyr,q_2017,ABC_biom1) %>% ggplot(aes(x=q_2017,y=ABC_biom1, color=Model)) + geom_point(alpha=.4) + mytheme + xlab("Survey catchability") + ylab("Projected biomass (kt)")
#mc.df %>% select(Model,Fmsyr,q_2017,M_Female) %>% ggplot(aes(x=q_2017,y=M_Female, color=Model)) + geom_point(alpha=.4) + mytheme + xlab("Survey catchability") + ylab("Natural mortality")

# M
#mc.df %>% select(Model,ModNum,Fmsyr,M_Female) %>% 
#	ggplot(aes(x=M_Female,fill=Model)) + geom_density(alpha=.4) + xlim(c(0.05,0.15))+ mytheme+ scale_y_continuous(breaks=NULL)
#mc.df %>% select(Model,ModNum,Fmsyr,M_Male)   %>%  filter(ModNum!=2&ModNum!=3) %>%
#	ggplot(aes(x=M_Male,fill=Model))   + geom_density(alpha=.4) + xlim(c(0.05,0.15))+ mytheme+ scale_y_continuous(breaks=NULL)

#=====================
# Retro
# get all retrospectives
#=====================
# Read in retro results
for (i in 0:10) {
  #rn=paste0("retro/r_mod2_R",i,".rep")
  rn=paste0("retro/r_mod6_R",i,".rep") #this really is model 2, copied over wrong...
  mn=paste0("retro",i)
  assign(mn,readList(rn))
  print(rn)
}
ret_fixq <- retouts 
ret_base <- retouts 
retouts <- list( R0=retro0, R1= retro1, R2= retro2, 
  R3= retro3, 
  R4= retro4 ,
  R5= retro5 ,
  R6= retro6 ,
  R7= retro7 ,
  R8= retro8 ,
  R9= retro9 ,
  R10= retro10 
  ) 
ret_newbase <- retouts
plot_ssb(ret_base,alpha=.2,xlim=c(1990,2017),ylim=c(0,1400))
plot_ssb(ret_fixq,alpha=.2,xlim=c(1990,2017),ylim=c(0,1400))
plot_ssb(ret_newbase,alpha=.2,xlim=c(1960,2017))
plot_bts(retouts[c(2,1)] ,alpha=.6)
#SSB ============================================================
df  <- data.table(Model = "Model 1", mod1$SSB )
for (i in 2:2) df <- rbind(df, data.table(Model=paste0("Model ",i),lstOuts[[i]]$SSB))
names(df) <- c("Model","yr","SSB","SE","lb","ub")
bdf <- filter(df,yr>1980,yr<=2016) %>% arrange(yr)
bdf

mc.df %>% select(Model,Fmsyr,ABC_biom1) %>% filter(Model=="Base")%>%
summarise(FOFL=mean(Fmsyr),FABC=1/mean(1/Fmsyr),Biomass=exp(mean(log(ABC_biom1))),ABC=FABC*Biomass,OFL=FOFL*Biomass,Buffer=1-ABC/OFL)
mc.df %>% select(Model,Fmsyr,ABC_biom1) %>% filter(Model=="Const_Sel")%>%
summarise(FOFL=mean(Fmsyr),FABC=1/mean(1/Fmsyr),Biomass=exp(mean(log(ABC_biom1))),ABC=FABC*Biomass,OFL=FOFL*Biomass,Buffer=1-ABC/OFL)

mc.df %>% select(Model,ABC_biom1) %>% ggplot(aes(x=ABC_biom1,fill=Model)) + geom_density(alpha=.4) + mytheme+ scale_y_continuous(breaks=NULL) + xlab("2017 Fishable biomass")
mc.df %>% select(Model,ABC_biom2) %>% ggplot(aes(x=ABC_biom2,fill=Model)) + geom_density(alpha=.4) + mytheme

# Read in example sets for illustrating obj function relative to number of params
  ex <- read_table2("ttt.rep",col_names=FALSE)
  names(ex) <- c("Npars","NLL","Mean")
  ex
  ex$sim    <- rep(1:5000,4)
  ex$Npars  <- as.factor(ex$Npars)
  ggplot(ex,aes(x=sim,y=NLL,color=Npars)) + geom_line(size=1.2) + mytheme + xlab("MCMC draw")
  ggplot(ex,aes(x=sim,y=Mean,color=Npars)) + geom_line() + mytheme + xlab("MCMC draw")
  ex %>% group_by(Npars)%>% summarise(Group_Mean=mean(Mean), Stdev=sd(Mean)*sqrt(mean(as.numeric(Npars))))
names(mc.df)
dim(mc.df)
mc.like.df <- mc.df[50:2000,c(54,5:12,14:17)] %>% mutate("SRR"=(rec_like_1+rec_like_2+rec_like_3+rec_like_4))
names(mc.like.df)
head(mc.like.df)
names(mc.like.df) <- c("M_Female","q","M","rec_like_1"," rec_like_2"," rec_like_3"," rec_like_4","Survey select","Fishery select","Catch","Survey index","Fishery age","Survey age","SRR")
mc.like.df.g <- mc.like.df %>% select("M_Female",q,M,"Survey select","Fishery select","Catch","Survey index","Fishery age","Survey age","SRR" ) %>% 
                gather(NLL,value=neg_log_posterior,2:10) 
p <- ggplot(mc.like.df.g,aes(x=M_Female,y=neg_log_posterior,color=NLL)) + ylab("-log posterior") + xlab("Female natural mortality") +
      mytheme + geom_point() + facet_wrap(~NLL,scales="free_y")  + guides(color=FALSE) 
p
# ------- Now for pairs from MCMC --------------------------------
mc.pair.df <- mc.df[50:2000,c(54,5:12,14:17)] %>% mutate("SRR"=(rec_like_1+rec_like_2+rec_like_3+rec_like_4))
mc.pair.df <- mc.df[50:2000,c(53:60,189,190,196:199)] #%>% 
                gather(Parameter,value=value,1:14) 
pairs(mc.pair.df)

 [17] "Age_like_srv"    "q_1982"          "q_1983"          "q_1984"         
 [21] "q_1985"          "q_1986"          "q_1987"          "q_1988"         
 [25] "q_1989"          "q_1990"          "q_1991"          "q_1992"         
 [29] "q_1993"          "q_1994"          "q_1995"          "q_1996"         
 [33] "q_1997"          "q_1998"          "q_1999"          "q_2000"         
 [37] "q_2001"          "q_2002"          "q_2003"          "q_2004"         
 [41] "q_2005"          "q_2006"          "q_2007"          "q_2008"         
 [45] "q_2009"          "q_2010"          "q_2011"          "q_2012"         
 [49] "q_2013"          "q_2014"          "q_2015"          "q_2016"         
 [53] "q_2017"          "M_Female"        "M_Male"          "Fmsyr"          
 [57] "ABC_biom1"       "ABC_biom2"       "Bmsy"            "MSY"            

[189] "ln_mean_R"       "F_7"             "F_8"             "F_9"            
[193] "F_10"            "F_11"            "F_12"            "sel_slope_srv_f"
[197] "sel_50_srv_f"    "sel_slope_srv_m" "sel_50_srv_m"   

?colsum
# ------- Profile M stuff
library(PBSadmb)
source("../R/prelims.R")
#rm(list=ls())
# Read in the output of the assessment
# Read in model results
i=1
M <- list(NULL)
for (i in 1:15) {
  rn=paste0("prof1/p_R",i,".rep")
  mn=paste0("mod",i)
  assign(mn,readList(rn))
  print(rn)
  #M[[i]]        <- lapply(rn, readList)
  #M[[i]]        <- list(paste0("Mod_",i) =readList(rn))
}
M <- list( "m1"=mod1, "m2" = mod2, "m3" = mod3, "m4" = mod4, "m5" = mod5, "m6" = mod6, 
	 "m7" = mod7, "m8" = mod8, "m9" = mod9, "m10" = mod10, "m11" = mod11, "m12" = mod12, 
	 "m13" = mod13)
, "m14" = mod14, "m15" = mod15)
mod15
.get_m_df(M)
# Make dataframe for prfile

	nLogPosterior(ilike) = wt_like(1); ilike++;
	nLogPosterior(ilike) = wt_like(2); ilike++;
	nLogPosterior(ilike) = wt_like(3); ilike++;
	nLogPosterior(ilike) = wt_fut_like; ilike++;
	nLogPosterior(ilike) = wt_msy_like; ilike++;
	nLogPosterior(ilike) = init_like  ; ilike++;
	nLogPosterior(ilike) = srv_like(1);   ilike++;
	nLogPosterior(ilike) = catch_like ; ilike++;
	nLogPosterior(ilike) = age_like_fsh(1); ilike++;
	nLogPosterior(ilike) = age_like_srv(1); ilike++;
	nLogPosterior(ilike) = rec_like(1); ilike++;
	nLogPosterior(ilike) = rec_like(2); ilike++;
	nLogPosterior(ilike) = rec_like(3); ilike++;
	nLogPosterior(ilike) = rec_like(4); ilike++;
	nLogPosterior(ilike) = sel_like(1); ilike++;
	nLogPosterior(ilike) = sel_like(2); ilike++;
	nLogPosterior(ilike) = q_like(1)  ; ilike++;
	nLogPosterior(ilike) = m_like     ; ilike++;
	nLogPosterior(ilike) = fpen       ; ilike++;


# ------- Biomass from MCMC -------------------------------------
biom.df <- (mc.df[,c(61:124)])
names(biom.df) <- 1954:2017
biom.df.g <- biom.df %>% gather(Year,value=Biomass,1:64)%>% mutate(year=jitter(as.numeric(Year),1)) 
ggplot(biom.df.g,aes(x=year,y=Biomass),color="red",alpha=.2) + geom_point(col="red",alpha=.2) + mytheme 
ggplot(biom.df.g,aes(x=Year,y=Biomass),alpha=.2) + geom_boxplot(fill="red") + mytheme 

# get %iles...
biom.df %>% gather(Year,value=Biomass,1:64)%>% group_by(Year) %>% summarize(Lower=quantile(Biomass,.1),Upper=quantile(Biomass,.9),median=median(Biomass))%>%ungroup()%>%mutate(Year=as.numeric(Year))%>%
  ggplot(aes(x=Year,y=median,ymin=Lower,ymax=Upper)) + geom_line() + ylab("Biomass (kt)") + geom_ribbon(fill="salmon" ,alpha=.2,col="salmon") + mytheme + expand_limits(y=0,x=c(1980,2018))

# Pull average temperature from ROMS output for survey depths <100m
# Set locale of roms data
datdir <- '~/Google Drive/ACLIM_shared/01_DATA/GitHub/ACLIM/Data/Rdata_files'
load(paste0(datdir,'/ROMSNPZ_output (1).Rdata'))
load(paste0(datdir,'/ROMS_NPZ (1).Rdata'))

csvdir <- '~/Google Drive/ACLIM_shared/01_DATA/GitHub/ACLIM/Data/ROMSNPZ_outputs/MIROC_rcp85/By_Station_csv'
csvdir <- '~/Google Drive/ACLIM_shared/01_DATA/GitHub/ACLIM/Data/ROMSNPZ_outputs/MIROC_rcp45/By_Station_csv'
bt.df <- read.csv(paste0(csvdir,'/BottomTemp_byStation.csv'),header=T)
area.df <- data.frame(read.table("strata.dat", header=T))

# make long, then group by area year, then compute area-weighted mean temps
tt <- gather(bt.df,Year,temp,X2006:X2100) %>% select(Stratum ,Year, temp) %>% 
      transmute(Year=as.numeric(str_sub(Year,2,5)),Stratum,temp )%>% group_by(Year,Stratum) %>% 
      summarize(temp=mean(temp)) %>% left_join(area.df) %>% filter(!is.na(ha)) %>% group_by(Year) %>% 
      summarize(temp = sum(temp*ha)/sum(ha))

# now need to mesh w/ model's value and calculate multiplier
bts_tem <- data.frame(read.table("bottom_temp.dat", header=T))
# Compute mean difference to rescale to mean from 2006-2017
tt$temp <- tt$temp+(filter(bts_tem,Year>2005) %>% summarize(temp=mean(tem)) - filter(tt,Year<2018) %>% summarize(temp=mean(temp)))
# Catchability equation
tt$q = exp( -1.1919e-01 + 7.3844e-02*tt$temp)
write.csv(tt,"rcp85.csv")
ggplot(tt,aes(x=Year,y=q)) + geom_line() + mytheme
ggplot(tt,aes(x=Year,y=temp)) + geom_line() + mytheme


names(area.df)
head(left_join(bt.df,area.df,by="Stratum"))
names(bt.df)
ls()
(ROMSNPZdat$modlist)
(ROMSNPZdat$MIROC_rcp85$cross)
dim(ROMSNPZdat)
names(ROMSNPZ_output)
dim(ROMSNPZ_output$MIROC_rcp85$SrvyReplicated)
(ROMSNPZ_output$MIROC_rcp85$SrvyReplicated$year)
(ROMSNPZ_output$MIROC_rcp85$SrvyReplicated$BottomTemp)
head(ROMSNPZ_output$MIROC_rcp85$station)
head(ROMSNPZ_output$MIROC_rcp85$station$BottomTemp)
load("/Users/jim/Google Drive/ACLIM_shared/01_DATA/GitHub/ACLIM/Data/ROMSNPZ_outputs/CESM_rcp85/CESM_rcp85_metadat.Rdata")
names(meta.data)
dim(meta.data)

bt.df <- data.frame(ROMSNPZ_output$MIROC_rcp85$station$BottomTemp)
dim(bt.df)
(bt.df[1:10,1:10 ])

