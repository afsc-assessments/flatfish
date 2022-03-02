#This set of code includes instructions for putting together the input file for the fm model (yfs_2021.dat, etc.)

#For any RACEBASE queries, YFS is 10210.
#In Obsint (observer database), YFS is 140.
#AI catches of YFS are considered  negligible so the AI data is not used in the assessment.


#Update oac_fsh_s (split sex fishery age compositions)
#AKFIN matched obsint exactly except in some years 1991, 1993-1997 when obsint did not return anything.
#So AKFIN data seemed fine to use. Here is the query details:
#AKFIN observer age frequency norpac age report species Name is equal to YELLOWFIN SOLE and	Age FMP Area is equal to BSAI and	Age FMP Subarea is equal to BS

#Fishery weight at age - go to AKFIN and BE SURE to download the flattened age file! I selected
#all years and Yellowfin sole in the Bering Sea only (not the AI)

age_file=read.csv("/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/norpac_age_report_flattened_YFS_10_20_21.csv")
yrs=as.numeric(names(table(age_file$Year)))
oacmat_f2021=matrix(0,length(seq(1990,2021,1)),40)#goes up to age 40
oacmat_m2021=matrix(0,length(seq(1990,2021,1)),40)
for(i in 1:length(yrs)){
 for(j in 1:40){
  oacmat_f2021[i,j]=length(age_file$Age[which(age_file$Year==yrs[i]&age_file$Age==j&age_file$Sex=="F")])
  oacmat_m2021[i,j]=length(age_file$Age[which(age_file$Year==yrs[i]&age_file$Age==j&age_file$Sex=="M")])
  print(yrs[i])
 }
}
write.csv(oacmat_f2021,"/Users/ingridspies/Downloads/oacmat_f2020.csv")
write.csv(oacmat_m2021,"/Users/ingridspies/Downloads/oacmat_m2021.csv")

#How many fishery ages per year?
nages=vector()
for(i in 1:length(yrs)){
 nages[i]=length(age_file$Age[which(age_file$Year==yrs[i]&age_file$Age>0)])
}

cbind(yrs,nages)


#Get proportion of males and females in the random fishery lengths to apply to the fishery age comp data.
propF=vector()
propM=vector()
for(i in 1:length(yrs)){
 propF[i]=length(age_file$Length..cm.[which(age_file$Year==yrs[i]&age_file$Length..cm.>0&age_file$Sex=="F")])/length(age_file$Length..cm.[which(age_file$Year==yrs[i]&age_file$Length..cm.>0)])
 propM[i]=length(age_file$Length..cm.[which(age_file$Year==yrs[i]&age_file$Length..cm.>0&age_file$Sex=="M")])/length(age_file$Length..cm.[which(age_file$Year==yrs[i]&age_file$Length..cm.>0)])
}

#why different sex ratio in some years? Temperature? Timing?
plot(yrs,propF,ylim=c(0,1))
lines(yrs,propM)

#To create oac_fsh_s you first need to get age data (above). Then you need to get fishery length comps.
#This data comes from AKFIN in the observer section on observer lengths.
length_file=read.csv("/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/norpac_length_report_YFS_10_6_21.csv")

yrs=seq(2018,2021,1)
oac_lenmat_F21=matrix(0,length(yrs),80)
colnames(oac_lenmat_F21)=seq(1,80,1)
rownames(oac_lenmat_F21)=yrs
oac_lenmat_M21=oac_lenmat_F21

for(i in 1:length(yrs)){
 for(j in 1:80){
  oac_lenmat_F21[i,j]=sum(length_file$Frequency[which(length_file$Year==yrs[i]&length_file$Length..cm.==j&length_file$Sex=="F")])
  oac_lenmat_M21[i,j]=sum(length_file$Frequency[which(length_file$Year==yrs[i]&length_file$Length..cm.==j&length_file$Sex=="M")])
 }
}


#Set up fishery age comps for the same set of years 
yrs=c(2018,2019,2020,2021)#note no aged data from 2021 yet.
Final_agematfishery=matrix(0,4,40)
for(k in 1:length(yrs)){
oac_LenAge_F=matrix(0,80,39)#80 lengths,39ages
oac_LenAge_M=matrix(0,80,39)#80 lengths,39ages
rownames(oac_LenAge_F)=seq(1,80,1);rownames(oac_LenAge_M)=seq(1,80,1)
colnames(oac_LenAge_F)=seq(1,39,1);colnames(oac_LenAge_M)=seq(1,39,1)
for(j in 1:39){
 for (i in 1:80){
  oac_LenAge_F[i,j]=nrow(age_file[which(age_file$Year==yrs[k]&age_file$Length..cm.==i&age_file$Sex=="F"&age_file$Age>0&age_file$Age==j),])
  oac_LenAge_M[i,j]=nrow(age_file[which(age_file$Year==yrs[k]&age_file$Length..cm.==i&age_file$Sex=="M"&age_file$Age>0&age_file$Age==j),])
   }
}

#Fishery Females - normalize so that each age proportions at each length sum to 1.
T1_f=oac_LenAge_F/rowSums(oac_LenAge_F)
#apply length frequencies to the proportion of age at length matrix
T2_f=oac_lenmat_F21[k,]*T1_f   #What about converting lengths to weights here
#The problem is that it does not take into account different weights at age in each year.
#sum over columns and normalize to 1
T3_f=colSums(T2_f,na.rm=TRUE)/sum(T2_f,na.rm=TRUE)
#create 20plus group
T4_f=c(T3_f[1:19],sum(T3_f[20:39]))#Then you will multiply by the proportion of females lengthed in the entire fishery for that year, and enter it into data file as a single matrix that sums to 1 for males and females.
PF=sum(oac_lenmat_F21[k,])/sum(oac_lenmat_F21[k,]+oac_lenmat_M21[k,])
T4_f_P=T4_f*PF

#2019 Fishery Males
T1_m=oac_LenAge_M/rowSums(oac_LenAge_M)
#apply length frequencies to the proportion of age at length matrix
T2_m=oac_lenmat_M21[k,]*T1_m
#sum over columns and normalize to 1
T3_m=colSums(T2_m,na.rm=TRUE)/sum(T2_m,na.rm=TRUE)
#create 20plus group
T4_m=c(T3_m[1:19],sum(T3_m[20:39]))#Then you will multiply by the proportion of females lengthed in the entire fishery for that year, and enter it into data file as a single matrix that sums to 1 for males and females.
PM=sum(oac_lenmat_M21[k,])/sum(oac_lenmat_F21[k,]+oac_lenmat_M21[k,])
T4_m_P=T4_m*PM

Final_agematfishery[k,]=c(T4_f_P,T4_m_P)#add to oac_fish_s row for 2019
}

#Final_agematfishery is the matrix of agecomps to use in oac_fsh_s.
#Note that there is no age data in final year.

#There are 2 options for wt_fsh_in. One is what I do below. The other is Jim Ianellis sampler code which does resampling over seasons.

agez=as.numeric(names(table(age_file$Age)))#2-40
table(age_file$Length..cm.)#7-58
table(age_file$Sex)
yrs=as.numeric(names(table(age_file$Year)))#1990-2021
#remove samples with weights >4kg. They are anomalies...probably wrong units.
age_file=age_file[which(age_file$Weight..kg.<4),]

#matrix of weight at age - from flattened norpac age specimen dataset
mat_wtageF=matrix(0,length(yrs),20)
agez=seq(1,20,1)
colnames(mat_wtageF)=agez
rownames(mat_wtageF)=yrs
mat_wtageM=mat_wtageF
plusgrp=vector()
for(i in 1:length(yrs)){
 for(j in 1:20){
  mat_wtageF[i,j]=mean(age_file$Weight..kg.[which(age_file$Year==yrs[i]&age_file$Age==agez[j]&age_file$Sex=='F')],na.rm=TRUE)
  mat_wtageF[i,20]=mean(age_file$Weight..kg.[which(age_file$Year==yrs[i]&age_file$Age>19&age_file$Sex=='F')],na.rm=TRUE)
  mat_wtageM[i,j]=mean(age_file$Weight..kg.[which(age_file$Year==yrs[i]&age_file$Age==agez[j]&age_file$Sex=='M')],na.rm=TRUE)
  mat_wtageM[i,20]=mean(age_file$Weight..kg.[which(age_file$Year==yrs[i]&age_file$Age>19&age_file$Sex=='M')],na.rm=TRUE)
     }
}   
mat_wtage2F=round(mat_wtageF*1000,0)
mat_wtage2M=round(mat_wtageM*1000,0)

write.csv(mat_wtage2F,"/Users/ingridspies/Downloads/mat_wtage2F.csv")
write.csv(mat_wtage2M,"/Users/ingridspies/Downloads/mat_wtage2M.csv")


#wts are in kg, so convert

#Since ages 1-3 are rare in the survey data find mean over all years length at those ages, all 3 sexes.
#Age 1 (1 record) srv_age2M[which(srv_age2$AGE==1),] 78.03666, 
sum(srv_age$AGEPOP[which(srv_age$AGE==1&srv_age$AGEPOP>0)]*srv_age$MEANLEN[which(srv_age$AGE==1&srv_age$AGEPOP>0)])/sum(srv_age$AGEPOP[which(srv_age$AGE==1&srv_age$AGEPOP>0)])

#Age 2  98.37778
sum(srv_age$AGEPOP[which(srv_age$AGE==2&srv_age$AGEPOP>0)]*srv_age$MEANLEN[which(srv_age$AGE==2&srv_age$AGEPOP>0)])/sum(srv_age$AGEPOP[which(srv_age$AGE==2&srv_age$AGEPOP>0)])

#Age 3  125.7847
sum(srv_age$AGEPOP[which(srv_age$AGE==3&srv_age$AGEPOP>0)]*srv_age$MEANLEN[which(srv_age$AGE==3&srv_age$AGEPOP>0)])/sum(srv_age$AGEPOP[which(srv_age$AGE==3&srv_age$AGEPOP>0)])

#Age 4
sum(srv_age$AGEPOP[which(srv_age$AGE==4&srv_age$AGEPOP>0)]*srv_age$MEANLEN[which(srv_age$AGE==4&srv_age$AGEPOP>0)])/sum(srv_age$AGEPOP[which(srv_age$AGE==4&srv_age$AGEPOP>0)])
#148.6219

#Age 5
sum(srv_age$AGEPOP[which(srv_age$AGE==5&srv_age$AGEPOP>0)]*srv_age$MEANLEN[which(srv_age$AGE==5&srv_age$AGEPOP>0)])/sum(srv_age$AGEPOP[which(srv_age$AGE==5&srv_age$AGEPOP>0)])
#174.7592

#Add to each length curve as many as needed (for fishery add ages 1-5)
#c(78.03666,98.37778,125.7847,148.6219,174.7592)
#c(1,2,3,4,5)

#Survey weight at age
#wt_srv_Females
srv_wtage=read.csv("/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/yfs_survey_raw_age_weight.csv",header=TRUE)
table(srv_wtage$REGION)#some GOA and BS in here.
table(srv_wtage$Year[which(srv_wtage$REGION=='BS')])#do 1982 and later

yrs=seq(1982,2021,1)[-39]
mat_wtage_srv_F=matrix(0,length(yrs),20)
colnames(mat_wtage_srv_F)=seq(1,20,1)
rownames(mat_wtage_srv_F)=yrs
mat_wtage_srv_M=mat_wtage_srv_F
age=seq(1,20,1)
for (i in 1:length(yrs)){
 for(j in 1:19){
 mat_wtage_srv_F[i,j]=mean(srv_wtage$WEIGHT[which(srv_wtage$Year==yrs[i]&srv_wtage$AGE==age[j]&srv_wtage$SEX=='2')])
 mat_wtage_srv_F[i,20]=mean(srv_wtage$WEIGHT[which(srv_wtage$Year==yrs[i]&srv_wtage$AGE>19&srv_wtage$SEX=='2')])
 mat_wtage_srv_M[i,j]=mean(srv_wtage$WEIGHT[which(srv_wtage$Year==yrs[i]&srv_wtage$AGE==age[j]&srv_wtage$SEX=='1')])
 mat_wtage_srv_M[i,20]=mean(srv_wtage$WEIGHT[which(srv_wtage$Year==yrs[i]&srv_wtage$AGE>19&srv_wtage$SEX=='1')])
   }
}
write.csv(round(mat_wtage_srv_F),"/Users/ingridspies/Downloads/mat_wtage_srv_F.csv")
write.csv(round(mat_wtage_srv_M),"/Users/ingridspies/Downloads/mat_wtage_srv_M.csv")
#males age 1 just add 4g for weight and females add 6g for weight.

#The final year is this years survey adn typically the same weight age is used for that year as the previous survey.


#Get survey age frequencies. These were normalized to the observed length frequencies in the population and These are just normalized so that males and females add to 1.
srv_age=read.csv("/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/survey/yellowfin_sole_agecomp_ebs_plusNW.csv",header=TRUE)

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


#Get length distribution by NMFS area for figure obs_sizecomp
#only from trawlers (gear=1 non pelagic trawl or 2 pelagic trawl)
#maybe switch to the length rather than age file.
table(age_file$NMFS.Area)
table(age_file$Length..cm.)#use 7-58cm
lens=seq(7,58,1)
areas=c(509,513,514,516,517,521,524)
lensM=matrix(0,length(lens),length(areas))
colnames(lensM)=areas;rownames(lensM)=lens
lensF=lensM
for(i in 1:length(lens)){
 for(j in 1:length(areas)){
  lensM[i,j]=nrow(age_file[which(age_file$Length..cm.==lens[i]&age_file$Sex=="M"&age_file$NMFS.Area==areas[j]&age_file$Gear<3),])
  lensF[i,j]=nrow(age_file[which(age_file$Length..cm.==lens[i]&age_file$Sex=="F"&age_file$NMFS.Area==areas[j]&age_file$Gear<3),])
  
 }
}

write.csv(lensM,"/Users/ingridspies/admbmodels/flatfish/assessments/yfs/doc/2021/lensM.csv")
write.csv(lensF,"/Users/ingridspies/admbmodels/flatfish/assessments/yfs/doc/2021/lensF.csv")

lensM=read.csv("/Users/ingridspies/admbmodels/flatfish/assessments/yfs/doc/2021/lensM.csv",header=TRUE)
lensF=read.csv("/Users/ingridspies/admbmodels/flatfish/assessments/yfs/doc/2021/lensF.csv",header=TRUE)


#Here is a nice script for fitting growth just in case (not used here)
#Smooth using VB growth Females age to length
VBf=growth(intype=2,unit=1,size=c(78.03666,98.37778,125.7847,148.6219,174.7592,10*agelen_yrF[,2]),age=c(1,2,3,4,5,agelen_yrF[,1]),
           calctype=1,wgtby=1,error=1,Sinf=6000,K=0.3,t0=-1)
P=summary(VBf$vout)$parameters[,1]
age=seq(1,40,1);Sinf=P[1];K=P[2];t0=P[3]
females=Sinf*(1-exp(-(K*(age-t0))))

#Fitting length to weight
#install.packages("stats",repos="https://cloud.r-project.org")
library(stats)
y=Lenwt1990_2021$Weight[which(Lenwt1990_2021$Year==2021)]
x=Lenwt1990_2021$Length[which(Lenwt1990_2021$Year==2021)]
outwl=nls(y~a*x^b,start=list(a=.003915,b=3.2232))
a=0.006395; b=3.162255
