radian #what is this line about?
rm(list=ls())
library(tidyverse)
library(grid)
library(ggridges)
#-------------------------------------------------------------------------------
# Visual compare runs
#-------------------------------------------------------------------------------
#Read in functions=========
#setwd("C:/GitProjects/flatfish/assessments/nrs/runs")
mydir = getwd()
Rdir = "../../R"
setwd(Rdir)
source("prelims.R")
setwd(mydir)
#C:\GitProjects\flatfish\assessments\R

#--------------------------------------
# Read in the output of the assessment
# The model specs
mod_names <- c("2020 no new", "2020 updated fish age","2020 updated fish age drop 95-97","2020 with time-varying fish wt-age")
.MODELDIR = c( "j1/", "j2/","j3/","j4/")

# Read report files and create report object (a list):
fn       <- paste0(.MODELDIR, "fm")
modlst   <- lapply(fn, read_admb)
names(modlst) <- mod_names
thismod <- 4 # the selected model
length(modlst)
  p1 <- plot_rec(modlst,xlim=c(1975.5,2020.5))
  ggsave("figs/mod_eval0b.pdf",plot=p1,width=8,height=4.0,units="in")
  p1 <- plot_ssb(modlst,xlim=c(1975.5,2020.5),alpha=.1)
  plot_bts(modlst) + theme_few(base_size=11)
  
  #Can't find this function
  #plot_agefit(M,type="fishery", case_label="No new data",gear="fsh")

  p1 <- plot_sel(modlst[[1]]); p1
  p1 <- plot_sel(modlst[[3]]); p1
  ggsave("figs/mod_fsh_sel.pdf",plot=p1,width=4,height=8,units="in")

  #this one doesn't work right now.
  p1 <- plot_srv_sel(M=modlst[[4]]$sel_srv_f, title="Survey selectivity",bysex=TRUE)
  #p1 <- plot_sel(sel=M$sel_bts,styr=1982,fill="darkblue") 
  #p1 <- plot_sel(mod = modlst[[4]],sel=M$sel_bts,styr=1982,fill="darkblue") 
  #plot_sel(sel=M$sel_eit,styr=1994,fill="darkblue") 
  ggsave("figs/mod_bts_sel.pdf",plot=p1,width=4,height=8,units="in")
 
  #this one doesn't work right now
  p1 <- plot_mnage(modlst[thismod]) 
  ggsave("figs/mod_mean_age.pdf",plot=p1,width=5.8,height=8,units="in")
  
  p1 <- plot_bts(modlst[thismod]) 
  ggsave("figs/mod_bts_biom.pdf",plot=p1,width=5.2,height=3.7,units="in")
 
  #couldn't find the function 
  p1 <- plot_ats(modlst[thismod]) 
  ggsave("figs/mod_ats_biom.pdf",plot=p1,width=5.2,height=3.7,units="in")
  
  #couldn't find the function
  p1 <- plot_avo(modlst[thismod]) 
  ggsave("figs/mod_avo_fit.pdf",plot=p1,width=5.2,height=3.7,units="in")
  
  #couldn't find the function
  p1 <- plot_cpue(modlst[[thismod]]) 
  ggsave("figs/mod_cpue_fit.pdf",plot=p1,width=5.2,height=3.7,units="in")
  p1 <- plot_recruitment(modlst[thismod],xlim=c(1963.5,2018.5),fill="yellow")
  ggsave("figs/mod_rec.pdf",plot=p1,width=9,height=4,units="in")
  
  #this one didn't work
  p1 <- plot_srr(modlst[thismod],alpha=.2,xlim=c(0,5200),ylim=c(0,75000))
  ggsave("figs/mod_srr.pdf",plot=p1,width=5.4,height=3.9,units="in")
  p1 <- plot_srr(modlst[c(2,4)],alpha=.2,xlim=c(0,5200),ylim=c(0,75000))
  ggsave("figs/bholt_ricker.pdf",plot=p1,width=7.4,height=3.9,units="in")
  pdf("../doc/figs/mod_fsh_age.pdf",width=6,height=8)
  dev.off()
  
  #---Data influence------------
  CAB_names <- factor(c("Model 16.1 \nlast year", "Catch added", "Add ATS", "Add BTS", "Add AVO"),levels=c("Model 16.1 \nlast year", "Catch added", "Add ATS", "Add BTS", "Add AVO"))
  CAB_names <- c("Model 16.1 \nlast year", "Catch added", "Add ATS", "Add BTS", "Add AVO")
  #factor(sizes, levels = c("small", "medium", "large"))
  .CABMODELDIR = c( "../2017/16.0/", "../runs/C/","../runs/CA/","../runs/CAB/","../runs/16.0/")

  # Read report file and create gmacs report object (a list):
  fn       <- paste0(.CABMODELDIR, "pm")
  CABmodlst   <- lapply(fn, read_admb)
  CAB_names <- 1:5
  names(CABmodlst) <- CAB_names
  p <-  plot_ssb(CABmodlst,xlim=c(2009.5,2018.5),alpha=.1,ylim=c(0,5200))
  CAB_names <- c("Model 16.1 \nlast year", "Catch added", "+ ATS", "+ BTS", "+ AVO")
  p <-  p + scale_fill_discrete(labels=CAB_names) + scale_color_discrete(labels=CAB_names) + theme_classic()
  p
  #plot_ssb(modlst[],xlim=c(2004.5,2018.5),alpha=.1,ylim=c(0,5200))
  ggsave("figs/mod_data.pdf",plot=p,width=6,height=4,units="in")
  #for (i in 1:length(mod_names)) modlst[[i]] <- c(modlst[[i]],get_vars(modlst[[i]]))




M <- M[refSet]
M <- M[1]
refSet=1


plot_srv_sel(M[refSet])
plot_srv_sel(M)
plot_sel(mod4,alpha=.2)

plot_srv_sel(M,bysex=FALSE)
plot_srv_sel(M[refSet],bysex=FALSE)

plot_age_comps(M[1])
plot_age_comps(M[1],type="survey")
plot_age_comps(M[4])

plot_sex_ratio(M,ylim=c(.2,.8))
plot_sex_ratio(M,ylim=c(.2,.8),type="Population")
plot_sex_ratio(M,ylim=c(.2,.8),type="Survey")

plot_age_comps(M,title="Survey age compositions",type="Survey")
.THEME <- .THEME + theme(strip.text.y = element_text(angle = 0))
plot_bts(M[1] ,alpha=.6) #Plot model one
plot_bts(M ,alpha=.6) #Plot model one
#make a table of likelihoods
.get_like_df(M)
plot_ssb(M,alpha=.26,xlim=c(1990,2018))
plot_ssb(M[c(1,3,5)],alpha=.26,xlim=c(1990,2018))
plot_rec(M,alpha=.26,xlim=c(1990,2018),ylim=c(0,5000))
plot_rec(M[1],alpha=.26)
,xlim=c(1990,2018),ylim=c(0,5000))
plot_rec(M[c(1,5,8)],alpha=.26,xlim=c(1990,2014))
plot_srr(M,alpha=.2)
plot_srr(M[c(1,4)],alpha=.26)
plot_srr(M[c(1)],alpha=.26)

.OVERlAY=TRUE
,xlim=c(0,1100),ylim=c(0,7.2))
like_tab <- data.table()
like_tab <- data.frame()
for (i in 1:4) {
  like_tab <- rbind(like_tab,(M[[i]]$nLogPosterior ))
}
dim(like_tab)
  names(like_tab) <- c("wt_like(1)", "wt_like(2)", "wt_like(3)", "wt_fut_like", "wt_msy_like", "init_like  ", "srv_like(1)", "catch_like ", "age_like_fsh(1)", "age_like_srv(1)",
  "rec_like(1)", "rec_like(2)", "rec_like(3)", "rec_like(4)", "sel_like(1)", "sel_like(2)", "q_prior(1)  ", "sigmaR_prior", "m_prior     ", "fpen")

like_tab

#Recruits==========================================================
mytheme = mytheme + theme(axis.text.x = element_text(angle=90, hjust=1, vjust=.5))
rdf <- data.frame(mod1$R)
rdf <- cbind(rdf,"2015")
names(rdf) <- c("yr","R","se","lb","ub","case")
rdf  <- filter(rdf , yr>1990,yr<2016)
mnR <- mean(rdf$R)
mnR
rdf0 <- data.frame(mod2$R)
rdf0 <- cbind(rdf0,"mod2")
names(rdf0) <- c("yr","R","se","lb","ub","case")
rdf0 <- filter(rdf0, yr>1990,yr<2016)
rdf <- rbind(rdf0,rdf)
tbl_df(rdf)
dodge <- position_dodge(width=0.8)
ggplot(rdf,aes(x=yr,y=R,fill=case)) + xlab("Year class") + ylab("Age 1 recruits (10e6)") + 
       geom_bar(width=0.75,position="dodge") + #,stat="identity",aes(fill=case)) + 
       geom_errorbar(aes(ymin=lb,ymax=ub),width=.3,colour="blue",position=dodge) + mytheme + geom_hline(aes(yintercept=mnR),linetype="dashed")

ggplot(rdf, aes(x=yr,y=R)) + 
  geom_point(position=dodge,na.rm=TRUE) + 
  geom_errorbar(data=rdf,position=dodge,aes(ymax=ub,ymin=lb), width=0.25)  + mytheme
ggplot(cabbage_exp, aes(x=Date, y=Weight, fill=Cultivar)) +
        geom_bar(position="dodge") +
        geom_errorbar(aes(ymin=Weight-se, ymax=Weight+se),
                      position=position_dodge(0.9), width=.2)


  #scale_y_continuous(limits=c(0,1800))+
     ggtitle("2014") + mytheme
     ggtitle("2015") + mytheme

df <- data.frame(Year=1977:2015,mod5$M)
ggplot(df,aes(x=Year,y=X1))+geom_line(size=2) + mytheme + ylab("Natural mortality") + ylim(c(0,.4))

#-------------------------------------------------------------------------------
# Fit to survey data
dt <- data.frame(mod1$Obs_Survey_1[,1:3],mod2$Obs_Survey_1[,3],mod3$Obs_Survey_1[,3],mod4$Obs_Survey_1[,3])
dt <- data.table(dt)
names(dt) <- c("Year","Observed","Model_1","Model_2","Model_3","Model_4")
dt<-melt(dt,id="Year")
dt
,aes(x=Age,y=value,colour=variable)) 
ggplot(dt,aes(x=Year,y=value,col=variable)) + geom_point(data=dt[variable=="Observed"],size=3) + geom_line(data=dt[variable!="Observed"]) + ylim(c(0,1500000)) + labs(x="Year",y="Survey biomass") + mytheme #+
            geom_line(data=)
#-------------------------------------------------------------------------------
#Selectivity
            mod1$sel_fsh_1
df <- data.frame(mod1$sel_fsh_1[,2:13] ); names(df) <- c("yr",1:11)
sdf <- gather(df,age,sel,2:12) %>% filter(yr>1990) %>% mutate(age=as.numeric(age)) #+ arrange(age,yr)
p1 <- ggplot(sdf, aes(x=age,y=sel/2+yr,group=yr)) +                  geom_ribbon(aes(ymin=yr,ymax=sel/1.9+yr),fill="tan",col="grey60",alpha=.3)  + ylab("")                        + xlab("Age") + guides(fill=FALSE,alpha=FALSE,col=FALSE) + mytheme
p1 <- p1 + scale_x_continuous(breaks = seq(1940, 1976, by = 4))
df <- data.frame(mod3$sel_fsh_1[,2:13] )%>% arrange(yr,age) ; names(df) <- c("yr",1:11)
sdf <- gather(df,age,sel,2:12) %>% filter(yr>1990) %>% mutate(age=as.numeric(age)) #+ arrange(age,yr)
p2 <- ggplot(sdf, aes(x=age,y=sel/2+yr,group=yr)) +                  geom_ribbon(aes(ymin=yr,ymax=sel/1.9+yr),fill="tan",col="grey60",alpha=.3)  + ylab("")                        + xlab("Age") + guides(fill=FALSE,alpha=FALSE,col=FALSE) + mytheme
grid.arrange(p1,p2,ncol=2)

df
p1

mod7$M
mod2$M_equil
IndexFit(mod1,yf=1980,yl=2015,f=1,main="Model 1",ylab="Survey biomass (t)")
IndexFit(mod5,yf=1980,yl=2015,f=1,main="Model 5",ylab="Survey biomass (t)")
IndexFit(mod7,yf=1980,yl=2015,f=1,main="Model 4",ylab="Survey biomass (t)")

AgeFits(mod1,rec_age=1,case_label="Model 1 assessment")
AgeFits(mod7,rec_age=1,case_label="Model 6 assessment")
AgeFits(mod4,rec_age=1,case_label="Model 4 assessment")
IndexFit(mod2,yf=1980,yl=2015,f=1,main="Model 2",ylab="Survey biomass (t)")
AgeFits(mod1,rec_age=1,case_label="Model 1 assessment")
AgeFits(mod2,rec_age=1,case_label="Model 2 assessment")
AgeFitsSrv(mod1,rec_age=1,case_label="2015 assessment")
Plot_Fspr()

#Selectivity==============================================
df <- data.frame(Model="Model 1",mod1$sel_fsh_1[,2:13] ); 
for (i in 2:7) df <- rbind(df, data.frame(Model=paste0("Model ",i),lstOuts[[i]]$sel_fsh_1[,2:13] ))
names(df) <- c("Model","yr",1:11)
sdf <- gather(df,age,sel,3:13)
tbl_df(sdf)
sdf$age <- as.numeric(sdf$age)
sdf <- data.table(sdf)
sdf <- sdf[yr>2010, (Selectivity=mean(sel)),.(Model,age)]
ggplot(sdf ,aes(x=age,y=V1,colour=Model),size=1.2) + geom_line(size=2) +ylab("Fishery selectivity") +xlab("Age")+ mytheme #+ facet_grid(yr~.)
#-------------------------------------------------------------------------------

p1 <- dplyr::filter(sdf,yr>1979) %>% arrange(yr,age) %>%ggplot(aes(x=age,y=sel/2+yr,group=yr)) + geom_ribbon(aes(ymin=yr,ymax=sel/1.9+yr),fill="tan",col="grey60",alpha=.3)  + ylab("Selectivity by year") + xlab("Age") + guides(fill=FALSE,alpha=FALSE,col=FALSE) + mytheme
p1

#-------------------------------------------------------------------------------
compareTime(lstOuts,"SSB",SD=T,Sum=NULL,legendPos="right",startYear=1980)
compareTime(lstOuts,"SSB",SD=F,Sum=NULL,startYear=1953)
compareTime(lstOuts,"R",SD=T)
compareTime(lstOuts,"TotBiom",SD=T)
compareMatrix(lstOuts,"TotF",SD=TRUE,Sum=NULL,YrInd=mod1$Yr,Apply=mean,legendPos="right")
#-------------------------------------------------------------------------------

p1 <- dplyr::filter(sdf,yr>1979) %>% arrange(yr,age) %>%ggplot(aes(x=age,y=sel/2+yr,group=yr)) + geom_ribbon(aes(ymin=yr,ymax=sel/1.9+yr),fill="tan",col="grey60",alpha=.3)  + ylab("Selectivity by year") + xlab("Age") + guides(fill=FALSE,alpha=FALSE,col=FALSE) + mytheme
p1
p2 <- dplyr::filter(sdf,yr>2002) %>% ggplot(aes(x=age,y=sel/2+yr,group=yr)) +                  geom_ribbon(aes(ymin=yr,ymax=sel/1.9+yr),fill="tan",col="grey60",alpha=.3)  + ylab("")                        + xlab("Age") + guides(fill=FALSE,alpha=FALSE,col=FALSE) + mytheme
grid.arrange(p1,p2,ncol=2)

p2 <- dplyr::filter(sdf,yr>1977) %>% ggplot(aes(x=age,y=sel/2+yr,group=yr)) + geom_ribbon(aes(ymin=yr,ymax=sel/1.6+yr,fill="salmon",col="grey",alpha=.2))  + ylab("")                        + xlab("Age") + guides(fill=FALSE,alpha=FALSE,col=FALSE) + mytheme

#Survey selectivity==============================================
mod1$sel_ind_1
srv_sel <- mod1$sel_ind_1[1,3:13]
srv_sel <- data.frame(Age=1:11,Selectivity=srv_sel/max(srv_sel))
srv_sel
mytheme = .THEME + theme(axis.text.x = element_text(angle=0, hjust=1, vjust=.5))
ggplot(srv_sel) + geom_line(aes(x=Age,y=Selectivity),size=2) +mytheme
#=====================
# Retro
# get all retrospectives
#=====================
setwd(outdir)
getwd()
# Read in retro results
for (i in 0:10) {
  rn=paste0("retro/ret1_",i,"_R.rep")
  mn=paste0("retro",i)
  assign(mn,readList(rn))
  print(rn)
}
retouts <- list()
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
tab = list(R0=mod1$SSB)
getwd()
for (i in 1:10) { tab=cbind(tab,retouts[[i]]$SSB)}

#pdf(paste(Figdir,"Retro_Mods.pdf",sep=""),width=9, height=6)
library(ggthemes)
names(mod1$SSB)
rn = "mod1"
dim(tdf)
p1 <- ggplot() + scale_y_continuous(limits=c(0,590000)) + ylab("Spawning biomass") + xlab("Year") + ggthemes::theme_base() + geom_line(data=bdf,aes(x=yr,y=SSB),size=4) +
           geom_ribbon(data=bdf ,aes(x=yr,y=SSB,ymin=lb,ymax=ub),fill="tan",col="grey",alpha=.6)  + guides(fill=FALSE,alpha=FALSE,col=FALSE) 
for (i in 1:10) {
  rn=paste("retro",i,sep="");
  tdf <- data.frame(get(rn)$SSB); names(tdf) <- c("yr","SSB","SE","lb","ub"); tdf <- filter(tdf,yr>1977)
  p1 <- p1 + geom_line(data=tdf,aes(x=yr,y=SSB),col=i,linetype=i,size=1.25)
  #p1 <- p1 + geom_segment(data=tdf,aes(x=yr,xend=yr,yend=SSB,y=SSB),arrow=arrow(angle=90,length=unit(.2,"cm")),size=2,col=i)
  tdf <- tdf[dim(tdf)[1],]
  p1 <- p1 + geom_point(data=tdf,aes(x=yr,y=SSB),size=4,col=i)
  #p1 <- p1 + geom_point(get(rn)$SSB[lr,1],get(rn)$SSB[lr,2],pch=19,col=i)
}
p1
# If you want to post lines when new survey data arrive...
# p1 <- p1 +  geom_vline(xintercept=c(2014,2012,2010,2008),linetype="dashed",size=1,col="grey")
# Color blind palette
# cb_palette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
# p1 <-    p1 + scale_fill_manual(values=cb_palette)
df <- data.frame(mod1$SSB )
names(df) <- c("yr","SSB","SE","lb","ub")
bdf <- filter(df,yr>1977,yr<=2018)
bdf2<- filter(df,yr>1977)
bdf
bdft <- bdf
for (i in 1:10) bdft <- cbind(bdft,rep(NA,41))
names(bdft)[6:15] <- paste0("SSB_",2017:2005)
for (i in 1:10) bdft[1:(39-i),i+5] <- get(paste0("retro",i))$SSB[14:(52-i),2]
bdft
for (i in 1:10) bdft[,i+5] <- bdft[,i+5]/bdf$SSB
p2 <- ggplot(bdft,aes(x=yr,y=SSB)) + scale_y_continuous(limits=c(.25,1.75)) + ylab("Relative spawning biomass") + xlab("Year") +  mytheme  
for (i in 1:10) {
  tdf <- data.frame(cbind(bdft[1],SSB=bdft[5+i]))[1:(38-i),]
  names(tdf) <- c("yr", "SSB")
  p2 <- p2 + geom_line(data=tdf, aes(x=yr,y=SSB),col=i,size=1.5)
  tdf <- tdf[dim(tdf)[1],]
  p2 <- p2 + geom_point(data=tdf,aes(x=yr,y=SSB),size=4,col=i)
}    
p2 <-p2 +geom_hline(aes(yintercept=1),size=3,linetype="dotted")
p2 <-p2 +geom_hline(aes(yintercept=1),size=1,col="grey")
p2
grid.arrange(p1,p2,nrow=2)
# Mohn's rho
rc = retro0$SSB[,2]
ntmp=0
rho=0
for (i in 1:15) {
  dtmp=get(paste0("retro",i))$SSB
  lr=length(dtmp[,1])
  ntmp= ntmp+(dtmp[lr,2] -rc[lr])/rc[lr]
  #rho = rho + (-(ALL[i,2]-ALL[*tsyrs-i,2+i]))/ALL[(j)*tsyrs-i,2]
  rho = rho + (-(dtmp[i,2]-rc[i]))/rc[lr]
  print(paste(i,ntmp/i,rho))
}    

#============================================================kkkkkkkkkk
# Model selected for 2013

# used in doc to compare this year w/ last...

rec_age=1
p.rec.hist(mod1,main="Model 1",ylab="Recruitment to age",fy=1930,ly=2015,plotmean="T")
# Survey fit
IndexFit(mod1,yf=1980,yl=2015,f=1,main="Model 1", ,ylab="Survey biomass (t)")
p.catch.fit(mod1,f=1,ylim=c(0,10000))
plot(mod1$SSB,typ="b",ylab="SSB",xlab="Year",ylim=c(0,.65e6))
mod1$SSB

#pdf(paste(Figdir,"TotB.pdf",sep=""),width=9, height=7)
detach(dat)
p.biom.pol(mod1,typ="SSB",main="Model 1",new=F,fy=1977,ly=2016)
lines(mod1$TotBiom[,1],mod1$TotBiom[,2],col="black",lty=2,lwd=3)
p.biom.pol(mod1,typ="TB",main="Model 1",new=F,fy=1977,ly=2014)
#dev.off()

styr=1976
p.stock.rec(mod6,main="Atka mackerel")
p.stock.rec(mod1,main="Atka mackerel")
p.eff.n(mod6,typ="F",f=1,main="Model")
p.eff.n(mod1,typ="S",f=1,main="Model 1")
AgeFits(mod1,rec_age=1,case_label="2015 assessment")
AgeFitsSrv(mod1,rec_age=1,case_label="2015 assessment")
#dev.off()
detach(dat)
# spawning biomass and last year's estimates 
p.biom.pol(mod1,typ="SSB",new=F,fy=1977,ly=2015)
lines(1976:2016,mod5$SSB[12:52,2],lwd=2)
#names(mod1)

# Rec
p.biom.stk(mod1,typ="R")
# Numbers at age
p.bub.age(mod1,siz=1000)
#dev.off()

p.rec.hist(mod1,fy=1977,ly=2015,main="Model 1")
lines(modsigmaR$R[,1],modsigmaR$R[,2],col="purple",lwd=2)
#dev.off()

# Likelihood table
tab       <- cbind(lstOuts[[1]]$Like_Comp_names,do.call(cbind,lapply(lstOuts,function(x){round(x[["Like_Comp"]],2)})))
tab       <- cbind(lstOuts[[1]]$Like_Comp_names,do.call(cbind,lapply(lstOuts,function(x){round(x[["Like_Comp"]],2)})))
tab
do.call(cbind,lapply(lstOuts,function(x){round(x[["Like_Comp"]],2)}))
do.call(cbind,lapply(lstOuts,function(x){round(x[["Like_Comp"]],2)}))
rbind(
cbind("q",do.call(cbind,lapply(lstOuts,function(x){round(x[["q_1"]][1,2],2)}))),
cbind("Npars",do.call(cbind,lapply(lstOuts,function(x){round(x[["Num_parameters_Est"]],2)}))),
cbind("M",do.call(cbind,lapply(lstOuts,function(x){round(x[["Mest"]][2],2)}))),
cbind("SigmaR",do.call(cbind,lapply(lstOuts,function(x){round(x[["Sigmar"]][2],2)}))),
cbind("EffN_Fish",do.call(cbind,lapply(lstOuts,function(x){round(mean(x[["EffN_Fsh_1"]][,2]),2)}))),
cbind("EffN_Surv",do.call(cbind,lapply(lstOuts,function(x){round(mean(x[["EffN_Survey_1"]][,2]),2)}))),
tab,
cbind("F2014",do.call(cbind,lapply(lstOuts,function(x){round((x[["F_fsh_1"]][38,2]),2)}))),
cbind("F2014/F40%",do.call(cbind,lapply(lstOuts,function(x){round((x[["F_fsh_1"]][38,2])/(x[["F40_est"]]),2)}))),
cbind("B 1977",do.call(cbind,lapply(lstOuts,function(x){round((x[["TotBiom"]][1,2]),0)}))),
cbind("CV",do.call(cbind,lapply(lstOuts,function(x){round((x[["TotBiom"]][1,3])/(x[["TotBiom"]][1,2])*100,0)}))),
cbind("B 2014",do.call(cbind,lapply(lstOuts,function(x){round((x[["TotBiom"]][38,2]),0)}))),
cbind("CV",do.call(cbind,lapply(lstOuts,function(x){round((x[["TotBiom"]][38,3])/(x[["TotBiom"]][38,2])*100,0)}))),
cbind("2001 YC",do.call(cbind,lapply(lstOuts,function(x){round((x[["R"]][26,2]),0)}))),
cbind("CV",do.call(cbind,lapply(lstOuts,function(x){round((x[["R"]][26,3])/(x[["R"]][26,2])*100,0)}))),
cbind("2006 YC",do.call(cbind,lapply(lstOuts,function(x){round((x[["R"]][31,2]),0)}))),
cbind("CV",do.call(cbind,lapply(lstOuts,function(x){round((x[["R"]][31,3])/(x[["R"]][31,2])*100,0)})))
)

?do.call
names(mod1)



mod1$Like_Comp
mod1$Like_Comp_names
SSB_Lastyr=read.table("clipboard")
names(mod1)

p.biom.pol(mod0,typ="SSB",new=F)
p.biom.pol(mod1,typ="SSB",new=F)
p.biom.pol(mod2,typ="SSB",new=F,main="Model 2".ly=2013)
lines(mod0$SSB[,1],mod0$SSB[,2],col="red")
lines(mod1$SSB[,1],mod1$SSB[,2],col="green")

#++++SSB CV figure=========================
plot(d3$SSB[,1],d3$SSB[,3]/d3$SSB[,2],typ="l",lty=2,ylim=c(0,.4),ylab="CV on spawning biomass",xlab="Year",cex.lab=1.4)
lines(d3$SSB[,1],d1$SSB[,3]/d1$SSB[,2],lwd=2)
lines(d3$SSB[,1],d2$SSB[,3]/d2$SSB[,2],lty=1)
lines(d3$SSB[,1],d7$SSB[,3]/d7$SSB[,2],lty=3)
legend(1968,.4, c("sigma_d=0.1","sigma_d=0.2","sigma_d=0.3", "sigma_d=1.0"),lty=c(1,1,2,3),lwd=c(2,1,1,1))

lines(modvsel$SSB[,1],modvsel$SSB[,2],col="red")
lines(mod2$SSB[,1],mod1$SSB[,2],col="purple",lwd=2)
lines(mod2$SSB[,1],mod2$SSB[,2],col="green",lwd=2)
lines(mod2$SSB[,1],mod3$SSB[,2],col="pink",lwd=2)
lines(mod2$SSB[,1],mod4$SSB[,2],col="black",lwd=2)

lines(modestM$SSB[,1],modestM$SSB[,2],col="salmon",lwd=2)
lines(modsigmaR$SSB[,1],modsigmaR$SSB[,2],col="purple",lwd=2)
modestM$Index_Q_1
names(mod1)

#++++Selectivity figure=========================
SelLastYr=c(0.00228954, 0.0333104,	0.337153,	0.879725,	1.13117,	1.32736,	1.619,	1.61509,	1.46665,	1.29413,	1.29413)
SelLastYr[[1]][1:11]
d1=readList(paste(outdir,"arc\\ds.1_R.rep",sep=""))
d2=readList(paste(outdir,"arc\\ds.2_R.rep",sep=""))
d3=readList(paste(outdir,"arc\\ds.3_R.rep",sep=""))
d7=readList(paste(outdir,"arc\\ds1.0_R.rep",sep=""))
q1.3=readList(paste(outdir,"arc\\q1.3_R.rep",sep=""))
plot(d1$N[36,3:12],typ="p",pch=19)
lines(d7$N[36,3:12])
k=36
plot(1:11,d3$sel_fsh_1[k,3:13]/max(d3$sel_fsh_1[k,3:13]),typ="l", ylab="Selectivity",xlab="Age",lwd=3, cex.lab=1.8)
lines(d1$sel_fsh_1[k,3:13]/max(d1$sel_fsh_1[k,3:13]),lty=2)
lines(d7$sel_fsh_1[k,3:13]/max(d7$sel_fsh_1[k,3:13]),lty=3)
lines(q1.3$sel_fsh_1[k,3:13]/max(q1.3$sel_fsh_1[k,3:13]),lty=3)
lines(SelLastYr/max(SelLastYr),lty=4)
SelLastYr
abline(h=.5)
legend(1,.95, c("sigma_d=0.3","sigma_d=0.1","sigma_d=1.0", "2011 Assessment"),lty=1:4,lwd=c(3,1,1,1,1))
#END ofSelectivity figure=========================


lines(mod1$TotBiom[,1],mod1$TotBiom[,2],lty=2,lwd=2)
pdf("Atka_2013.pdf",width=9, height=7)
Mntns(mod0,"Model 0")
Mntns(mod1,"Model 1")
Mntns(mod2,"Model 2")
mod1$Q_Survey_1
mod2$Q_Survey_1
dev.off()

pdf(paste(Figdir,"Selectivity.pdf",sep=""),width=7, height=11)
par(mfrow=c(1,2))
sel.age.mountain(mod1, f=1, new="F",typ="F", xvec=c(1:11),main="Model 1")
sel.age.mountain(mod2, f=1, new="F",typ="F", xvec=c(1:11),main="Model 2")
sel.age.mountain(mod2.2, f=1, new="F",typ="F", xvec=c(1:11),main="Model 2.2")
sel.age.mountain(mod1.2, f=1, new="F",typ="F", xvec=c(1:11),main="Model 2.2")
dev.off()
par(mfcol=c(1,1),mar=c(5,5,4,2) + 0.1)  

p.catch.fit(mod1,f=1,ylab="Catch biomass (t)",ylim=c(0,120000))
names(mod1)
                 
mod1$Fshry_names="Trawl"                 
spwn_ratio(mod1,main="Model 1")
cont.f.age.res(mod1, typ = "F", f = 1, lage = 1, hage = 11, cl ="COL")
p.bub.age(mod1,lage=1,hage=11,fy=1977,ly=2011,siz=100)
detach(dat)
Plot_Phase()
AgeFits(mod2,f=1,case_label="2013 assessment",rec_age=1)
AgeFits(mod1,f=1,case_label="2013 assessment",rec_age=1)
                 
modsigmaR$R
                 xlab="Age",ylab="Year",zscale=2.5,new=F,cex.yax=1.,fy=1980)
detach(dat)
IndexFit(mod,yf=1980,yl=2010,f=2,main=main)

par(mfcol=c(1,1))

# show fit to catch biomass
CatchFit(mod2.2)

# show spawning biomass relative to population with no fishing
spwn_ratio(mod1,fy=1962,ly=2015) 
fix(spwn_ratio) 

detach(dat)
# example of writing multiple plots to pdf file:
#pdf("figs/agefits.pdf",width=9, height=7)
  #AgeFits(am1,f=1)
#dev.off()

# another example of writing multiple plots to pdf file:
#pdf("figs/survey_fit.pdf",width=7, height=9)
#Mntns(am1,"Model 1")
    # Indices(am1,"Model 1")
par(mfrow=c(1,1))
IndexFit(mod1,main="Model 1",yf=1990,ylab="Survey biomass (t)")
detach(dat) 
Plot_Fspr()
source("R/Plot_Atkas.R")
#spwn_ratio(am1) 
#plt_proj(am1)
#dev.off()

dev.off()

p.biom.pol(retro2,typ="SSB",main="Model 1",new=F,fy=1977,ly=2013)
for (i in 1:9) {
  rn=paste0("retro1",i);
  lines(get(rn)$SSB[,1],get(rn)$SSB[,2],col=i)
}
pdf(paste(Figdir,"Retro_Mod2.pdf",sep=""),width=7, height=9)
par(mfrow=c(2,1))
p.biom.pol(retro0,typ="SSB",main="Model 2",new=F,fy=1977,ly=2012)
#plot(retro0$SSB[,1],retro0$SSB[,2],ylim=c(0,550),      ylab="Spawning biomass (kt)",type="l",lwd=2,xlab="",lty=2)
ssb=1966:2013
retro0$R
names(retro1)
rrr=1977:2012
for (i in 0:10) {
  rn=paste("retro",i,sep="");
  lines(get(rn)$SSB[,1],get(rn)$SSB[,2],col=i)
  ssb=rbind(ssb,c(t(get(rn)$SSB[,2]),rep(NA,i)))
  rrr=rbind(rrr,c(t(get(rn)$R[,2]),rep(NA,i)))
  }
write.csv(ssb,"Atka_SSB.csv")
write.csv(rrr,"Atka_rec.csv")

system("atka_ssb.csv")
?write.csv
rrr
rep(NA,2)
plot(retro0$SSB[,1],rep(0,length(retro0$SSB[,1])),
     ylim=c(-.7,.7),
     ylab="Relative difference from terminal year",
     type="l",xlab="Year",lty=2,lwd=2)
for (i in 1:10) {
  rn=paste("retro",i,sep="");
  lines(get(rn)$SSB[,1],
        (get(rn)$SSB[,2]/retro0$SSB[1:(48-i),2])-1,col=i)
  }


dev.off()
p.biom.pol(mod2,typ="SSB",n.mod=1,main="Model 2",new=F,fy=1977,ly=2013)

p.biom.pol(mod2,typ="SSB",n.mod=2,mod1,main="Model 1",new=F,fy=1977,ly=2013)
lines(SSB_Lastyr[,1],SSB_Lastyr[,2]/2,lwd=2,col="red")

# Plot selectivity in multiple crappy panels
p.select.hist(mod1,typ="F",h="T",f=1,lage=1,hage=11,fy=1985,ly=2000)
# Plot selectivity in multiple crappy color grayscale 
c.select(mod1)
dev.off()  
