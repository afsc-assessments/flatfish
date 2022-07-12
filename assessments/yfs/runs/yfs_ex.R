rm(list=ls())
# For some reason I can't get this to work anymore so
# best to redo: source("../../R/prelims.R")
# 
getwd()
source(("../../R/prelims.R"))
library(doParallel)
library(patchwork)
library(GGally)
mytheme = theme_few()
#Get Maxime's indices
load("Overlap.RData")
load("Overlap_male.RData")
load("Overlap_female.RData")
glimpse(Overlap_female)
glimpse(Overlap_female)
dim(bt)
names(modlst[[1]])
bt <- t(modlst[[1]]$Bottom_temp) %>% as.data.frame()
bt <- as_tibble(bt) %>% transmute(temperature=V1,timing=V2,interaction=V3)
bt$year <- c(1982:2019,2021)
bt <- bt %>% mutate(type=)
bt %>% print(n=Inf)
df <- bt %>% pivot_longer(!year,names_to="type",values_to="index") %>%
rbind(Overlap%>%transmute(year=Years,index=Index,type="overlap"))
glimpse(df)
(df) %>% filter(type!="interaction",type!="timing") %>%
ggplot(aes(x=year,y=index,color=type)) + theme_few() +
          geom_smooth() + geom_point()
df%>%filter(type=="overlap")

# Run model from last year
mod_dir <- c("max0", "max1","max2","max3","max4")
fn        <- paste0(mod_dir, "/fm");fn
mod_names <- c("max0", "max1","max2","max3","max4")
nmods <- length(mod_names)

registerDoParallel(nmods)
system.time( modlst <- mclapply(fn, read_admb,mc.cores=nmods) )
names(modlst) <- mod_names
names(modlst)
plot_bts(modlst[c(1,2,4)],overlay=TRUE)
names(modlst[[1]])
(modlst[[1]]$pred_srv)
mean((log(modlst[[1]]$eb_bts)-log(modlst[[1]]$ob_bts))^2)^.5
mean((log(modlst[[2]]$eb_bts)-log(modlst[[2]]$ob_bts))^2)^.5
mean((log(modlst[[3]]$eb_bts)-log(modlst[[3]]$ob_bts))^2)^.5
mean((log(modlst[[4]]$eb_bts)-log(modlst[[4]]$ob_bts))^2)^.5
mean((log(modlst[[5]]$eb_bts)-log(modlst[[5]]$ob_bts))^2)^.5

# get MCMC results and plot coefficients  marginals
mcdf3<-as_tibble(read.table("max3/evalout.rep",header=FALSE))
mcdf1<-as_tibble(read.table("max1/evalout.rep",header=FALSE))
mcdf0<-as_tibble(read.table("max0/evalout.rep",header=FALSE))
mcnames<- c("obj_fun","beta_temp","beta_timing","interaction","Alpha",c(1982:2019,2021))
mcnames<- c("obj_fun","beta_overlap","beta_temp","beta_timing","Alpha",c(1982:2019,2021))
names(mcdf0)<-mcnames
names(mcdf3)<-mcnames
mcnames<- c("obj_fun","beta_overlap","Alpha",c(1982:2019,2021))
names(mcdf1)<-mcnames
glimpse(mcdf3)
glimpse(mcdf0)
glimpse(mcdf1 )
sum(mcdf$beta_overlap>0)/5000
sum(mcdf1$beta_overlap>0)/3000

mcdf$recent_q <- rowMeans(mcdf[,34:44])
mcdf %>% select(beta_overlap,beta_temp,beta_timing,Alpha,recent_q) %>% sample_n(3000) %>%
  ggpairs(aes(color="salmon",alpha=.4))

ggplot()
tmp <- mcdf %>% select(beta_overlap,beta_temp,beta_timing) %>%
pivot_longer(cols=1:3,names_to="parameter",values_to="value") 
tmp <- mcdf2 %>% select(beta_overlap) %>%
pivot_longer(cols=1:1,names_to="parameter",values_to="value") 
tmp <- mcdf0 %>% select(beta_temp,beta_timing,interaction) %>%
pivot_longer(cols=1:3,names_to="parameter",values_to="value") 
tmp

p1 <- ggplot(tmp,aes(x=value,color=parameter,fill=parameter )) + geom_density(alpha=.7) +
      xlab("Coefficient value") + ggthemes::theme_few(base_size=14) + xlim(c(-.15,.15)) + geom_vline(xintercept=0);p1
p1
rbind(p1$data, p2$data %>% mutate(parameter="overlap_alone")) %>%
ggplot(aes(x=value,color=parameter,fill=parameter )) + geom_density(alpha=.7) +
      ggthemes::theme_few()

tmp <- mcdf3[,6:44] %>% pivot_longer(cols=1:38,names_to="year",values_to="value")  %>%
#tmp <- mcdf1[,6:42] %>% pivot_longer(cols=1:36,names_to="year",values_to="value")  %>%
filter(as.numeric(year)>1999) %>% mutate(year=as.factor(year))
tmp %>% ggplot(aes(x=year,y=value)) + geom_violin(fill="salmon") +
      ylim(c(.5,1.2)) +
      ggthemes::theme_few(base_size=14) + ylab("Survey availability")
mcnames<- c("obj_fun","wt_like",
          "q_prior",
          "m_prior",
          "rec_like",
          "sel_like",
          "catch_like",
          "srv_like",
          "age_like_fsh",
          "age_like_srv",
          "q_srv",
          "natmort_f", 
          "natmort_m", 
          "Fmsyr",
          "ABC_biom",
          "Bmsy",
          "msy",
          "TotBiom",
          "SSB", 
          "mean_log_rec",
          "partial_F_f",
          "sel_slope_srv",
          "sel50_srv",
          "sel_slope_srv_m",
          "sel50_srv_m",
    "mean_N_fsh_age",
    "mean_N_srv_age",
    "R_alpha",
    "R_beta")


#--Now make the projection files
setup<-list(
  Run_name     = noquote("YFS"),
  Tier         = 3    ,
  nalts        = 7    ,
  alts         = c(1,2,3,4,5,6,7),
  tac_abc      = 1,    #' Flag to set TAC equal to ABC (1 means true, otherwise false)
  srr          = 1 ,   #' Stock-recruitment type (1=Ricker, 2=Bholt)
  rec_proj     = 1,    #' projection rec form (default: 1 = use observed mean and std, option 2 = use estimated SRR and estimated sigma R)
  srr_cond     = 0 ,   #' SR-Conditioning (0 means no, 1 means use Fmsy == F35%?, 2 means Fmsy == F35% and Bmsy=B35%  condition (affects SRR fits)
  srr_prior    = 0.0,  #' Condition that there is a prior that mean historical recruitment is similar to expected recruitment at half mean SSB and double mean SSB 0 means don't use, otherwise specify CV
  write_big    = 1,    #' Flag to write big file (of all simulations rather than a summary, 0 means don't do it, otherwise do it) Write_Big
  nyrs_proj    = 14,   #' Number of projection years
  nsims        = 100, #' Number of simulations
  beg_yr_label = 2019  #' Begin Year
)
config<-list(
  nFixCatchYrs = 2,
  nSpecies     = 1,
  OYMin        = .1343248,
  OYMax        = 1943248,
  dataFiles    = noquote("data/yfs.dat"),
  ABCMult      = 1,
  PoplnScalar  = 1000,
  AltFabcSPR   = 0.75,
  nTAC         = 1,
  TACIndices   = 1,
  Catch        = c( 2019,m2$obs_catch[length(m2$obs_catch)],   2017,55000. )
)

datfile <- list(
  runname     = noquote("m2"), 
  ssl_spp     = 0,         # SSL_spp
  Dorn_buffer = 0,         # Dorn_buffer
  nfsh        = 1,         # N_fsh
  nsex        = 2,         # N_sexes
  avgF5yr     = 0.0661399, # avg_5yr_F
  F40_mult    = 1,         # F_40_multiplier
  spr_abc     = 0.4,       # SPR_abc
  spr_msy     = 0.35,      # SPR_msy
  sp_mo       = 8,         # spawn_month
  nages       = dim(m2$natage_m)[2],        # N_ages
  Frat        = 1,         # F_ratio
	# M
	M    = c(rep(natmort_f),nages),rep(natmort_m,nages)), 
	#  Maturity
	pmat = m2$maturity,
	#  Wt_at_age_spawners  
	wtage_sp  = m2$wt_srv_f,
	#  Wt_at_age_fsh
	wtage_fsh = c(m2$wt_srv_f, m2$wt_srv_m), 
	# select
	sel = c(0.002576427,0.040030753,0.651104228,0.768404263,0.794886081,1,0.889293108,0.604815671,0.451169778,0.403195516,0.403195516),
	# N
	N   = c(511.179,378.528,278.443,194.385,183.423,45.5404,61.1188,19.8073,39.6285,33.6501,51.7806),
	# Nyrs
	nyrs = 37,
	# recruits
	R    = c(1578.51,479.509,357.919,443.588,318.981,413.125,514.351,600.987,536.301,692.34,452.279,1618.73,702.801,372.811,597.812,1136.19,402.862,424.179,1025.36,207.05,383.695,1054.64,2224.52,1379.34,1545.81,345.556,454.884,617.194,404.876,993.497,727.754,236.795,505.948,258.653,726.627,524.198,473.54),
	# SSB 
	SSB  = c(206.391,194.569,187.097,183.296,195.289,240.774,252.143,238.163,223.199,200.776,182.378,179.671,189.193,198.242,212.123,233.484,277.891,282.004,250.709,231.816,218.403,195.275,181.628,189.976,175.912,168.624,220.206,315.124,376.621,397.171,365.476,317.159,277.777,242.719,233.415,223.636,198.117,183.537,177.91)
	)
[1] "Bzero"                      "phizero"                    "alpha_sr"                   "R_alpha"                   
 [5] "R_beta"                     "sigmaR"                     "SRR_SSB"                    "future_ABC"                
 [9] "rechat"                     "rechat.sd"                  "Yr"                         "Yr_wt"                     
[13] "wt_obs_f"                   "wt_pred_f"                  "wt_obs_m"                   "wt_pred_m"                 
[17] "wt_srv_f"                   "wt_srv_m"                   "wt_like"                    "Z_f"                       
[21] "Z_m"                        "F_f"                        "F_m"                        "nLogPosterior"             
[25] "natmort_f"                  "natmort_m"                  "future_SSB"                 "future_TotBiom"            
[29] "future_catch"               "sel_srv_f"                  "sel_srv_m"                  "sel_fsh_f"                 
[33] "sel_fsh_m"                  "survey_likelihood"          "catch_likelihood"           "age_likelihood_for_fishery"
[37] "age_likeihood_for_survey"   "recruitment_likelilhood"    "selectivity_likelihood"     "q_Prior"                   
[41] "sigmaR_Prior"               "m_Prior"                    "F_penalty"                  "SPR_penalty"               
[45] "obj_fun"                    "Obs_catch"                  "Pred_catch"                 "Bottom_temp"               
[49] "pred_srv"                   "catage_f"                   "catage_m"                   "natage_f"                  
[53] "natage_m"                   "maturity"                  


A <- c(m0,m1,m2,m3)
plot_bts(m0)
ls()
#mods <- c("Base","Base","Const. fish sel.","Short_dat","Sex specific M","Constant survey q","Est_Sex_M_G2","Temperature-growth","Sigma R estimated","Sigma R 1.0","Full SRR Series")
#---------------------------------------------------------------
#for (i in c(2,3,5:6,8:11)){
# Read in regular results
A <- NULL
i=0
for (i in c(0:3)){
  rn=paste0("max",i,"/fm.rep")
  mn=paste0("model_",i)
  A[[i+1]] <-  read.rep(rn)
  sr <- read.table(paste0("max",i,"/sex_ratio.rep"))
  names(sr) <- c("Year","source","sex_ratio")
  A[[i+1]]$sex_ratio <- sr %>% arrange(source,Year)
  assign(mn,names(A[[i+1]]))
  print(rn)
	print(i)
}
length(A)
names(A) <- 0:3 
names(A)
plot_bts(A)
.get_bts_df(A)
.get_bts_df
M=A
function(M,biomass=TRUE)
{
    n <- length(M)
    mdf <- NULL
    i=1
    for (i in 1:n)
    {
        A <- M[[i]]
        df <- data.frame(year = A$yr_bts)
        df$Model <- names(M)[i]
        if (biomass)
        {
          df$obs  <- A$ob_bts
          df$pre  <- A$eb_bts
          df$lb   <- A$ob_bts-1.96*A$sd_ob_bts
          df$ub   <- A$ob_bts+1.96*A$sd_ob_bts
        }
        else{
          df$obs  <- A$ot_bts
          df$pre  <- A$et_bts
          df$lb   <- A$ot_bts-1.96*A$sd_ot_bts
          df$ub   <- A$ot_bts+1.96*A$sd_ot_bts
        }
        mdf     <- rbind(mdf, df)
    }
    return(mdf)
}

## ADNUTS try
library(adnuts)
# Model name
m <- './fm'
# Directory  
d <- 'max3'
d <- 'max1'
d <- 'max0'
# Assumes a converged MLE model has already been run....
setwd(d)
system(paste(m, '-nox -iprint 200 -mcmc 10 -binp fm.bar -phase 22 -hbf 1'))
setwd('..')

## Two different ways to gets NUTS working. First is to use the
## Hessian (metric) just like with the RMW. Note the control argument.
iter <- 1000 # maybe too many...depends are number cores...I used 8...
chains=8
fit.mle0 <- sample_nuts(model=m, path=d, iter=iter, warmup=iter/4,
                   chains=chains, cores=chains, control=list(metric='mle'))
pairs_admb(fit.mle0, pars=1:6, order='slow')

init <- function() rnorm(numpars)
fit.mle <- sample_nuts(model=m, path=d, iter=iter, warmup=iter/4,
                   chains=chains, cores=chains, control=list(metric='mle'))
pairs_admb(fit.mle, pars=1:6, order='slow')
print(fit.mle)
plot_sampler_params(fit.mle)
launch_shinyadmb(fit.mle)

mon <- monitor(fit.mle$samples, warmup=fit.mle$warmup, print=FALSE)


## Now with more thinning
thin <- 200
iter <- 1000*thin
fit.rwm <- sample_admb(model=m, path=d, iter=iter, algorithm='RWM', warmup=.25*iter,
                    seeds=seeds, chains=chains, thin=thin,
                    parallel=TRUE, cores=chains)

launch_shinyadmb(fit)

## Diagnose pilot analsyis
mon <- monitor(fit.rwm$samples, warmup=fit.rwm$warmup, print=FALSE)
ess <- mon[,'n_eff']
(slow <- names(sort(ess))[1:6]) # slowest mixing parameters
pairs_admb(fit=fit.rwm, pars=slow)
(fast <- names(sort(ess, decr=TRUE))[1:6]) # fastest
pairs_admb(fit=fit.rwm, pars=fast)

## Another trick is you can run for a certain duration if you
## have a time limit. Specify the warmup period and then a really
## large value for iter and set a duration


### End of pilot exploration.


### Explore using NUTS
setwd(d)
m
system(paste(m, '-nox -binp amak.bar -phase 22 -mcmc 10 -hbf 1'))
setwd('..')

## Never thin NUTS and use 500-1000 iterations per chain w/
## approximately 1/4 warmup
thin <- 20
iter <- 5000*thin
fit.rwm <- sample_admb(model=m, path=d, iter=iter, algorithm='RWM', warmup=iter/4,
                   seeds=seeds, parallel=TRUE, chains=chains,
                   cores=chains, control=list(metric='mle'))
chains
## Look at high correlations
library(corrplot)
x <- fit.mle$mle$cor
dimnames(x) <- list('par'=fit.mle$mle$par.names, 'par2'=fit.mle$mle$par.names)
ind <- sort(unique(which(abs(x)>.0 & x!= 1, arr.ind=TRUE)[,1]))
y <- x[ind, ind]
ind
corrplot(y, method='color', type='upper')


## Alternatively if no Hessian is available (e.g., b/c of
## hierarchical model), then adapt a diagonal one during
## warmup. This is much slower b/c it doesn't know the shape of
## the posterior
iter <- 100
fit.diag <- sample_admb(model=m, path=d, iter=iter, algorithm='NUTS', warmup=iter/4,
                   seeds=seeds, parallel=TRUE, chains=chains, cores=chains)

## Now the samples from fit.diag can be used to estimate the
## covariance and that can be used directly.
fit.updated <- sample_admb(model=m, path=d, iter=iter, algorithm='NUTS', warmup=iter/4,
                   seeds=seeds, parallel=TRUE, chains=chains,
                   cores=chains, control=list(metric=fit$covar.est))


save.image()
setwd(d)
system("./pm_mcmc -mceval")
sdf <- read.table("mceval_srv.dat")
names(sdf)<- c("Year","obs","predicted","draw")
sdf2 <- sdf %>% filter(draw==1)
ggplot(sdf2,aes(x=Year,y=obs)) + 
   geom_point(data=sdf,aes(x=jitter(Year),y=predicted), size=.5,alpha=.2,color="grey") + 
   scale_y_continuous(breaks=seq(0,12e6,by=4e5))  +
   scale_x_continuous(breaks=seq(1990,2020,by=2))  +
   theme_few() + ylab("Survey estimates") +
    geom_line(size=2,color="salmon") + geom_point(size=4,color="red",shape=3)
head(sdf)

sdf <- read.table("mceval_M.dat") 
names(sdf)<- c("Year","M","x")
tail(sdf)
sdf <- sdf %>%filter(Year==2020)
dim(sdf)
ggplot(sdf,aes(x=M)) + geom_density(fill="gold") + theme_few() + geom_vline(xintercept=mean(sdf$M)) +
       geom_vline(xintercept=0.3, color = "grey",size=1,linetype=2)


sdf <- read.table("mceval_sr.dat")
head(sdf)
names(sdf)<- c("Source","Stock","Recruits")
dim(sdf)
sdf2<-sdf %>% sample_n(100000)
ggplot(sdf2,aes(x=Stock,y=Recruits,color=Source)) + 
   theme_few() + geom_point(size=4,alpha=.1) 
   head(sdf)
   ylab("Survey estimates") +
   scale_y_continuous(breaks=seq(0,12e6,by=4e5))  +
   scale_x_continuous(breaks=seq(1990,2020,by=2))  +



