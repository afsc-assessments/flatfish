#Update oac_fsh_s (split sex fishery age compositions)

#THis was the AKFIN age comps. It seems like AKFIN matched obsint exactly
#except in some years 1991, 1993-1997 when obsint did not return anything.
#AKFIN HERE
#AKFIN observer age frequency norpac age report species Name is equal to YELLOWFIN SOLE and	Age FMP Area is equal to BSAI and	Age FMP Subarea is equal to BS
oac=read.csv("/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2020 YFS/norpac_age_report_YFS_10_1_20.csv",header=TRUE)
oac21=read.csv("/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/norpac_age_report_YFS_10_5_21.csv",header=TRUE)
yrs=as.numeric(names(table(oac21$Year)))
oacmat_f2020=matrix(0,length(seq(1990,2021,1)),40)
oacmat_m2020=matrix(0,length(seq(1990,2021,1)),40)
oacmat_f2021=matrix(0,length(seq(1990,2021,1)),40)
oacmat_m2021=matrix(0,length(seq(1990,2021,1)),40)
for(i in 1:length(yrs)){
 for(j in 1:40){
  oacmat_f2020[i,j]=length(oac$Age[which(oac$Year==yrs[i]&oac$Age==j&oac$Sex=="F")])
  oacmat_m2020[i,j]=length(oac$Age[which(oac$Year==yrs[i]&oac$Age==j&oac$Sex=="M")])
  oacmat_f2021[i,j]=length(oac21$Age[which(oac21$Year==yrs[i]&oac21$Age==j&oac21$Sex=="F")])
  oacmat_m2021[i,j]=length(oac21$Age[which(oac21$Year==yrs[i]&oac21$Age==j&oac21$Sex=="M")])
  print(yrs[i])
 }
}
write.csv(oacmat_f2020,"/Users/ingridspies/Downloads/oacmat_f2020.csv")
write.csv(oacmat_m2020,"/Users/ingridspies/Downloads/oacmat_m2020.csv")
write.csv(oacmat_f2021,"/Users/ingridspies/Downloads/oacmat_f2020.csv")
write.csv(oacmat_m2021,"/Users/ingridspies/Downloads/oacmat_m2021.csv")

#How many fishery ages per year?
nages=vector()
for(i in 1:length(yrs)){
 nages[i]=length(oac21$Age[which(oac21$Year==yrs[i]&oac21$Age>0)])
}

cbind(yrs,nages)

#Get length distribution by NMFS area for figure obs_sizecomp
#only from trawlers (gear=1 non pelagic trawl or 2 pelagic trawl)
table(oac$NMFS.Area)
table(oac21$NMFS.Area)
table(oac$Length..cm.)#use 7-58cm
table(oac21$Length..cm.)#use 7-58cm
lens=seq(7,58,1)
areas=c(509,513,514,516,517,521,524)
lensM=matrix(0,length(lens),length(areas))
colnames(lensM)=areas;rownames(lensM)=lens
lensF=lensM
for(i in 1:length(lens)){
 for(j in 1:length(areas)){
  lensM[i,j]=nrow(oac21[which(oac21$Length..cm.==lens[i]&oac21$Sex=="M"&oac21$NMFS.Area==areas[j]&oac21$Gear<3),])
  lensF[i,j]=nrow(oac21[which(oac21$Length..cm.==lens[i]&oac21$Sex=="F"&oac21$NMFS.Area==areas[j]&oac21$Gear<3),])
  
   }
}

write.csv(lensM,"/Users/ingridspies/admbmodels/flatfish/assessments/yfs/doc/2021/lensM.csv")
write.csv(lensF,"/Users/ingridspies/admbmodels/flatfish/assessments/yfs/doc/2021/lensF.csv")

#Get proportion of males and females in the random fishery lengths to apply to the fishery age comp data.
propF=vector()
propM=vector()
for(i in 1:length(yrs)){
 propF[i]=length(oac21$Length..cm.[which(oac21$Year==yrs[i]&oac21$Length..cm.>0&oac21$Sex=="F")])/length(oac21$Length..cm.[which(oac21$Year==yrs[i]&oac21$Length..cm.>0)])
 propM[i]=length(oac21$Length..cm.[which(oac21$Year==yrs[i]&oac21$Length..cm.>0&oac21$Sex=="M")])/length(oac21$Length..cm.[which(oac21$Year==yrs[i]&oac21$Length..cm.>0)])
}

#why different sex ratio in some years? Temperature? Timing?
plot(yrs,propF,ylim=c(0,1))
lines(yrs,propM)

#OBSINT here
oac1=read.csv("/Users/ingridspies/admbmodels/flatfish/assessments/yfs/doc/2020/yfs_allyrs_obsint_age_wt_len.csv",header=TRUE)
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
#This data comes from AKFIN in the observer section on observer lengths.
oac_lens21=read.csv("/Users/ingridspies/Documents/WorkDellStuff/Assessments/YFS/2021/norpac_length_report_YFS_10_6_21.csv",header=TRUE)

#Create vectors of length frequencies from the fishery from the age file
oac_lenmat_F=matrix(0,2,80)
colnames(oac_lenmat_F)=seq(1,80,1)
rownames(oac_lenmat_F)=c(2018,2019)
oac_lenmat_M=oac_lenmat_F
yrs=c(2018,2019)

for(i in 1:2){
 for(j in 1:80){
  oac_lenmat_F[i,j]=sum(oac_lens$Frequency[which(oac_lens$Year==yrs[i]&oac_lens$Length_cm==j&oac_lens$Sex=="F")])
  oac_lenmat_M[i,j]=sum(oac_lens$Frequency[which(oac_lens$Year==yrs[i]&oac_lens$Length_cm==j&oac_lens$Sex=="M")])
   }
}
#Try creating the same data from the norpac dataset and it is exactly the same as last time.
yrs=seq(2018,2021,1)
oac_lenmat_F21=matrix(0,length(yrs),80)
colnames(oac_lenmat_F21)=seq(1,80,1)
rownames(oac_lenmat_F21)=yrs
oac_lenmat_M21=oac_lenmat_F21

for(i in 1:length(yrs)){
 for(j in 1:80){
  oac_lenmat_F21[i,j]=sum(oac_lens21$Frequency[which(oac_lens21$Year==yrs[i]&oac_lens21$Length..cm.==j&oac_lens21$Sex=="F")])
  oac_lenmat_M21[i,j]=sum(oac_lens21$Frequency[which(oac_lens21$Year==yrs[i]&oac_lens21$Length..cm.==j&oac_lens21$Sex=="M")])
 }
}


#Set up fishery age comps for 2019 (age data comes from the age data part lengths a separate dataset)

yrs=c(2018,2019,2020,2021)#note no aged data from 2021 yet.
Final_agematfishery=matrix(0,4,40)
for(k in 1:length(yrs)){
oac_LenAge_F=matrix(0,80,39)#80 lengths,39ages
oac_LenAge_M=matrix(0,80,39)#80 lengths,39ages
rownames(oac_LenAge_F)=seq(1,80,1);rownames(oac_LenAge_M)=seq(1,80,1)
colnames(oac_LenAge_F)=seq(1,39,1);colnames(oac_LenAge_M)=seq(1,39,1)
for(j in 1:39){
 for (i in 1:80){
  oac_LenAge_F[i,j]=nrow(oac21[which(oac21$Year==yrs[k]&oac21$Length..cm.==i&oac21$Sex=="F"&oac21$Age>0&oac21$Age==j),])
  oac_LenAge_M[i,j]=nrow(oac21[which(oac21$Year==yrs[k]&oac21$Length..cm.==i&oac21$Sex=="M"&oac21$Age>0&oac21$Age==j),])
   }
}

#Fishery Females - normalize so that each age proportions at each length sum to 1.
T1_f=oac_LenAge_F/rowSums(oac_LenAge_F)
#apply length frequencies to the proportion of age at length matrix
T2_f=oac_lenmat_F21[k,]*T1_f
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

srvage_2019=c(agematF_nn[38,],agematM_nn[38,])
sum(srvage_2019)

plot(YFS18_2$TotBiom,ylab="BiomassX1000t",xlab="Year")
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



