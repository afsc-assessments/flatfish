#setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
setwd("D:\\Research\\ABS\\ABS OA Rock Sole\\Code\\")
source("Utilities.r")  ## What is this I cannot find it

library(RcppArmadillo)
library(Rcpp)

Plot <- F



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

SetParameters <- function(EvalFile,Isim)
 {
  Amax <- 20
  Nsex <- 2
  
  start_yr <- EvalFile$styr[Isim]
  end_yr <- EvalFile$endyr[Isim]
  HistYr <- end_yr-start_yr+1
  Amax <- EvalFile$nages[Isim]

  # Extract environmental parameters
  spawnfrac <- as.numeric(EvalFile$spawnfrac[Isim])
  Growth_alpha <- EvalFile$Growth_alpha[Isim]
  Env1 <- EvalFile$Env1[Isim]
  Env2 <- EvalFile$Env2[Isim]
  phPar <- EvalFile$PhPar[Isim]

  M <- matrix(0,nrow=Nsex,ncol=Amax)
  M[1,] <- EvalFile$M_f[Isim]
  M[2,] <- EvalFile$M_m[Isim]

  Linf <- c(EvalFile$Linf_f[Isim],EvalFile$Linf_m[Isim])
  Kappa <- c(EvalFile$K_f[Isim],EvalFile$K_m[Isim])
  T0 <- c(EvalFile$t0_f[Isim],EvalFile$t0_m[Isim])
  aa <- c(EvalFile$a_f[Isim],EvalFile$a_m[Isim])
  bb <- c(EvalFile$b_f[Isim],EvalFile$b_m[Isim])

  # Selecivity
  Sel  <- matrix(0,nrow=Nsex,ncol=Amax)
  Sel[1,] <- as.numeric(EvalFile[Isim,paste("Self_",1:Amax,sep="")])
  Sel[2,] <- as.numeric(EvalFile[Isim,paste("Selm_",1:Amax,sep="")])
  # Initial N
  Ninit <- matrix(1,nrow=Nsex,ncol=Amax)
  Ninit[1,] <- as.numeric(EvalFile[Isim,paste("Nf_",1:Amax,sep="")])
  Ninit[2,] <- as.numeric(EvalFile[Isim,paste("Nm_",1:Amax,sep="")])
  # Weight-at-age
  Wcatch <- matrix(0,nrow=Nsex,ncol=Amax)
  Wcatch[1,] <- as.numeric(EvalFile[Isim,paste("WghtfC_",1:Amax,sep="")])
  Wcatch[2,] <- as.numeric(EvalFile[Isim,paste("WghtmC_",1:Amax,sep="")])
  WghtPop <- Wcatch
  Wpristine <- matrix(0,nrow=Nsex,ncol=Amax)
  Wpristine[1,] <- as.numeric(EvalFile[Isim,paste("Wghtf0_",1:Amax,sep="")])
  Wpristine[2,] <- as.numeric(EvalFile[Isim,paste("Wghtm0_",1:Amax,sep="")])
  # Maturity
  Matur <- as.numeric(EvalFile[Isim,paste("Matu_",1:Amax,sep="")])

  SSB <- as.numeric(EvalFile[Isim,paste("SSB_",start_yr:end_yr,sep="")])
  SSB <- SSB[-length(SSB)]

  BasicData <- NULL
  BasicData$Nsex <- Nsex
  BasicData$Amax <- Amax
  BasicData$M <- M
  BasicData$Wcatch <- Wcatch
  BasicData$Wpristine <- Wpristine
  BasicData$Matur <- Matur
  BasicData$Sel <- Sel
  BasicData$Linf <- Linf               
  BasicData$Kappa <- Kappa
  BasicData$T0 <- T0
  BasicData$aa <- aa
  BasicData$bb <- bb
  BasicData$spawnfrac <- spawnfrac
  BasicData$Ninit <- Ninit
  #print(str(BasicData))

  sprf0 <- SPR(BasicData,0.0)
  R_alpha = as.numeric(EvalFile$R_alpha[Isim])  
  R_beta = as.numeric(EvalFile$R_beta[Isim])  
  Rzero = -(log(1/(R_alpha*sprf0)))/(sprf0*R_beta)
  #cat(R_alpha,R_beta,R_alpha*117.335*exp(-R_beta*117.335),"\n")
  Steep <- exp(0.8*log(R_alpha*sprf0))/5.0
  R0 <- log(5*Steep)/(0.8*sprf0*R_beta)
  B0 <- R0*sprf0
  cat(sprf0,Steep,R0,Rzero,B0,"\n")
  test1 <- R0/B0*exp(log(5*Steep)/0.8)
  test2 <- log(5*Steep)/(0.8*B0)
  Top <- R0*117.335/B0*exp(log(5*Steep)/0.8*(1-117.35/B0))
  #cat(test1,test2,Top,"\n")

  # Parameters we change)
  BasicPars <- NULL
  BasicPars$R0 <- R0
  BasicPars$B0 <- B0
  BasicPars$Steep <- Steep
  BasicPars$SigmaR <- EvalFile$SigmaR[Isim] 
   BasicPars$EnvPars <- c(phPar,Env1,Env2,Growth_alpha)*1
  #print(BasicPars$EnvPars)
   
  Outs <- NULL
  Outs$BasicPars <- BasicPars
  Outs$BasicData <- BasicData
   
  return(Outs)
 }

# -----------------------------------------------------------------------------

ExtractData <- function()
 {
  Future <- read.csv("FutureEnv.csv",skip=3,head=F)
  #print(head(Future))
  Past <- read.csv("HistEnv.csv",skip=3,head=F)
  #print(head(Past))
  
  titles <- c("pH","SST","Cold Pool","Wind")
  
  # The environmental variables
  EnvironmentalData <- matrix(0,nrow=100,ncol=10)
  
  par(mfrow=c(2,2))
  Slope <- rep(0,4)
  Normalize <- c(F,T,T,F)
  for (Index in 1:4)
  {
    Use <- which(!is.na(Past[,Index+1]))
    Years <- Past[Use,1]
    HistV <- Past[Use,Index+1]
    MinY <- min(Years);MaxY <- max(Years)
    
    Use <- which(Future[,1] >=MinY & Future[,1] <=MaxY )
    FutV <- Future[Use,Index+1]
    Slope[Index] <- 1
    
    if (Normalize[Index]==T)
    {
      MeanFutV <- mean(FutV)
      SDFutV <- sd(FutV)
      FutV <- (Future[Use,Index+1]-MeanFutV)/SDFutV
      Future[,Index+1] <- (Future[,Index+1]-MeanFutV)/SDFutV
      Reg <- lm(HistV~FutV-1)
      Slope[Index] <- coef(Reg)[1]
      #print(Slope[Index])
      FutV <- FutV*Slope[Index]
    }
    plot(FutV,HistV,xlab="From Future Series",ylab="From Past Series")
    title(titles[Index])
    
    Years <- Future[,1]
    FutV <- Future[,Index+1]
    RefYr <- which(Years==2018)
    Nyear <- sum(Years>=2018)
    EnvironmentalData[1:Nyear,Index] <- FutV[RefYr:(RefYr+Nyear-1)]*Slope[Index]
  }  
  
  EvalFile <- read.table("Project.Inp",head=T)
  PostPhFile <- read.table("post1.csv",sep=",",head=T)
  EvalFile$PhPar <- PostPhFile$phPar
  #print(head(EvalFile))
  
  Outs <- NULL
  Outs$EvalFile <- EvalFile
  Outs$EnvironmentalData <- EnvironmentalData
  return(Outs)
 }

# -----------------------------------------------------------------------------
DoRun1 <- function(Outs,Plots=F)
{
 EnvironmentalData <- Outs$EnvironmentalData
 EvalFile <- Outs$EvalFile
 Nsim <- length(EvalFile[,1])
 Nsim <- 20

 # Options to specify (relates to functional forms and drivers)
 RunOptions <- NULL
 RunOptions$WeightOpt <- 1
 RunOptions$SROpt <- 2
 RunOptions$NenvLinks <- 4
 # Env Links (1=Env before SR; 2=Env after SR 3=Growth)
 RunOptions$EnvLinks <- matrix(c(2,1,0 ,2,3,0, 2,4,0, 3,2,0),byrow=T,ncol=3)
 RunOptions$EnvLinks[,2] <- RunOptions$EnvLinks[,2] -1
 print(RunOptions)

 set.seed(117711)

 Nyear <- 20
 Trajs <- matrix(0,nrow=Nsim,ncol=1000)
 RefsOut <- array(0,dim=c(10,Nsim,8))
 for (Isim in 1:Nsim)
  {  
   Outs <- SetParameters(EvalFile,Isim)
   BasicPars <- Outs$BasicPars
   BasicData <- Outs$BasicData
   B0 <- BasicPars$B0
   
   for (Iyear in 1:8)
    {
     TheYear <- (Iyear-1)*10  
     Refs <- DoGetMSYC(BasicData, BasicPars, RunOptions, EnvironmentalData, q=1,Price=1,Cost=200,TheYear=TheYear) 
     MSY <- Refs$MSY
     FMSY <- Refs$FMSY
     BMSY <- Refs$BMSY/B0
     F35 <- Refs$F35
     FMEY <- Refs$FMEY
     MEY <- Refs$MEY
     BMEY <- Refs$BMEY/B0
     CMEY <- Refs$CMEY
     cat(MSY,FMSY,BMSY,F35,FMEY,MEY,BMEY,CMEY,"\n")
     RefsOut[,Isim,Iyear] <- c(Isim,TheYear,MSY,FMSY,BMSY,F35,FMEY,MEY,BMEY,CMEY)

    if (Plot==T) 
     {
      par(mfrow=c(2,2))
      plot(Refs$Fs,Refs$Yields,xlab="Fishing mortality",ylab="Yield",type="l",ylim=c(0,MSY*1.1),yaxs="i")
      lines(Refs$Fs,Refs$Costs,lty=2)
      points(FMSY,MSY,pch=16)
      plot(Refs$SSBs/Refs$SSBs[1],Refs$Yields,xlab="SSB",ylab="Yield",type="l",xlim=c(0,1),ylim=c(0,MSY*1.1),yaxs="i")
      points(BMSY/Refs$SSBs[1],MSY,pch=16)
      points(BMEY/Refs$SSBs[1],CMEY,pch=1)
      plot(Refs$Fs,Refs$SPRs/Refs$SPRs[1],xlab="Fishing mortality",ylab="SPR",type="l",ylim=c(0,1.05),yaxs="i")
      points(F35,0.35,pch=16)
      plot(Refs$Fs,Refs$Profits,xlab="Fishing mortality",ylab="Profit",type="l",ylim=c(0,MEY*1.1),yaxs="i")
      points(FMEY,MEY,pch=16)
     }
   } #Iyear
  } # Isim 
   
 StatName <- c("MSY","FMSY","BMSY","F35","FMEY","MEY","BMEY","CMEY")
 par(mfrow=c(4,2))  
 for (Istat in c(4,7))
  {
   for (Iyear in 1:8)  
     hist(RefsOut[Istat,,Iyear],main="",xlab=StatName[Istat])
  } 
 OutFileName <- "Fig1.out"
 write("",OutFileName)
 for (Istat in 1:8)
 {
  write(Istat,OutFileName,append=T) 
  write(t(RefsOut[Istat+2,,]),OutFileName,append=T,ncol=8)
   
 } 
 
}

# =======================================================================
# =======================================================================

tst <- function()
 {  
  # Store historical data
  #BasicPars <- BasicParStore
  #BasicPars$SigmaR=0
  #Trajs[Isim,1:(HistYr-1)] <- SSB/B0
  #N<- Project(BasicData,BasicPars,RunOptions,EnvironmentalData,Nyear=83,FullF=0)
  #print(str(N))
  #Output <- ExtractOut(N)
  #print(Output$SSB/Output$SSB0)
  #plot(1:100,Output$SSB/Output$SSB0)
  #AA
    
  #N<- Project(BasicData,BasicPars,RunOptions,EnvironmentalData,Nyear=Nyear,FullF=0.1)
  #Output <- ExtractOut(N)
  #print(Output$SSB[2]/Output$SSB0)
  #Trajs[Isim,(HistYr):(HistYr+Nyear-1)] <- Output$SSB/Output$SSB0



FinYr <- HistYr+Nyear-1

par(mfrow=c(2,1))
quants <- matrix(0,nrow=5,ncol=FinYr) 
 for (Iyear in 1:FinYr) quants[,Iyear] <- quantile(Trajs[,Iyear],prob=c(0.05,0.25,0.5,0.75,0.95))
#print(quants)
years <-  start_yr:(end_yr+Nyear-1)
xx <- c(years,rev(years))   


plot(years,quants[3,],xlab="Year",ylab="SSB/SSB0",type="l",lwd=2,ylim=c(0,1.2),col="red")
yy <- c(quants[1,],rev(quants[5,]))
polygon(xx,yy,col="gray10")
yy <- c(quants[2,],rev(quants[4,]))
polygon(xx,yy,col="gray90")
lines(years,quants[3,],lwd=2,col="red")
abline(v=2018,lwd=2,col="red")


plot(years,Trajs[1,1:FinYr],xlab="Year",ylab="SSB/SSB0",type="l",lwd=2,ylim=c(0,1.2))
for (Isim in 2:Nsim)
  lines(years,Trajs[Isim,1:FinYr]) 


}
        
Outs <- ExtractData()
DoRun1(Outs,Plots=F)
  