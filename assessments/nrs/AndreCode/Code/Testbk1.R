#setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
setwd("D:\\Research\\ABS\\ABS OA Rock Sole\\Code\\")
source("Utilities.r")  ## What is this I cannot find it

library(RcppArmadillo)
library(Rcpp)


# -----------------------------------------------------------------------------

ExtractOut<-function(X)

{
 N <- X[[1]]  
 SSB <- X[[2]]  
 Neqn <- X[[3]]  
 SSB0 <- X[[4]]
 Catch <- X[[5]]
 
 Outs <- NULL
 Outs$N <- N
 Outs$SSB <- SSB
 Outs$Neqn <- Neqn
 Outs$SSB0 <- SSB0
 Outs$Catch <- Catch
 return(Outs)

}


# -----------------------------------------------------------------------------

sourceCpp("ReferencePoints.cpp")
sourceCpp("model.cpp")

# -----------------------------------------------------------------------------

EvalFile <- read.table("PRoject.Inp")
print(head(EvalFile))



DataFile <- read.table("fm.rep",comment.char = "?",fill=T,blank.lines.skip=T,stringsAsFactors=F,col.names=1:100)

Amax <- 20
NhistY <- 44
Nsex <- 2


# Recuitment
Index <- MatchTable(DataFile,Char1="Bzero")[1]; Bzero <- as.numeric(DataFile[Index+1,1])
Index <- MatchTable(DataFile,Char1="phizero")[1]; phizero <- as.numeric(DataFile[Index+1,1])
R0 <- Bzero/phizero/1000


# Natural mortality
Index <- MatchTable(DataFile,Char1="natmort_f"); Mf <- as.numeric(DataFile[Index+1,1])
Index <- MatchTable(DataFile,Char1="natmort_m"); Mm <- as.numeric(DataFile[Index+1,1])

# N-at-age
Index <- MatchTable(DataFile,Char1="natage_f"); 
NatageF <- matrix(0,nrow=NhistY,ncol=Amax)
for (Iyear in 1:NhistY)
 for (Iage in 1:Amax)        
  NatageF[Iyear,Iage] <- as.numeric(DataFile[Index+Iyear,Iage])
Index <- MatchTable(DataFile,Char1="natage_m"); 
NatageM <- matrix(0,nrow=NhistY,ncol=Amax)
for (Iyear in 1:NhistY)
 for (Iage in 1:Amax)        
  NatageM[Iyear,Iage] <- as.numeric(DataFile[Index+Iyear,Iage])

# Selectivity
Index <- MatchTable(DataFile,Char1="sel_fsh_f")[1] 
SelFshF <- matrix(0,nrow=NhistY,ncol=Amax)
for (Iyear in 1:NhistY)
 for (Iage in 1:Amax)        
  SelFshF[Iyear,Iage] <- as.numeric(DataFile[Index+Iyear,Iage])
Index <- MatchTable(DataFile,Char1="sel_fsh_m")[1] 
SelFshM <- matrix(0,nrow=NhistY,ncol=Amax)
for (Iyear in 1:NhistY)
 for (Iage in 1:Amax)        
  SelFshM[Iyear,Iage] <- as.numeric(DataFile[Index+Iyear,Iage])

# maturity
Index <- MatchTable(DataFile,Char1="maturity")[1] 
Maturity <- matrix(0,nrow=NhistY,ncol=Amax)
for (Iyear in 1:NhistY)
 for (Iage in 1:Amax)        
  Maturity[Iyear,Iage] <- as.numeric(DataFile[Index+Iyear,Iage])

# Weight(catch)
Index <- MatchTable(DataFile,Char1="wt_fsh_f")[1] 
WghtFshF <- matrix(0,nrow=NhistY,ncol=Amax)
for (Iyear in 1:NhistY)
 for (Iage in 1:Amax)        
  WghtFshF[Iyear,Iage] <- as.numeric(DataFile[Index+Iyear,Iage])
Index <- MatchTable(DataFile,Char1="wt_fsh_m")[1] 
WghtFshM <- matrix(0,nrow=NhistY,ncol=Amax)
for (Iyear in 1:NhistY)
 for (Iage in 1:Amax)        
  WghtFshM[Iyear,Iage] <- as.numeric(DataFile[Index+Iyear,Iage])

# Weight(catch)
Index <- MatchTable(DataFile,Char1="wt_pop_f")[1] 
WghtPopF <- matrix(0,nrow=NhistY,ncol=Amax)
for (Iyear in 1:NhistY)
 for (Iage in 1:Amax)        
  WghtPopF[Iyear,Iage] <- as.numeric(DataFile[Index+Iyear,Iage])
Index <- MatchTable(DataFile,Char1="wt_pop_m")[1] 
WghtPopM <- matrix(0,nrow=NhistY,ncol=Amax)
for (Iyear in 1:NhistY)
 for (Iage in 1:Amax)        
  WghtPopM[Iyear,Iage] <- as.numeric(DataFile[Index+Iyear,Iage])

FF <- 0.1
M <- matrix(0,nrow=Nsex,ncol=Amax)
M[1,] <- Mf
M[2,] <- Mf
#print(M)

# Now store parameters
Sel  <- matrix(0,nrow=Nsex,ncol=Amax)
Sel[1,] <- SelFshF[NhistY,]
Sel[2,] <- SelFshM[NhistY,]
#print(Sel)
Ninit <- matrix(1,nrow=Nsex,ncol=Amax)
Ninit[1,] <- NatageF[NhistY,]
Ninit[2,] <- NatageM[NhistY,]
#print(Ninit)
Wcatch <- matrix(0,nrow=Nsex,ncol=Amax)
Wcatch[1,] <- WghtFshF[NhistY,]
Wcatch[2,] <- WghtFshM[NhistY,]
#print(Wcatch)

Linf <- c(38.034,34.030)
Kappa <- c(0.137,0.161)
T0 <- c(0.297,0.515)
aa <- c(0.00618,0.00505)
bb <- c(3.1765,3.2243)

Fec <- Maturity[NhistY,]*WghtPopF[NhistY,]
#print(Fec)

MCMCFile <- read.table("Project.Inp",comment.char = "?",fill=T,blank.lines.skip=T,stringsAsFactors=F,col.names=1:100)
Nmcmc <- length(MCMCFile[,1])/2

Ipnt <- 0; MCMCN <- array(0,dim=c(Nmcmc,Nsex,Amax)) 
for (Imcmc in 1:Nmcmc)
  for (Isex in 1:Nsex)
    { Ipnt <- Ipnt + 1;
      MCMCN[Imcmc,Isex,] <- as.numeric(MCMCFile[Ipnt,1:Amax])   
    }

# =======================================================================

# test call
spawnfrac <- 1.0/12.0
xx <- yprC(0,Nsex,Amax,M,Sel,Wcatch,Fec,spawnfrac)
#print(xx)


BasicData <- NULL
BasicData$Nsex <- Nsex
BasicData$Amax <- Amax
BasicData$M <- M
BasicData$Wcatch <- Wcatch
BasicData$Fec <- Fec
BasicData$Sel <- Sel
BasicData$Linf <- Linf               # 6
BasicData$Kappa <- Kappa
BasicData$T0 <- T0
BasicData$aa <- aa
BasicData$bb <- bb

# Parameters we change)
BasicPars <- NULL
BasicPars$R0 <- R0
BasicPars$Steep <- 0.75
BasicPars$SigmaR <- 0.6              # 2
BasicPars$EnvPars <- c(0.1,1,1)

# Options to specify (relates to functional forms and drivers)
RunOptions <- NULL
RunOptions$WeightOpt <- 2
RunOptions$SROpt <- 2
# Type, Variable, Par
RunOptions$NenvLinks <- 3
RunOptions$EnvLinks <- matrix(c(0,0,0,0,1,1,3,0,0),byrow=T,ncol=3)
RunOptions$EnvLinks <- matrix(c(0,0,0,2,1,1,0,0,0),byrow=T,ncol=3)
print(RunOptions)

# Ten environmental variables
EnvironmentalData <- matrix(0,nrow=100,ncol=10)
EnvironmentalData[,1] <- seq(from=0,to=1,length=100)
EnvironmentalData[,2] <- seq(from=0,to=-1,length=100)

set.seed(117711)
Nsim <- 100
Nyear <- 20
Trajs <- matrix(0,nrow=Nsim,ncol=Nyear)
for (Isim in 1:Nsim)
 {  
  Ninit <- MCMCN[Isim,,] 
  #print(BasicData)
  set.seed(117711)
  N<- Project(BasicData,BasicPars,RunOptions,EnvironmentalData,Nyear=100,Ninit=Ninit,spawnfrac,FullF=0)
  print(str(N))
  AA
  Output <- ExtractOut(N)
  #print(Output$SSB[100]/Output$SSB0)

  set.seed(117711)
  N<- Project(BasicData,BasicPars,RunOptions,EnvironmentalData,Nyear=Nyear,Ninit=Ninit,spawnfrac,FullF=0.1)
  Output <- ExtractOut(N)
  #print(Output$SSB[2]/Output$SSB0)
  Trajs[Isim,] <-Output$SSB/Output$SSB0

}
 
par(mfrow=c(2,1))
quants <- matrix(0,nrow=5,ncol=Nyear) 
 for (Iyear in 1:Nyear) quants[,Iyear] <- quantile(Trajs[,Iyear],prob=c(0.05,0.25,0.5,0.75,0.95))
print(quants)
xx <- c(1:Nyear,rev(1:Nyear))   


plot(1:Nyear,quants[3,],xlab="Year",ylab="SSB/SSB0",type="l",lwd=2,ylim=c(0,1.2),col="red")
yy <- c(quants[1,],rev(quants[5,]))
polygon(xx,yy,col="gray10")
yy <- c(quants[2,],rev(quants[4,]))
polygon(xx,yy,col="gray90")
lines(1:Nyear,quants[3,],lwd=2,col="red")


plot(1:Nyear,Trajs[1,],xlab="Year",ylab="SSB/SSB0",type="l",lwd=2,ylim=c(0,1.2))
for (Isim in 2:Nsim)
  lines(1:Nyear,Trajs[Isim,]) 


AAA

# Test code for reference points
Refs <- DoGetMSYC(Nsex, Amax, M,Sel, Wcatch, Fec, Steep=0.7,spawnfrac,R0=R0,q=1,Price=1,Cost=200000) 
MSY <- Refs[[1]]
FMSY <- Refs[[3]]
BMSY <- Refs[[2]]
F35 <- Refs[[8]]
FMEY <- Refs[[12]]
MEY <- Refs[[13]]
BMEY <- Refs[[14]]
CMEY <- Refs[[15]]
print(Refs)

par(mfrow=c(2,2))
plot(Refs[[4]],Refs[[6]],xlab="Fishing mortality",ylab="Yield",type="l",ylim=c(0,MSY*1.1),yaxs="i")
lines(Refs[[4]],Refs[[10]],lty=2)
points(FMSY,MSY,pch=16)
plot(Refs[[5]]/Refs[[5]][1],Refs[[6]],xlab="SSB",ylab="Yield",type="l",ylim=c(0,MSY*1.1),yaxs="i")
points(BMSY/Refs[[5]][1],MSY,pch=16)
points(BMEY/Refs[[5]][1],CMEY,pch=1)
plot(Refs[[4]],Refs[[7]]/Refs[[7]][1],xlab="Fishing mortality",ylab="SPR",type="l",ylim=c(0,1.05),yaxs="i")
points(F35,0.35,pch=16)
plot(Refs[[4]],Refs[[11]],xlab="Fishing mortality",ylab="Profit",type="l",ylim=c(0,MEY*1.1),yaxs="i")
points(FMEY,MEY,pch=16)


        

