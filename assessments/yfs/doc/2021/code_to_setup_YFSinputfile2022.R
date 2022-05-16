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
yrs=seq(1982,2021,1)
matfsh_wtageF=matrix(0,length(yrs),20)
agez=seq(1,20,1)
colnames(matfsh_wtageF)=agez
rownames(matfsh_wtageF)=yrs
matfsh_wtageM=matfsh_wtageF
plusgrp=vector()
for(i in 1:length(yrs)){
 for(j in 1:20){
  matfsh_wtageF[i,j]=mean(age_file$Weight..kg.[which(age_file$Year==yrs[i]&age_file$Age==agez[j]&age_file$Sex=='F')],na.rm=TRUE)
  matfsh_wtageF[i,20]=mean(age_file$Weight..kg.[which(age_file$Year==yrs[i]&age_file$Age>19&age_file$Sex=='F')],na.rm=TRUE)
  matfsh_wtageM[i,j]=mean(age_file$Weight..kg.[which(age_file$Year==yrs[i]&age_file$Age==agez[j]&age_file$Sex=='M')],na.rm=TRUE)
  matfsh_wtageM[i,20]=mean(age_file$Weight..kg.[which(age_file$Year==yrs[i]&age_file$Age>19&age_file$Sex=='M')],na.rm=TRUE)
 }
}   
matfsh_wtage2F=round(matfsh_wtageF*1000,0)
matfsh_wtage2M=round(matfsh_wtageM*1000,0)
#wts are in kg, so convert
write.csv(matfsh_wtage2F,"/Users/ingridspies/Downloads/matfsh_wtage2F.csv")
write.csv(matfsh_wtage2M,"/Users/ingridspies/Downloads/matfsh_wtage2M.csv") 


#########################REDO SURVEY AND WT_POP_IN YFS WEIGHT AT AGE.
#I need to redo the survey weight at age for 2021 because 2020 and previous values were fixed and not based entirely on data.
#1.compile all the length weight data and estimate the a and b of a*L^b
#2.compute mean length at age for all years
#3.compute mean wts given those mean lengths using a*Lbar^b for each age and year.
#4.Compare maybe with the the mean weights you already computed...

#Survey weight at age
#wt_srv_Females
#srv_wtage=read.csv("/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/yfs_survey_raw_age_weight.csv",header=TRUE)
srv_wtage=read.csv("/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/survey_wtage/YFSageSurvey1954_2021.csv",header=TRUE)
table(srv_wtage$REGION)#some GOA and BS in here.
table(srv_wtage$Year[which(srv_wtage$REGION=='BS')])#do all possible years 1971 and later

yrs=seq(1971,2021,1)
mat_wtage_srv_F=matrix(0,length(yrs),20)
colnames(mat_wtage_srv_F)=seq(1,20,1)
rownames(mat_wtage_srv_F)=yrs
mat_wtage_srv_M=mat_wtage_srv_F
age=seq(1,20,1)
for (i in 1:length(yrs)){
 for(j in 1:19){
 mat_wtage_srv_F[i,j]=mean(srv_wtage$WEIGHT[which(srv_wtage$Year==yrs[i]&srv_wtage$AGE==age[j]&srv_wtage$SEX=='2'&srv_wtage$REGION=="BS")],na.rm=TRUE)
 mat_wtage_srv_F[i,20]=mean(srv_wtage$WEIGHT[which(srv_wtage$Year==yrs[i]&srv_wtage$AGE>19&srv_wtage$SEX=='2'&srv_wtage$REGION=="BS")],na.rm=TRUE)
 mat_wtage_srv_M[i,j]=mean(srv_wtage$WEIGHT[which(srv_wtage$Year==yrs[i]&srv_wtage$AGE==age[j]&srv_wtage$SEX=='1'&srv_wtage$REGION=="BS")],na.rm=TRUE)
 mat_wtage_srv_M[i,20]=mean(srv_wtage$WEIGHT[which(srv_wtage$Year==yrs[i]&srv_wtage$AGE>19&srv_wtage$SEX=='1'&srv_wtage$REGION=="BS")],na.rm=TRUE)
   }
}
#write.csv(mat_wtage_srv_F,"/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/mat_wtage_srv_F.csv")
#write.csv(mat_wtage_srv_M,"/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/mat_wtage_srv_M.csv")

mat_wtage_srv_F=read.csv("/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/mat_wtage_srv_F.csv",header=TRUE)
mat_wtage_srv_M=read.csv("/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/mat_wtage_srv_M.csv",header=TRUE)


#Here I compile all the length weight data
yrs=seq(1971,2021,1)
mat_lenage_srv_F=matrix(0,length(yrs),20)
colnames(mat_lenage_srv_F)=seq(1,20,1)
rownames(mat_lenage_srv_F)=yrs
mat_lenage_srv_M=mat_lenage_srv_F
for (i in 1:length(yrs)){
 for(j in 1:19){
  mat_lenage_srv_F[i,j]=mean(srv_wtage$LENGTH[which(srv_wtage$Year==yrs[i]&srv_wtage$AGE==age[j]&srv_wtage$SEX=='2'&srv_wtage$REGION=="BS")],na.rm=TRUE)
  mat_lenage_srv_F[i,20]=mean(srv_wtage$LENGTH[which(srv_wtage$Year==yrs[i]&srv_wtage$AGE>19&srv_wtage$SEX=='2'&srv_wtage$REGION=="BS")],na.rm=TRUE)
  mat_lenage_srv_M[i,j]=mean(srv_wtage$LENGTH[which(srv_wtage$Year==yrs[i]&srv_wtage$AGE==age[j]&srv_wtage$SEX=='1'&srv_wtage$REGION=="BS")],na.rm=TRUE)
  mat_lenage_srv_M[i,20]=mean(srv_wtage$LENGTH[which(srv_wtage$Year==yrs[i]&srv_wtage$AGE>19&srv_wtage$SEX=='1'&srv_wtage$REGION=="BS")],na.rm=TRUE)
 }
}
#write.csv(mat_lenage_srv_F,"/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/mat_lenage_srv_F.csv")
#write.csv(mat_lenage_srv_M,"/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/mat_lenage_srv_M.csv")

mat_lenage_srv_F=read.csv("/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/mat_lenage_srv_F.csv",header=TRUE)
mat_lenage_srv_M=read.csv("/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/mat_lenage_srv_M.csv",header=TRUE)

#Here is estimate the a and b of a*L^b
#Fitting length to weight to fill in gaps in weight at ages
#install.packages("stats",repos="https://cloud.r-project.org")
library(stats)
agewts=data.frame(cbind(srv_wtage$LENGTH,srv_wtage$WEIGHT,srv_wtage$SEX))
colnames(agewts)=c("Length","Weight","Sex")
agewtsF=agewts[which(agewts$Length>0&agewts$Weight>0&agewts$Sex==2),]
agewtsM=agewts[which(agewts$Length>0&agewts$Weight>0&agewts$Sex==1),]

x=agewtsF$Weight;y=agewtsF$Length/10
outalF=nls(x~a*y^b,start=list(a=.003915,b=3.2232))
aF=0.005868; bF=3.205037 
plot(agewtsF$Length/10,agewtsF$Weight,ylab="Weight (g)",xlab="Length (cm)",main="Female Length-Weight relationship",cex.lab=1.4,cex.axis=1.4)
lines(seq(1,500,1),aF*seq(1,500,1)^bF,lwd=2,col="red")

x=agewtsM$Weight;y=agewtsM$Length/10
outalM=nls(x~a*y^b,start=list(a=.003915,b=3.2232))
aM=0.009102; bM=3.067694 
plot(agewtsM$Length/10,agewtsM$Weight,ylab="Weight (g)",xlab="Length (cm)",main="Male Length-Weight relationship",cex.lab=1.4,cex.axis=1.4)
lines(seq(1,500,1),(aM*seq(1,500,1)^bM),lwd=2,col="red")

#3.compute mean wts given those mean lengths using a*Lbar^b for each age and year.
#Convert mean lengths at age to weight
mat_lenage_srv_F_wtcalc=aF*(mat_lenage_srv_F[,2:21]/10)^bF
mat_lenage_srv_M_wtcalc=aM*(mat_lenage_srv_M[,2:21]/10)^bM
rownames(mat_lenage_srv_F_wtcalc)=c(seq(1971,2019,1),2021);colnames(mat_lenage_srv_F_wtcalc)=seq(1,20,1)
rownames(mat_lenage_srv_M_wtcalc)=c(seq(1971,2019,1),2021);colnames(mat_lenage_srv_M_wtcalc)=seq(1,20,1)

#write.csv(mat_lenage_srv_F_wtcalc,"/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/mat_lenage_srv_F_wtcalc.csv")
#write.csv(mat_lenage_srv_M_wtcalc,"/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/mat_lenage_srv_M_wtcalc.csv")

mat_lenage_srv_F_wtcalc=read.csv("/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/mat_lenage_srv_F_wtcalc.csv",header=TRUE)
mat_lenage_srv_M_wtcalc=read.csv("/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/mat_lenage_srv_M_wtcalc.csv",header=TRUE)

#Plot mat_wtage_srv_F, mat_wtage_srv_M, and compare with mat_lenage_srv_F_wtcalc, mat_lenage_srv_M_wtcalc
colnames(mat_wtage_srv_F)=c("Year",seq(1,20,1));colnames(mat_wtage_srv_M)=c("Year",seq(1,20,1))
colnames(mat_lenage_srv_F_wtcalc)=c("Year",seq(1,20,1));colnames(mat_lenage_srv_M_wtcalc)=c("Year",seq(1,20,1))

LW2F=reshape2::melt(mat_lenage_srv_F_wtcalc,id="Year");colnames(LW2F)=c("Year","Age","Weight")
#LW2F$Year=as.factor(LW2F$Year)
ggplot(LW2F)+geom_point(aes(x=Age,y=Weight,color=Year),na.rm=TRUE)+ggtitle("Females - lengths converted to weights")+theme_bw()
#YFSFem_lens_convtowts.pdf

LW2M=reshape2::melt(mat_lenage_srv_M_wtcalc,id="Year");colnames(LW2M)=c("Year","Age","Weight")
LW2M$Year=as.factor(LW2M$Year)
ggplot(LW2M)+geom_point(aes(x=Age,y=Weight,color=Year),na.rm=TRUE)+ggtitle("Males - lengths converted to weights")+theme_bw()
#YFSMal_lens_convtowt.pdf
#plot age 8 males
LW2M8=LW2M[which(LW2M$Age==8),];LW2M8$Sex=rep("Male",nrow(LW2M8))
LW2F8=LW2F[which(LW2F$Age==8),];LW2F8$Sex=rep("Female",nrow(LW2F8))
LW2MF8=rbind(LW2M8,LW2F8)
#write.csv(LW2MF8,"/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/LW2MF8.csv")
LW2MF8=read.csv("/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/LW2MF8.csv",header=TRUE)
ggplot(LW2MF8)+geom_point(aes(x=Year,y=Weight,color=Sex))+scale_x_discrete(breaks = seq(1971,2019, by = 2))+theme_bw()+ggtitle("Mean weight (g) of Male and Female YFS, age 8")

#Plot age 8 male and female lengths - note these are redundant because the weight comes from the length
colnames(mat_lenage_srv_M)=c("Year",seq(1,20,1))
m8=data.frame(mat_lenage_srv_M[,c(1,9)]);colnames(m8)=c("Year","Length")
Sex=rep("Male",nrow(m8))
m8_1=cbind(m8,Sex)
colnames(mat_lenage_srv_F)=c("Year",seq(1,20,1))
f8=data.frame(mat_lenage_srv_F[,c(1,9)]);colnames(f8)=c("Year","Length")
Sex=rep("Female",nrow(f8))
f8_1=cbind(f8,Sex)
fm8=rbind(m8_1,f8_1)
#write.csv(fm8,"/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/fm8.csv")
ggplot(fm8)+geom_point(aes(x=Year,y=Length/10,color=Sex),na.rm=TRUE)+theme_bw()+ggtitle("Mean length of age 8 male and female YFS")+ylab("Length (g)")


#Relationship is significant for age 8
y=LW2M[which(LW2M$Age==8),]$Weight
x=as.numeric(LW2M[which(LW2M$Age==8),]$Year)
M8=lm(y~x);summary(M8)
#Plot age 8 females
ggplot(LW2F[which(LW2F$Age==8),])+geom_point(aes(x=Year,y=Weight))+scale_x_discrete(breaks = seq(1971,2019, by = 2))+theme_bw()+ggtitle("Female YFS, age 8")
y=LW2F[which(LW2F$Age==8),]$Weight[4:50]
x=as.numeric(LW2F[which(LW2F$Age==8),]$Year[4:50])
F8=lm(y~x);summary(F8)

#Relationship is significant for age 5
y=LW2M[which(LW2M$Age==5),]$Weight
x=as.numeric(LW2M[which(LW2M$Age==5),]$Year)
M5=lm(y~x);summary(M5)
#Plot age 5 females
ggplot(LW2F[which(LW2F$Age==5),])+geom_point(aes(x=Year,y=Weight))+theme_bw()+ggtitle("Female YFS, age 5")
y=LW2F[which(LW2F$Age==5),]$Weight[4:50]
x=as.numeric(LW2F[which(LW2F$Age==5),]$Year[4:50])
F5=lm(y~x);summary(F5)

#Relationship is significant for age 7
y=LW2M[which(LW2M$Age==7),]$Weight
x=as.numeric(LW2M[which(LW2M$Age==7),]$Year)
M7=lm(y~x);summary(M7)
#Plot age 7 females
ggplot(LW2F[which(LW2F$Age==7),])+geom_point(aes(x=Year,y=Weight))+theme_bw()+ggtitle("Female YFS, age 7")
y=LW2F[which(LW2F$Age==7),]$Weight[4:50]
x=as.numeric(LW2F[which(LW2F$Age==7),]$Year[4:50])
F7=lm(y~x);summary(F7)

#Get a mean overall length at age for males, females to fill gaps with from 1971-2021

mean_lenage_srv_F=vector();mean_lenage_srv_M=vector()
 for(j in 1:19){
  mean_lenage_srv_F[j]=mean(srv_wtage$LENGTH[which(srv_wtage$AGE==age[j]&srv_wtage$SEX=='2'&srv_wtage$REGION=="BS")],na.rm=TRUE)
  mean_lenage_srv_F[20]=mean(srv_wtage$LENGTH[which(srv_wtage$AGE>19&srv_wtage$SEX=='2'&srv_wtage$REGION=="BS")],na.rm=TRUE)
  mean_lenage_srv_M[j]=mean(srv_wtage$LENGTH[which(srv_wtage$AGE==age[j]&srv_wtage$SEX=='1'&srv_wtage$REGION=="BS")],na.rm=TRUE)
  mean_lenage_srv_M[20]=mean(srv_wtage$LENGTH[which(srv_wtage$AGE>19&srv_wtage$SEX=='1'&srv_wtage$REGION=="BS")],na.rm=TRUE)
 }

#Convert mean lengths to a mean weight
mean_lenage_srv_F_wtcalc=aF*(mean_lenage_srv_F/10)^bF
mean_lenage_srv_M_wtcalc=aM*(mean_lenage_srv_M/10)^bM

#Want to take mat_wtage_srv_F and fill NAs with mat_lenage_srv_F_wtcalc for that year.
#If that is NA, fill with mean_lenage_srv_F_wtcalc

#YFS survey final
YFS_lenwt_finF=matrix(0,50,20)#Start with just 50 years 1971-2021
YFS_lenwt_finM=matrix(0,50,20)

mat_wtage_srv_Fc=mat_wtage_srv_F[,3:22];rownames(mat_wtage_srv_Fc)=seq(1971,2020,1)#trim off extra columns
mat_wtage_srv_Mc=mat_wtage_srv_M[,3:22];rownames(mat_wtage_srv_Mc)=seq(1971,2020,1)#trim off extra columns

yrs=c(seq(1971,2019,1),2021)
#First add in the true mean weights at age.
for(i in 1:50){#i=years
 for(j in 1:20){
  if(!is.na(mat_wtage_srv_Fc[i,j])){YFS_lenwt_finF[i,j]=mat_wtage_srv_Fc[i,j]}
  if(!is.na(mat_wtage_srv_Mc[i,j])){YFS_lenwt_finM[i,j]=mat_wtage_srv_Mc[i,j]}
   }
}
#Now add in the converted lengths to weights
mat_lenage_srv_F_wtcalcC=mat_lenage_srv_F_wtcalc[,2:21]
mat_lenage_srv_M_wtcalcC=mat_lenage_srv_M_wtcalc[,2:21]

for(i in 1:50){#i=years
 for(j in 1:20){
  if(YFS_lenwt_finF[i,j]==0){YFS_lenwt_finF[i,j]=mat_lenage_srv_F_wtcalcC[i,j]}
  if(YFS_lenwt_finM[i,j]==0){YFS_lenwt_finM[i,j]=mat_lenage_srv_M_wtcalcC[i,j]}
 }
}
#now missing values filled with NAs. Fill these last few with overall mean weights converted from overall mean lengths
for(i in 1:50){#i=years
 for(j in 1:20){
  if(is.na(YFS_lenwt_finF[i,j])){YFS_lenwt_finF[i,j]=round(mean_lenage_srv_F_wtcalc[j])}
  if(is.na(YFS_lenwt_finM[i,j])){YFS_lenwt_finM[i,j]=round(mean_lenage_srv_M_wtcalc[j])}
 }
}
#here years is c(seq(1971,2019,1),2021)
#this made row 50, 2020 the mean of all years
# but I think a better choice would be the mean of the last 5 years with data, 2015-2019
YFS_lenwt_finF[50,]=round(colMeans(YFS_lenwt_finF[45:49,]))
YFS_lenwt_finM[50,]=round(colMeans(YFS_lenwt_finM[45:49,]))

rownames(YFS_lenwt_finF)=yrs;rownames(YFS_lenwt_finM)=yrs
#write.csv(YFS_lenwt_finF,"/Users/ingridspies/Downloads/YFS_lenwt_finF.csv")
#write.csv(YFS_lenwt_finM,"/Users/ingridspies/Downloads/YFS_lenwt_finM.csv")

#Use means from first 10 years (1971-1980) to fill in years 1954-1970, as we know that weight at age is increasing (due to length at age increasing).
meanF_1971_1980=round(colMeans(YFS_lenwt_finF[1:10,]))
meanM_1971_1980=round(colMeans(YFS_lenwt_finM[1:10,]))

#Create new vectors yrs 1971-2021. This is not missing 2020 because Model expects all years
YFS_lenwtF_1954_2021=matrix(0,68,20)
YFS_lenwtM_1954_2021=matrix(0,68,20)
for(i in 1:17){YFS_lenwtF_1954_2021[i,]=meanF_1971_1980}#fill in years 1954-1970 with means 1971-1980
for(i in 1:17){YFS_lenwtM_1954_2021[i,]=meanM_1971_1980}#fill in years 1954-1970 with means 1971-1980

YFS_lenwtF_1954_2021[18:67,]=YFS_lenwt_finF
YFS_lenwtM_1954_2021[18:67,]=YFS_lenwt_finM

#Make the last year (2021) same as 2020, so 2020 and 2021 are both the mean of the last 5 years 2015-2019
YFS_lenwtF_1954_2021[68,]=YFS_lenwtF_1954_2021[67,]
YFS_lenwtM_1954_2021[68,]=YFS_lenwtM_1954_2021[67,]

#This is the final to use in survey weights at age in Model.
#write.csv(YFS_lenwtF_1954_2021,"/Users/ingridspies/Downloads/YFS_lenwtF_1954_2021.csv")
#write.csv(YFS_lenwtM_1954_2021,"/Users/ingridspies/Downloads/YFS_lenwtM_1954_2021.csv")

YFS_lenwtF_1954_2021=read.csv("/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/YFS_lenwtF_1954_2021.csv",header=TRUE)
YFS_lenwtM_1954_2021=read.csv("/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/YFS_lenwtM_1954_2021.csv",header=TRUE)

YFS_lenwtF_1954_2021C=data.frame(cbind(seq(1954,2021,1),YFS_lenwtF_1954_2021))
YFS_lenwtM_1954_2021C=data.frame(cbind(seq(1954,2021,1),YFS_lenwtM_1954_2021))
colnames(YFS_lenwtF_1954_2021C)=c("Year",seq(1,20,1))
YFS_lenwtF_1954_2021C$Year=as.factor(YFS_lenwtF_1954_2021C$Year)
colnames(YFS_lenwtM_1954_2021C)=c("Year",seq(1,20,1))
YFS_lenwtM_1954_2021C$Year=as.factor(YFS_lenwtM_1954_2021C$Year)
YFF=reshape2::melt(YFS_lenwtF_1954_2021C,id="Year");colnames(YFF)=c("Year","Age","Weight")
YFM=reshape2::melt(YFS_lenwtM_1954_2021C,id="Year");colnames(YFM)=c("Year","Age","Weight")
ggplot(YFF)+geom_point(aes(x=Age,y=Weight,color=Year))+theme_bw()+ggtitle("Female survey weight at age used in model")#Fem_srvWTAGE_MODELFIN.pdf
ggplot(YFM)+geom_point(aes(x=Age,y=Weight,color=Year))+theme_bw()+ggtitle("Male survey weight at age used in model")#Mal_srvWTAGE_MODELFIN.pdf

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

#write.csv(lensM,"/Users/ingridspies/admbmodels/flatfish/assessments/yfs/doc/2021/lensM.csv")
#write.csv(lensF,"/Users/ingridspies/admbmodels/flatfish/assessments/yfs/doc/2021/lensF.csv")

lensM=read.csv("/Users/ingridspies/admbmodels/flatfish/assessments/yfs/doc/2021/lensM.csv",header=TRUE)
lensF=read.csv("/Users/ingridspies/admbmodels/flatfish/assessments/yfs/doc/2021/lensF.csv",header=TRUE)


#Here is a nice script for fitting von Bertalanffy growth just in case (not used here)
#Smooth using VB growth Females age to length
library(fishmethods)

srv_wtage=read.csv("/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/survey_wtage/YFSageSurvey1954_2021.csv",header=TRUE)

VBf=growth(intype=1,unit=1,size=srv_wtage$LENGTH,age=srv_wtage$AGE,
           calctype=1,wgtby=1,error=1,Sinf=6000,K=0.3,t0=-1)
P=summary(VBf$vout)$parameters[,1]
age=seq(1,40,1);Sinf=P[1];K=P[2];t0=P[3]
females=Sinf*(1-exp(-(K*(age-t0))))

data(pinfish)
growth(intype=1,unit=1,size=pinfish$sl,age=pinfish$age,
       calctype=1,wgtby=1,error=1,Sinf=200,K=0.3,t0=-1)
#$vonbert
#[1] "Model: Length = Sinf*(1-exp(-K*(t-t0)))+e" "Response: Individual Length" 

yrs=length(AI$yrs_srv)
YFS18_2$yrs_srv_age_s
YFS18_2$oac_srv_s

#YFS18_2$oac_fsh_s actual, This is separated by sex 1975-2020.
Femz=YFS18_2$oac_fsh_s[,1:20]
Malz=YFS18_2$oac_fsh_s[,21:40]

yrs=length(seq(1975,2020,1))
Age=rep(seq(1,20,1),each=yrs)
Frequency=c(Femz)
Year=rep(seq(1975,2020,1),length(yrs))
fishlen=data.frame(Year,Age,Frequency)
p2 <- ggplot(fishlen, aes(Age,Year)) +
 geom_tile(aes(fill = Frequency),colour = "lightgrey")+
 scale_fill_gradient(low = "white",high = "darkblue")+ 
 scale_y_continuous(breaks=seq(1975,2020,1),labels=seq(1975,2020,1))+ 
 ggtitle("YFS Ages - Fishery") +
 theme(axis.text.y=element_text(size=rel(.7)))+theme_bw()



#The next exploration of growth is in the increments from one year to the next
# I calculated growth increments for years 1982 to 2019 and then I compared them with the temperature in the first summer
#Here are lengths
lenF=mat_lenage_srv_F[1:49,]
lenM=mat_lenage_srv_M[1:49,]

N=c(rep(18,18),18,18,rev(seq(2,17,1)))#This represents the number of years a cohort is represented by the data  and removed 2020
tempz=read.csv("/Users/ingridspies/Downloads/tempz.csv",header=TRUE)
Year=seq(1982,2018,1)
matM_len=matrix(0,length(Year),length(seq(2,19,1)))
matF_len=matrix(0,length(Year),length(seq(2,19,1)))
tempMAT_len=matrix(0,length(Year),length(seq(2,19,1)))
colnames(matM_len)=seq(2,19,1);colnames(matF_len)=seq(2,19,1)
rownames(matF_len)=Year;rownames(matM_len)=Year
for(j in 1:length(N)){
 for(i in 1:N[j]){
  matM_len[j,i]=lenM[(9+i+j+2),(i+3)]-lenM[(9+i+j+1),(i+2)]
  matF_len[j,i]=lenF[(9+i+j+2),(i+3)]-lenF[(9+i+j+1),(i+2)]
  tempMAT_len[j,i]=tempz[which(tempz$YEAR==1982+i+j-1),3]
 }}

colnames(tempMAT_len)=seq(2,19,1);colnames(matM_len)=seq(2,19,1);colnames(matF_len)=seq(2,19,1)
#cbind(Year,tempMAT_len);cbind(Year,matM_len);cbind(Year,matF_len)
rownames(tempMAT_len)=Year;rownames(matM_len)=Year;rownames(matF_len)=Year


#rownames(tempMAT)=Year;rownames(matM)=Year;rownames(matF)=Year
#colnames(tempMAT)=seq(2,19,1);colnames(matM)=seq(2,19,1);colnames(matF)=seq(2,19,1)

matM2_len=reshape2::melt(matM_len,id=c("Year"))
matF2_len=reshape2::melt(matF_len,id=c("Year"))
tempMAT2_len=reshape2::melt(tempMAT_len,id=c("Year"))
colnames(tempMAT2_len)=c("Year","Age1","Temperature")
colnames(matM2_len)=c("Year","Age1","Growth_Male")
colnames(matF2_len)=c("Year","Age1","Growth_Female")
OUT_len=cbind(tempMAT2_len,matM2_len$Growth_Male,matF2_len$Growth_Female)
colnames(OUT_len)=c("Year","Age1","Temperature","Growth_Male","Growth_Female")


#what we are interested in is temperature.
OUT_len2=OUT_len[which(OUT_len$Temperature!=0),]
#Look at the data
#Males and females grow in length more early in life
ggplot(data=OUT_len2)+geom_point(aes(x=Age1,y=Growth_Male,color=Temperature))+theme_bw()+ggtitle("Male Growth by Age")+xlab("First age of the growth increment")#Year implies year of birth only

ggplot(data=OUT_len2)+geom_point(aes(x=Age1,y=Growth_Female,color=Temperature))+theme_bw()+ggtitle("Female Growth by Age")+xlab("First age of the growth increment")#Year implies year of birth only

#Growth by length for all ages and temperature (year too but year corelates with temp)

ggplot(data=OUT_len2[which(OUT_len2$Age1<13),])+geom_point(aes(x=Temperature,y=Growth_Male,color=Age1))+theme_bw()+
 ggtitle("YFS male growth increment up to age 12 to 13, \nby increment and temperature")+
 ylab("Growth (cm)")+
 guides(col= guide_legend(title= "Growth\nincrement\nfirst age"))

#Is it possible that more recent years grow faster at the same temperatures? It sort of looks like it here
ggplot(data=OUT_len2[which(OUT_len2$Age1<14),])+geom_point(aes(x=Temperature,y=Growth_Female,color=Age1))+
 guides(col= guide_legend(title= "Growth\nincrement\nfirst age"))+
 ggtitle("YFS female growth increment up to age 13 to 14, \nby increment and temperature")+
 ylab("Growth (cm)")+theme_bw()

#
ggplot(data=OUT_len2)+geom_point(aes(x=Age1,y=Growth_Male,color=Year))+theme_bw()+ggtitle("Male Growth by Age")#Year implies year of birth only

ggplot(data=OUT_len2)+geom_point(aes(x=Age1,y=Growth_Female,color=Year))+theme_bw()+ggtitle("Female Growth by Age")#Year implies year of birth only


#First run Levenes test to look whether variance is the same by age
OUT_len$Age_factor=as.factor(OUT_len$Age1)#set up age as a factor
leveneTest(Growth_Female~Age_factor,OUT_len)#variance in growth changes by age (more variance older ages)
leveneTest(Growth_Male~Age_factor,OUT_len)#Also significant for males

OUT_len2=OUT_len[which(OUT_len$Temperature>0),]
[which(OUT_len2$Age1<20),]
leveneTest(Growth_Female~Age_factor,OUT_len2[which(OUT_len2$Age1<10),])
leveneTest(Growth_Male~Age_factor,OUT_len2[which(OUT_len2$Age1<10),])

leveneTest(Growth_Female~Age_factor,OUT_len2)
leveneTest(Growth_Male~Age_factor,OUT_len2)

#Not significant actually
#As you can see, the test returned a significant outcome. Here it is important to know the hypotheses built into the test: Levene’s test’s null hypothesis, which we would accept if the test came back insignificantly, implies that the variance is homogenous, and we can proceed with our ANOVA. However, the test did come back significantly, which means that the variances between Petal.Length of the different species are significantly different.


OUT_len2$Temp_factor=as.factor(OUT_len2$Temperature)#set up temperature as a factor
leveneTest(Growth_Female~Temp_factor,OUT_len2[which(OUT_len2$Age1<20),])#no significant difference in variance by temperature once temp=0 is removed. This is good
leveneTest(Growth_Male~Temp_factor,OUT_len2[which(OUT_len2$Age1<8),])#For males there seems to be difference in variance by temperature (?).

fit = aov(Growth_Female ~ Temperature, OUT_len2[which(OUT_len2$Age1<9),])#Effect for females with all ages
summary(fit)#Females seem to have no temperature effect? 
fit = aov(Growth_Male ~ Temperature, OUT_len2)#Significant effect for males with all ages.
summary(fit)#Males no effect on growth by temperature
fit = aov(Growth_Male ~ Temperature, OUT_len2[which(OUT_len2$Age1<9),])#More effect younger ages
summary(fit)#Males no effect on growth by temperature even at younger ages

library(psych)
describeBy(OUT_len2$Growth_Female, OUT_len2$Temperature)#lots of info


ggplot(OUT_len2[which(OUT_len2$Age1<9),],aes(y=Growth_Female, x=Temp_factor,fill=Temp_factor))+
 stat_summary(fun="mean", geom="bar",position="dodge")+
 stat_summary(fun.data = mean_se, geom = "errorbar", position="dodge",width=.8)+theme_bw()+
 theme(legend.position="none")+theme(axis.text.x=element_text(angle=90,hjust=1))

ggplot(OUT_len2[which(OUT_len2$Age1<9),],aes(y=Growth_Male, x=Temp_factor, fill=Temp_factor))+
 stat_summary(fun="mean", geom="bar",position="dodge")+
 stat_summary(fun.data = mean_se, geom = "errorbar", position="dodge",width=.8)+theme_bw()+theme(axis.text.x=element_text(angle=90,hjust=1))+theme(legend.position="none")
#first negative year is 1993. Nothing notable about it.
#Second negative year is 1998. This one the survey started very late.

ggplot(OUT_len2[which(OUT_len2$Age1<10),],aes(y=Growth_Male, x=Year, fill=Year))+
 stat_summary(fun="mean", geom="bar",position="dodge")+
 stat_summary(fun.data = mean_se, geom = "errorbar", position="dodge",width=.8)+theme_bw()+theme(axis.text.x=element_text(angle=90,hjust=1))+theme(legend.position="none")+
 ggtitle("YFS males <10yrs")
#This trails off over the last 10 years because of only age 2to 3 growth, age 3 to 4 growth maybe?

ggplot(OUT_len2[which(OUT_len2$Age1<10),],aes(y=Growth_Female, x=Year, fill=Year))+
 stat_summary(fun="mean", geom="bar",position="dodge")+
 stat_summary(fun.data = mean_se, geom = "errorbar", position="dodge",width=.8)+theme_bw()+
 theme(legend.position="none")+theme(axis.text.x=element_text(angle=90,hjust=1))+ggtitle("YFS females <10yrs")

fit2=aov(Growth_Female~Age1+Temperature,OUT_len2[which(OUT_len2$Age1<9),])
Anova(fit2, type="III")
#Females controlling for any effects of age, Temperature seems to affect growth

fit2=aov(Growth_Male~Temperature+Age1,OUT_len2[which(OUT_len2$Age1<9),])
Anova(fit2, type="III")
#Males controlling for any effects of age, Temperature seems to affect growth

#Can I test the effect on growth by year controlling for temperature?
fit2=aov(Growth_Female~Year+Temperature,OUT_len2[which(OUT_len2$Age1<10),])
Anova(fit2, type="III")
#Females controlling for effect of Year there is an effect of temperature (no significant effect of Year though)

fit2=aov(Growth_Male~Year+Temperature,OUT_len2[which(OUT_len2$Age1<10),])
Anova(fit2, type="III")
#Again with males, controlling for effect of Year there is an effect of temperature (no significant effect of Year though)


#As you can see in our row Temperature, column Pr(>F), which is the p-value, species still has a significant impact on the growth of Females, even when controlling for the Age. 

loook at fishery otoliths
talk with Beth
mothn






