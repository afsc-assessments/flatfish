rm(list=ls())
# For some reason I can't get this to work anymore so
# best to redo: source("../../R/prelims.R")
# 
getwd()
source(("../../R/prelims.R"))
library(doParallel)
library(patchwork)
mytheme = theme_few()
# Run model from last year
mod_dir <- c("max0", "max1","max2","max3")
fn        <- paste0(mod_dir, "/fm");fn
mod_names <- c("max0", "max1","max2","max3")
nmods <- length(mod_names)

registerDoParallel(nmods)
system.time( modlst <- mclapply(fn, read_admb,mc.cores=nmods) )
names(modlst) <- mod_names
names(modlst)
plot_bts(modlst[c(1,4)],overlay=TRUE)


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