#Update oac_fsh_s (split sex fishery age compositions)

#THis was the AKFIN age comps. It seems like AKFIN matched obsint exactly
#except in some years 1991, 1993-1997 when obsint did not return anything.
#AKFIN HERE
oac=read.csv("/Users/ingridspies/admbmodels/flatfish/assessments/yfs/doc/2020/data/norpac_age_report_YFS_10_1_20.csv",header=TRUE)
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
#OBSINT here
oac1=read.csv("/Users/ingridspies/admbmodels/flatfish/assessments/yfs/doc/2020/data/yfs_allyrs_obsint_age_wt_len.csv",header=TRUE)
yrs=seq(1990,2020,1)
oacmat_f1=matrix(0,length(yrs),39)
oacmat_m1=matrix(0,length(yrs),39)
for(i in 1:length(yrs)){
 for(j in 1:39){
  oacmat_f1[i,j]=length(oac1$AGE[which(oac1$YEAR==yrs[i]&oac1$AGE==j&oac1$SEX=="F")])
  oacmat_m1[i,j]=length(oac1$AGE[which(oac1$YEAR==yrs[i]&oac1$AGE==j&oac1$SEX=="M")])
  print(yrs[i])
 }
}
rownames(oacmat_f1)=yrs
rownames(oacmat_m1)=yrs

oacmat_f-oacmat_f1 #this shows mostly the same data just not the missing years.

#To create oac_fsh_s you first need to get age data (above). Then you need to get fishery length comps.
oac_lens=read.csv("/Users/ingridspies/admbmodels/flatfish/assessments/yfs/doc/2020/data/YFS_fisherylengths_2018_2019.csv",header=TRUE)

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
#1 set up matrix of length by age from read otoliths in 2018
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
  oac_LenAge_F[i,j]=nrow(oac1[which(oac1$YEAR==2019&oac1$LENGTH_CM==i&oac1$SEX=="F"&oac1$AGE>0&oac1$AGE==j),])
  oac_LenAge_M[i,j]=nrow(oac1[which(oac1$YEAR==2019&oac1$LENGTH_CM==i&oac1$SEX=="M"&oac1$AGE>0&oac1$AGE==j),])
   }
}

#Get vector of length freqs from fishery (need to redo from obsint)

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

