#Update oac_fsh_s (split sex fishery age compositions)

#THis was the AKFIN age comps. It seems like AKFIN matched obsint exactly
#except in some years 1991, 1993-1997 when obsint did not return anything.
#AKFIN HERE
oac=read.csv("/Users/ingridspies/admbmodels/flatfish/assessments/yfs/doc/norpac_age_report_YFS_10_1_20.csv",header=TRUE)
yrs=as.numeric(names(table(oac$Year)))
oacmat_f=matrix(0,length(seq(1990,2020,1)),39)
oacmat_m=matrix(0,length(seq(1990,2020,1)),39)
for(i in 1:length(yrs)){
 for(j in 1:39){
  oacmat_f[i,j]=length(oac$Age[which(oac$Year==yrs[i]&oac$Age==j&oac$Sex=="F")])
  oacmat_m[i,j]=length(oac$Age[which(oac$Year==yrs[i]&oac$Age==j&oac$Sex=="M")])
  
  print(yrs[i])
 }
}

#Get length distribution by NMFS area for figure obs_sizecomp
table(oac$NMFS.Area)
table(oac$Length..cm.)#use 7-58cm
lens=seq(7,58,1)
areas=c(509,513,514,516,517,521,524)
lensM=matrix(0,length(lens),length(areas))
colnames(lensM)=areas;rownames(lensM)=lens
lensF=lensM
for(i in 1:length(lens)){
 for(j in 1:length(areas)){
  lensM[i,j]=nrow(oac[which(oac$Length..cm.==lens[i]&oac$Sex=="M"&oac$NMFS.Area==areas[j]&oac$Gear<3),])
  lensF[i,j]=nrow(oac[which(oac$Length..cm.==lens[i]&oac$Sex=="F"&oac$NMFS.Area==areas[j]&oac$Gear<3),])
  
   }
}

write.csv(lensM,"/Users/ingridspies/admbmodels/flatfish/assessments/yfs/doc/lensM.csv")
write.csv(lensF,"/Users/ingridspies/admbmodels/flatfish/assessments/yfs/doc/lensF.csv")


#OBSINT here
oac1=read.csv("/Users/ingridspies/admbmodels/flatfish/assessments/yfs/doc/yfs_allyrs_obsint_age_wt_len.csv",header=TRUE)
yrs=seq(1990,2020,1)
oacmat_f1=matrix(0,length(yrs),39)
oacmat_m1=matrix(0,length(yrs),39)
#matrix of length at age from the fishery
for(i in 1:length(yrs)){
 for(j in 1:39){
  oacmat_f1[i,j]=length(oac1$AGE[which(oac1$YEAR==yrs[i]&oac1$AGE==j&oac1$SEX=="F")])
  oacmat_m1[i,j]=length(oac1$AGE[which(oac1$YEAR==yrs[i]&oac1$AGE==j&oac1$SEX=="M")])
  print(yrs[i])
 }
}
rownames(oacmat_f1)=yrs
rownames(oacmat_m1)=yrs

f=c(oacmat_f1[30,1:19],sum(oacmat_f1[30,20:39]))
f1=f/sum(f)

m=c(oacmat_m1[30,1:19],sum(oacmat_m1[30,20:39]))
m1=m/sum(m)

oacmat_f-oacmat_f1 #this shows mostly the same data just not the missing years.

#try mean weight at age
wtage_ff=matrix(0,length(yrs),20)
colnames(wtage_ff)=seq(1,20,1);rownames(wtage_ff)=seq(1990,2020,1)
wtage_mf=wtage_ff
for(i in 1:length(yrs)){
 for(j in 1:19){
  wtage_ff[i,j]=round(1000*mean(oac1$WEIGHT_KG[which(oac1$AGE==j&oac1$YEAR==yrs[i]&oac1$SEX=="F")]),3)
  wtage_mf[i,j]=round(1000*mean(oac1$WEIGHT_KG[which(oac1$AGE==j&oac1$YEAR==yrs[i]&oac1$SEX=="M")]),3)
  wtage_ff[i,20]=round(1000*mean(oac1$WEIGHT_KG[which(oac1$AGE>19&oac1$YEAR==yrs[i]&oac1$SEX=="F")]),3)
  wtage_mf[i,20]=round(1000*mean(oac1$WEIGHT_KG[which(oac1$AGE>19&oac1$YEAR==yrs[i]&oac1$SEX=="M")]),3)
   }
}

#try years 2006:2016 to compare with TomWs work. These are years 17:27
#try weighted by number of otoliths read. Nope that does not match.
colSums(rowSums(oacmat_f1)[17:27]*wtage_ff[17:27,],na.rm=TRUE)/sum(rowSums(oacmat_f1)[17:27])
colSums(rowSums(oacmat_m1)[17:27]*wtage_mf[17:27,],na.rm=TRUE)/sum(rowSums(oacmat_m1)[17:27])

#he just took means from 2006-2016 and used them for all years after 2007.


#To create oac_fsh_s you first need to get age data (above). Then you need to get fishery length comps.
oac_lens=read.csv("/Users/ingridspies/admbmodels/flatfish/assessments/yfs/doc/YFS_fisherylengths_2018_2019.csv",header=TRUE)

oac_lenmat_F=matrix(0,2,80)
colnames(oac_lenmat_F)=seq(1,80,1)
rownames(oac_lenmat_F)=c(2018,2019)
oac_lenmat_M=oac_lenmat_F
yrs=c(2018,2019)

#Create vectors of length frequencies from the fishery
for(i in 1:2){
 for(j in 1:80){
  oac_lenmat_F[i,j]=sum(oac_lens$Frequency[which(oac_lens$Year==yrs[i]&oac_lens$Length_cm==j&oac_lens$Sex=="F")])
  oac_lenmat_M[i,j]=sum(oac_lens$Frequency[which(oac_lens$Year==yrs[i]&oac_lens$Length_cm==j&oac_lens$Sex=="M")])
  
   }
}

#there are not as many lengths for 2018 as TomW had. 119242	females 94783 males
#here I have 107638 females and 84865 males

#AKFIN data is fine. so use it to do a length/age matrix for 2018 and compare with TomWs
#1 set up matrix of length by age from read otoliths in 2019 
#This is a sparse matrix but it has all ages and lenghts from 2019
oac_LenAge_F=matrix(0,80,39)#80 lengths,39ages
rownames(oac_LenAge_F)=seq(1,80,1)
colnames(oac_LenAge_F)=seq(1,39,1)
for(j in 1:39){
 for (i in 1:80){
  oac_LenAge_F[i,j]=length(oac$Age[which(oac$Year==2018&oac$Length..cm.==i&oac$Age==j&oac$Sex=="F")])
 }
}
write.csv(oac_LenAge_F,"/Users/ingridspies/Downloads/oac_LenAge_F.csv")

#Test TomWs female length comps with this 8-49
#2 Make vector of length frequencies from fishery for the same lenghts as rows of matrix
TW_LF_fem2018=c(0,0,0,0,0,0,0,4,	3,5	,12	,11	,23,	45,	73,	83,	127,	143,	211,	233,	331,	518,	916,	1562,	2367,	3282,	4032	,4306,	4738,	5414,	6640,	8786,	11158,	12849,	13295,	12079,	9793,	7085,	4550,	2468,	1181,	506,	239,	78	,45	,21,	13,	10,	7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
#Normalization step 1. Turn numbers at age into proportions of age at each length so ages at each length sum to 1.
T1=oac_LenAge_F/rowSums(oac_LenAge_F)
#apply length frequencies to the proportion of age at length matrix
T2=TW_LF_fem2018*T1
#sum over columns and normalize to 1
T3=colSums(T2,na.rm=TRUE)/sum(T2,na.rm=TRUE)
#create 20plus group
T4=c(T3[1:19],sum(T3[20:39]))#Then you will multiply by the proportion of females lengthed in the entire fishery for that year, and enter it into data file as a single matrix that sums to 1 for males and females.

#Set up fishery age comps for 2019 (will need to re-pull fishery lenghts with obsint)
oac_LenAge_F=matrix(0,80,39)#80 lengths,39ages
oac_LenAge_M=matrix(0,80,39)#80 lengths,39ages
rownames(oac_LenAge_F)=seq(1,80,1);rownames(oac_LenAge_M)=seq(1,80,1)
colnames(oac_LenAge_F)=seq(1,39,1);colnames(oac_LenAge_M)=seq(1,39,1)
for(j in 1:39){
 for (i in 1:80){
  oac_LenAge_F[i,j]=nrow(oac1[which(oac1$YEAR=="2019"&oac1$LENGTH_CM==i&oac1$SEX=="F"&oac1$AGE>0&oac1$AGE==j),])
  oac_LenAge_M[i,j]=nrow(oac1[which(oac1$YEAR=="2019"&oac1$LENGTH_CM==i&oac1$SEX=="M"&oac1$AGE>0&oac1$AGE==j),])
   }
}

#Get vector of length freqs from fishery (need to redo from obsint)
#proportion at age yrs_fsh_age_split  oac_fsh
#Create vectors of length frequencies from the fishery
oac_lenmat_F[2,]#fishery vector of lengths for 2019 there were 114,728
oac_lenmat_M[2,]#fishery vector of lengths for 2019 there were 86,094

#2019 Fishery Females
T1_f=oac_LenAge_F/rowSums(oac_LenAge_F)
#apply length frequencies to the proportion of age at length matrix
T2_f=oac_lenmat_F[2,]*T1_f
#sum over columns and normalize to 1
T3_f=colSums(T2_f,na.rm=TRUE)/sum(T2_f,na.rm=TRUE)
#create 20plus group
T4_f=c(T3_f[1:19],sum(T3_f[20:39]))#Then you will multiply by the proportion of females lengthed in the entire fishery for that year, and enter it into data file as a single matrix that sums to 1 for males and females.
PF=sum(oac_lenmat_F[2,])/sum(oac_lenmat_F[2,]+oac_lenmat_M[2,])
T4_f_P=T4_f*PF

#2019 Fishery Males
T1_m=oac_LenAge_M/rowSums(oac_LenAge_M)
#apply length frequencies to the proportion of age at length matrix
T2_m=oac_lenmat_M[2,]*T1_m
#sum over columns and normalize to 1
T3_m=colSums(T2_m,na.rm=TRUE)/sum(T2_m,na.rm=TRUE)
#create 20plus group
T4_m=c(T3_m[1:19],sum(T3_m[20:39]))#Then you will multiply by the proportion of females lengthed in the entire fishery for that year, and enter it into data file as a single matrix that sums to 1 for males and females.
PM=sum(oac_lenmat_M[2,])/sum(oac_lenmat_F[2,]+oac_lenmat_M[2,])
T4_m_P=T4_m*PM

sum(T4_f_P   +T4_m_P)

c(T4_f_P,T4_m_P)#add to oac_fish_s row for 2019

#Get survey age frequencies. These were normalized to the observed length frequencies in the population and These are just normalized so that males and females add to 1.
srv_age=read.csv("/Users/ingridspies/admbmodels/flatfish/assessments/yfs/doc/survey/yellowfin_sole_agecomp_ebs_plusNW.csv",header=TRUE)

yrs=names(table(srv_age$YEAR))
agematF=matrix(0,length(yrs),20)
colnames(agematF)=seq(1,20,1);rownames(agematF)=yrs
agematM=agematF

for(i in 1:length(yrs)){
 for(j in 1:19){
  agematF[i,j]=sum(srv_age$AGEPOP[which(srv_age$YEAR==yrs[i]&srv_age$AGE==j&srv_age$SEX==2)])
  agematM[i,j]=sum(srv_age$AGEPOP[which(srv_age$YEAR==yrs[i]&srv_age$AGE==j&srv_age$SEX==1)])
  agematF[i,20]=sum(srv_age$AGEPOP[which(srv_age$YEAR==yrs[i]&srv_age$AGE>19&srv_age$SEX==2)])
  agematM[i,20]=sum(srv_age$AGEPOP[which(srv_age$YEAR==yrs[i]&srv_age$AGE>19&srv_age$SEX==1)])
 }
}
agematF_n=agematF/rowSums(agematF)
agematM_n=agematM/rowSums(agematM)
agematF_nn=agematF_n*(rowSums(agematF)/(rowSums(agematF)+rowSums(agematM)))
agematM_nn=agematM_n*(rowSums(agematM)/(rowSums(agematF)+rowSums(agematM)))

srvage_2019=c(agematF_nn[38,],agematM_nn[38,])
sum(srvage_2019)

plot(YFS2$TotBiom,ylab="BiomassX1000t",xlab="Year")
lines(YFS5$TotBiom)
legend("topleft",c("2019 wt_fsh","2020 wt_fish"),pch=c(1,-1),lty=c(-1,1))


plot(YFS2$SSB,ylab="Female Spawning Biomass X1000t",xlab="Year")
lines(YFS5$SSB)
legend("topleft",c("2019 wt_fsh","2020 wt_fish"),pch=c(1,-1),lty=c(-1,1))


#YFS things to do later
#figure out Jim's catch at age protocol.
#adjust the wt_pop_f and wt_pop_m so that it might represent a different time of the year...like spawning time? Summer?

#Note YFS2$wt_srv_f-YFS2$wt_pop_f these are the same right now.


#Get research catch
rescat=read.csv("/Users/ingridspies/admbmodels/flatfish/assessments/yfs/doc/NoncommercialFishery CatchYFS_10_23_20.csv")
yrs=as.numeric(names(table(rescat$Year)))
res=matrix(0,length(yrs),1)
for(i in 1:length(yrs)){
 res[i]=sum(rescat$Weight[which(rescat$Year==yrs[i])])
}

cbind(yrs,round(res/1000,0))

#Get the number of fishery ages for each year.
yrs=names(table(oac1$YEAR))
fishages=vector()
for(i in 1:length(yrs)){
 fishages[i]=length(oac1$AGE[which(oac1$AGE>0&oac1$YEAR==yrs[i])])
}
cbind(yrs,fishages)



