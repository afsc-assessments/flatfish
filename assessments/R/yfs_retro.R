rm(list=ls())
# Set this where you ran model:
setwd("/Users/ingridspies/admbmodels/flatfish/assessments/yfs")
#setwd("~/_mymods/flatfish/assessments/yfs")
# This is one directory above where yfs is...your mileage may vary
source("../R/prelims.R")
source("../R/yfs.R")
setwd("/Users/ingridspies/admbmodels/flatfish/assessments/yfs/runs/data")
mqtext <- as.matrix(read.table("M_q.dat",as.is=TRUE)) # the combos of M and q
qspec <- as.vector(mqtext[1,])
Mspec <- as.vector(mqtext[2,])

# Read in the output of the assessment
# Read in model results
ssb <- data.frame()
rec <- data.frame()
surv_like <- data.frame()
for (i in 1:40) {
  rn=paste0("mq_profile/mod",i,"_R.rep")
  mn=paste0("mq_",i)
  assign(mn,readList(rn))
  #for (j in 0:10) {
    #rn=paste0("mq_retro/mq",i,"_",j,"_R.rep")
    #mn=paste0("ret_",i,"_",j)
    #assign(mn,readList(rn))
    print(rn)
    rtmp <- data.frame(get(mn)$R)
    names(rtmp) <- c("Year","Recruits","Stdev","lb","ub")
    btmp <- data.frame(get(mn)$SSB)
    names(btmp) <- c("Year","SSB","Stdev","lb","ub")
    #btmp$termyr <- rtmp$termyr <- 2017-j
    ltmp <- data.frame(get(mn)$survey_likelihood)
    names(ltmp) <- "Survey_NLL"
    #ltmp$termyr <- 2017-j
    btmp$M <- rtmp$M <- ltmp$M <- Mspec[i]
    btmp$q <- rtmp$q <- ltmp$q <- qspec[i]
    surv_like <- rbind(surv_like,ltmp)
    ssb       <- rbind(ssb,btmp)
    rec       <- rbind(rec,rtmp)
  #}
}
dim(rec)
dim(ssb)
dim(surv_like)
surv_like$mq <- as.factor(paste0(surv_like$M,"_",surv_like$q))
ssb$mq <- as.factor(paste0(ssb$M,"_",ssb$q))
rec$mq <- as.factor(paste0(ssb$M,"_",ssb$q))
#--Plot likelihoods--------------
surv_like %>% filter(termyr==2017) %>% mutate(M=as.factor(M)) %>% ggplot(aes(x=q,y=Survey_NLL,color=M)) + 
        ylim(c(80,120)) + geom_line(size=1.5) + ylab("Survey index -log likelihood") + .THEME

#--Mohn's rho--------------------
j=ssb$mq[1200]
j
rho.df <- NULL
unique(ssb$mq)
for (j in unique(ssb$mq)) {
  dtmp <- ssb[ssb$mq==j,]
  rc   <- dtmp[dtmp$termyr==2017,2]
  ntmp <- 0
  rho  <- 0
  for (i in 1:10) {
    #dtmp=get(paste0("retro",i))$SSB)
    dtmp2 <- dtmp[dtmp$termyr==(2017-i),]
    lr    <- length(dtmp2[,1])
    print(dtmp2[(lr-7):lr,2])
    ntmp  <-  ntmp + (dtmp2[lr,2] -rc[lr]) / rc[lr]
    #rho = rho + (-(ALL[i,2]-ALL[*tsyrs-i,2+i]))/ALL[(j)*tsyrs-i,2]
    rho   <-  rho + (dtmp2[lr,2] - rc[lr]) / rc[lr]
  }    
  print(j)
  rho.df <- rbind(rho.df,data.frame(rho=rho/10,M_q=j))
}    

rho.df
names(dtmp)
dtmp$Term_yr <- as.factor(dtmp$termyr)
ssb$Term_yr <- as.factor(ssb$termyr)

main <- paste0("M=0.08, q=0.8, Mohn's rho = 0.11")
filter(ssb,mq=="0.08_0.8") %>% ggplot(aes(x=Year,y=SSB,color=Term_yr)) + geom_line(size=1.2) + xlim(c(1990,2017))+ .THEME + ggtitle(main) + ylim(c(0,1500))
main <- paste0("M=0.09, q=0.9, Mohn's rho = -0.03")
filter(ssb,mq=="0.09_0.9") %>% ggplot(aes(x=Year,y=SSB,color=Term_yr)) + geom_line(size=1.2) + xlim(c(1990,2017))+ .THEME + ggtitle(main) + ylim(c(0,1500))
main <- paste0("M=",0.14, ", q=",1.2,", Mohn's rho = ","-0.22")
filter(ssb,mq=="0.14_1.2") %>% ggplot(aes(x=Year,y=SSB,color=Term_yr)) + geom_line(size=1.2) + xlim(c(1990,2017))+ .THEME + ggtitle(main) + ylim(c(0,1500))

unique(ssb$mq)
for (j in unique(ssb$mq)) {
  dtmp <- ssb[ssb$mq==j,]
  rc   <- dtmp[dtmp$termyr==2017,2]
  ntmp <- 0
  rho  <- 0
  for (i in 1:10) {
    #dtmp=get(paste0("retro",i))$SSB)
    dtmp2 <- dtmp[dtmp$termyr==(2017-i),]
    lr    <- length(dtmp2[,1])
    print(dtmp2[(lr-7):lr,2])
    ntmp  <-  ntmp + (dtmp2[lr,2] -rc[lr]) / rc[lr]
    #rho = rho + (-(ALL[i,2]-ALL[*tsyrs-i,2+i]))/ALL[(j)*tsyrs-i,2]
    rho   <-  rho + (dtmp2[lr,2] - rc[lr]) / rc[lr]
  }    
  print(j)
  rho.df <- rbind(rho.df,data.frame(rho=rho/10,M_q=j))
}    
