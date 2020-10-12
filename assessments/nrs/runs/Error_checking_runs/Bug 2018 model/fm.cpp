#ifdef DEBUG
  #ifndef __SUNPRO_C
    #include <cfenv>
    #include <cstdlib>
  #endif
#endif
	// Include AD class definitions
  #include <admodel.h>
 // logs input for checking
	/**
	\def log_input(object)
	Prints name and value of \a object on ADMB report %ofstream file.
	*/
	#undef log_input
	#define log_input(object) writeinput << "# " #object "\n" << object << endl;
 // Shorter way to write to R_report
	/**
	\def REPORT(object)
	Prints name and value of \a object on ADMB report %ofstream file.
	*/
	#undef REPORT
	#define REPORT(object) R_report << "$" #object "\n" << object << endl;
  #undef WriteData
  #define WriteData(object) SimDat << "#" #object "\n" << object << endl;
  ofstream writeinput("writeinput.log");
  ofstream R_report("fm_R.rep");
  ofstream report_sex_ratio("sex_ratio.rep");
  ofstream SimDat("sim.dat");
  adstring model_name;
  adstring datafile;
  adstring projfile_name;
  adstring cntrlfile_name;
  adstring tmpstring;
  adstring repstring;
  ofstream evalout("evalout.rep");
  ofstream srecpar("srecpar.rep"); // To write srec-parameters for projection model
  // ofstream ssb_retro("ssb_retro.rep",ios::app); // To write srec-parameters for projection model
#ifdef DEBUG
  #include <chrono>
#endif
#include <admodel.h>
#ifdef USE_ADMB_CONTRIBS
#include <contrib.h>

#endif
  extern "C"  {
    void ad_boundf(int i);
  }
#include <fm.htp>

model_data::model_data(int argc,char * argv[]) : ad_comm(argc,argv)
{
  adstring tmpstring;
  tmpstring=adprogram_name + adstring(".dat");
  if (argc > 1)
  {
    int on=0;
    if ( (on=option_match(argc,argv,"-ind"))>-1)
    {
      if (on>argc-2 || argv[on+1][0] == '-')
      {
        cerr << "Invalid input data command line option"
                " -- ignored" << endl;
      }
      else
      {
        tmpstring = adstring(argv[on+1]);
      }
    }
  }
  global_datafile = new cifstream(tmpstring);
  if (!global_datafile)
  {
    cerr << "Error: Unable to allocate global_datafile in model_data constructor.";
    ad_exit(1);
  }
  if (!(*global_datafile))
  {
    delete global_datafile;
    global_datafile=NULL;
  }
  oper_mod = 0;
  mcmcmode = 0;
  mcflag   = 1;
  tmpstring=adprogram_name + adstring(".dat");
  if (argc > 1)
  {
    int on=0;
    if ( (on=option_match(argc,argv,"-ind"))>-1)
    {
      if (on>argc-2 | argv[on+1][0] == '-') 
      { 
        cerr << "Invalid input data command line option"
           " -- ignored" << endl;  
      }
      else
      {
        cntrlfile_name = adstring(argv[on+1]);
      }
    }
    if ( (on=option_match(argc,argv,"-om"))>-1)
    {
      oper_mod  = 1;
      cout<<"Got to operating model option "<<oper_mod<<endl;
    }
    if ( (on=option_match(argc,argv,"-mcmc"))>-1)
    {
      mcmcmode = 1;
    }
  }
  global_datafile= new cifstream(cntrlfile_name);
  if (!global_datafile)
  {
  }
  else
  {
    if (!(*global_datafile))
    {
      delete global_datafile;
      global_datafile=NULL;
    }
  }
ad_comm::change_datafile_name("mod.ctl");  // GRID
 *(ad_comm::global_datafile) >>  model_name; 
 *(ad_comm::global_datafile) >>  datafile; 
  Growth_Option.allocate("Growth_Option");
  phase_grwth=-2;
  phase_wt  = -1;
  phase_growth_cov = -1;
  switch (Growth_Option)
  {
    case 0 : // Use constant time-invariant growth (from base growth parameters)
    break;
    case 1 : // Use empirical (values in data file) mean wts at age
    break;
    case 2 : // start out with base growth values and deviations decomposed by year and age
    {
      phase_wt = 1;
      phase_growth_cov=-1; 
    }
    break;
    case 3 : // Use base growth values (not estimated) and deviations as fn of temperature and decomposed by year and age
    {
      phase_wt  = -1; 
      phase_growth_cov =  1;
    }
    break;
  }
  ABC_age_lb.allocate("ABC_age_lb");
  phase_age_incr.allocate("phase_age_incr");
  phase_init_age_comp.allocate("phase_init_age_comp");
  phase_mn_rec.allocate("phase_mn_rec");
 if ( phase_mn_rec<0) do_wt_only=1; else do_wt_only=0;
  phase_rec_dev.allocate("phase_rec_dev");
  phase_mn_f.allocate("phase_mn_f");
  phase_F40.allocate("phase_F40");
  phase_fmort.allocate("phase_fmort");
  phase_proj.allocate("phase_proj");
  phase_logist_sel.allocate("phase_logist_sel");
  phase_logist_sel_devs.allocate("phase_logist_sel_devs");
  phase_male_sel.allocate("phase_male_sel");
  phase_q.allocate("phase_q");
  q_alpha_prior.allocate("q_alpha_prior");
  phase_q_alpha.allocate("phase_q_alpha");
  q_beta_prior.allocate("q_beta_prior");
  phase_q_beta_in.allocate("phase_q_beta_in");
  phase_m_f.allocate("phase_m_f");
  phase_m_m.allocate("phase_m_m");
  phase_sr.allocate("phase_sr");
  phase_env_cov.allocate("phase_env_cov");
  phase_sigmaR.allocate("phase_sigmaR");
  phase_wtfmsy.allocate("phase_wtfmsy");
  pf_sigma.allocate("pf_sigma");
  a50_sigma.allocate("a50_sigma");
  slp_sigma.allocate("slp_sigma");
  q_exp.allocate("q_exp");
  q_sigma.allocate("q_sigma");
 ln_q_in = log(q_exp);
  m_exp.allocate("m_exp");
  m_sigma.allocate("m_sigma");
  sigmaR_exp.allocate("sigmaR_exp");
  sigmaR_sigma.allocate("sigmaR_sigma");
  nselages.allocate("nselages");
    log_input(datafile);
    log_input(model_name);
    log_input(Growth_Option);
    log_input(phase_grwth);
    log_input(phase_wt);
    log_input(phase_age_incr);
    log_input(phase_growth_cov);
    log_input(ABC_age_lb);
    log_input(phase_F40);           //Phase to begin spawning biomass estimation
    log_input(phase_fmort);         //Phase to begin mortality estimation
    log_input(phase_proj);          //Phase to begin future projections
    log_input(phase_logist_sel);    //Phase to begin logistic selectivity estimation
    log_input(phase_male_sel);      //Phase to begin logistic selectivity estimation
    log_input(phase_q);
    log_input(q_alpha_prior);
    log_input(phase_q_alpha);
    log_input(q_beta_prior);
    log_input(phase_q_beta_in);
    log_input(phase_m_f);
    log_input(phase_m_m);
    log_input(phase_sr);
    log_input(phase_env_cov);  //
    log_input(phase_sigmaR);        //
    log_input(phase_wtfmsy);        //
    log_input(pf_sigma);         // penalty cv for selectivity used in Fmsy calcs
    log_input(a50_sigma);        // 
    log_input(slp_sigma);        //
    log_input(q_exp);
    log_input(q_sigma);
    log_input(m_exp);
    log_input(m_sigma);
    log_input(sigmaR_exp);
    log_input(sigmaR_sigma);
    log_input(nselages);
  lambda.allocate(1,10,"lambda");
  styr_sr.allocate("styr_sr");
  endyr_sr.allocate("endyr_sr");
  styr_wt.allocate("styr_wt");
  endyr_wt.allocate("endyr_wt");
  yr1_futcat.allocate("yr1_futcat");
  yr2_futcat.allocate("yr2_futcat");
  n_retro.allocate("n_retro");
 phase_male_sel_offset = lambda(4); 
 log_input(lambda); 
 log_input(styr_sr); log_input(endyr_sr);
 log_input(styr_wt); log_input(endyr_wt);
 log_input(yr1_futcat); log_input(yr1_futcat);
 log_input(n_retro); 
 log_input(phase_male_sel_offset);      //Phase to begin logistic selectivity estimation
ad_comm::change_datafile_name("fut_temp.dat");  
  nyrs_fut.allocate("nyrs_fut");
  fut_temp.allocate(1,nyrs_fut,"fut_temp");
 log_input(nyrs_fut); 
 log_input(fut_temp); 
ad_comm::change_datafile_name(datafile);  
  styr.allocate("styr");
  endyr_in.allocate("endyr_in");
 endyr = endyr_in;
  nages.allocate("nages");
  a_lw_f.allocate("a_lw_f");
  b_lw_f.allocate("b_lw_f");
  a_lw_m.allocate("a_lw_m");
  b_lw_m.allocate("b_lw_m");
  nfsh.allocate("nfsh");
  obs_catch.allocate(1,nfsh,styr,endyr,"obs_catch");
log_input(obs_catch);
  nyrs_fsh_age_c.allocate(1,nfsh,"nyrs_fsh_age_c");
  nyrs_fsh_age_s.allocate(1,nfsh,"nyrs_fsh_age_s");
log_input(nyrs_fsh_age_c); log_input(nyrs_fsh_age_s);
  yrs_fsh_age_c.allocate(1,nfsh,1,nyrs_fsh_age_c,"yrs_fsh_age_c");
  yrs_fsh_age_s.allocate(1,nfsh,1,nyrs_fsh_age_s,"yrs_fsh_age_s");
log_input(yrs_fsh_age_c);
log_input(yrs_fsh_age_s);
  oac_fsh_c.allocate(1,nfsh,1,nyrs_fsh_age_c,1,nages,"oac_fsh_c");
  oac_fsh_s.allocate(1,nfsh,1,nyrs_fsh_age_s,1,2*nages,"oac_fsh_s");
log_input(oac_fsh_s); 
  wt_fsh_in.allocate(1,nfsh,styr,endyr,1,2*nages,"wt_fsh_in");
  wt_fsh_b_in.allocate(1,nfsh,styr,endyr,1,nages);
  wt_fsh_f_in.allocate(1,nfsh,styr,endyr,1,nages);
  wt_fsh_m_in.allocate(1,nfsh,styr,endyr,1,nages);
  for (int k=1;k<=nfsh;k++) 
    for (int i=styr;i<=endyr;i++) 
      for (int j=1;j<=nages;j++) 
      {
        wt_fsh_f_in(k,i,j) = wt_fsh_in(k,i,j);
        wt_fsh_m_in(k,i,j) = wt_fsh_in(k,i,nages+j);
      }
  wt_fsh_b_in = (wt_fsh_m_in + wt_fsh_f_in)/2.;
  log_input(wt_fsh_f_in(1,endyr));
  log_input(wt_fsh_m_in(1,endyr));
  wt_fsh_tmp_f.allocate(1,nages,styr_wt,endyr_wt);
  wt_fsh_tmp_m.allocate(1,nages,styr_wt,endyr_wt);
  wt_pop_tmp_f.allocate(1,nages,styr_wt,endyr_wt);
  wt_pop_tmp_m.allocate(1,nages,styr_wt,endyr_wt);
  wt_fsh_mn_f.allocate(1,nages);
  wt_fsh_mn_m.allocate(1,nages);
  wt_pop_mn_f.allocate(1,nages);
  wt_pop_mn_m.allocate(1,nages);
  wt_fsh_sigma_f.allocate(1,nages);
  wt_fsh_sigma_m.allocate(1,nages);
  wt_pop_sigma_f.allocate(1,nages);
  wt_pop_sigma_m.allocate(1,nages);
  nsmpl_fsh_c.allocate(1,nfsh,1,nyrs_fsh_age_c,"nsmpl_fsh_c");
  nsmpl_fsh_s.allocate(1,nfsh,1,nyrs_fsh_age_s,"nsmpl_fsh_s");
log_input(nsmpl_fsh_c);
log_input(nsmpl_fsh_s);
  nsrv.allocate("nsrv");
  phase_q_beta.allocate(1,nsrv);
 phase_q_beta = phase_q_beta_in;
  nyrs_srv.allocate(1,nsrv,"nyrs_srv");
log_input(nsrv);
  yrs_srv.allocate(1,nsrv,1,nyrs_srv,"yrs_srv");
  mo_srv.allocate(1,nsrv,"mo_srv");
  obs_srv.allocate(1,nsrv,1,nyrs_srv,"obs_srv");
  obs_se_srv.allocate(1,nsrv,1,nyrs_srv,"obs_se_srv");
  obs_lse_srv.allocate(1,nsrv,1,nyrs_srv);
log_input(obs_se_srv);
log_input(obs_srv);
 obs_lse_srv = elem_div(obs_se_srv,obs_srv);
 obs_lse_srv = sqrt(log(square(obs_lse_srv) + 1.));
  nyrs_srv_age_c.allocate(1,nsrv,"nyrs_srv_age_c");
  nyrs_srv_age_s.allocate(1,nsrv,"nyrs_srv_age_s");
  yrs_srv_age_c.allocate(1,nsrv,1,nyrs_srv_age_c,"yrs_srv_age_c");
  yrs_srv_age_s.allocate(1,nsrv,1,nyrs_srv_age_s,"yrs_srv_age_s");
log_input( nyrs_srv_age_c);
log_input(  yrs_srv_age_s);
  nsmpl_srv_c.allocate(1,nsrv,1,nyrs_srv_age_c,"nsmpl_srv_c");
  nsmpl_srv_s.allocate(1,nsrv,1,nyrs_srv_age_s,"nsmpl_srv_s");
log_input(nsmpl_srv_s);
  oac_srv_c.allocate(1,nsrv,1,nyrs_srv_age_c,1,nages,"oac_srv_c");
  oac_srv_s.allocate(1,nsrv,1,nyrs_srv_age_s,1,2*nages,"oac_srv_s");
  wt_srv_f_in.allocate(1,nsrv,styr,endyr,1,nages,"wt_srv_f_in");
  wt_srv_m_in.allocate(1,nsrv,styr,endyr,1,nages,"wt_srv_m_in");
  wt_obs_f.allocate(styr_wt,endyr_wt,1,nages);
  wt_obs_m.allocate(styr_wt,endyr_wt,1,nages);
 for (i=styr_wt;i<=endyr_wt;i++) {wt_obs_f(i) = wt_srv_f_in(1,i); wt_obs_m(i) = wt_srv_m_in(1,i); }
  wt_pop_f_in.allocate(styr,endyr,1,nages,"wt_pop_f_in");
  wt_pop_m_in.allocate(styr,endyr,1,nages,"wt_pop_m_in");
log_input(oac_srv_s);
  age_vector.allocate(1,2*nages);
 for (int j=1; j<=nages;j++)
  age_vector(j) = double(j);
 for (int j=nages+1; j<=2*nages;j++)
  age_vector(j) = double(j-nages);
  maturity.allocate(styr,endyr,1,nages,"maturity");
log_input(maturity);
  init_age_comp.allocate("init_age_comp");
  n_env_cov.allocate(1,nsrv,"n_env_cov");
log_input(n_env_cov);
  env_cov.allocate(1,nsrv,1,n_env_cov,1,nyrs_srv,"env_cov");
  for (int j=1;j<=nsrv;j++) for (int k=1;k<=n_env_cov(j);k++) { env_cov(j,k) -= mean(env_cov(j,k)); }
log_input(env_cov);
  rec_lag=1;    //Lag between year-class and recruitment
  if (phase_init_age_comp>0&&init_age_comp > 0)
  {
    styr_rec            = styr ;  // Change in two places (see below)
    phase_init_age_comp = 2;
  }
  else
  {
    styr_rec            = styr - nages+1; // Extend recruitment devs back in time to estimate init_age from rec_dev
    phase_init_age_comp = -2; // Don't estimate initial age comp parameters
  }
  spawnmo.allocate("spawnmo");
spmo_frac    =(spawnmo-1)/12.;
log_input(spawnmo);
  srv_mo.allocate(1,nsrv,"srv_mo");
  srv_mo_frac.allocate(1,nsrv);
 srv_mo_frac =(srv_mo - 1.) /12.;
log_input(srv_mo);
  n_wts.allocate(styr_wt,endyr_wt,1,nages,"n_wts");
 log_input(n_wts);
  growth_cov.allocate(styr,endyr,"growth_cov");
 log_input(growth_cov);
 num_proj_Fs = 5;
  offset_srv.allocate(1,nsrv);
  offset_fsh.allocate(1,nfsh);
  offset_fsh.initialize();
  offset_srv.initialize();
  for (int k=1;k<=nfsh;k++)
  {
    for (i=1;i<=nyrs_fsh_age_c(k);i++)
    {
      oac_fsh_c(k,i) /= sum(oac_fsh_c(k,i));
      offset_fsh(k)  -= nsmpl_fsh_c(k,i)*(oac_fsh_c(k,i) + 0.001) * log(oac_fsh_c(k,i) + 0.001); 
    }
    for (i=1;i<=nyrs_fsh_age_s(k);i++)
    {
      oac_fsh_s(k,i) /= sum(oac_fsh_s(k,i));
      offset_fsh(k)  -= nsmpl_fsh_s(k,i)*(oac_fsh_s(k,i) + 0.001) * log(oac_fsh_s(k,i) + 0.001); 
    }
  }
  for (int k=1;k<=nsrv;k++)
  {
    for (i=1;i<=nyrs_srv_age_c(k);i++)
    {
      oac_srv_c(k,i) /= sum(oac_srv_c(k,i));
      offset_srv(k)-= nsmpl_srv_c(k,i)*(oac_srv_c(k,i) + 0.001) * log(oac_srv_c(k,i) + 0.001);  
    }
    for (int i=1;i<=nyrs_srv_age_s(k);i++)
    {
      oac_srv_s(k,i) /= sum(oac_srv_s(k,i));
      offset_srv(k)-= nsmpl_srv_s(k,i)*(oac_srv_s(k,i) + 0.001) * log(oac_srv_s(k,i) + 0.001); 
    }
  }
  log_input(offset_fsh);
  log_input(offset_srv);
   double btmp=0.;
   double ctmp=0.;
   dvector ntmp(1,nages);
   ntmp(1) = 1.;
   for (int a=2;a<=nages;a++)
     ntmp(a) = ntmp(a-1)*exp(-m_exp-.05);
   btmp = wt_pop_f_in(endyr)(1,nages) * ntmp;
   ctmp = mean(obs_catch);
   log_input( ctmp );
   R_guess = log((ctmp/.02 )/btmp) ;
   log_input( R_guess );
	 // Now that everything is read in, can change the "endyr" to reflect retrospective year
	 endyr = endyr - n_retro;
	 // Lag between weights and years
	 if (endyr <= endyr_wt) endyr_wt = endyr - (endyr_in-endyr_wt );
	 if (endyr <= endyr_wt) endyr_wt = endyr - (endyr_in-endyr_wt );
	 endyr_sr = endyr - (endyr_in-endyr_sr );
   styr_fut=endyr+1;
   endyr_fut=endyr+nyrs_fut;
   for (int isrv=1;isrv<=nsrv;isrv++)
   {
    // need to adjust survey observation dimensions
     for (int iyr=1;iyr<=nyrs_srv(isrv);iyr++)
		 {
       if (endyr <= yrs_srv(isrv,iyr))
         nyrs_srv(isrv) = min(nyrs_srv(isrv),iyr);
			// cout<<iyr<<" "<<nyrs_srv(isrv)<<" "<<yrs_srv(isrv,iyr)<<" "<<endyr<<endl;
		 }
		 // exit(1);
     for (int iyr=1;iyr<=nyrs_srv_age_c(isrv);iyr++)
       if (endyr <= yrs_srv_age_c(isrv,iyr))
         nyrs_srv_age_c(isrv) = min(nyrs_srv_age_c(isrv),iyr);
     for (int iyr=1;iyr<=nyrs_srv_age_s(isrv);iyr++)
       if (endyr <= yrs_srv_age_s(isrv,iyr))
         nyrs_srv_age_s(isrv) = min(nyrs_srv_age_s(isrv),iyr);
     //cout << nyrs_srv(isrv)<<endl;exit(1);
   }
   for (int ifsh=1;ifsh<=nfsh;ifsh++)
   {
     for (int iyr=1;iyr<=nyrs_fsh_age_s(ifsh);iyr++)
       if (endyr <= yrs_fsh_age_s(ifsh,iyr))
         nyrs_fsh_age_s(ifsh) = min(nyrs_fsh_age_s(ifsh),iyr);
     for (int iyr=1;iyr<=nyrs_fsh_age_c(ifsh);iyr++)
       if (endyr <= yrs_fsh_age_c(ifsh,iyr))
         nyrs_fsh_age_c(ifsh) = min(nyrs_fsh_age_c(ifsh),iyr);
   }
ad_comm::change_datafile_name("future_catch.dat");  
  future_ABC.allocate(1,nfsh,styr_fut,endyr_fut,"future_ABC");
 log_input(future_ABC); 
  if (global_datafile)
  {
    delete global_datafile;
    global_datafile = NULL;
  }
}

model_parameters::model_parameters(int sz,int argc,char * argv[]) : 
 model_data(argc,argv) , function_minimizer(sz)
{
  initializationfunction();
  ln_q_srv.allocate(1,nsrv,phase_q,"ln_q_srv");
  natmort_f.allocate(.02,.30,phase_m_f,"natmort_f");
  natmort_m.allocate(.02,.30,phase_m_m,"natmort_m");
  Linf_f.allocate(25.,50.,phase_grwth,"Linf_f");
  K_f.allocate(.05,1.0,phase_grwth,"K_f");
  t0_f.allocate(-5.,5.0,phase_grwth,"t0_f");
  Linf_m.allocate(25.,50.,phase_grwth,"Linf_m");
  K_m.allocate(.05,1.0,phase_grwth,"K_m");
  t0_m.allocate(-5.,5.0,phase_grwth,"t0_m");
  base_incr_f.allocate(2,nages,"base_incr_f");
  #ifndef NO_AD_INITIALIZE
    base_incr_f.initialize();
  #endif
  base_incr_m.allocate(2,nages,"base_incr_m");
  #ifndef NO_AD_INITIALIZE
    base_incr_m.initialize();
  #endif
  incr_dev.allocate(styr+1,endyr,2,nages,"incr_dev");
  #ifndef NO_AD_INITIALIZE
    incr_dev.initialize();
  #endif
  age_incr.allocate(5,nages-5,-10,10,phase_age_incr,"age_incr");
  yr_incr.allocate(styr+1,endyr,-10,10,phase_wt,"yr_incr");
  growth_alpha.allocate(phase_growth_cov,"growth_alpha");
  q_alpha.allocate(1,nsrv,phase_q_alpha,"q_alpha");
  q_beta.allocate(1,nsrv,1,n_env_cov,phase_q_beta,"q_beta");
  mean_log_rec.allocate(phase_mn_rec,"mean_log_rec");
  rec_dev.allocate(styr_rec,endyr,-15,15,phase_rec_dev,"rec_dev");
  mean_log_init.allocate(phase_init_age_comp,"mean_log_init");
  init_dev_m.allocate(2,nages,-15,15,phase_init_age_comp,"init_dev_m");
  init_dev_f.allocate(2,nages,-15,15,phase_init_age_comp,"init_dev_f");
  sigmaRsq.allocate("sigmaRsq");
  #ifndef NO_AD_INITIALIZE
  sigmaRsq.initialize();
  #endif
  avg_rec_dev.allocate("avg_rec_dev");
  #ifndef NO_AD_INITIALIZE
  avg_rec_dev.initialize();
  #endif
  sigma_rec.allocate("sigma_rec");
  #ifndef NO_AD_INITIALIZE
  sigma_rec.initialize();
  #endif
  var_rec.allocate("var_rec");
  #ifndef NO_AD_INITIALIZE
  var_rec.initialize();
  #endif
  log_avg_fmort.allocate(1,nfsh,phase_mn_f,"log_avg_fmort");
  fmort_dev.allocate(1,nfsh,styr,endyr,-15,15,phase_fmort,"fmort_dev");
  Fmort.allocate(styr,endyr,"Fmort");
  #ifndef NO_AD_INITIALIZE
    Fmort.initialize();
  #endif
  hrate.allocate("hrate");
  #ifndef NO_AD_INITIALIZE
  hrate.initialize();
  #endif
  kobs_tot_catch.allocate("kobs_tot_catch");
  #ifndef NO_AD_INITIALIZE
  kobs_tot_catch.initialize();
  #endif
  Fnew.allocate("Fnew");
  #ifndef NO_AD_INITIALIZE
  Fnew.initialize();
  #endif
  sel_slope_fsh_f.allocate(1,nfsh,phase_logist_sel,"sel_slope_fsh_f");
  sel50_fsh_f.allocate(1,nfsh,phase_logist_sel,"sel50_fsh_f");
  sel_slope_fsh_devs_f.allocate(1,nfsh,styr,endyr,-5,5,phase_logist_sel_devs,"sel_slope_fsh_devs_f");
  sel50_fsh_devs_f.allocate(1,nfsh,styr,endyr,-10,10,phase_logist_sel_devs,"sel50_fsh_devs_f");
  slope_tmp.allocate("slope_tmp");
  #ifndef NO_AD_INITIALIZE
  slope_tmp.initialize();
  #endif
  sel50_tmp.allocate("sel50_tmp");
  #ifndef NO_AD_INITIALIZE
  sel50_tmp.initialize();
  #endif
  sel_slope_fsh_m.allocate(1,nfsh,phase_logist_sel,"sel_slope_fsh_m");
  male_sel_offset.allocate(-4,4,phase_male_sel_offset,"male_sel_offset");
  sel_slope_fsh_devs_m.allocate(1,nfsh,styr,endyr,-5,5,phase_logist_sel_devs,"sel_slope_fsh_devs_m");
  sel50_fsh_m.allocate(1,nfsh,phase_logist_sel,"sel50_fsh_m");
  sel50_fsh_devs_m.allocate(1,nfsh,styr,endyr,-10,10,phase_logist_sel_devs,"sel50_fsh_devs_m");
  sel_slope_srv.allocate(1,nsrv,phase_logist_sel,"sel_slope_srv");
  sel50_srv.allocate(1,nsrv,phase_logist_sel,"sel50_srv");
  sel_slope_srv_m.allocate(1,nsrv,phase_male_sel,"sel_slope_srv_m");
  sel50_srv_m.allocate(1,nsrv,phase_male_sel,"sel50_srv_m");
  F40.allocate(1,nfsh,0.01,10.,phase_F40,"F40");
  F35.allocate(1,nfsh,0.01,10.,phase_F40,"F35");
  F30.allocate(1,nfsh,0.01,10.,phase_F40,"F30");
  R_logalpha.allocate(phase_sr,"R_logalpha");
  R_logbeta.allocate(phase_sr+1,"R_logbeta");
  SRC_recruits.allocate(styr_sr,endyr_sr,"SRC_recruits");
  #ifndef NO_AD_INITIALIZE
    SRC_recruits.initialize();
  #endif
  SAM_recruits.allocate(styr_sr,endyr_sr,"SAM_recruits");
  #ifndef NO_AD_INITIALIZE
    SAM_recruits.initialize();
  #endif
  sigmaR.allocate(phase_sigmaR,"sigmaR");
  R_alpha.allocate("R_alpha");
  #ifndef NO_AD_INITIALIZE
  R_alpha.initialize();
  #endif
  SRR_SSB.allocate(0,30,"SRR_SSB");
  #ifndef NO_AD_INITIALIZE
    SRR_SSB.initialize();
  #endif
  rechat.allocate(0,30,"rechat");
  pred_rec.allocate(styr,endyr,"pred_rec");
  wt_fsh.allocate(1,nfsh,styr,endyr,1,nages,"wt_fsh");
  #ifndef NO_AD_INITIALIZE
    wt_fsh.initialize();
  #endif
  wt_fsh_f.allocate(1,nfsh,styr,endyr,1,nages,"wt_fsh_f");
  #ifndef NO_AD_INITIALIZE
    wt_fsh_f.initialize();
  #endif
  wt_fsh_m.allocate(1,nfsh,styr,endyr,1,nages,"wt_fsh_m");
  #ifndef NO_AD_INITIALIZE
    wt_fsh_m.initialize();
  #endif
  wt_srv_f.allocate(1,nsrv,styr,endyr,1,nages,"wt_srv_f");
  #ifndef NO_AD_INITIALIZE
    wt_srv_f.initialize();
  #endif
  wt_srv_m.allocate(1,nsrv,styr,endyr,1,nages,"wt_srv_m");
  #ifndef NO_AD_INITIALIZE
    wt_srv_m.initialize();
  #endif
  wt_pop_f.allocate(styr,endyr,1,nages,"wt_pop_f");
  #ifndef NO_AD_INITIALIZE
    wt_pop_f.initialize();
  #endif
  wt_pop_m.allocate(styr,endyr,1,nages,"wt_pop_m");
  #ifndef NO_AD_INITIALIZE
    wt_pop_m.initialize();
  #endif
  wt_vbg_f.allocate(1,nages,"wt_vbg_f");
  #ifndef NO_AD_INITIALIZE
    wt_vbg_f.initialize();
  #endif
  wt_vbg_m.allocate(1,nages,"wt_vbg_m");
  #ifndef NO_AD_INITIALIZE
    wt_vbg_m.initialize();
  #endif
  wt_pred_f.allocate(styr_wt,endyr_wt,1,nages,"wt_pred_f");
  #ifndef NO_AD_INITIALIZE
    wt_pred_f.initialize();
  #endif
  wt_pred_m.allocate(styr_wt,endyr_wt,1,nages,"wt_pred_m");
  #ifndef NO_AD_INITIALIZE
    wt_pred_m.initialize();
  #endif
  wt_fsh_fut_f.allocate(1,nages,phase_wtfmsy,"wt_fsh_fut_f");
  wt_fsh_fut_m.allocate(1,nages,phase_wtfmsy,"wt_fsh_fut_m");
  wt_pop_fut_f.allocate(1,nages,phase_wtfmsy,"wt_pop_fut_f");
  wt_pop_fut_m.allocate(1,nages,phase_wtfmsy,"wt_pop_fut_m");
  R_beta.allocate("R_beta");
  #ifndef NO_AD_INITIALIZE
  R_beta.initialize();
  #endif
  phizero.allocate("phizero");
  #ifndef NO_AD_INITIALIZE
  phizero.initialize();
  #endif
  log_sel_fsh_f.allocate(1,nfsh,styr,endyr,1,nages,"log_sel_fsh_f");
  #ifndef NO_AD_INITIALIZE
    log_sel_fsh_f.initialize();
  #endif
  log_sel_fsh_m.allocate(1,nfsh,styr,endyr,1,nages,"log_sel_fsh_m");
  #ifndef NO_AD_INITIALIZE
    log_sel_fsh_m.initialize();
  #endif
  sel_fsh_f.allocate(1,nfsh,styr,endyr,1,nages,"sel_fsh_f");
  #ifndef NO_AD_INITIALIZE
    sel_fsh_f.initialize();
  #endif
  sel_fsh_m.allocate(1,nfsh,styr,endyr,1,nages,"sel_fsh_m");
  #ifndef NO_AD_INITIALIZE
    sel_fsh_m.initialize();
  #endif
  log_sel_srv_f.allocate(1,nsrv,1,nages,"log_sel_srv_f");
  #ifndef NO_AD_INITIALIZE
    log_sel_srv_f.initialize();
  #endif
  log_sel_srv_m.allocate(1,nsrv,1,nages,"log_sel_srv_m");
  #ifndef NO_AD_INITIALIZE
    log_sel_srv_m.initialize();
  #endif
  log_msy_sel_f.allocate(1,nages,phase_proj,"log_msy_sel_f");
  log_msy_sel_m.allocate(1,nages,phase_proj,"log_msy_sel_m");
  partial_F_f.allocate(1,nages,"partial_F_f");
  #ifndef NO_AD_INITIALIZE
    partial_F_f.initialize();
  #endif
  partial_F_m.allocate(1,nages,"partial_F_m");
  #ifndef NO_AD_INITIALIZE
    partial_F_m.initialize();
  #endif
  sel_srv_f.allocate(1,nsrv,1,nages,"sel_srv_f");
  #ifndef NO_AD_INITIALIZE
    sel_srv_f.initialize();
  #endif
  sel_srv_m.allocate(1,nsrv,1,nages,"sel_srv_m");
  #ifndef NO_AD_INITIALIZE
    sel_srv_m.initialize();
  #endif
  pred_srv.allocate(1,nsrv,styr,endyr,"pred_srv");
  #ifndef NO_AD_INITIALIZE
    pred_srv.initialize();
  #endif
  eac_fsh_c.allocate(1,nfsh,1,nyrs_fsh_age_c,1,nages,"eac_fsh_c");
  #ifndef NO_AD_INITIALIZE
    eac_fsh_c.initialize();
  #endif
  eac_srv_c.allocate(1,nsrv,1,nyrs_srv_age_c,1,nages,"eac_srv_c");
  #ifndef NO_AD_INITIALIZE
    eac_srv_c.initialize();
  #endif
  eac_fsh_s.allocate(1,nfsh,1,nyrs_fsh_age_s,1,2*nages,"eac_fsh_s");
  #ifndef NO_AD_INITIALIZE
    eac_fsh_s.initialize();
  #endif
  eac_srv_s.allocate(1,nsrv,1,nyrs_srv_age_s,1,2*nages,"eac_srv_s");
  #ifndef NO_AD_INITIALIZE
    eac_srv_s.initialize();
  #endif
  pred_catch.allocate(1,nfsh,styr,endyr,"pred_catch");
  #ifndef NO_AD_INITIALIZE
    pred_catch.initialize();
  #endif
  natage_f.allocate(styr,endyr,1,nages,"natage_f");
  #ifndef NO_AD_INITIALIZE
    natage_f.initialize();
  #endif
  natage_m.allocate(styr,endyr,1,nages,"natage_m");
  #ifndef NO_AD_INITIALIZE
    natage_m.initialize();
  #endif
  catage_f.allocate(1,nfsh,styr,endyr,1,nages,"catage_f");
  #ifndef NO_AD_INITIALIZE
    catage_f.initialize();
  #endif
  catage_m.allocate(1,nfsh,styr,endyr,1,nages,"catage_m");
  #ifndef NO_AD_INITIALIZE
    catage_m.initialize();
  #endif
  Z_m.allocate(styr,endyr,1,nages,"Z_m");
  #ifndef NO_AD_INITIALIZE
    Z_m.initialize();
  #endif
  Z_f.allocate(styr,endyr,1,nages,"Z_f");
  #ifndef NO_AD_INITIALIZE
    Z_f.initialize();
  #endif
  F_m.allocate(1,nfsh,styr,endyr,1,nages,"F_m");
  #ifndef NO_AD_INITIALIZE
    F_m.initialize();
  #endif
  F_f.allocate(1,nfsh,styr,endyr,1,nages,"F_f");
  #ifndef NO_AD_INITIALIZE
    F_f.initialize();
  #endif
  expl_biom.allocate(1,nfsh,styr,endyr,"expl_biom");
  #ifndef NO_AD_INITIALIZE
    expl_biom.initialize();
  #endif
  S_m.allocate(styr,endyr,1,nages,"S_m");
  #ifndef NO_AD_INITIALIZE
    S_m.initialize();
  #endif
  S_f.allocate(styr,endyr,1,nages,"S_f");
  #ifndef NO_AD_INITIALIZE
    S_f.initialize();
  #endif
  surv_f.allocate("surv_f");
  #ifndef NO_AD_INITIALIZE
  surv_f.initialize();
  #endif
  surv_m.allocate("surv_m");
  #ifndef NO_AD_INITIALIZE
  surv_m.initialize();
  #endif
  SSB.allocate(styr,endyr,"SSB");
  q_srv.allocate(1,nsrv,1982,endyr,"q_srv");
  sigma.allocate("sigma");
  #ifndef NO_AD_INITIALIZE
  sigma.initialize();
  #endif
  nLogPosterior.allocate(1,21,"nLogPosterior");
  #ifndef NO_AD_INITIALIZE
    nLogPosterior.initialize();
  #endif
  rec_like.allocate(1,4,"rec_like");
  #ifndef NO_AD_INITIALIZE
    rec_like.initialize();
  #endif
  catch_like.allocate("catch_like");
  #ifndef NO_AD_INITIALIZE
  catch_like.initialize();
  #endif
  wt_fut_like.allocate("wt_fut_like");
  #ifndef NO_AD_INITIALIZE
  wt_fut_like.initialize();
  #endif
  wt_msy_like.allocate("wt_msy_like");
  #ifndef NO_AD_INITIALIZE
  wt_msy_like.initialize();
  #endif
  init_like.allocate("init_like");
  #ifndef NO_AD_INITIALIZE
  init_like.initialize();
  #endif
  sigmaR_prior.allocate("sigmaR_prior");
  #ifndef NO_AD_INITIALIZE
  sigmaR_prior.initialize();
  #endif
  q_prior.allocate(1,nsrv,"q_prior");
  #ifndef NO_AD_INITIALIZE
    q_prior.initialize();
  #endif
  m_prior.allocate("m_prior");
  #ifndef NO_AD_INITIALIZE
  m_prior.initialize();
  #endif
  age_like_fsh.allocate(1,nfsh,"age_like_fsh");
  #ifndef NO_AD_INITIALIZE
    age_like_fsh.initialize();
  #endif
  age_like_srv.allocate(1,nsrv,"age_like_srv");
  #ifndef NO_AD_INITIALIZE
    age_like_srv.initialize();
  #endif
  wt_like.allocate(1,3,"wt_like");
  #ifndef NO_AD_INITIALIZE
    wt_like.initialize();
  #endif
  sel_like.allocate(1,3,"sel_like");
  #ifndef NO_AD_INITIALIZE
    sel_like.initialize();
  #endif
  fpen.allocate("fpen");
  #ifndef NO_AD_INITIALIZE
  fpen.initialize();
  #endif
  obj_fun.allocate("obj_fun");
  prior_function_value.allocate("prior_function_value");
  likelihood_function_value.allocate("likelihood_function_value");
  srv_like.allocate(1,nsrv,"srv_like");
  #ifndef NO_AD_INITIALIZE
    srv_like.initialize();
  #endif
  SPR_ABC.allocate("SPR_ABC");
  #ifndef NO_AD_INITIALIZE
  SPR_ABC.initialize();
  #endif
  SPR_OFL.allocate("SPR_OFL");
  #ifndef NO_AD_INITIALIZE
  SPR_OFL.initialize();
  #endif
  sigmaR_fut.allocate("sigmaR_fut");
  #ifndef NO_AD_INITIALIZE
  sigmaR_fut.initialize();
  #endif
  ftmp.allocate(1,nfsh,"ftmp");
  #ifndef NO_AD_INITIALIZE
    ftmp.initialize();
  #endif
  SB0.allocate("SB0");
  #ifndef NO_AD_INITIALIZE
  SB0.initialize();
  #endif
  SBF40.allocate("SBF40");
  #ifndef NO_AD_INITIALIZE
  SBF40.initialize();
  #endif
  SBF35.allocate("SBF35");
  #ifndef NO_AD_INITIALIZE
  SBF35.initialize();
  #endif
  SBF30.allocate("SBF30");
  #ifndef NO_AD_INITIALIZE
  SBF30.initialize();
  #endif
  sprpen.allocate("sprpen");
  #ifndef NO_AD_INITIALIZE
  sprpen.initialize();
  #endif
  Fratio.allocate(1,nfsh,"Fratio");
  #ifndef NO_AD_INITIALIZE
    Fratio.initialize();
  #endif
  Nspr.allocate(1,4,1,nages,"Nspr");
  #ifndef NO_AD_INITIALIZE
    Nspr.initialize();
  #endif
  nage_future_f.allocate(styr_fut,endyr_fut,1,nages,"nage_future_f");
  #ifndef NO_AD_INITIALIZE
    nage_future_f.initialize();
  #endif
  nage_future_m.allocate(styr_fut,endyr_fut,1,nages,"nage_future_m");
  #ifndef NO_AD_INITIALIZE
    nage_future_m.initialize();
  #endif
  rec_dev_future.allocate(styr_fut,endyr_fut,phase_proj,"rec_dev_future");
  SSB_future.allocate(styr_fut,endyr_fut,"SSB_future");
  #ifndef NO_AD_INITIALIZE
    SSB_future.initialize();
  #endif
  TotBiom_future.allocate(styr_fut,endyr_fut,"TotBiom_future");
  #ifndef NO_AD_INITIALIZE
    TotBiom_future.initialize();
  #endif
  F_future_f.allocate(1,nfsh,styr_fut,endyr_fut,1,nages,"F_future_f");
  #ifndef NO_AD_INITIALIZE
    F_future_f.initialize();
  #endif
  F_future_m.allocate(1,nfsh,styr_fut,endyr_fut,1,nages,"F_future_m");
  #ifndef NO_AD_INITIALIZE
    F_future_m.initialize();
  #endif
  Z_future_f.allocate(styr_fut,endyr_fut,1,nages,"Z_future_f");
  #ifndef NO_AD_INITIALIZE
    Z_future_f.initialize();
  #endif
  Z_future_m.allocate(styr_fut,endyr_fut,1,nages,"Z_future_m");
  #ifndef NO_AD_INITIALIZE
    Z_future_m.initialize();
  #endif
  S_future_f.allocate(styr_fut,endyr_fut,1,nages,"S_future_f");
  #ifndef NO_AD_INITIALIZE
    S_future_f.initialize();
  #endif
  S_future_m.allocate(styr_fut,endyr_fut,1,nages,"S_future_m");
  #ifndef NO_AD_INITIALIZE
    S_future_m.initialize();
  #endif
  catage_future_f.allocate(styr_fut,endyr_fut,1,nages,"catage_future_f");
  #ifndef NO_AD_INITIALIZE
    catage_future_f.initialize();
  #endif
  catage_future_m.allocate(styr_fut,endyr_fut,1,nages,"catage_future_m");
  #ifndef NO_AD_INITIALIZE
    catage_future_m.initialize();
  #endif
  avg_rec_dev_future.allocate("avg_rec_dev_future");
  #ifndef NO_AD_INITIALIZE
  avg_rec_dev_future.initialize();
  #endif
  avg_F_future.allocate(1,5,"avg_F_future");
  #ifndef NO_AD_INITIALIZE
    avg_F_future.initialize();
  #endif
  msy.allocate("msy");
  Fmsy.allocate("Fmsy");
  logFmsy.allocate("logFmsy");
  Fmsyr.allocate("Fmsyr");
  logFmsyr.allocate("logFmsyr");
  ABC_biom.allocate(styr_fut,endyr_fut,"ABC_biom");
  Bmsy.allocate("Bmsy");
  Bmsyr.allocate("Bmsyr");
  TotBiom.allocate(styr,endyr,"TotBiom");
  endbiom.allocate("endbiom");
  depletion.allocate("depletion");
 npfs = num_proj_Fs-2;
  future_catch.allocate(1,npfs,styr_fut,endyr_fut,"future_catch");
  future_Fs.allocate(styr_fut,endyr_fut,"future_Fs");
  future_SSB.allocate(1,num_proj_Fs,styr_fut,endyr_fut,"future_SSB");
  future_TotBiom.allocate(1,num_proj_Fs,styr_fut,endyr_fut,"future_TotBiom");
}

void model_parameters::preliminary_calculations(void)
{

#if defined(USE_ADPVM)

  admaster_slave_variable_interface(*this);

#endif
  // Initialize matrices used in the model
  // exit(1);
  for (i=styr;i<=endyr;i++) 
  {
    for (int ifsh=1;ifsh<=nfsh;ifsh++) 
	  {
      wt_fsh_f(ifsh,i) = wt_fsh_f_in(ifsh,i);
      wt_fsh_m(ifsh,i) = wt_fsh_m_in(ifsh,i);
		}
    for (int isrv=1;isrv<=nsrv;isrv++) 
	  {
      wt_srv_f(isrv,i) = wt_srv_f_in(isrv,i);
      wt_srv_m(isrv,i) = wt_srv_m_in(isrv,i);
		}
    wt_pop_f(i) = wt_pop_f_in(i);
    wt_pop_m(i) = wt_pop_m_in(i);
	}
  for (i=styr_wt;i<=endyr_wt;i++) 
  {
    for (j=1;j<=nages;j++) 
    {
      //note, only uses fishery 1 for this... needs to be updated for more than 1 fishery
      wt_fsh_tmp_f(j,i) = wt_fsh_f_in(1,i,j);
      wt_fsh_tmp_m(j,i) = wt_fsh_m_in(1,i,j);
      wt_pop_tmp_f(j,i) = value(wt_pop_f(i,j));//note, only uses fishery 1 for this... needs to be updated for more than 1 fishery
      wt_pop_tmp_m(j,i) = value(wt_pop_m(i,j));//note, only uses fishery 1 for this... needs to be updated for more than 1 fishery
		}
  }
  // cout<<"tmp wt fsh"<<endl;
  // cout<<wt_fsh_tmp_f<<endl;
  for (j=1;j<=nages;j++)
  {
    wt_fsh_mn_f(j) = mean(wt_fsh_tmp_f(j));
    wt_fsh_mn_m(j) = mean(wt_fsh_tmp_m(j));
    wt_pop_mn_f(j) = mean(wt_pop_tmp_f(j));
    wt_pop_mn_m(j) = mean(wt_pop_tmp_m(j));
    wt_fsh_sigma_f(j) = sqrt(norm2(wt_fsh_tmp_f(j)-wt_fsh_mn_f(j))/(endyr_wt-styr_wt+1) );
    wt_fsh_sigma_m(j) = sqrt(norm2(wt_fsh_tmp_m(j)-wt_fsh_mn_m(j))/(endyr_wt-styr_wt+1) );
    wt_pop_sigma_f(j) = sqrt(norm2(wt_pop_tmp_f(j)-wt_pop_mn_f(j))/(endyr_wt-styr_wt+1) );
    wt_pop_sigma_m(j) = sqrt(norm2(wt_pop_tmp_m(j)-wt_pop_mn_m(j))/(endyr_wt-styr_wt+1) );
    //check for zero values or no variance 
    if (wt_pop_mn_f(j)==0.)
    {
      wt_pop_mn_f(j)=.03;
      wt_pop_mn_m(j)=.03;
    }
    if (wt_fsh_mn_m(j)==0.)
    {
      wt_fsh_mn_f(j)=.03;
      wt_fsh_mn_m(j)=.03;
    }
    if (wt_pop_sigma_f(j)<0.03)
    {
      wt_pop_sigma_f(j)=.03*wt_pop_mn_f(j);
      wt_pop_sigma_m(j)=.03*wt_pop_mn_m(j);
    }
    if (wt_fsh_sigma_f(j)<0.03)
    {
      wt_fsh_sigma_f(j)=.03*wt_fsh_mn_f(j);
      wt_fsh_sigma_m(j)=.03*wt_fsh_mn_m(j);
    }
  }
  adj_1=1.0;
  adj_2=1.0; 
  SSB_1=1.0;
  SSB_2=1.0; 
  if(phase_wtfmsy>0)
  {
    wt_fsh_fut_f= wt_fsh_mn_f; // initializes estimates to correct values...
    wt_fsh_fut_m= wt_fsh_mn_m; // initializes estimates to correct values...
    wt_pop_fut_f= wt_pop_mn_f; // initializes estimates to correct values...
    wt_pop_fut_m= wt_pop_mn_m; // initializes estimates to correct values...
  }
  else
  {
    wt_fsh_fut_f = wt_fsh_f_in(1,endyr) ; // initializes estimates to correct values...
    wt_fsh_fut_m = wt_fsh_m_in(1,endyr) ;
    wt_pop_fut_f = wt_pop_f(endyr)   ; // initializes estimates to correct values...
    wt_pop_fut_m = wt_pop_m(endyr)   ; // initializes estimates to correct values...
  }
  for (int j=1;j<=nages;j++)
  {
      wt_vbg_f(j) = value(a_lw_f * pow(Linf_f*(1.-exp(-K_f*(double(j)-t0_f))),b_lw_f));
      wt_vbg_m(j) = value(a_lw_m * pow(Linf_m*(1.-exp(-K_m*(double(j)-t0_m))),b_lw_m));
  }
  base_incr_f(2,nages) = wt_vbg_f(2,nages) - ++wt_vbg_f(1,nages-1);
  base_incr_m(2,nages) = wt_vbg_m(2,nages) - ++wt_vbg_m(1,nages-1);
  // cout <<base_incr_f<<endl<<base_incr_m<<endl;exit(1);
  switch (Growth_Option)
  {
    case 0 : // Use constant time-invariant growth (from base growth parameters)
    {
      for (k=1;k<=nfsh;k++)
        for (i=styr;i<=endyr;i++)
        {
          wt_fsh_f(k,i) = wt_vbg_f;
          wt_fsh_m(k,i) = wt_vbg_m;
        }
      for (k=1;k<=nsrv;k++)
        for (i=styr;i<=endyr;i++)
        {
          wt_srv_f(k,i) = wt_vbg_f;
          wt_srv_m(k,i) = wt_vbg_m;
        }
        for (i=styr;i<=endyr;i++)
        {
          wt_pop_f(i) = wt_vbg_f;
          wt_pop_m(i) = wt_vbg_m;
        }
    }
    // cout<<wt_srv_f<<endl;exit(1);
    break;
    case 1 : // Use empirical (values in data file) mean wts at age
    {
      // No need to do anything since they are initialized at these values...
    }
    break;
    case 2 : // start out with base growth values and deviations decomposed by year and age
    {
      for (k=1;k<=nfsh;k++)
        for (i=styr;i<=endyr;i++)
        {
          wt_fsh_f(k,i) = wt_vbg_f;
          wt_fsh_m(k,i) = wt_vbg_m;
        }
      for (k=1;k<=nsrv;k++)
        for (i=styr;i<=endyr;i++)
        {
          wt_srv_f(k,i) = wt_vbg_f;
          wt_srv_m(k,i) = wt_vbg_m;
        }
        for (i=styr;i<=endyr;i++)
        {
          wt_pop_f(i) = wt_vbg_f;
          wt_pop_m(i) = wt_vbg_m;
        }
    }
    break;
    case 3 : // Use base growth values (not estimated) and deviations as fn of temperature and
             // decomposed by year and age
    {
    }
    break;
  }
  log_input(wt_fsh_f);
  log_input(wt_fsh_m);
  log_input(wt_srv_f);
  log_input(wt_srv_m);
  log_input(wt_pop_f);
  log_input(wt_pop_m);
}

void model_parameters::initializationfunction(void)
{
  Linf_m.set_initial_value(34.030);
  K_m.set_initial_value(0.161);
  t0_m.set_initial_value(0.515);
  Linf_f.set_initial_value(38.034);
  K_f.set_initial_value(0.137);
  t0_f.set_initial_value(0.297);
  wt_fsh_fut_f.set_initial_value(.8);
  wt_fsh_fut_m.set_initial_value(.8);
  wt_pop_fut_f.set_initial_value(.8);
  wt_pop_fut_m.set_initial_value(.8);
  q_alpha.set_initial_value(0.);
  q_beta.set_initial_value(0.);
  R_logalpha.set_initial_value(-4.18844741303);
  R_logbeta.set_initial_value(-5.8380e+00);
  sigmaR.set_initial_value(sigmaR_exp);
  natmort_f.set_initial_value(m_exp);
  natmort_m.set_initial_value(m_exp);
  mean_log_rec.set_initial_value(0.8);
  mean_log_init.set_initial_value(-.8);
  log_avg_fmort.set_initial_value(-2.);
  ln_q_srv.set_initial_value(0.);
  sel_slope_fsh_f.set_initial_value(0.8);
  sel_slope_fsh_m.set_initial_value(.8);
  sel_slope_fsh_m.set_initial_value(.8);
  sel_slope_srv.set_initial_value(.8);
  sel50_fsh_f.set_initial_value(5.);
  sel50_fsh_m.set_initial_value(5.);
  sel50_srv.set_initial_value(3.);
  F40.set_initial_value(.12);
  F35.set_initial_value(.16);
  F30.set_initial_value(.21);
  growth_alpha.set_initial_value(.38);
}

void model_parameters::userfunction(void)
{
  obj_fun =0.0;
  // if (Growth_Option>1&&(current_phase()<=1))
  if (Growth_Option>1 && (last_phase()||current_phase()<=phase_wt))
    Get_wt_age();
  if(!do_wt_only)
  {
    get_selectivity();
    get_mortality();
    get_numbers_at_age();
    //if(active(R_logalpha))
    compute_sr_fit();
    if (sd_phase() || mceval_phase())
    {
      get_msy();
      dvariable maxspawn=max(SSB)*1.2;
      for (i=0;i<=30;i++)
      {
        SRR_SSB(i) = double(i+.001)*maxspawn/30; 
        rechat(i)  = R_alpha*SRR_SSB(i)*(mfexp(-R_beta*SRR_SSB(i)));
      }
      Future_projections();
      for (i=styr;i<=endyr;i++)
        pred_rec(i) = 2.*natage_f(i,1);
    }
    catch_at_age();
  }
  evaluate_the_objective_function();
  // next part returns the Byesian posterior for the listed parameters
  if (mceval_phase())
  {
    // if (oper_mod)
      // Oper_Model();
    // else
    {
     // compute_spr_rates();
      // write_mceval();
    }
   //  inf  0 0 0  inf 0.0814782  13.984 1.64572 8.52093 0  32.6187 30.3609 0 0.00937666  90.4879  586.823  539.73  0.846482 0.93861 0.861563 0.874594 0.822898 0.948608 0.870741 0.929537 0.887822 0.921366 0.841266 0.939439 0.807067 0.819997 0.964657 0.898865 0.970638 0.741473 0.857768 0.890177 0.962105 1.0011 0.968926 0.974933 0.821446 0.819997 0.781815 0.786663 0.783197 0.880017 0.762049 0.828732 0.960408 0.964657 1.10127 0.901082 0.108481 0.125338 0.123776 2632.62 2541.99 495.109 441.419  2316.82 2297.56 2273.5 2244.68 2231.11 2214.01 2063.31 1643.45 1145.61 793.073 833.721 829.768 875.837 862.19 791.983 824.822 792.25 838.237 904.882 1148.06 1380.96 1709.52 2009.46 2315.49 2608.21 2768.31 2952.35 3121.75 3236.7 3229.15 3448.95 3467.12 3193.03 3159.11 3057.89 3100.9 2971.87 3087 3290.59 3314.14 3346.24 3133.91 3044.85 3058.49 2791.15 2621.02 2668.73 2599.82 2643.57 2849.5 3060.22 3170.87 3163.42 3178.93 3055.94 2894.21 2962.15 2996.96 2993.04 2952.77 2742.2 2761.32 2915.27 2940.14  901.167 920.002 921.81 908.759 883.521 817.961 640.2 342.496 40.5581 8.5617 19.2127 39.7057 66.8238 90.8636 115.809 123.692 93.8937 67.3402 55.344 58.6771 65.6652 106.58 162.363 251.184 368.564 493.526 636.116 771.942 853.952 970.539 1064.57 1123.49 1117.1 1116.88 1059.53 1031.97 1044.92 1132.33 1219.69 1258.41 1264.11 1264.75 1197.41 1158.19 1088.47 1080.12 1068.13 1063.64 1063.77 1073.22 1106.35 1125.56 1150.04 1158.91 1135.78 1101.19 1079.63 1059.48 1045.84 1042.59 1005.04 1009.94 1029.02 1038.32 0.807464  0.0837012 0.188333 0.359539 0.565576 0.749304 0.873568  1.58871  5.05441  0.0245567  -0.00616844
    evalout <<obj_fun<<" "<<
              wt_like<<" "<<
              q_prior<<" "<<
              m_prior<<" "<<
             rec_like<<" "<<
             sel_like<<" "<<
           catch_like<<" "<<
             srv_like<<" "<<
             age_like_fsh<<" "<<
             age_like_srv<<" "<<
		        q_srv(1)(1982,endyr)<<" "<<
		        natmort_f<<" "<< 
		        natmort_m<<" "<< 
						Fmsyr <<" "<<ABC_biom<<" "<<Bmsy<<" "<<msy<<" "<< TotBiom 
                     << " "<<SSB <<" "<< mean_log_rec <<" "<<partial_F_f(7,12)<<
                        " "<<sel_slope_srv<<" "<<sel50_srv<<
                        " "<<sel_slope_srv_m<<" "<<sel50_srv_m;
	  double mean_N_fsh_age=0;
    for (k=1;k<=nfsh;k++)
    {
      for (i=1;i<=nyrs_fsh_age_c(k);i++) // combined sexes
        mean_N_fsh_age += Eff_N(oac_fsh_c(k,i),eac_fsh_c(k,i));
      for (i=1;i<=nyrs_fsh_age_s(k);i++) // split sexes
			  mean_N_fsh_age += Eff_N(oac_fsh_s(k,i),eac_fsh_s(k,i));
			mean_N_fsh_age /= double(nyrs_fsh_age_c(k) + nyrs_fsh_age_s(k));
    }
    evalout << " " <<mean_N_fsh_age;
		double mean_N_srv_age=0;
    for (k=1;k<=nsrv;k++)
    {
      for (i=1;i<=nyrs_srv_age_c(k);i++) // combined sexes
        mean_N_srv_age += Eff_N(oac_srv_c(k,i),eac_srv_c(k,i));
      for (i=1;i<=nyrs_srv_age_s(k);i++) // split sexes
			  mean_N_srv_age += Eff_N(oac_srv_s(k,i),eac_srv_s(k,i));
			mean_N_srv_age /= double(nyrs_srv_age_c(k) + nyrs_srv_age_s(k));
    }
    evalout << " " <<mean_N_srv_age;
  } 
	// Alpha and beta of SRR
  evalout << " " <<R_alpha<<" "<<R_beta<<endl;
}

void model_parameters::get_selectivity(void)
{
  //Logistic selectivity is modeled for the fishery and survey, by age
  if (active(sel_slope_fsh_f))
  {
    dvariable slope_tmp;
    dvariable sel50_tmp;
  //   time invariant selectivy calculations
  //  for (k=1;k<=nfsh;k++)
  //  {
  //    log_sel_fsh_f(k)(1,nselages) = -log( 1.0 + mfexp(-sel_slope_fsh(k) * (age_vector(1,nselages) - sel50_fsh(k)) ));
  //    log_sel_fsh_f(k)(nselages,nages) = log_sel_fsh_f(k,nselages);
  //
  //    dvariable slope_tmp = sel_slope_fsh(k) * mfexp(sel_slope_fsh_m(k));
  //    dvariable sel50_tmp = sel50_fsh(k)     * mfexp(sel50_fsh_m(k));
  //   log_sel_fsh_m(k)(1,nselages) = -log( 1.0 + mfexp(-slope_tmp * (age_vector(1,nselages) - sel50_tmp) ));
  //    log_sel_fsh_m(k)(nselages,nages) = log_sel_fsh_m(k,nselages);
  //  }
  //  time-varying selectivy calculations, by sex for the fishery, females first
    for (k=1;k<=nfsh;k++)
    {
      for (i=styr;i<=endyr;i++)
      {
        // cout<<k<<" "<<i<<" "<<sel_slope_fsh_devs_f(k,i)<<endl;
        slope_tmp = sel_slope_fsh_f(k)*mfexp(sel_slope_fsh_devs_f(k,i));
        sel50_tmp = sel50_fsh_f(k)*mfexp(sel50_fsh_devs_f(k,i));
        for (j=1;j<=nselages;j++)
        {
          log_sel_fsh_f(k,i,j) = -log(1.0 + mfexp(-slope_tmp*((j)-sel50_tmp)));
        }
     //  males
        slope_tmp = sel_slope_fsh_m(k)*mfexp(sel_slope_fsh_devs_m(k,i));
        sel50_tmp = sel50_fsh_m(k)*mfexp(sel50_fsh_devs_m(k,i));
        for (j=1;j<=nselages;j++)
        {
          log_sel_fsh_m(k,i,j) = -log(1.0+mfexp(-slope_tmp*((j)-sel50_tmp)));
        }
        for (j=nselages+1;j<=nages;j++)
        {
          log_sel_fsh_f(k,i,j)=log_sel_fsh_f(k,i,j-1);
          log_sel_fsh_m(k,i,j)=log_sel_fsh_m(k,i,j-1);
        }
      }
    }
    for (k=1;k<=nsrv;k++)
    {
      log_sel_srv_f(k)(1,nselages) = -log( 1.0 + mfexp(-1.*sel_slope_srv(k) * (age_vector(1,nselages) - sel50_srv(k)) ));
      log_sel_srv_f(k)(nselages,nages) = log_sel_srv_f(k,nselages);
      dvariable slope_tmp = sel_slope_srv(k) * mfexp(sel_slope_srv_m(k));
      dvariable sel50_tmp = sel50_srv(k)     * mfexp(sel50_srv_m(k));
      log_sel_srv_m(k)(1,nselages) = -log( 1.0 + mfexp(-slope_tmp * (age_vector(1,nselages) - sel50_tmp) ));
      log_sel_srv_m(k)(nselages,nages) = log_sel_srv_m(k,nselages);
    }
  }
  sel_srv_f   = mfexp(log_sel_srv_f);
  sel_srv_m   = mfexp(log_sel_srv_m);
  sel_fsh_f   = mfexp(log_sel_fsh_f);
  sel_fsh_m   = mfexp(log_sel_fsh_m);
  if (active(male_sel_offset)) 
    sel_fsh_m   = mfexp(log_sel_fsh_m+male_sel_offset);
  partial_F_f = mfexp(log_msy_sel_f);
  partial_F_m = mfexp(log_msy_sel_m);
}

void model_parameters::get_mortality(void)
{
  Z_f.initialize();
  Z_m.initialize();
  F_f.initialize();
  F_m.initialize();
  S_f.initialize();
  S_m.initialize();
  surv_f.initialize();
  surv_m.initialize();
  Fmort.initialize();
  surv_f    = mfexp(-natmort_f);
  surv_m    = mfexp(-natmort_m);
  Z_f = natmort_f;
  Z_m = natmort_m;
  Fmort = 0.;
  for (k=1;k<=nfsh;k++)
  {
    Fmort  += mfexp(log_avg_fmort(k) + fmort_dev(k));
    for (i=styr;i<=endyr;i++)
    {
      F_f(k,i)  = (mfexp(log_avg_fmort(k) + fmort_dev(k,i))* sel_fsh_f(k,i)) ;
      F_m(k,i)  = (mfexp(log_avg_fmort(k) + fmort_dev(k,i))* sel_fsh_m(k,i)) ;
    }
    Z_f += F_f(k);
    Z_m += F_m(k);
  }
  S_f = mfexp(-Z_f);
  S_m = mfexp(-Z_m);
}

void model_parameters::get_numbers_at_age(void)
{
  //Initial age composition
  // Initial age comp independent from recruitment...
  if (styr_rec == styr)
  {
    for (j=2;j<=nages;j++)
    {
      natage_m(styr,j) = .5*mfexp(mean_log_init + init_dev_m(j) );
      natage_f(styr,j) = .5*mfexp(mean_log_init + init_dev_f(j) );
    }
  }
  else  // Initial age comp consistent with estimated recruitment levels
  {
    int itmp;
    for (j=1;j<nages;j++)
    {
      itmp=styr+1-j;
      natage_f(styr,j) = 0.5*mfexp(mean_log_rec-natmort_f*double(j-1)+rec_dev(itmp));
      natage_m(styr,j) = 0.5*mfexp(mean_log_rec-natmort_m*double(j-1)+rec_dev(itmp));
    }
    //Plus group in the first year
    itmp=styr+1-nages;
    natage_f(styr,nages) = 0.5*mfexp(mean_log_rec+rec_dev(itmp) - natmort_f*(nages-1))/(1.-surv_f);
    natage_m(styr,nages) = 0.5*mfexp(mean_log_rec+rec_dev(itmp) - natmort_m*(nages-1))/(1.-surv_m);
  }
  //Recruitment in subsequent years
  for (i=styr;i<=endyr;i++)
  {
    natage_m(i,1) = 0.5*mfexp(mean_log_rec+rec_dev(i));
    natage_f(i,1) = natage_m(i,1);
  }
  pred_rec(styr) = 2.*natage_m(styr,1);
  //Fill in the rest of the matrix of numbers at age by applying F's
  for (i=styr;i<endyr;i++)
  {
    natage_m(i+1)(2,nages)= ++elem_prod(natage_m(i)(1,nages-1),S_m(i)(1,nages-1));
    natage_m(i+1,nages)  +=  natage_m(i,nages)*S_m(i,nages);
    natage_f(i+1)(2,nages)= ++elem_prod(natage_f(i)(1,nages-1),S_f(i)(1,nages-1));
    natage_f(i+1,nages)  +=  natage_f(i,nages)*S_f(i,nages);
    TotBiom(i)=natage_f(i)*wt_pop_f(i) + natage_m(i)*wt_pop_m(i);
    SSB(i)  =  elem_prod(natage_f(i),pow(S_f(i),spmo_frac)) * elem_prod(wt_pop_f(i),maturity(i));  //need to add recruitment lag
		if (SSB(i)<0) cout <<i<<" "<<wt_pop_f(i)(1,5)<<" "<< maturity(i)(4,7) <<" "<< spmo_frac << endl;
    // SSB_1         = value(elem_prod(elem_prod(Ntmp,pow(Stmp,spmo_frac)),maturity)*wt_pop_fut);
    pred_rec(i+1) = 2.*natage_f(i+1,1);
  }
 //  SSB(endyr) = (natage(endyr)/2) * elem_prod(wt_pop(endyr),maturity);
  SSB(endyr)  =  elem_prod(natage_f(endyr),pow(S_f(endyr),spmo_frac)) * elem_prod(wt_pop_f(endyr),maturity(endyr));  //need to add recruitment lag
  TotBiom(endyr)   =  natage_f(endyr)*wt_pop_f(endyr) + natage_m(endyr)*wt_pop_m(endyr);
  if (sd_phase())
  {
    depletion = TotBiom(endyr)/TotBiom(styr);
    endbiom=TotBiom(endyr);
  }
  //Survey computations
  for (k=1;k<=nsrv;k++)
  {
    for (i=1;i<=nyrs_srv(k);i++)
    {
      int srvyrtmp = yrs_srv(k,i);
      dvariable b1tmp = elem_prod(natage_f(srvyrtmp),exp( -Z_f(srvyrtmp) * srv_mo_frac(k) )) * elem_prod(sel_srv_f(k),wt_srv_f(k,srvyrtmp));
      b1tmp          += elem_prod(natage_m(srvyrtmp),exp( -Z_m(srvyrtmp) * srv_mo_frac(k) )) * elem_prod(sel_srv_m(k),wt_srv_m(k,srvyrtmp));
      if (active(q_beta(k))) 
			{
        q_srv(k,srvyrtmp) = mfexp(q_alpha(k));
        for (int j=1;j<=n_env_cov(k);j++)
					q_srv(k,srvyrtmp) *= mfexp( q_beta(k,j) * env_cov(k,j,i)) ;
      }
      else
      {
        q_srv(k) = mfexp(ln_q_srv(k));
      }
      pred_srv(k,srvyrtmp)     = q_srv(k,srvyrtmp) * b1tmp;
    }
    for (i=1;i<=nyrs_srv_age_c(k);i++)
    {
      int yrtmp = yrs_srv_age_c(k,i); 
      eac_srv_c(k,i) = elem_prod(sel_srv_f(k),natage_f(yrtmp)) + elem_prod(sel_srv_m(k),natage_m(yrtmp)) ; 
      eac_srv_c(k,i)/= sum(eac_srv_c(k,i));
    }
    for (i=1;i<=nyrs_srv_age_s(k);i++)
    {
      int yrtmp = yrs_srv_age_s(k,i); 
      eac_srv_s(k,i)(1,nages) = elem_prod(sel_srv_f(k),natage_f(yrtmp));
      // eac_srv_s(k,i)(nages+1,2*nages)  = elem_prod(sel_srv(k),natage_m(yrtmp)).shift(nages+1);
      for (j=1;j<=nages;j++)
        eac_srv_s(k,i,j+nages) = sel_srv_m(k,j) * natage_m(yrtmp,j);
      eac_srv_s(k,i)/= sum(eac_srv_s(k,i));
     }
   }
}

void model_parameters::catch_at_age(void)
{
  catage_f.initialize();
  catage_m.initialize();
  pred_catch.initialize();
  for (k=1;k<=nfsh;k++)
  {
    for (i=styr;i<=endyr;i++)
    {
      catage_f(k,i) = elem_prod(elem_div(F_f(k,i),Z_f(i)),elem_prod(1. - S_f(i),natage_f(i)));
      catage_m(k,i) = elem_prod(elem_div(F_m(k,i),Z_m(i)),elem_prod(1. - S_m(i),natage_m(i)));
      pred_catch(k,i) = catage_f(k,i)*wt_fsh_f(k,i) ;
      pred_catch(k,i)+= catage_m(k,i)*wt_fsh_m(k,i);
    }
    // if (sd_phase()) C_age = catage_f(1,endyr-2);
    for (i=1;i<=nyrs_fsh_age_c(k);i++)
    {
      int yrtmp = yrs_fsh_age_c(k,i);
      eac_fsh_c(k,i) = catage_f(k,yrtmp) + catage_m(k,yrtmp);
      eac_fsh_c(k,i)/= sum(eac_fsh_c(k,i));
    }
    for (i=1;i<=nyrs_fsh_age_s(k);i++)
    {
      int yrtmp = yrs_fsh_age_s(k,i);
      eac_fsh_s(k,i)(1,nages) = catage_f(k,yrtmp);
      // eac_fsh_s(k,i)(nages+1,2*nages) = catage_f(k,yrtmp).shift(nages+1);
      for (j=1;j<=nages;j++)
        eac_fsh_s(k,i,j+nages) = catage_m(k,yrtmp,j);
      eac_fsh_s(k,i) /= sum(eac_fsh_s(k,i));
    }
  }
}

void model_parameters::evaluate_the_objective_function(void)
{
  if (active(F40))
  {
    // compute_spr_rates();
    dvar_vector incr_dev_tmp(2,nages);
    // two degree increase in temperature
    incr_dev_tmp(5,nages-5)     = growth_alpha * 2.0 + age_incr;
    incr_dev_tmp(nages-4,nages) = incr_dev_tmp(nages-5) ;
    incr_dev_tmp(2,4)           = incr_dev_tmp(5) ;
    wt_pop_fut_f(1)        = wt_vbg_f(1);
    wt_pop_fut_m(1)        = wt_vbg_m(1);
    wt_pop_fut_f(2,nages)  = ++wt_vbg_f(1,nages-1) + elem_prod(base_incr_f,mfexp(incr_dev_tmp)) ; // initializes estimates to correct values...
    wt_pop_fut_m(2,nages)  = ++wt_vbg_m(1,nages-1) + elem_prod(base_incr_m,mfexp(incr_dev_tmp)) ; // initializes estimates to correct values...
  }
  fpen.initialize();
  wt_like.initialize();
  q_prior.initialize();
  if(active(yr_incr)||active(age_incr)||active(growth_alpha))
  {
    // cout <<wt_pred_f(1988)(3,7)<<endl;
    for (i=styr_wt;i<=endyr_wt;i++)
    {
      for (j=3;j<nages;j++)
      {
         // matrices for the period of wt-age data (modify to use sample size) divided by 2 to account for males and females...
         wt_like(1) += 0.5*log(.1+ .5*n_wts(i,j)*square(log(wt_pred_f(i,j) + .1) - log(wt_obs_f(i,j) + .1)) ); 
         wt_like(1) += 0.5*log(.1+ .5*n_wts(i,j)*square(log(wt_pred_m(i,j) + .1) - log(wt_obs_m(i,j) + .1)) ); // matrices for the period of wt-age data (modify to use sample size)
         // wt_like(1) += 50.*(n_wts(i,j)*square(log(wt_pred_f(i,j) + .1) - log(wt_obs_f(i,j) + .1)) ); // matrices for the period of wt-age data (modify to use sample size)
         // wt_like(1) += 50.*(n_wts(i,j)*square(log(wt_pred_m(i,j) + .1) - log(wt_obs_m(i,j) + .1)) ); // matrices for the period of wt-age data (modify to use sample size)
      }
    }
    // wt_like(1) += 50.*norm2(log(wt_pred_f + .01) - log(wt_obs_f + .01)); // matrices for the period of wt-age data (modify to use sample size)
    // wt_like(1) += 50.*norm2(log(wt_pred_m + .01) - log(wt_obs_m + .01)); // matrices for the period of wt-age data (modify to use sample size)
    // obj_fun += 50.*norm2(incr_dev);
    if(active(age_incr))
      wt_like(2) += 12.5 * norm2(first_difference(first_difference(age_incr)));
      // wt_like(2) += 12.5 * norm2(age_incr);
    if(active(yr_incr))
      wt_like(3) += 12.5 * norm2(yr_incr);
    // cout<<"ObjFunWt: "<< norm2(log(wt_pred_m) - log(wt_obs_m))<< endl;; // matrices for the period of wt-age data (modify to use sample size)
    obj_fun += sum(wt_like);
  }
  if (!do_wt_only)
  {
    if (active(rec_dev))
    {
      rec_like(1) = norm2(rec_dev);
      sigma_rec = norm2(rec_dev);
      var_rec = (sigma_rec/((endyr-styr)+1))+.0001;      //variance of Rbar from styr to endyr
      rec_like(2)  = norm2(init_dev_m);
      rec_like(2) += norm2(init_dev_f);
      rec_like(4) = (1/(2*var_rec))*norm2(rec_dev_future);
    }
    if(active(R_logalpha))
      rec_like(3) = (0.5*norm2(log(SAM_recruits)-log(SRC_recruits+1.0e-3)))/(sigmaR*sigmaR);
    obj_fun += lambda(1)* sum(rec_like);
    if (active(sigmaR))
    {
       sigmaR_prior = .5* square(log(sigmaR)-log(sigmaR_exp))/(sigmaR_sigma*sigmaR_sigma);
       obj_fun  += sigmaR_prior;
     }
    // Note not general to multiple surveys...also ln_q_srv should be a "free" parameter because q_surve is an sdreport variable?
    if (active(ln_q_srv)||active(q_alpha))
    {
       q_prior(1) = .5* norm2(log(q_srv(1)(1982,endyr))-log(q_exp))/(q_sigma*q_sigma);
       obj_fun  += q_prior(1);
     }
    if (active(sel_slope_fsh_devs_f))
    {
      sel_like.initialize();
      // Implies a CV of 0.5 on time-varying selectivity parameter
      sel_like(1) += .5*norm2(sel_slope_fsh_devs_f)/(slp_sigma*slp_sigma);
      sel_like(1) += .5*norm2(sel_slope_fsh_devs_m)/(slp_sigma*slp_sigma);
      sel_like(2) += .5*norm2(sel50_fsh_devs_f)/(a50_sigma*a50_sigma);
      sel_like(2) += .5*norm2(sel50_fsh_devs_m)/(a50_sigma*a50_sigma);
      obj_fun += sum(sel_like);
    }
    if (active(natmort_f))
    {
       m_prior = .5* square(log(natmort_f)-log(m_exp))/(m_sigma*m_sigma);
       obj_fun += m_prior;
    }
    if (current_phase()>phase_wt)
    {
      Age_Like();
      Srv_Like();
      if (phase_fmort>0)
      {
        catch_like = 0.;
        for (int ifsh=1;ifsh<=nfsh;ifsh++)
          catch_like += norm2(log(obs_catch(ifsh)(styr,endyr)+.000001)-log(pred_catch(ifsh)+.000001));
        obj_fun += lambda(3) * catch_like;
      }
      Fmort_Pen();
      obj_fun +=fpen;
    }
    if(active(wt_fsh_fut_f)) 
	{
	  wt_fut_like=0.;
    for (int j=1;j<=nages;j++)
    {
      dvariable res = wt_fsh_mn_f(j)-wt_fsh_fut_f(j);
      wt_fut_like += res*res / (2.*wt_fsh_sigma_f(j)*wt_fsh_sigma_f(j));
      res           = wt_fsh_mn_m(j)-wt_fsh_fut_m(j);
      wt_fut_like += res*res / (2.*wt_fsh_sigma_m(j)*wt_fsh_sigma_m(j));
      res = wt_pop_mn_f(j)-wt_pop_fut_f(j);
      wt_fut_like += res*res / (2.*wt_pop_sigma_f(j)*wt_pop_sigma_f(j));
      res = wt_pop_mn_m(j)-wt_pop_fut_m(j);
      wt_fut_like += res*res / (2.*wt_pop_sigma_m(j)*wt_pop_sigma_m(j));
    }
		obj_fun += wt_fut_like;
  }
  if(active(log_msy_sel_f)) 
  {
	  wt_msy_like=0.;
    // dvar_vector pf_tmp = log(F(1,endyr)/F(1,endyr,nages)); // NOTE: For one fishery only!!!
    // obj_fun += 0.5*norm2(pf_tmp - log_sel_coff)/(pf_sigma*pf_sigma);
    dvar_vector log_sel_mean(1,nages);
    log_sel_mean  = log_sel_fsh_f(1,endyr) ;
    log_sel_mean += log_sel_fsh_f(1,endyr-1) ;
    log_sel_mean += log_sel_fsh_f(1,endyr-2) ; 
    log_sel_mean /= 3. ; 
    wt_msy_like += 0.5*norm2(log_sel_mean - log_msy_sel_f)/(pf_sigma*pf_sigma);
    log_sel_mean  = log_sel_fsh_m(1,endyr) ;
    log_sel_mean += log_sel_fsh_m(1,endyr-1) ;
    log_sel_mean += log_sel_fsh_m(1,endyr-2) ; 
    log_sel_mean /= 3. ; 
    wt_msy_like += 0.5*norm2(log_sel_mean - log_msy_sel_m)/(pf_sigma*pf_sigma);
		obj_fun += wt_msy_like;
  }
  // small penalty to initialize stock to have similar values (unless data suggest otherwise)
  if(active(init_dev_m))
	{
    init_like = norm2(init_dev_m-init_dev_f);
		obj_fun += init_like;
  }
  }
}

void model_parameters::Fmort_Pen(void)
{
  if (current_phase()<3)
     fpen += 10.*norm2(Fmort - .2);
  else
     fpen += .01*norm2(Fmort - .2);
  fpen += 100.*square(mean(fmort_dev));
}

void model_parameters::Srv_Like(void)
{
  srv_like.initialize();
  //cout<<pred_srv(1,yrs_srv(1,22)) <<" "<<pred_srv(1,yrs_srv(1,21)) <<endl;
  for (k=1;k<=nsrv;k++)
	{
    for (i=1;i<=nyrs_srv(k);i++)
		{
     // Log-normal
      srv_like(k) += lambda(2) * square(log(obs_srv(k,i) / pred_srv(k,yrs_srv(k,i)) ))/ (2.* obs_lse_srv(k,i) * obs_lse_srv(k,i)); 
      // cout << i<<" "<<yrs_srv(k,i)<<" "<< lambda(2) * square(log(obs_srv(k,i) / pred_srv(k,yrs_srv(k,i)) ))/ (2.* obs_lse_srv(k,i) * obs_lse_srv(k,i))<<endl; 
     // Normal
      //srv_like(k) += lambda(2) * square(obs_srv(k,i) - pred_srv(k,yrs_srv(k,i)) )/ (2.* obs_se_srv(k,i) * obs_se_srv(k,i));
    }
  }
  obj_fun += sum(srv_like);
}

void model_parameters::Age_Like(void)
{
  age_like_fsh.initialize();
  for (k=1;k<=nfsh;k++)
  {
      for (i=1;i<=nyrs_fsh_age_c(k);i++)
         age_like_fsh(k) -= nsmpl_fsh_c(k,i)*(oac_fsh_c(k,i) + 0.001) * log(eac_fsh_c(k,i) + 0.001);
      for (i=1;i<=nyrs_fsh_age_s(k);i++)
         age_like_fsh(k) -= nsmpl_fsh_s(k,i)*(oac_fsh_s(k,i) + 0.001) * log(eac_fsh_s(k,i) + 0.001);
  }
  age_like_fsh-=offset_fsh;
  obj_fun += sum(age_like_fsh);
  age_like_srv.initialize();
  for (k=1;k<=nsrv;k++)
  {
    for (i=1;i<=nyrs_srv_age_c(k);i++)
      age_like_srv(k) -= nsmpl_srv_c(k,i)*(oac_srv_c(k,i) + 0.001) * log(eac_srv_c(k,i) + 0.001);
    for (i=1;i<=nyrs_srv_age_s(k);i++)
      age_like_srv(k) -= nsmpl_srv_s(k,i)*(oac_srv_s(k,i) + 0.001) * log(eac_srv_s(k,i) + 0.001);
  }
  age_like_srv-=offset_srv;
  obj_fun += sum(age_like_srv);
}

dvariable model_parameters::spr_ratio(dvariable trial_F,dvar_vector& sel)
{
  dvariable SBtmp;
  dvar_vector Ntmp(1,nages);
  dvar_vector srvtmp(1,nages);
  SBtmp.initialize();
  Ntmp.initialize();
  srvtmp.initialize();
  dvar_vector Ftmp(1,nages);
  Ftmp = sel*trial_F;
  srvtmp  = exp(-(Ftmp + natmort_f) );
  dvar_vector wttmp = wt_pop_f(endyr);
  Ntmp(1)=1.;
  j=1;
  // Sp_Biom_future(i) = elem_prod(wt_pop ,maturity) * elem_prod(nage_future(i),pow(S_future(i),yrfrac)) ;
	// Note using end-year maturity for spr
  SBtmp  += Ntmp(j)*maturity(endyr,j)*wttmp(j)*pow(srvtmp(j),spmo_frac);
  for (j=2;j<nages;j++)
  {
    Ntmp(j) = Ntmp(j-1)*srvtmp(j-1);
    SBtmp  += Ntmp(j)*maturity(endyr,j)*wttmp(j)*pow(srvtmp(j),spmo_frac);
  }
  Ntmp(nages)=Ntmp(nages-1)*srvtmp(nages-1)/(1.-srvtmp(nages));
  SBtmp  += Ntmp(nages)*maturity(endyr,nages)*wttmp(nages)*pow(srvtmp(nages),spmo_frac);
  // cout<<sel_tmp<<endl<< " Trial: "<<trial_F<<" "<<SBtmp<<" Phizero "<<phizero<<endl;
  phizero=get_spr(0.0);
  return(get_spr(trial_F)/phizero);
}

void model_parameters::compute_spr_rates(void)
{
  SB0=0.;
  SBF40=0.; 
  SBF35=0.;
  SBF30=0.;
  for (i=1;i<=4;i++)
    Nspr(i,1)=1.;
  // dvar_matrix sel_tmp(sel_fsh_f(1).colmin(),sel_fsh_f(1).colmax(),sel_fsh_f(1).rowmin(),sel_fsh_f(1).rowmax());
  // sel_tmp = trans(sel_fsh_f(1));
  dvar_matrix sel_tmpu(1,nfsh,1,nages);
  dvar_matrix sel_tmp(1,nages,1,nfsh);
  for (k=1;k<=nfsh;k++)
    sel_tmpu(k) = sel_fsh_f(k,endyr);
  sel_tmp = trans(sel_tmpu);
  for (j=2;j<nages;j++)
  {
    Nspr(1,j) = Nspr(1,j-1)*exp(-natmort_f);
    Nspr(2,j) = Nspr(2,j-1)*exp(-(natmort_f+F40*sel_tmp(j-1)));
    Nspr(3,j) = Nspr(3,j-1)*exp(-(natmort_f+F35*sel_tmp(j-1)));
    Nspr(4,j) = Nspr(4,j-1)*exp(-(natmort_f+F30*sel_tmp(j-1)));
  }
  Nspr(1,nages)=Nspr(1,nages-1)*exp(-natmort_f)/(1.-exp(-natmort_f));
  Nspr(2,nages)=Nspr(2,nages-1)*exp(-(natmort_f+F40*sel_tmp(nages-1)))/(1.-exp(-(natmort_f+F40*sel_tmp(nages))));
  Nspr(3,nages)=Nspr(3,nages-1)*exp(-(natmort_f+F35*sel_tmp(nages-1)))/(1.-exp(-(natmort_f+F35*sel_tmp(nages))));
  Nspr(4,nages)=Nspr(4,nages-1)*exp(-(natmort_f+F30*sel_tmp(nages-1)))/(1.-exp(-(natmort_f+F30*sel_tmp(nages))));
  for (j=1;j<=nages;j++)
  {
    SB0    += 0.5 * Nspr(1,j) * maturity(endyr,j) * wt_pop_fut_f(j) * exp(-spmo_frac*natmort_f);
    SBF40  += 0.5 * Nspr(2,j) * maturity(endyr,j) * wt_pop_fut_f(j) * exp(-spmo_frac*(natmort_f+F40*sel_tmp(j)));
    SBF35  += 0.5 * Nspr(3,j) * maturity(endyr,j) * wt_pop_fut_f(j) * exp(-spmo_frac*(natmort_f+F35*sel_tmp(j)));
    SBF30  += 0.5 * Nspr(4,j) * maturity(endyr,j) * wt_pop_fut_f(j) * exp(-spmo_frac*(natmort_f+F30*sel_tmp(j)));
  }
  sprpen   =10.*square(SBF40-0.4*SB0);
  sprpen  +=10.*square(SBF35-0.35*SB0);
  sprpen  +=10.*square(SBF30-0.3*SB0);
  obj_fun += sprpen;
}

void model_parameters::compute_sr_fit(void)
{
  // sigmaR = 0.6;
  R_alpha=mfexp(R_logalpha);
  R_beta=mfexp(R_logbeta);
  for (int i=styr_sr; i <= endyr_sr; i++)
  {
    SAM_recruits(i)= 2.*natage_f(i,1);
    SRC_recruits(i) = SRecruit(SSB(i-rec_lag));
  }
}

dvariable model_parameters::SRecruit(const dvariable& Stmp)
{
  RETURN_ARRAYS_INCREMENT();
  dvariable RecTmp;
  RecTmp = R_alpha*Stmp*mfexp(-R_beta*Stmp);              // Ricker model
  /* switch (SrType)
  {
    case 1: // Eq. 12
      break;
    case 2:
      RecTmp = Stmp / ( alpha + beta * Stmp);        //Beverton-Holt form
      break;
    case 3:
      RecTmp = mfexp(log_avgrec);                    //Avg recruitment
      break;
    case 4:
      RecTmp = Stmp * mfexp( alpha  - Stmp * beta) ; //old Ricker form
      break;
  }
	*/
  RETURN_ARRAYS_DECREMENT();
  return RecTmp;
}

dvariable model_parameters::get_yield(const dvariable& Ftmp)
{
  dvariable phi;  
  dvariable ypr;
  dvariable yield;
  dvariable R_eq;
  phi  = get_spr(Ftmp);
  R_eq = -(log(1/(R_alpha*phi)))/(phi*R_beta);   // Ricker formulation of equilibrium recruitment at each F
  ypr  = get_ypr(Ftmp);
  yield=R_eq*ypr;
  return(yield);
}

dvariable model_parameters::get_spr(dvariable Ftemp)
{
  dvariable phi;
  dvar_vector sel_tmp(1,nages);
  sel_tmp = partial_F_f; // Set selectivity to 
  dvar_vector Ntmp(1,nages);
  Ntmp(1)=1.;
  for (j=2;j<=nages;j++)
  {
     Ntmp(j)=Ntmp(j-1)*exp(-(natmort_f+Ftemp*sel_tmp(j-1)));  // fills in matrix for ages 2 through nages-1
   }   
   Ntmp(nages)=Ntmp(nages-1)*exp(-(natmort_f+Ftemp*sel_tmp(nages-1)))/(1.-exp(-(natmort_f+Ftemp*sel_tmp(nages))));
   phi = 0.5*elem_prod(Ntmp,maturity(endyr))*elem_prod(wt_pop_fut_f,exp(-spmo_frac*(natmort_f+Ftemp*sel_tmp)));
   return(phi);
}

dvariable model_parameters::get_ypr(dvariable Ftemp)
{
  dvariable ypr;
  dvar_vector sel_tmp_f(1,nages);
  dvar_vector sel_tmp_m(1,nages);
  sel_tmp_f = partial_F_f; // Set selectivity to 
  sel_tmp_m = partial_F_m; // Set selectivity to 
  dvar_vector Ntmp_f(1,nages);
  dvar_vector Ntmp_m(1,nages);
  Ntmp_f(1)=1.;
  Ntmp_m(1)=1.;
  for (j=2;j<=nages;j++)
  {
     Ntmp_f(j)=Ntmp_f(j-1)*exp(-(natmort_f+Ftemp*sel_tmp_f(j-1)));  // fills in matrix for ages 2 through nages-1
     Ntmp_m(j)=Ntmp_m(j-1)*exp(-(natmort_m+Ftemp*sel_tmp_m(j-1)));  // fills in matrix for ages 2 through nages-1
  }   
   Ntmp_f(nages)=Ntmp_f(nages-1)*exp(-(natmort_f+Ftemp*sel_tmp_f(nages-1)))/(1.-exp(-(natmort_f+Ftemp*sel_tmp_f(nages))));
   Ntmp_m(nages)=Ntmp_m(nages-1)*exp(-(natmort_m+Ftemp*sel_tmp_m(nages-1)))/(1.-exp(-(natmort_m+Ftemp*sel_tmp_m(nages))));
   // ypr = elem_div(Ftemp*sel_tmp,Ftemp*sel_tmp+natmort)*elem_prod(elem_prod(Ntmp,wt_pop(endyr)),(1-exp(-(natmort+Ftemp*sel_tmp))));
   ypr  = elem_div(Ftemp*sel_tmp_f,Ftemp*sel_tmp_f+natmort_f)*elem_prod(elem_prod(Ntmp_f,wt_fsh_fut_f),(1-exp(-(natmort_f+Ftemp*sel_tmp_f))));
   ypr += elem_div(Ftemp*sel_tmp_m,Ftemp*sel_tmp_m+natmort_m)*elem_prod(elem_prod(Ntmp_m,wt_fsh_fut_m),(1-exp(-(natmort_m+Ftemp*sel_tmp_m))));
   return(ypr);
}

dvariable model_parameters::get_biom_per_rec(dvariable Ftemp)
{
 // calculation of equilibrium biomass for geometric mean calc determination
  dvariable bpr;
  dvar_vector sel_tmp_f(1,nages);
  dvar_vector sel_tmp_m(1,nages);
  dvar_vector Ntmp_f(1,nages);
  dvar_vector Ntmp_m(1,nages);
  sel_tmp_f = partial_F_f; // Set selectivity to 
  sel_tmp_m = partial_F_m; // Set selectivity to 
  Ntmp_f(1)=1.;
  Ntmp_m(1)=1.;
  for (j=2;j<=nages;j++)
  {
     Ntmp_f(j)=Ntmp_f(j-1)*exp(-(natmort_f+Ftemp*sel_tmp_f(j-1)));  // fills in matrix for ages 2 through nages-1
     Ntmp_m(j)=Ntmp_m(j-1)*exp(-(natmort_m+Ftemp*sel_tmp_m(j-1)));  // fills in matrix for ages 2 through nages-1
  }   
   // bpr = Ntmp(6,nages)*wt_pop(endyr)(6,nages); //JNI? need to change here to wt_fmsy?
   bpr  = Ntmp_f(ABC_age_lb,nages)*wt_pop_fut_f(ABC_age_lb,nages); 
   bpr += Ntmp_m(ABC_age_lb,nages)*wt_pop_fut_m(ABC_age_lb,nages); 
   return(bpr);
}

void model_parameters::get_msy(void)
{
    double d;
    dvariable F1;
    dvariable F2;
    dvariable F3;
    dvariable yld1;
    dvariable yld2;
    dvariable yld3;
    dvariable Fprime;
    dvariable F2prime;
    dvariable R_eq;
    dvariable phi;
    F1 = 1.1* natmort_f;          //start with F=M
    d=0.00001;
    for (i=1;i<=6;i++)
    {
      F2      = F1+d;
      F3      = F1-d;
      yld1    = get_yield(F1);
      yld2    = get_yield(F2);
      yld3    = get_yield(F3);
      Fprime  = (yld2-yld3)/(2*d);   //  Newton-Raphson approximation for first derivitive
      F2prime = (yld3-(2*yld1)+yld2)/(d*d);  // Newton-Raphson approximation for second derivitive
      F1     -= Fprime/F2prime;              // value to increment F for next time through the loop
      // cout <<"F1= "<<F1<<" Fprime= "<<Fprime<<endl;
    }
    Fmsy    = F1;
    phi     = get_spr(Fmsy);
    R_eq    = -(log(1/(R_alpha*phi)))/(phi*R_beta);   // Ricker formulation of equilibrium recruitment at each F
    Bmsy    = R_eq*phi;
    msy     = get_yield(Fmsy);
    logFmsy = log(Fmsy);
    Bmsy    = R_eq*phi;
    SPR_OFL = spr_ratio(Fmsy,partial_F_f);
    Bmsyr   = R_eq*get_biom_per_rec(Fmsy)    ;
    Fmsyr   = msy/Bmsyr;
    logFmsyr= log(Fmsyr);
}

void model_parameters::Future_projections(void)
{
  nage_future_f(styr_fut)(2,nages) = ++elem_prod(natage_f(endyr)(1,nages-1),S_f(endyr)(1,nages-1));
  nage_future_f(styr_fut,nages)   += natage_f(endyr,nages)*S_f(endyr,nages);
  nage_future_m(styr_fut)(2,nages) = ++elem_prod(natage_m(endyr)(1,nages-1),S_m(endyr)(1,nages-1));
  nage_future_m(styr_fut,nages)   += natage_m(endyr,nages)*S_m(endyr,nages);
  dvar_vector meanF(1,nfsh) ;
  // compute mean F based on last three years of Fs (assuming nages is fully selected and males and females the same...)
  meanF(1) = mean(trans(F_m(1))(nages)(endyr-3,endyr));
  future_SSB.initialize();
  future_Fs.initialize();
  future_catch.initialize();
  for (int m=1;m<=num_proj_Fs;m++)
  {
    switch (m)
    {
      case 1:
        ftmp = F40;
        break;
      case 2:
        ftmp = F35;
        break;
      case 3:
        ftmp = meanF;
        break;
      case 4:
        ftmp = 0.0;
        break;
      case 5: // this is the case for fixed future catch
        ftmp = 0.0;
        break;
     }
  //Calculation of future F's, Z and survival (S)
     Z_future_f = natmort_f;
     Z_future_m = natmort_m;
     dvar_vector wt_tmp_f(1,nages);   
     dvar_vector wt_tmp_m(1,nages);   
     for (i=endyr+1;i<=endyr_fut;i++)
     {
       // compute future ssb/rec under no fishing (but only need to do that once...)
       if (m==1)
       {
         // future_spr0(i) = get_spr(0.);
       }
       // Set growth if temperature related
       if (Growth_Option==3)
       {
         dvar_vector incr_dev_tmp(2,nages);
         incr_dev_tmp(5,nages-5)     = growth_alpha * fut_temp(i-endyr) ;
         incr_dev_tmp(nages-4,nages) = incr_dev_tmp(nages-5) ;
         incr_dev_tmp(2,4)           = incr_dev_tmp(5) ;
         wt_tmp_f(1)        = wt_vbg_f(1);
         wt_tmp_f(2,nages)  = ++wt_vbg_f(1,nages-1) + elem_prod(base_incr_f,mfexp(incr_dev_tmp)) ; // initializes estimates to correct values...
         wt_tmp_m(1)        = wt_vbg_m(1);
         wt_tmp_m(2,nages)  = ++wt_vbg_m(1,nages-1) + elem_prod(base_incr_m,mfexp(incr_dev_tmp)) ; // initializes estimates to correct values...
         wt_pop_fut_f           = wt_tmp_f;
         wt_pop_fut_m           = wt_tmp_m;
         wt_fsh_fut_f           = wt_tmp_f;
         wt_fsh_fut_m           = wt_tmp_m;
       }
       for (k=1;k<=nfsh;k++)
       {
         F_future_f(k,i) = sel_fsh_f(k,endyr) * ftmp(k);
         Z_future_f(i)  += F_future_f(k,i);
         F_future_m(k,i) = sel_fsh_m(k,endyr) * ftmp(k);
         Z_future_m(i)  += F_future_m(k,i);
       }
       S_future_f(i) = exp(-Z_future_f(i));
       S_future_m(i) = exp(-Z_future_m(i));
     }
  //Future recruitment and SSB
  //Mean average recruitment of the time-series is used for the projection
    //NOTE spawningbiomass is beginyear, NOT spawnmonth xxx
  dvariable Rectmp=mfexp(mean_log_rec);
  for (i=styr_fut;i<=endyr_fut;i++)
  {
		// cout<<"Future rec, 3-yr avg: "<<i<<" "<<Rectmp<< " "<< .5*mean(pred_rec(endyr-3,endyr))<< endl;
    nage_future_f(i,1) = Rectmp*mfexp(rec_dev_future(i));
    nage_future_m(i,1) = nage_future_f(i,1);
		if (m==5) 
		{
      Z_future_f = natmort_f;
      Z_future_m = natmort_m;
      for (k=1;k<=nfsh;k++)
      {
        ftmp(k)         = SolveF2(nage_future_f(i),nage_future_m(i),future_ABC(k,i)); // Only works for 1 fishery
				future_Fs(i)   += ftmp(k);
        F_future_f(k,i) = sel_fsh_f(k,endyr) * ftmp(k);
        Z_future_f(i)  += F_future_f(k,i);
        F_future_m(k,i) = sel_fsh_m(k,endyr) * ftmp(k);
        Z_future_m(i)  += F_future_m(k,i);
      }
      S_future_f(i) = exp(-Z_future_f(i));
      S_future_m(i) = exp(-Z_future_m(i));
      ABC_biom(i)      = nage_future_f(i)(ABC_age_lb,nages) * wt_pop_fut_f(ABC_age_lb,nages); 
      ABC_biom(i)     += nage_future_m(i)(ABC_age_lb,nages) * wt_pop_fut_m(ABC_age_lb,nages); 
    }
    SSB_future(i)      = elem_prod(nage_future_f(i),pow(S_future_f(i),spmo_frac)) * elem_prod(wt_pop_fut_f,maturity(endyr));  //need to add recruitment lag
    Rectmp             = R_alpha*SSB_future(i)*(mfexp(-R_beta*SSB_future(i)));
    TotBiom_future(i)  = nage_future_f(i)*wt_pop_fut_f; 
    TotBiom_future(i) += nage_future_m(i)*wt_pop_fut_m; 
  //Now graduate for the next year.....
	  if (i!=endyr_fut)
	  {
      nage_future_f(i+1)(2,nages) = ++elem_prod(nage_future_f(i)(1,nages-1),S_future_f(i)(1,nages-1));
      nage_future_f(i+1,nages)   += nage_future_f(i,nages) * S_future_f(i,nages);
      nage_future_m(i+1)(2,nages) = ++elem_prod(nage_future_m(i)(1,nages-1),S_future_m(i)(1,nages-1));
      nage_future_m(i+1,nages)   += nage_future_m(i,nages) * S_future_m(i,nages);
    }
    nage_future_f(endyr_fut,1) = .5*Rectmp*mfexp(rec_dev_future(endyr_fut));
    nage_future_m(endyr_fut,1) = nage_future_f(endyr_fut,1) ;
  }
  SSB_future(endyr_fut) = elem_prod(nage_future_f(endyr_fut),pow(S_future_f(endyr_fut),spmo_frac)) * elem_prod(wt_pop_fut_f,maturity(endyr));  //need to add recruitment lag
  TotBiom_future(endyr_fut)  = nage_future_f(endyr_fut)*wt_pop_fut_f;
  TotBiom_future(endyr_fut) += nage_future_m(endyr_fut)*wt_pop_fut_m;
  //Calculations of catch at predicted future age composition
  for (i=styr_fut;i<=endyr_fut;i++)
  {
    catage_future_f(i) = 0.;
    catage_future_m(i) = 0.;
    for (k=1;k<=nfsh;k++)
    {
      catage_future_f(i) += elem_prod(nage_future_f(i), elem_prod(F_future_f(k,i), elem_div( (1.-S_future_f(i) ),Z_future_f(i))));
      catage_future_m(i) += elem_prod(nage_future_m(i), elem_prod(F_future_m(k,i), elem_div( (1.-S_future_m(i) ),Z_future_m(i))));
    }
    if (m<=npfs)  // catch biomass in future
      future_catch(m,i)  += catage_future_f(i)*wt_fsh_fut_f + catage_future_m(i)*wt_fsh_fut_m      ;
    future_SSB(m,i) = SSB_future(i);
    future_TotBiom(m,i) = TotBiom_future(i);
   }
  }   //End of loop over F's
}

void model_parameters::write_srec(void)
{
  dvariable phi;  
  phizero=get_spr(0.0);
  // cout<<phizero<<endl;
  dvariable Rzero = -(log(1/(R_alpha*phizero)))/(phizero*R_beta);   // Ricker formulation of equilibrium recruitment at each F
  dvariable Bzero = Rzero*phizero;
  dvariable Btmp  =  .8*Bzero;
  srecpar << "# Bzero,  PhiZero,  Alpha, sigmaR"<<endl;
  srecpar     << Bzero          <<
         " "  << phizero/1000   <<
         " "  << (log(R_alpha)-R_beta*Btmp+log(phizero))/(1.-Btmp/Bzero) <<
         " "  << sigmaR         << endl;
  R_report << "$Bzero" <<endl;
  R_report << Bzero    <<endl;
  R_report << "$phizero" <<endl;
  R_report << phizero/1000<<endl;
  R_report << "$alpha_sr" <<endl;
  R_report << (log(R_alpha)-R_beta*Btmp+log(phizero))/(1.-Btmp/Bzero) <<endl;
  R_report << "$R_alpha" <<endl;
  R_report << R_alpha <<endl;
  R_report << "$R_beta" <<endl;
  R_report << R_beta <<endl;
  R_report << "$sigmaR" <<endl;
  R_report << sigmaR    <<endl;
}

void model_parameters::compute_spr_rates_2(void)
{
  //Compute SPR Rates 
  F35 = get_spr_rates(.35);
  F40 = get_spr_rates(.40);
}

dvariable model_parameters::get_spr_rates(double spr_percent)
{
  RETURN_ARRAYS_INCREMENT();
  double df=1.e-3;
  dvariable F1 ;
  F1.initialize();
  F1 = .9*natmort_f;
  dvariable F2;
  dvariable F3;
  dvariable yld1;
  dvariable yld2;
  dvariable yld3;
  dvariable dyld;
  dvariable dyldp;
  // Newton Raphson stuff to go here
  for (int ii=1;ii<=6;ii++)
  {
    F2     = F1 + df;
    F3     = F1 - df;
    yld1   = -100.*square(log(spr_percent/spr_ratio(F1)));
    yld2   = -100.*square(log(spr_percent/spr_ratio(F2)));
    yld3   = -100.*square(log(spr_percent/spr_ratio(F3)));
    dyld   = (yld2 - yld3)/(2*df);                          // First derivative (to find the root of this)
    dyldp  = (yld3-(2*yld1)+yld2)/(df*df);  // Newton-Raphson approximation for second derivitive
    F1    -= dyld/dyldp;
  }
  RETURN_ARRAYS_DECREMENT();
  return(F1);
}

dvariable model_parameters::spr_ratio(dvariable trial_F)
{
  RETURN_ARRAYS_INCREMENT();
  dvariable SBtmp;
  dvar_vector Ntmp(1,nages);
  dvar_vector srvtmp(1,nages);
  SBtmp.initialize();
  Ntmp.initialize();
  srvtmp.initialize();
  dvar_vector Ftmp(1,nages);
  dvar_vector wttmp = wt_pop_fut_f;
  Ftmp = sel_fsh_f(1,endyr) * trial_F;
  srvtmp  = mfexp(-(Ftmp + natmort_f) );
  Ntmp(1)=1.;
  j=1;
  SBtmp  += Ntmp(j)*maturity(endyr,j)*wttmp(j)*pow(srvtmp(j),spmo_frac);
  for (j=2;j<nages;j++)
  {
    Ntmp(j) = Ntmp(j-1)*srvtmp(j-1);
    SBtmp  += Ntmp(j)*maturity(endyr,j)*wttmp(j)*pow(srvtmp(j),spmo_frac);
   // !!spmo_frac    =(spawnmo-1)/12.;
  }
  Ntmp(nages)=Ntmp(nages-1)*srvtmp(nages-1)/(1.-srvtmp(nages));
  SBtmp  += Ntmp(nages)*maturity(endyr,nages)*wttmp(nages)*pow(srvtmp(nages),spmo_frac);
  RETURN_ARRAYS_DECREMENT();
  return(SBtmp/phizero);
}

void model_parameters::report(const dvector& gradients)
{
 adstring ad_tmp=initial_params::get_reportfile_name();
  ofstream report((char*)(adprogram_name + ad_tmp));
  if (!report)
  {
    cerr << "error trying to open report file"  << adprogram_name << ".rep";
    return;
  }
  save_gradients(gradients);
  dvar_vector wt_pop_tmp_f(1,nages);
	int ilike=1;
	nLogPosterior(ilike) = wt_like(1); ilike++;
	nLogPosterior(ilike) = wt_like(2); ilike++;
	nLogPosterior(ilike) = wt_like(3); ilike++;
	nLogPosterior(ilike) = wt_fut_like; ilike++;
	nLogPosterior(ilike) = wt_msy_like; ilike++;
	nLogPosterior(ilike) = init_like  ; ilike++;
	nLogPosterior(ilike) = srv_like(1);   ilike++;
	nLogPosterior(ilike) = catch_like ; ilike++;
	nLogPosterior(ilike) = age_like_fsh(1); ilike++;
	nLogPosterior(ilike) = age_like_srv(1); ilike++;
	nLogPosterior(ilike) = rec_like(1); ilike++;
	nLogPosterior(ilike) = rec_like(2); ilike++;
	nLogPosterior(ilike) = rec_like(3); ilike++;
	nLogPosterior(ilike) = rec_like(4); ilike++;
	nLogPosterior(ilike) = sel_like(1); ilike++;
	nLogPosterior(ilike) = sel_like(2); ilike++;
	nLogPosterior(ilike) = q_prior(1)  ; ilike++;
	nLogPosterior(ilike) = sigmaR_prior; ilike++;
	nLogPosterior(ilike) = m_prior     ; ilike++;
	nLogPosterior(ilike) = fpen       ; ilike++;
  for (int i=0;i<=3;i++)
    {
      dvar_vector incr_dev_tmp(2,nages);
      incr_dev_tmp(5,nages-5)     = growth_alpha * double(i) ;
      incr_dev_tmp(nages-4,nages) = incr_dev_tmp(nages-5) ;
      incr_dev_tmp(2,4)           = incr_dev_tmp(5) ;
      wt_pop_tmp_f(1)        = wt_vbg_f(1);
      wt_pop_tmp_f(2,nages)  = ++wt_vbg_f(1,nages-1) + elem_prod(base_incr_f,mfexp(incr_dev_tmp)) ; // initializes estimates to correct values...
      report <<i<<" "<<double(i)*growth_alpha<<" "<<wt_pop_tmp_f<<endl;
    }
    report << "wt_pop_f"<<endl;
    report << wt_pop_f<<endl;
    report << "wt_pop_m"<<endl;
    report << wt_pop_m<<endl;
  // This section to write s-rec parameters to input file for projection model
  // need Rzero, phizero calculated then use alpha and beta
  if (active(R_logbeta))
    write_srec();
  cout<<"Done with phase "<<current_phase()<<" --in report file"<<endl;
  cout<<wt_pop_mn_f(4,10)<<endl;
  cout<<wt_fsh_mn_f(4,10)<<endl;
  report << model_name<<endl;
  if (last_phase()&&!do_wt_only)
  {
  dvariable Ftemp;
  Ftemp=0.01;
  dvariable ypr;
  dvariable yield;
  dvariable phi;  
  dvariable R_eq;
   for (i=1;i<=60;i++) // range of F values to evaluate for Fmsy (0.02 to 0.31-30 steps)
    {
     Ftemp=Ftemp+0.01;            //increments F by 0.01 each pass through the loop
     phi=get_spr(Ftemp);
     R_eq = -(log(1/(R_alpha*phi)))/(phi*R_beta);   // Ricker formulation of equilibrium recruitment at each F
     ypr=get_ypr(Ftemp);
     yield=R_eq*ypr;
     cout <<" Ftemp= "<<Ftemp<<" r= "<<yield/(R_eq*phi)<<" phi= "<<phi<<" R_eq= "<<R_eq<<" ypr= "<<ypr<<" yield= "<<yield<< endl;
    }
  }
  report << "Estimated_numbers_of_fish year "<<age_vector << endl;
   for (i=styr;i<=endyr;i++)
     report << " "<<  i << ", "<< natage_f(i) << natage_m(i)<<endl;
  report << endl<< "Estimated_F_mortality Fishery Year " << age_vector<< endl;
   for (k=1;k<=nfsh;k++)
     for (i=styr;i<=endyr;i++)
       report << " "<< k <<" "<< i << " "<<F_f(k,i) << " " << F_m(k,i)<<endl;
   report << endl << "Observed survey values " << endl;
   for (k=1;k<=nsrv;k++)
   {
     int ii=1;
     report <<endl<< "ObsSurvey "<< k <<"  " <<"predSurvey "<< endl;
     for (i=styr;i<=endyr;i++)
     {
        if (yrs_srv(k,ii)==i)
        {
          report << i << ", " << obs_srv(k,ii) << ", " << pred_srv(k,i)<< endl;
          ii++;
        }
        else
         report << i<< ",NA, "<<pred_srv(k,i)<<endl;
     }
  }
  report << endl<< "Observed_proportion "<<endl;
  for (k=1;k<=nfsh;k++)
  {
    report << "Observed_fishery_age_comp "<< k <<"  "<<endl ;
    for (i=1;i<=nyrs_fsh_age_c(k);i++)
      report   << yrs_fsh_age_c(k,i)<< ", " << oac_fsh_c(k,i) << " "<<Eff_N(oac_fsh_c(k,i),eac_fsh_c(k,i))<< endl; 
		if (last_phase()) 
    {
      if (nyrs_fsh_age_c(k) >0)
      {
        R_report << "$yrs_fsh_age_c" <<endl;
        R_report << yrs_fsh_age_c(k) <<endl;
        R_report << "$eac_fsh_c"<<endl;
        for (i=1;i<=nyrs_fsh_age_c(k);i++)
          R_report << eac_fsh_c(k,i) << endl; 
        R_report << "$oac_fsh_c"<<endl;
        for (i=1;i<=nyrs_fsh_age_c(k);i++)
          R_report << oac_fsh_c(k,i) << endl; 
        R_report << "$effN_fsh_c"<<endl;
        for (i=1;i<=nyrs_fsh_age_c(k);i++)
          R_report <<Eff_N(oac_fsh_c(k,i),eac_fsh_c(k,i)) <<" ";
        R_report <<endl;
      }
      if (nyrs_fsh_age_s(k) >0)
      {
        R_report << "$yrs_fsh_age_s" <<endl;
        R_report << yrs_fsh_age_s(k) <<endl;
        R_report << "$eac_fsh_s"<<endl;
        for (i=1;i<=nyrs_fsh_age_s(k);i++)
          R_report << eac_fsh_s(k,i) << endl; 
        R_report << "$oac_fsh_s"<<endl;
        for (i=1;i<=nyrs_fsh_age_s(k);i++)
          R_report << oac_fsh_s(k,i) << endl; 
        R_report << "$effN_fsh_s"<<endl;
        for (i=1;i<=nyrs_fsh_age_s(k);i++)
          R_report <<Eff_N(oac_fsh_s(k,i),eac_fsh_s(k,i)) <<" ";
        R_report <<endl;
      }
    }
    for (i=1;i<=nyrs_fsh_age_s(k);i++)
    {
      report << yrs_fsh_age_s(k,i)<< ", " << oac_fsh_s(k,i) << ", Female/Total: "<< sum(oac_fsh_s(k,i)(1,nages)) 
             << " "<<Eff_N(oac_fsh_s(k,i),eac_fsh_s(k,i)) 
             << " "<<mn_age(oac_fsh_s(k,i))
             << " "<<mn_age(eac_fsh_s(k,i))
             << " "<<Sd_age(oac_fsh_s(k,i),eac_fsh_s(k,i))
             << " "<<Eff_N2(oac_fsh_s(k,i),eac_fsh_s(k,i))
             <<endl;
    }
  }
  report << endl << "Predicted_prop_Fishery "<<endl;
  for (k=1;k<=nfsh;k++)
  {
    report << "Pred_fishery_age_comp "<< k <<"  "<<endl ;
    for (i=1;i<=nyrs_fsh_age_c(k);i++)
      report << yrs_fsh_age_c(k,i)<< ", " << eac_fsh_c(k,i) << endl;
    for (i=1;i<=nyrs_fsh_age_s(k);i++)
      report << yrs_fsh_age_s(k,i)<< ", " << eac_fsh_s(k,i) << ", Female/Total: "<< sum(eac_fsh_s(k,i)(1,nages)) << endl; 
  }
  report << endl<< "Observed_prop_Survey "<<endl;
  for (k=1;k<=nsrv;k++)
  {
    if(last_phase())
    {
      if (nyrs_srv_age_c(k) >0)
      {
        R_report << "$yrs_srv_age_c" <<endl;
        R_report << yrs_srv_age_c(k) <<endl;
        R_report << "$eac_srv_c"<<endl;
        for (i=1;i<=nyrs_srv_age_c(k);i++)
          R_report << eac_srv_c(k,i) << endl; 
        R_report << "$oac_srv_c"<<endl;
        for (i=1;i<=nyrs_srv_age_c(k);i++)
          R_report << oac_srv_c(k,i) << endl; 
        R_report << "$effN_srv_c"<<endl;
        for (i=1;i<=nyrs_srv_age_c(k);i++)
          R_report <<Eff_N(oac_srv_c(k,i),eac_srv_c(k,i)) <<" ";
        R_report <<endl;
      }
      if (nyrs_srv_age_s(k) >0)
      {
        R_report << "$yrs_srv_age_s" <<endl;
        R_report << yrs_srv_age_s(k) <<endl;
        R_report << "$eac_srv_s"<<endl;
        for (i=1;i<=nyrs_srv_age_s(k);i++)
          R_report << eac_srv_s(k,i) << endl; 
        R_report << "$oac_srv_s"<<endl;
        for (i=1;i<=nyrs_srv_age_s(k);i++)
          R_report << oac_srv_s(k,i) << endl; 
        R_report << "$effN_srv_s"<<endl;
        for (i=1;i<=nyrs_srv_age_s(k);i++)
          R_report <<Eff_N(oac_srv_s(k,i),eac_srv_s(k,i))<<" ";
        R_report <<endl;
      }
    }
    report << "Obs_Survey_age_comp "<< k <<"  "<<endl ;
    for (i=1;i<=nyrs_srv_age_c(k);i++)
    {
      report << yrs_srv_age_c(k,i)<< ", " << oac_srv_c(k,i)  << " "<<Eff_N(oac_srv_c(k,i),eac_srv_c(k,i))<< endl; 
    }
    for (i=1;i<=nyrs_srv_age_s(k);i++)
    {
      report << yrs_srv_age_s(k,i)<< ", " << oac_srv_s(k,i) << ", Female/Total: "<< sum(oac_srv_s(k,i)(1,nages))  << " "<<Eff_N(oac_srv_s(k,i),eac_srv_s(k,i))<< endl; 
    }
  }
  report << endl << "Predicted_prop_Survey "<<endl;
  for (k=1;k<=nsrv;k++)
  {
    report << "Pred_Survey_age_comp "<< k <<"  "<<endl ;
    for (i=1;i<=nyrs_srv_age_c(k);i++)
      report << yrs_srv_age_c(k,i)<< ", " << eac_srv_c(k,i) << endl;
    for (i=1;i<=nyrs_srv_age_s(k);i++)
      report << yrs_srv_age_s(k,i)<< ", " << eac_srv_s(k,i) << ", Female/Total: "<< sum(eac_srv_s(k,i)(1,nages)) << endl; 
  }
  report << endl<< "Observed_catch_biomass " << endl;
  for (int ifsh=1;ifsh<=nfsh;ifsh++)
    report << obs_catch(ifsh)(styr,endyr) << endl;
  report << "predicted_catch_bomass" << endl;
  for (int ifsh=1;ifsh<=nfsh;ifsh++)
    report << pred_catch(ifsh) << endl;
  report << endl << "Estimated_annual_Fishing_mortality "<< endl;
  for (i=styr; i<endyr;i++)
  {
    report << i << " ";
    for (k=1;k<=nfsh;k++)
      report<< mean(F_f(k,i)) << " ";
    report <<Fmort(i)<<endl;
  }
  report << endl<<"Selectivity sex fshry_age " << age_vector(1,nages)<<endl;
  for (k=1;k<=nfsh;k++)
  {
  for (i=styr; i<=endyr;i++)
    report << "Fishery female " << k <<" "<<i<<" "<< sel_fsh_f(k,i) << endl;
    report<<endl;
  for (i=styr; i<=endyr;i++)
    report << "Fishery male "   << k <<" "<<i<<" "<< sel_fsh_m(k,i) << endl;
    report<<endl;
  }
  report << "Partial_F  Female  0      " <<partial_F_f  << endl;
  report << "Partial_F  Male    0      " <<partial_F_m  << endl;
  for (k=1;k<=nsrv;k++)
  {
    report << "Survey female " << k <<"  " <<sel_srv_f(k) << endl;
    report << "Survey male   " << k <<"  " <<sel_srv_m(k) << endl;
  }
  report << endl<<"Female_spawning_biomass " << endl;
    for (i=styr;i<=endyr;i++)
      report <<i<<", "<<SSB(i)<<endl;
  report << endl<<"Total_biomass " << endl;
    for (i=styr;i<=endyr;i++)
      report <<i<<",  "<<TotBiom(i)<<endl;
  report <<endl<<endl;
  report <<"F40= " << F40 << endl;
  report <<"F35= " << F35 << endl;
  report <<"F30= " << F30 << endl;
  report <<"Unfished_spawning_biomass_per_recruit " << SB0 << endl;
  report << "Spawning_biomass_per_recruit_from_F40_harvest_rate " << SBF40<<endl;
  report << "Spawning_biomass_per_recruit_from_F35_harvest_rate " << SBF35<<endl;
  report << "Spawning_biomass_per_recruit_from_F30_harvest_rate " << SBF30<<endl;
  report << "Projected_spawning_biomass " << endl;
  report << "F40_spawning_biomass " << future_SSB(1) <<endl;
  report << "F35_spawning_biomass " << future_SSB(2) <<endl;
  report << "F30_spawning_biomass " << future_SSB(3) <<endl;
  report << "F=0_spawning_biomass " << future_SSB(4) <<endl;
  report << "Projected_total_biomass " << endl;
  report << "F40_total_biomass " << future_TotBiom(1) <<endl;
  report << "F35_total_biomass " << future_TotBiom(2) <<endl;
  report << "F30_total_biomass " << future_TotBiom(3) <<endl;
  report << "F=0_total_biomass " << future_TotBiom(4) <<endl;
  report << "Projected_catch " << endl;
  report << "F40_harvest " << future_catch(1) <<endl;
  report << "F35_harvest " << future_catch(2) <<endl;
  report << "three-yr-mean_harvest" << future_catch(3) <<endl;
  report << "F=0_harvest " << " 0 0 0 0 0 0 0 0 0 0 0 " <<endl;
  report << endl << "Likelihood_Components " << endl;
  report << "survey_likelihood " << srv_like << endl;
  report << "catch_likelihood " <<  catch_like << endl;
  report << "age_likelihood_for_fishery " << age_like_fsh << endl;
  report << "age_likeihood_for_survey " << age_like_srv << endl;
  report << "recruitment_likelilhood " << rec_like << endl;
  report << "selectivity_likelihood " << sel_like << endl;
  report << "q_Prior " <<q_prior <<endl;
  report << "m_Prior " <<m_prior <<endl;
  report << "sigmaR_Prior " <<sigmaR_prior <<endl;
  report << "F_penalty " << fpen << endl;
  if (phase_env_cov>0)
  {
    // report << "alpha= " << q_alpha << endl;
    // report << "beta= " << q_beta << endl;
    // report << endl<<"Environmental_effect_q " << endl;
  // init_ivector n_env_cov(1,nsrv)
  // !!log_input(n_env_cov);
  // init_3darray env_cov(1,nsrv,1,n_env_cov,1,nyrs_srv)
  // !!  for (int j=1;j<=nsrv;j++) for (int k=1;k<=n_env_cov(j);k++) { env_cov(j,k) -= mean(env_cov(j,k)); }
    // for (i=1;i<=nyrs_srv(1);i++)
      // for (k=1;k<=n_env_cov(1);k++);
        // report <<yrs_srv(1,i)<<", "<<env_cov(1,k,i)<<", "<<endl;// mfexp(-q_alpha(1)+q_beta(1,k)*env_cov(1,k,i))<<endl;
  }
  // if (phase_env_cov>0) report << " survey_q= " << mean(exp(-q_alpha+q_beta*env_cov(1)))<<endl; else
   /*
   */
  report << "survey_q = " << mean(q_srv(1))<<endl;
  report << "M (F M)  = " << natmort_f<<" "<<natmort_m << endl;
  report << endl << "Ricker_spawner-recruit_estimates" << endl;
  report << "stock_assessment_model_recruitment_estimates" << endl;
  report << SAM_recruits << endl;
  report << "Ricker_model_predicted_recruitment"<<endl;
  report << SRC_recruits << endl;
  report << "Ricker_alpha= " << endl;
  report << R_alpha << endl;
  report << "Ricker_beta = " << endl;
  report << R_beta << endl;
  report << "Estimated_catch_at_age " << endl;
  report <<"Fishery Year " << age_vector <<endl;
  for (k=1;k<=nfsh;k++)
    for (i=styr;i<=endyr;i++)
      report <<k <<"  " << i << " "<< catage_f(1,i) <<", "<<catage_m(1,i)<< endl;
  report << "Estimated_stock_recruitment_curve" << endl;
  report << "Stock recruitment " << endl;
  dvariable stmp;
  dvariable maxspawn=max(SSB)*1.2;
   for (i=0;i<=30;i++)
   {
     // SRR_SSB(i) = double(i+.001)*maxspawn/30; 
     // rechat(i)  = R_alpha*stmp*(mfexp(-R_beta*SRR_SSB(i)));
     report <<  stmp<<" "<< R_alpha*stmp*(mfexp(-R_beta*stmp))<<endl;  // Ricker model
   }
  report << "Estimated_sex_ratio Year Total Mature Age_7+"<< endl;
   for (i=styr;i<=endyr;i++)
     report << " "<<  i << ", "<< 
     sum(natage_f(i))/sum(natage_f(i)+natage_m(i))<<" "<<
     sum(elem_prod(maturity(i),natage_f(i)))/sum(elem_prod(maturity(i),natage_f(i)+natage_m(i)))<<" "<<
     sum(natage_f(i)(7,nages))/sum(natage_f(i)(7,nages)+natage_m(i)(7,nages))<<" "<<
     endl;
  report << "Fishry_wts_age"<<endl;
  report << wt_fsh_f <<endl<<endl;
  report << wt_fsh_m <<endl<<endl;
  report << "Survey_wts_age"<<endl;
  report << wt_srv_f <<endl<<endl;
  report << wt_srv_m <<endl;
  report << "Increment_deviations"<<endl;
  report << incr_dev <<endl<<endl;
  report << "predicted_Observerd_wts"<<endl;
  report << wt_pred_f       <<endl<<endl;
  report << wt_obs_f       <<endl<<endl;
  report << "Wt_Like"<<endl;
  report << wt_like <<endl<<endl;
  report << "Age_Incr_component"<<endl;
  report << age_incr <<endl<<endl;
  report << "Future_Mean_wt"<<endl;
  report << "Female_wt_future: " <<wt_pop_fut_f <<endl<<endl;
  report << "Male_wt_future: "   <<wt_pop_fut_m <<endl<<endl;
  report << "Female_wt_base: " <<wt_vbg_f <<endl<<endl;
  report << "Male_wt_base: "   <<wt_vbg_m <<endl<<endl;
  // exit(1) ;
  report << "SARA file for Angie Greig" << endl;
  report << "Yellowfin sole       # stock  " << endl;
  report << "BSAI       # region     (AI AK BOG BSAI EBS GOA SEO WCWYK)" << endl;
  report << "2013       # ASSESS_YEAR - year assessment is presented to the SSC" << endl;
  report << "1a         # TIER  (1a 1b 2a 2b 3a 3b 4 5 6) " << endl;
  report << "none       # TIER2  if mixed (none 1a 1b 2a 2b 3a 3b 4 5 6)" << endl;
  report << "full       # UPDATE (new benchmark full partial)" << endl;
  report << "2          # LIFE_HIST - SAIP ratings (0 1 2 3 4 5)" << endl;
  report << "3          # ASSES_FREQ - SAIP ratings (0 1 2 3 4 5) " << endl;
  report << "5          # ASSES_LEV - SAIP ratings (0 1 2 3 4 5)" << endl;
  report << "5          # CATCH_DAT - SAIP ratings (0 1 2 3 4 5) " << endl;
  report << "3          # ABUND_DAT - SAIP ratings (0 1 2 3 4 5)" << endl;
  report << "654300     # Minimum B  Lower 95% confidence interval for spawning biomass in assessment year" << endl;
  report << "499000     # Maximum B  Upper 95% confidence interval for spawning biomass in assessment year" << endl;
  report << "366000     # BMSY  is equilibrium spawning biomass at MSY (Tiers 1-2) or 7/8 x B40% (Tier 3)" << endl;
  report << "ADMB       # MODEL - Required only if NMFS toolbox software used; optional otherwise " << endl;
  report << "NA         # VERSION - Required only if NMFS toolbox software used; optional otherwise" << endl;
  report << "2          # number of sexes  if 1 sex=ALL elseif 2 sex=(FEMALE, MALE) " << endl;
  report << "1          # number of fisheries" << endl;
  report << "1000000    # multiplier for recruitment, N at age, and survey number (1,1000,1000000)" << endl;
  report << "1          # recruitment age used by model or size" << endl;
  report << "1          # age+ or mmCW+ used for biomass estimate" << endl;
  report << "\"Single age\"        # Fishing mortality type such as \"Single age\" or \"exploitation rate\"" << endl;
  report << "\"Age model\"         # Fishing mortality source such as \"Model\" or \"(total catch (t))/(survey biomass (t))\"" << endl;
  report << "\"Age of maximum F\"  # Fishing mortality range such as \"Age of maximum F\"" << endl; 
  report << "#FISHERYDESC -list of fisheries (ALL TWL LGL POT FIX FOR DOM TWLJAN LGLMAY POTAUG ...)" << endl; 
  report << "ALL" << endl; 
  report <<"#FISHERYYEAR - list years used in the model " << endl;
   for (i=styr;  i<=endyr; i++)
      report << i << "	";
      report<<endl;  
  report<<"#AGE - list of ages used in the model"<<endl;
   for (i=1; i<=20;i++)
      report << i << "	";
      report<<endl;    
  report <<"#RECRUITMENT - Number of recruits by year " << endl;
   for (i=styr;  i<=endyr;  i++)
	   report  << natage_f(i,1)+natage_m(i,1) << "	";
	   report<<endl;     
  report <<"#SPAWNBIOMASS - Spawning biomass by year in metric tons " << endl;
   for (i=styr;  i<=endyr;  i++)
      report  << SSB(i) << "	";
      report<<endl;  
  report <<"#TOTALBIOMASS - Total biomass by year in metric tons " << endl;
   for (i=styr;  i<=endyr;  i++)
      report  << TotBiom << "	";
      report<<endl;
 // cout <<F_f<<endl;
   report <<"#TOTFSHRYMORT - Fishing mortality rate by year " << endl;
  	for (i=styr;  i<=endyr;  i++)
  	   report  << (F_f(1,i,20)+ F_m(1,i,20))/2<< "	";
  	   report<<endl;
  report <<"#TOTALCATCH - Total catch by year in metric tons " << endl;
   for (i=styr;  i<=endyr;  i++)
      report  << obs_catch(1,i) << "	";
      report<<endl;
  report <<"#MATURITY - Maturity ratio by age (females only)" << endl;  
      report  << maturity(endyr) << endl; 
  report <<"#SPAWNWT - Average spawning weight (in kg) for ages 8-20"<< endl; 
      report <<"0.165 0.212 0.259 0.292 327.8 0.361 0.39 0.412 0.429 0.46 0.47 0.49 0.56"<<endl;                              
      report<<endl;
  report <<"#NATMORT - Natural mortality rate for females then males"<< endl; 
  for (i=1;  i<=20;  i++) 
  report  << 0.12 <<"	";
  report<< endl;   
  for (i=1;  i<=20;  i++) 
  report  << 0.12 <<"	";
  report<< endl;
  report << "#N_AT_AGE - Estimated numbers of female (first) then male (second) fish at age " << endl;
  for (i=styr; i<=endyr;i++)
    report <<natage_f(i)<< "	";
    report<<endl;
  for (i=styr; i<=endyr;i++)
    report <<natage_m (i)<< "	";
    report<<endl;
  report <<"#FSHRY_WT_KG - Fishery weight at age (in kg) females (first) males (second), only one fishery"<< endl;   
   report <<wt_fsh_f_in(1,endyr)/1000  << "	";
   report<<endl;         
   report <<wt_fsh_m_in(1,endyr)/1000  << "	";
   report<<endl;
  report << "#SELECTIVITY - Estimated fishery selectivity for females (first) males (second) at age " << endl;
   report <<" " <<sel_fsh_f(1,endyr);
   report<<endl;
   report <<" "  <<sel_fsh_m(1,endyr);
   report<<endl;
  report << "#SURVEYDESC"<<endl;
  report<<"EBS_trawl_survey BS_slope_trawl_survey AI_trawl_survey"<<endl;
  report<<"SURVEYMULT"<<endl;
  report<<"1 1 1"<<endl;
  report << "#EBS_trawl_survey - Bering Sea shelf survey biomass (Year, Obs_biomass, Pred_biomass) " << endl;
   for (i=1; i<=nsrv;i++)
     report << yrs_srv(i) << "	";
     report<<endl;
   for (i=1; i<=nsrv;i++) 
     report<< obs_srv(i)<< "	";
     report<< endl;
  report<<"#STOCKNOTES"<<endl;
  report<<"\"SAFE report indicates that this stock was not subjected to overfishing in 2012 and is neither overfished nor approaching a condition of being overfished in 2013.\""<<endl;
  cout <<"End of report file for phase "<<current_phase()<<endl;
	// if (last_phase()) ssb_retro << SSB <<endl;
}

void model_parameters::between_phases_calculations(void)
{
  // Set the msy selectivity to something reasonable???
  log_msy_sel_f = log_sel_fsh_f(1,endyr-2);
  log_msy_sel_m = log_sel_fsh_m(1,endyr-2);
}

void model_parameters::set_runtime(void)
{
  dvector temp1("{1000,500,1000,6000}");
  maximum_function_evaluations.allocate(temp1.indexmin(),temp1.indexmax());
  maximum_function_evaluations=temp1;
  dvector temp("{.0000001,.001,.00001,1e-7}");
  convergence_criteria.allocate(temp.indexmin(),temp.indexmax());
  convergence_criteria=temp;
}

double model_parameters::mn_age(const dvar_vector& pobs)
{
  int lb1 = pobs.indexmin();
  int ub1 = pobs.indexmax();
  dvector av = age_vector(lb1,ub1)  ;
  double mobs = value(pobs*av);
  return mobs;
}

double model_parameters::Sd_age(const dvar_vector& pobs, const dvar_vector& phat)
{
  int lb1 = pobs.indexmin();
  int ub1 = pobs.indexmax();
  dvector av = age_vector(lb1,ub1)  ;
  double mobs = value(pobs*av);
  double stmp = value(sqrt(elem_prod(av,av)*pobs - mobs*mobs));
  return stmp;
}

double model_parameters::Eff_N_adj(const double, const dvar_vector& pobs, const dvar_vector& phat)
{
  int lb1 = pobs.indexmin();
  int ub1 = pobs.indexmax();
  dvector av = age_vector(lb1,ub1)  ;
  double mobs = value(pobs*av);
  double mhat = value(phat*av );
  double rtmp = mobs-mhat;
  double stmp = value(sqrt(elem_prod(av,av)*pobs - mobs*mobs));
  return square(stmp)/square(rtmp);
}

double model_parameters::Eff_N2(const dvar_vector& pobs, const dvar_vector& phat)
{
  int lb1 = pobs.indexmin();
  int ub1 = pobs.indexmax();
  dvector av = age_vector(lb1,ub1)  ;
  double mobs = value(pobs*av);
  double mhat = value(phat*av );
  double rtmp = mobs-mhat;
  double stmp = value(sqrt(elem_prod(av,av)*pobs - mobs*mobs));
  return square(stmp)/square(rtmp);
}

double model_parameters::Eff_N(const dvar_vector& pobs, const dvar_vector& phat)
{
  dvar_vector rtmp = elem_div((pobs-phat),sqrt(elem_prod(phat,(1-phat))));
  double vtmp;
  vtmp = value(norm2(rtmp)/size_count(rtmp));
  return 1/vtmp;
}

dvariable model_parameters::SolveF2(const dvar_vector& N_tmp_f, dvar_vector& N_tmp_m, double  TACin)
{
  dvariable dd = 10.;
  dvariable cc = TACin;
  dvar_vector wttmp_f   = wt_pop_fut_f;
  dvar_vector wttmp_m   = wt_pop_fut_m;
  dvariable btmp =  N_tmp_f * wttmp_f ;
  dvariable ftmp;
  ftmp = TACin/btmp;
  dvar_vector Fatmp_f = ftmp * partial_F_f;
  dvar_vector Fatmp_m = ftmp * partial_F_m;
  dvar_vector Z_tmp_f   = Fatmp_f + natmort_f;
  dvar_vector Z_tmp_m   = Fatmp_m + natmort_m;
  dvar_vector S_tmp_f   = exp(-Z_tmp_f);
  dvar_vector S_tmp_m   = exp(-Z_tmp_m);
  int icount;
  icount=0;
  while (dd > 1e-5)
  {
    icount++;
    ftmp   += (TACin-cc) / btmp;
    Fatmp_f = ftmp * partial_F_f;
    Z_tmp_f   = Fatmp_f + natmort_f;
    S_tmp_f   = mfexp( -Z_tmp_f );
    Fatmp_m = ftmp * partial_F_m;
    Z_tmp_m   = Fatmp_m + natmort_m;
    S_tmp_m   = mfexp( -Z_tmp_m );
    cc  = (wttmp_f * elem_prod(elem_div(Fatmp_f,  Z_tmp_f),elem_prod(1.-S_tmp_f,N_tmp_f))); // Catch equation (vectors)
    cc += (wttmp_m * elem_prod(elem_div(Fatmp_m,  Z_tmp_m),elem_prod(1.-S_tmp_m,N_tmp_m))); // Catch equation (vectors)
    dd = cc / TACin - 1.;
    //cout << ispp<<" "<< ftmp << " "<< cc << " "<<TACin<<endl; //cout << sel_F << endl << sel_M << endl << endl; //cout << Fratsel_F << endl << Fratsel_M << endl; //exit(1);
    if (dd<0.) dd *= -1.;
    // cout<<"Ftmp "<<cc<<" "<< ftmp<<endl;
    if (icount>100) dd=1e-6;
  }
  return(ftmp);
  /* FUNCTION dvariable SolveF2(const dvar_vector& N_tmp, double  TACin)
  dvariable dd = 10.;
  dvariable cc = TACin;
  dvar_vector wttmp   = wt_pop_fut_f;
  dvariable btmp =  N_tmp * wttmp ;
  dvariable ftmp;
  ftmp = TACin/btmp;
  dvar_vector Fatmp   = ftmp * partial_F;
  dvar_vector Z_tmp    = Fatmp+ natmort;
  dvar_vector S_tmp = exp(-Z_tmp);
  int icount;
  icount=0;
  while (dd > 1e-5)
  {
    icount++;
    ftmp += (TACin-cc) / btmp;
    Fatmp = ftmp * partial_F;
    Z_tmp = Fatmp + natmort;
    S_tmp = mfexp( -Z_tmp );
    cc = (wttmp * elem_prod(elem_div(Fatmp,  Z_tmp),elem_prod(1.-S_tmp,N_tmp))); // Catch equation (vectors)
    dd = cc / TACin - 1.;
    //cout << ispp<<" "<< ftmp << " "<< cc << " "<<TACin<<endl; //cout << sel_F << endl << sel_M << endl << endl; //cout << Fratsel_F << endl << Fratsel_M << endl; //exit(1);
    if (dd<0.) dd *= -1.;
    // cout<<"Ftmp "<<cc<<" "<< ftmp<<endl;
    if (icount>100) dd=1e-6;
  }
  return(ftmp);
  */
}

void model_parameters::Write_sd(void)
{
 int m = 5; // the projection for Tier 1 stuff
 dvariable hm_f = exp(logFmsyr - logFmsyr.sd*logFmsyr.sd /2.);
 dvariable am_f = exp(logFmsyr + logFmsyr.sd*logFmsyr.sd /2.);
 ofstream ABCreport("future_ABC.rep");
 for (i = styr_fut;i<=endyr_fut;i++)
 {
   dvariable cv_b = ABC_biom.sd(i)/ABC_biom(i);
   dvariable gm_b = exp(log(ABC_biom(i))-(cv_b*cv_b)/2.);
   if(future_SSB(m,i) < Bmsy)
     adj_1 = value((future_SSB(m,i)/Bmsy - 0.05)/(1.-0.05));
   ABCreport <<        gm_b  * hm_f * adj_1  <<" "<< endl;
 }
 ABCreport.close();
 ofstream sdreport("extra_sd.rep");
 sdreport << "Year HM_Fmsyr AM_Fmsyr GM_Biom Catch_Assump ABC_HM OFL_AM Bmsy SSB Adjust "<<endl;
 for (i = styr_fut;i<=endyr_fut;i++)
 {
   dvariable cv_b = ABC_biom.sd(i)/ABC_biom(i);
   dvariable gm_b = exp(log(ABC_biom(i))-(cv_b*cv_b)/2.);
   if(future_SSB(m,i) < Bmsy)
     adj_1 = value((future_SSB(m,i)/Bmsy - 0.05)/(1.-0.05));
   sdreport << i                 <<" "<<
	         hm_f                  <<" "<<
	         am_f                  <<" "<<
	         gm_b                  <<" "<<
	         trans(future_ABC)(i)  <<" "<<
           gm_b  * hm_f * adj_1  <<" "<<
           gm_b  * am_f * adj_1  <<" "<<
           Bmsy                  <<" "<< 
           future_SSB(m,i)       <<" "<< 
           adj_1                 <<" "<< endl;
 }
 /*
   sdreport <<"HM_F "
            << hm_f << " "<<hm_f<<endl 
            <<"AM_F "
            << am_f << " "<<am_f<<endl 
            <<"GM_6+Biom "
            << gm_b << " "<<gm_b2<<endl 
            <<"Catch_assumed " 
            // << obs_catch(1,endyr)<<" "<<mean(obs_catch(1)(endyr-3,endyr)) <<endl
            << yr1_futcat <<" "<< yr2_futcat <<endl
            <<"ABC " 
            << gm_b  * hm_f * adj_1         << " " 
            << gm_b2 * hm_f * adj_1         << endl
            <<"OFL " 
            << gm_b  * am_f * adj_1         << " " 
            << gm_b2 * am_f * adj_2         << endl
            <<"SSB " 
            << SSB_1                        << " " 
            << SSB_2                        << endl
            <<"Applied_Adjustments " 
            <<                adj_1         << " " 
            <<                adj_2         << " " <<endl
            <<"Maturity_used "              <<endl
            << maturity(endyr)              <<" "<<endl
            << "wt "<<wt_pop_fut_f          <<endl ;
 */
  sdreport.close();
  // From AMAK 
 /* FUNCTION Oper_Model
 // Initialize things used here only
  // Calc_Dependent_Vars();
  int nsims;
  ifstream sim_in("nsims.dat");
  sim_in >> nsims; sim_in.close();
  dvector ran_srv_vect(1,nsrv);
  ofstream SaveOM("Om_Out.dat",ios::app);
  double C_tmp;
  dvariable Fnow;
  dvariable meanrec;
  meanrec=mean(recruits);
  dvector new_srv(1,nsrv);
  new_srv.initialize();
  dvariable mean5plus;
  mean5plus.initialize();
  for (i=1975;i<=1999;i++)
    mean5plus += natage(i)(5,nages)*wt_fsh(1,i)(5,nages);
  mean5plus /= 25.;
  system("cls"); cout<<"Number of replicates: "<<endl;
  // Initialize recruitment in first year
  nage_future(styr_fut,1) = meanrec;
  nage_future(styr_fut)(2,nages)              = ++elem_prod(natage(endyr)(1,nages-1),S(endyr)(1,nages-1));
  nage_future(styr_fut,nages)                += natage(endyr,nages)*S(endyr,nages);
  for (int isim=1;isim<=nsims;isim++)
  {
    cout<<isim<<" ";
    // Copy file to get mean for Mgt Strategies
    system("init_stuff.bat");
    for (i=styr_fut;i<=endyr_fut;i++)
    {
      // Some unit normals...
      ran_srv_vect.fill_randn(rng);
      // Create new survey observations
      for (k = 1 ; k<= nsrv ; k++)
        new_srv(k) = mfexp(ran_srv_vect(k)*.2)*value(nage_future(i)*q_srv(k)*sel_srv(k,endyr)); // use value function since converts to a double
      // Append new survey observation to datafile
      ofstream srv_out("NewSrv.dat",ios::app);
      srv_out <<i<<" "<< new_srv<<endl; srv_out.close();
      system("ComputeTAC.bat"); // commandline function to get TAC (catchnext.dat)
      // Now read in TAC (actual catch)
      ifstream CatchNext("CatchNext.dat");
      CatchNext >> C_tmp; CatchNext.close();
      Fnow = SolveF2(endyr,nage_future(i), C_tmp);
      F_future(1,i) = sel_fsh(1,endyr) * Fnow;
      Z_future(i)   = F_future(1,i) + natmort;
      S_future(i)   = mfexp(-Z_future(i));
      // nage_future(i,1)  = SRecruit( Sp_Biom_future(i-rec_age) ) * mfexp(rec_dev_future(i)) ;     
      nage_future(i,1)  = meanrec;
      Sp_Biom_future(i) = wt_mature * elem_prod(nage_future(i),pow(S_future(i),spmo_frac)) ;
      // Now graduate for the next year....
      if (i<endyr_fut)
      {
        nage_future(i+1)(2,nages) = ++elem_prod(nage_future(i)(1,nages-1),S_future(i)(1,nages-1));
        nage_future(i+1,nages)   += nage_future(i,nages)*S_future(i,nages);
      }
      catage_future(i) = 0.; 
      for (k = 1 ; k<= nfsh ; k++)
        catage_future(i) += elem_prod(nage_future(i) , elem_prod(F_future(k,i) , elem_div( ( 1.- S_future(i) ) , Z_future(i))));
      SaveOM << model_name       <<
        " "  << isim             <<
        " "  << i                <<
        " "  << Fnow             <<
        " "  << nage_future(i)(5,nages)*wt_fsh(1,endyr)(5,nages)/mean5plus <<
        " "  << nage_future(i)(5,nages)*wt_fsh(1,endyr)(5,nages)<<
        " "  << Sp_Biom_future(i)<<
        " "  << catage_future(i)*wt_fsh(1,endyr)<<
        " "  << nage_future(i)<<
        " "  << F_future(1,i)<<
      endl;
    }
  }
  SaveOM.close  init_int styr
  */
  WriteData( endyr_in);
  WriteData(nages);
  WriteData( a_lw_f);
  WriteData( b_lw_f);
  WriteData( a_lw_m);
  WriteData( b_lw_m);
  WriteData( nfsh  );                                      //Number of fisheries
  WriteData( obs_catch);
  WriteData( nyrs_fsh_age_c);
  WriteData( nyrs_fsh_age_s);
  WriteData( yrs_fsh_age_c);
  WriteData( yrs_fsh_age_s);
  WriteData( oac_fsh_c);
  WriteData( oac_fsh_s);
  WriteData( wt_fsh_in);
  WriteData( nsmpl_fsh_c);
  WriteData( nsmpl_fsh_s);
  WriteData( nsrv  );
  WriteData( nyrs_srv);
  WriteData( yrs_srv);
  WriteData( mo_srv);
  WriteData( obs_srv);
  WriteData( obs_se_srv);
  WriteData( nyrs_srv_age_c);
  WriteData( nyrs_srv_age_s);
  WriteData( yrs_srv_age_c);
  WriteData( yrs_srv_age_s);
  WriteData( nsmpl_srv_c);
  WriteData( nsmpl_srv_s);
  WriteData( oac_srv_c);
  WriteData( oac_srv_s);
  WriteData( wt_srv_f_in);
  WriteData( wt_srv_m_in);
  WriteData(  wt_pop_f_in); 
  WriteData(  wt_pop_m_in); 
  WriteData( maturity);
  WriteData( init_age_comp);
  WriteData( n_env_cov);
  WriteData( env_cov);
  WriteData( spawnmo);
  WriteData( srv_mo); 
  WriteData( n_wts);
  WriteData( growth_cov);
}

void model_parameters::Get_wt_age(void)
{
  incr_dev.initialize();
  if (active(yr_incr)||active(age_incr)||active(growth_alpha))
  {
    switch (Growth_Option)
    {
      case 0 : // Use constant time-invariant growth (from base growth parameters)
        // No need to do anything since they are initialized at these values...
      break;
      case 1 : // Use empirical (values in data file) mean wts at age
        // No need to do anything since they are initialized at these values...
      break;
      case 2 : // Use base growth values (not estimated) and deviations decomposed by year and age
      {
        // Do it once for all years then apply to each fishery and survey...
        // initialize survey "1" and first year of growth to mean
        Initial_wt();
        for (i=styr+1;i<=endyr;i++)
        {
          // Age component estimated from 5-15
          incr_dev(i)(5,nages-5)     = yr_incr(i) + age_incr;
          incr_dev(i)(nages-4,nages) = incr_dev(i,nages-5) ;
          incr_dev(i)(2,4) = incr_dev(i,5) ;
          wt_srv_f(1,i,1) = wt_srv_f(1,i-1,1);
          wt_srv_m(1,i,1) = wt_srv_m(1,i-1,1);
          wt_srv_f(1,i)(2,nages) = ++wt_srv_f(1,i-1)(1,nages-1) + elem_prod(base_incr_f,mfexp(incr_dev(i))) ;
          wt_srv_m(1,i)(2,nages) = ++wt_srv_m(1,i-1)(1,nages-1) + elem_prod(base_incr_m,mfexp(incr_dev(i))) ;
          wt_pop_f(i) = wt_srv_f(1,i);
          wt_pop_m(i) = wt_srv_m(1,i);
        }
        Get_Pred_wt();
      }
      break;
      case 3 : // Use base growth values (not estimated) and deviations as fn of temperature and // decomposed by year and age
      {
        Initial_wt();
        for (i=styr+1;i<=endyr;i++)
        {
          // Age component estimated from 5-15
          // if (i >=1982)
            incr_dev(i)(5,nages-5)     = growth_alpha * growth_cov(i) ; // + age_incr; vestigial
          // else 
          //   incr_dev(i)(5,nages-5)     = 0.;
          incr_dev(i)(nages-4,nages) = incr_dev(i,nages-5) ;
          incr_dev(i)(2,4) = incr_dev(i,5) ;
          wt_srv_f(1,i,1) = wt_srv_f(1,i-1,1);
          wt_srv_m(1,i,1) = wt_srv_m(1,i-1,1);
          wt_srv_f(1,i)(2,nages) = ++wt_srv_f(1,i-1)(1,nages-1) + elem_prod(base_incr_f,mfexp(incr_dev(i))) ;
          wt_srv_m(1,i)(2,nages) = ++wt_srv_m(1,i-1)(1,nages-1) + elem_prod(base_incr_m,mfexp(incr_dev(i))) ;
          wt_pop_f(i) = wt_srv_f(1,i);
          wt_pop_m(i) = wt_srv_m(1,i);
        }
        Get_Pred_wt();
      }
      break;
    }
  }
}

void model_parameters::Initial_wt(void)
{
  wt_srv_f(1,styr) = wt_vbg_f;
  wt_srv_m(1,styr) = wt_vbg_m;
  wt_pop_f(styr)   = wt_vbg_f;
  wt_pop_m(styr)   = wt_vbg_m;
}

void model_parameters::Get_Pred_wt(void)
{
  // Get predicted weights
  for (i=styr_wt;i<=endyr_wt;i++)
  {
    wt_pred_f(i) = wt_srv_f(1,i);   
    wt_pred_m(i) = wt_srv_m(1,i); 
  }
  // for other surveys set equal to survey 1...
  for (k=2;k<=nsrv;k++)
    for (i=styr;i<=endyr;i++)
    {
      wt_srv_f(k,i) = wt_srv_f(1,i) ;
      wt_srv_m(k,i) = wt_srv_m(1,i) ;
    }
  // set fisheries equal to surveys 
  for (k=1;k<=nfsh;k++)
    for (i=styr;i<=endyr;i++)
    {
      wt_fsh_f(k,i) = wt_srv_f(1,i) ;
      wt_fsh_m(k,i) = wt_srv_m(1,i) ;
    }
}

void model_parameters::Write_R_wts(void)
{
  R_report<<"$Yr"<<endl; for (i=styr;i<=endyr;i++) R_report<<i<<" "; R_report<<endl;
  R_report<<"$Yr_wt"<<endl; for (i=styr_wt;i<=endyr_wt;i++) R_report<<i<<" "; R_report<<endl;
  R_report<<"$wt_obs_f" <<endl;
  R_report<<  wt_obs_f  <<endl;
  R_report<<"$wt_pred_f"<<endl;
  R_report<<  wt_pred_f <<endl;
  R_report<<"$wt_obs_m" <<endl;
  R_report<<  wt_obs_m  <<endl;
  R_report<<"$wt_pred_m"<<endl;
  R_report<< wt_pred_m  <<endl;
  R_report<<"$wt_srv_f" <<endl;
  R_report<<  wt_srv_f  <<endl;
  R_report<<"$wt_srv_m" <<endl;
  R_report<<  wt_srv_m  <<endl;
  R_report<<"$wt_like"  <<endl;
  R_report <<  wt_like(1)<<endl;
  // Make a dataframe (long) with year, Population, report << "Estimated_sex_ratio Year Total Mature Age_7+"<< endl;
  // R_report<<"$sex_ratio"  <<endl;
  for (i=styr;i<=endyr;i++)
    report_sex_ratio << i << " Population "<< sum(natage_f(i))/sum(natage_f(i)+natage_m(i))<<endl;
  for (i=styr;i<=endyr;i++)
    report_sex_ratio << i << " Mature "<< 
     sum(elem_prod(maturity(i),natage_f(i)))/sum(elem_prod(maturity(i),natage_f(i)+natage_m(i)))<<endl;
  for (i=styr;i<=endyr;i++)
    report_sex_ratio << i << " Age_7_plus "<< 
     sum(natage_f(i)(7,nages))/sum(natage_f(i)(7,nages)+natage_m(i)(7,nages))<<endl;
  // init_3darray oac_fsh_s(1,nfsh,1,nyrs_fsh_age_s,1,2*nages)  //Fishery age compositions
	for (k=1;k<=nfsh;k++)
	{
    for (i=1;i<=nyrs_fsh_age_s(k);i++)
      report_sex_ratio << yrs_fsh_age_s(k,i) << " Fishery_obs "<< sum(oac_fsh_s(k,i)(1,nages)) /sum(oac_fsh_s(k,i)) << endl;
    for (i=1;i<=nyrs_fsh_age_s(k);i++)
      report_sex_ratio << yrs_fsh_age_s(k,i) << " Fishery_est "<< sum(eac_fsh_s(k,i)(1,nages)) /sum(eac_fsh_s(k,i)) << endl;
    for (i=1;i<=nyrs_srv_age_s(k);i++)
      report_sex_ratio << yrs_srv_age_s(k,i) << " Survey_est "<< sum(eac_srv_s(k,i)(1,nages)) /sum(eac_srv_s(k,i)) << endl;
    for (i=1;i<=nyrs_srv_age_s(k);i++)
      report_sex_ratio << yrs_srv_age_s(k,i) << " Survey_obs "<< sum(oac_srv_s(k,i)(1,nages)) /sum(oac_srv_s(k,i)) << endl;
	}
}

void model_parameters::Write_R(void)
{
  Write_R_wts();
  // R_report<<"$TotF"<<endl << Ftot<<endl;
  /* R_report<<"$TotBiom_NoFish"<<endl; for (i=styr;i<=endyr;i++) 
  {
    double lb=value(TotBiom_NoFish(i)/exp(2.*sqrt(log(1+square(TotBiom_NoFish.sd(i))/square(TotBiom_NoFish(i))))));
    double ub=value(TotBiom_NoFish(i)*exp(2.*sqrt(log(1+square(TotBiom_NoFish.sd(i))/square(TotBiom_NoFish(i))))));
    R_report<<i<<" "<<TotBiom_NoFish(i)<<" "<<TotBiom_NoFish.sd(i)<<" "<<lb<<" "<<ub<<endl;
  }
  R_report<<"$SSB_NoFishR"<<endl; for (i=styr;i<=endyr;i++) 
  {
    double lb=value(Sp_Biom_NoFishR(i)/exp(2.*sqrt(log(1+square(Sp_Biom_NoFishR.sd(i))/square(Sp_Biom_NoFishR(i))))));
    double ub=value(Sp_Biom_NoFishR(i)*exp(2.*sqrt(log(1+square(Sp_Biom_NoFishR.sd(i))/square(Sp_Biom_NoFishR(i))))));
    R_report<<i<<" "<<Sp_Biom_NoFishR(i)<<" "<<Sp_Biom_NoFishR.sd(i)<<" "<<lb<<" "<<ub<<endl;
  }
  */ 
  REPORT(nLogPosterior);
  REPORT(natmort_f);
  REPORT(natmort_m);
  REPORT(future_SSB);
  REPORT(future_TotBiom);
  REPORT(future_catch);
  REPORT(sel_srv_f);
  REPORT(sel_srv_m);
  REPORT(sel_fsh_f);
  REPORT(sel_fsh_m);
  R_report << "$survey_likelihood "         << endl << srv_like     << endl;
  R_report << "$catch_likelihood "          << endl << catch_like   << endl;
  R_report << "$age_likelihood_for_fishery" << endl << age_like_fsh << endl;
  R_report << "$age_likeihood_for_survey "  << endl << age_like_srv << endl;
  R_report << "$recruitment_likelilhood "   << endl << rec_like     << endl;
  R_report << "$selectivity_likelihood "    << endl << sel_like     << endl;
  R_report << "$q_Prior "                   << endl << q_prior      << endl;
  R_report << "$sigmaR_Prior "              << endl << sigmaR_prior << endl;
  R_report << "$m_Prior "                   << endl << m_prior      << endl;
  R_report << "$F_penalty"                  << endl << fpen         << endl;
  R_report << "$SPR_penalty"                << endl << sprpen       << endl;
  R_report << "$obj_fun"                    << endl << obj_fun      << endl;
  R_report<<"$Future_F"<<endl; 
	for (i=styr_fut;i<=endyr_fut;i++) 
  {
    double lb=value(future_Fs(i)/exp(2.*sqrt(log(1+square(future_Fs.sd(i))/square(future_Fs(i))))));
    double ub=value(future_Fs(i)*exp(2.*sqrt(log(1+square(future_Fs.sd(i))/square(future_Fs(i))))));
    R_report<<i<<" "<<future_Fs(i)<<" "<<future_Fs.sd(i)<<" "<<lb<<" "<<ub<<endl;
  }
  R_report<<"$SSB"<<endl; 
	for (i=styr;i<=endyr;i++) 
  {
    double lb=value(SSB(i)/exp(2.*sqrt(log(1+square(SSB.sd(i))/square(SSB(i))))));
    double ub=value(SSB(i)*exp(2.*sqrt(log(1+square(SSB.sd(i))/square(SSB(i))))));
    R_report<<i<<" "<<SSB(i)<<" "<<SSB.sd(i)<<" "<<lb<<" "<<ub<<endl;
  }
  R_report<<"$TotBiom"<<endl; 
  for (i=styr;i<=endyr;i++) 
  {
    double lb=value(TotBiom(i)/exp(2.*sqrt(log(1+square(TotBiom.sd(i))/square(TotBiom(i))))));
    double ub=value(TotBiom(i)*exp(2.*sqrt(log(1+square(TotBiom.sd(i))/square(TotBiom(i))))));
    R_report<<i<<" "<<TotBiom(i)<<" "<<TotBiom.sd(i)<<" "<<lb<<" "<<ub<<endl;
  }
  R_report<<"$yr_bts"<<endl;
  R_report<<yrs_srv(1)<<endl;
  R_report<<"$eb_bts"<<endl;
  double rmse=0.;
  for (int i=1;i<=nyrs_srv(1);i++)
  {
    R_report<<pred_srv(1,yrs_srv(1,i))<<endl;
    rmse += value(square(log(obs_srv(1,i)) - log(pred_srv(1,yrs_srv(1,i)))));
  }
  rmse = sqrt(rmse/nyrs_srv(1));
  R_report << "$rmse_srv"                   << endl << rmse         << endl;
  R_report<<"$ob_bts"<<endl;
  R_report<<obs_srv(1)<<endl;
  R_report<<"$sd_ob_bts"<<endl;
  R_report<<obs_se_srv(1)<<endl;
  R_report<<"$R"<<endl; for (i=styr;i<=endyr;i++) 
  {
    double lb=value(pred_rec(i)/exp(2.*sqrt(log(1+square(pred_rec.sd(i))/square(pred_rec(i))))));
    double ub=value(pred_rec(i)*exp(2.*sqrt(log(1+square(pred_rec.sd(i))/square(pred_rec(i))))));
    R_report<<i<<" "<<pred_rec(i)<<" "<<pred_rec.sd(i)<<" "<<lb<<" "<<ub<<endl;
  }
  int k=1;
  R_report<<"$q"<<endl; for (i=1982;i<=endyr;i++) 
  {
    double lb=value(q_srv(k,i)/exp(2.*sqrt(log(1+square(q_srv.sd(k,i))/square(q_srv(k,i))))));
    double ub=value(q_srv(k,i)*exp(2.*sqrt(log(1+square(q_srv.sd(k,i))/square(q_srv(k,i))))));
    R_report<<i<<" "<<q_srv(k,i)<<" "<<q_srv.sd(k,i)<<" "<<lb<<" "<<ub<<endl;
  }
  for (k=1;k<=nsrv;k++)
  {
    R_report << endl<< "$yrs_srv"<<endl;
    R_report << yrs_srv(k) << endl;
    R_report << "$q_srv"<<endl;
    for (i=1;i<=nyrs_srv(k);i++)
      R_report<< q_srv(k,yrs_srv(k,i)) <<" ";
	  R_report<< endl;
	}
  /* 
  for (int k=1;k<=5;k++){
    R_report<<"$SSB_fut_"<<k<<endl; 
    for (i=styr_fut;i<=endyr_fut;i++) 
    {
      double lb=value(future_biomass(k,i)/exp(2.*sqrt(log(1+square(future_biomass.sd(k,i))/square(future_biomass(k,i))))));
      double ub=value(future_biomass(k,i)*exp(2.*sqrt(log(1+square(future_biomass.sd(k,i))/square(future_biomass(k,i))))));
      R_report<<i<<" "<<future_biomass(k,i)<<" "<<future_biomass.sd(k,i)<<" "<<lb<<" "<<ub<<endl;
    }
  }
  double ctmp;
  for (int k=1;k<=5;k++){
    R_report<<"$Catch_fut_"<<k<<endl; 
    for (i=styr_fut;i<=endyr_fut;i++) 
    {
      if (k==5) ctmp=0.;else ctmp=value(future_catch(k,i));
      R_report<<i<<" "<<ctmp<<endl;
    }
  }
    R_report << "$N"<<endl;
    for (i=styr;i<=endyr;i++) 
      R_report <<   i << " "<< natage(i) << endl;
      R_report   << endl;
    for (int k=1;k<=nfsh;k++)
    {
      R_report << "$F_age_"<< (k) <<""<< endl ;
      for (i=styr;i<=endyr;i++) 
        R_report <<i<<" "<<F(k,i)<<" "<< endl;
        R_report   << endl;
    }
    R_report <<endl<< "$Fshry_names"<< endl;
    for (int k=1;k<=nfsh;k++)
      R_report << fshname(k) << endl ;
    R_report <<endl<< "$Index_names"<< endl;
    for (int k=1;k<=nsrv;k++)
      R_report << srvname(k) << endl ;
    for (int k=1;k<=nsrv;k++)
    {
      int ii=1;
      R_report <<endl<< "$Obs_Survey_"<< k <<""<< endl ;
      for (i=styr;i<=endyr;i++)
      {
        if (ii<=yrs_srv(k).indexmax())
        {
          if (yrs_srv(k,ii)==i)
          {
            R_report << i<< " "<< obs_srv(k,ii) << " "<< pred_srv(k,i) <<" "<< obs_se_srv(k,ii) <<endl; //values of survey index value (annual)
            ii++;
          }
          else
            R_report << i<< " -1 "<< " "<< pred_srv(k,i)<<" -1 "<<endl;
        }
        else
          R_report << i<< " -1 "<< " "<< pred_srv(k,i)<<" -1 "<<endl;
      }
      R_report   << endl;
    }
    R_report   << endl;
    for (int k=1;k<=nfsh;k++)
    {
      if (nyrs_fsh_age(k)>0) 
      { 
        R_report << "$pobs_fsh_"<< (k) <<""<< endl;
        for (i=1;i<=nyrs_fsh_age(k);i++) 
          R_report << yrs_fsh_age(k,i)<< " "<< oac_fsh(k,i) << endl;
        R_report   << endl;
      }
    }
    for (int k=1;k<=nfsh;k++)
    {
      if (nyrs_fsh_age(k)>0) 
      { 
        R_report << "$phat_fsh_"<< (k) <<""<< endl;
        for (i=1;i<=nyrs_fsh_age(k);i++) 
          R_report << yrs_fsh_age(k,i)<< " "<< eac_fsh(k,i) << endl;
          R_report   << endl;
      }
    }
    for (int k=1;k<=nsrv;k++)
    {
      if (nyrs_srv_age(k)>0) 
      { 
        R_report << "$pobs_srv_"<<(k)<<""<<  endl;
        for (i=1;i<=nyrs_srv_age(k);i++) 
          R_report << yrs_srv_age(k,i)<< " "<< oac_srv(k,i) << endl;
          R_report   << endl;
      }
    }
    for (int k=1;k<=nsrv;k++)
    {
      if (nyrs_srv_age(k)>0) 
      { 
        R_report << "$phat_srv_"<<(k)<<""<<  endl;
        for (i=1;i<=nyrs_srv_age(k);i++) 
          R_report << yrs_srv_age(k,i)<< " "<< eac_srv(k,i) << endl;
          R_report   << endl;
      }
    }
    for (int k=1;k<=nfsh;k++)
    {
      R_report << endl<< "$Obs_catch_"<<(k) << endl;
      R_report << obs_catch(k)(styr,endyr)<< endl;
      R_report   << endl;
      R_report << "$Pred_catch_" <<(k) << endl;
      R_report << pred_catch(k) << endl;
      R_report   << endl;
    }
    for (int k=1;k<=nfsh;k++)
    {
      R_report << "$F_fsh_"<<(k)<<" "<<endl;
      for (i=styr;i<=endyr;i++)
      {
        R_report<< i<< " ";
        R_report<< mean(F(k,i)) <<" "<< mean(F(k,i))*max(sel_fsh(k,i)) << " ";
        R_report<< endl;
      }
    }
    for (int k=1;k<=nfsh;k++)
    {
      R_report << endl<< "$sel_fsh_"<<(k)<<"" << endl;
      for (i=styr;i<=endyr;i++)
        R_report << k <<"  "<< i<<" "<<sel_fsh(k,i) << endl; 
      R_report   << endl;
    }
    for (int k=1;k<=nsrv;k++)
    {
      R_report << endl<< "$sel_srv_"<<(k)<<"" << endl;
      for (i=styr;i<=endyr;i++)
        R_report << k <<"  "<< i<<" "<<sel_srv(k,i) << endl;
        R_report << endl;
    }
    R_report << endl<< "$Stock_Rec"<< endl;
    for (i=styr_rec;i<=endyr;i++)
      if (active(log_Rzero))
        R_report << i<< " "<<Sp_Biom(i-rec_age)<< " "<< SRecruit(Sp_Biom(i-rec_age))<< " "<< mod_rec(i)<<endl;
      else 
        R_report << i<< " "<<Sp_Biom(i-rec_age)<< " "<< " 999" << " "<< mod_rec(i)<<endl;
        R_report   << endl;
    R_report <<"$stock_Rec_Curve"<<endl;
    R_report <<"0 0"<<endl;
    dvariable stock;
    for (i=1;i<=30;i++)
    {
      stock = double (i) * Bzero /25.;
      if (active(log_Rzero))
        R_report << stock <<" "<< SRecruit(stock)<<endl;
      else
        R_report << stock <<" 99 "<<endl;
    }
    R_report   << endl;
    R_report   << endl<<"$Like_Comp" <<endl;
    obj_comps(11)= obj_fun - sum(obj_comps) ; // Residual
    obj_comps(12)= obj_fun ;
    R_report   <<obj_comps<<endl;
    R_report   << endl;
    R_report   << endl<<"$Like_Comp_names" <<endl;
    R_report   <<"catch_like     "<<endl
             <<"age_like_fsh     "<<endl
             <<"sel_like_fsh     "<<endl
             <<"surv_like        "<<endl
             <<"age_like_srv     "<<endl
             <<"sel_like_srv     "<<endl
             <<"rec_like         "<<endl
             <<"fpen             "<<endl
             <<"post_priors_srvq "<<endl
             <<"post_priors      "<<endl
             <<"residual         "<<endl
             <<"total            "<<endl;
    for (int k=1;k<=nfsh;k++)
    {
      R_report << "$Sel_Fshry_"<< (k) <<""<<endl;
      R_report << sel_like_fsh(k) << endl;
    }
    R_report   << endl;
    for (int k=1;k<=nsrv;k++)
    {
      R_report << "$Survey_Index_"<< (k) <<"" <<endl;
      R_report<< surv_like(k)<<endl;
    }
    R_report   << endl;
    R_report << setw(10)<< setfixed() << setprecision(5) <<endl;
    for (int k=1;k<=nsrv;k++)
    {
      R_report << "$Age_Survey_"<< (k) <<"" <<endl;
      R_report << age_like_srv(k)<<endl;
    }
    R_report   << endl;
    for (int k=1;k<=nsrv;k++)
    {
      R_report << "$Sel_Survey_"<< (k) <<""<<endl;
      R_report<< sel_like_srv(k,1) <<" "<<sel_like_srv(k,2)<<" "<<sel_like_srv(k,3)<< endl;
    }
    R_report   << endl;
    R_report << setw(10)<< setfixed() << setprecision(5) <<endl;
    R_report   << "$Rec_Pen" <<endl<<sigmaR<<"  "<<rec_like<<endl;
    R_report   << endl;
    R_report   << "$F_Pen" <<endl;
    R_report<<fpen(1)<<"  "<<fpen(2)<<endl;
    R_report   << endl;
    for (int k=1;k<=nsrv;k++)
    {
      R_report << "$Q_Survey_"<< (k) <<""<<endl
             << " "<<post_priors_srvq(k)
             << " "<< q_srv(k)
             << " "<< qprior(k)
             << " "<< cvqprior(k)<<endl;
      R_report << "$Q_power_Survey_"<< (k) <<""<<endl
             << " "<<post_priors_srvq(k)
             << " "<< q_power_srv(k)
             << " "<< q_power_prior(k)
             << " "<< cvq_power_prior(k)<<endl;
    }
             R_report   << endl;
    R_report << "$M"<<endl;
    R_report << " "<< post_priors(1)
             << " "<< M
             << " "<< natmortprior
             << " "<< cvnatmortprior <<endl;
    R_report   << endl;
    R_report << "$Steep"<<endl;
    R_report << " "<< post_priors(2)
             << " "<< steepness
             << " "<< steepnessprior
             << " "<< cvsteepnessprior <<endl;
    R_report   << endl;
    R_report << "$Sigmar"<<endl;
    R_report << " "<< post_priors(3)
             << " "<< sigmaR
             << " "<< sigmaRprior
             << " "<< cvsigmaRprior <<endl;
    R_report   << endl;
    R_report<<"$Num_parameters_Est"<<endl;
    R_report<<initial_params::nvarcalc()<<endl;
    R_report   << endl;
  R_report<<"$Steep_Prior" <<endl;
  R_report<<steepnessprior<<" "<<
    cvsteepnessprior<<" "<<
    phase_srec<<" "<< endl;
    R_report   << endl;
  R_report<<"$sigmaRPrior " <<endl;
  R_report<<sigmaRprior<<" "<<  cvsigmaRprior <<" "<<phase_sigmaR<<endl;
  R_report   << endl;
  R_report<<"$Rec_estimated_in_styr_endyr " <<endl;
  R_report<<styr_rec    <<" "<<endyr        <<" "<<endl;
  R_report   << endl;
  R_report<<"$SR_Curve_fit__in_styr_endyr " <<endl;
  R_report<<styr_rec_est<<" "<<endyr_rec_est<<" "<<endl;
  R_report   << endl;
  R_report<<"$Model_styr_endyr" <<endl;
  R_report<<styr        <<" "<<endyr        <<" "<<endl;
  R_report   << endl;
  R_report<<"$M_prior "<<endl;
  R_report<< natmortprior<< " "<< cvnatmortprior<<" "<<phase_M<<endl;
  R_report   << endl;
  R_report<<"$qprior " <<endl;
  R_report<< qprior<<" "<<cvqprior<<" "<< phase_q<<endl;
  R_report<<"$q_power_prior " <<endl;
  R_report<< q_power_prior<<" "<<cvq_power_prior<<" "<< phase_q_power<<endl;
  R_report   << endl;
  R_report<<"$cv_catchbiomass " <<endl;
  R_report<<cv_catchbiomass<<" "<<endl;
  R_report   << endl;
  R_report<<"$Projection_years"<<endl;
  R_report<< nproj_yrs<<endl;
  R_report   << endl;
  R_report << "$Fsh_sel_opt_fish "<<endl;
  for (int k=1;k<=nfsh;k++)
    R_report<<k<<" "<<fsh_sel_opt(k)<<" "<<sel_change_in_fsh(k)<<endl;
    R_report   << endl;
   R_report<<"$Survey_Sel_Opt_Survey " <<endl;
  for (int k=1;k<=nsrv;k++)
  R_report<<k<<" "<<(srv_sel_opt(k))<<endl;
  R_report   << endl;
  R_report <<"$Phase_survey_Sel_Coffs "<<endl;
  R_report <<phase_selcoff_srv<<endl;
  R_report   << endl;
  R_report <<"$Fshry_Selages " << endl;
  R_report << nselages_in_fsh  <<endl;
  R_report   << endl;
  R_report <<"$Survy_Selages " <<endl;
  R_report <<nselages_in_srv <<endl;
  R_report   << endl;
  R_report << "$Phase_for_age_spec_fishery"<<endl;
  R_report <<phase_selcoff_fsh<<endl;
  R_report   << endl;
  R_report << "$Phase_for_logistic_fishery"<<endl;
  R_report <<phase_logist_fsh<<endl;
  R_report   << endl;
  R_report << "$Phase_for_dble_logistic_fishery "<<endl;
  R_report <<phase_dlogist_fsh<<endl;
  R_report   << endl;
  R_report << "$Phase_for_age_spec_survey  "<<endl;
  R_report <<phase_selcoff_srv<<endl;
  R_report   << endl;
  R_report << "$Phase_for_logistic_survey  "<<endl;
  R_report <<phase_logist_srv<<endl;
  R_report   << endl;
  R_report << "$Phase_for_dble_logistic_srvy "<<endl;
  R_report <<phase_dlogist_srv<<endl;
  R_report   << endl;
  for (int k=1;k<=nfsh;k++)
  {
    if (nyrs_fsh_age(k)>0)
    {
      R_report <<"$EffN_Fsh_"<<(k)<<""<<endl;
      for (i=1;i<=nyrs_fsh_age(k);i++)
      {
        double sda_tmp = Sd_age(oac_fsh(k,i));
        R_report << yrs_fsh_age(k,i);
        R_report<< " "<<Eff_N(oac_fsh(k,i),eac_fsh(k,i)) ;
        R_report << " "<<Eff_N2(oac_fsh(k,i),eac_fsh(k,i));
        R_report << " "<<mn_age(oac_fsh(k,i));
        R_report << " "<<mn_age(eac_fsh(k,i));
        R_report << " "<<sda_tmp;
        R_report << " "<<mn_age(oac_fsh(k,i)) - sda_tmp *2. / sqrt(n_sample_fsh_age(k,i));
        R_report << " "<<mn_age(oac_fsh(k,i)) + sda_tmp *2. / sqrt(n_sample_fsh_age(k,i));
        R_report <<endl;
      }
    }
  }
  for (int k=1;k<=nfsh;k++)
  {
    R_report <<"$C_fsh_" <<(k)<<"" << endl; 
    for (i=styr;i<=endyr;i++)
      R_report <<i<<" "<<catage(k,i)<< endl;
  }
  R_report <<"$wt_a_pop" << endl<< wt_pop  <<endl;
  R_report <<"$mature_a" << endl<< maturity<<endl;
  for (int k=1;k<=nfsh;k++)
  {
    R_report <<"$wt_fsh_"<<(k)<<""<<endl;
    for (i=styr;i<=endyr;i++)
      R_report <<i<<" "<<wt_fsh(k,i)<< endl;
  }
  for (int k=1;k<=nsrv;k++)
  {
    R_report <<"$wt_srv_"<<(k)<<""<<endl;
    for (i=styr;i<=endyr;i++)
      R_report <<i<<" "<<wt_srv(k,i)<< endl;
  }
  for (int k=1;k<=nsrv;k++)
  {
    if (nyrs_srv_age(k)>0)
    {
      R_report <<"$EffN_Survey_"<<(k)<<""<<endl;
      for (i=1;i<=nyrs_srv_age(k);i++)
      {
        double sda_tmp = Sd_age(oac_srv(k,i));
        R_report << yrs_srv_age(k,i)
                << " "<<Eff_N(oac_srv(k,i),eac_srv(k,i)) 
                 << " "<<Eff_N2(oac_srv(k,i),eac_srv(k,i))
                 << " "<<mn_age(oac_srv(k,i))
                 << " "<<mn_age(eac_srv(k,i))
                 << " "<<sda_tmp
                 << " "<<mn_age(oac_srv(k,i)) - sda_tmp *2. / sqrt(n_sample_srv_age(k,i))
                 << " "<<mn_age(oac_srv(k,i)) + sda_tmp *2. / sqrt(n_sample_srv_age(k,i))
                 <<endl;
      }
    }
  }
  */ 
  R_report.close();
}

void model_parameters::final_calcs()
{
  if (!do_wt_only)
  {
    write_srec();
    REPORT(SRR_SSB);
    REPORT(future_ABC);
    REPORT(rechat);
    REPORT(rechat.sd);
    // REPORT(future_spr0);
    // REPORT(future_spr0.sd);
    Write_sd();
    Write_R();
  }
  else
    Write_R_wts();
  /*
		*/
}

model_data::~model_data()
{}

model_parameters::~model_parameters()
{}

#ifdef _BORLANDC_
  extern unsigned _stklen=10000U;
#endif


#ifdef __ZTC__
  extern unsigned int _stack=10000U;
#endif

  long int arrmblsize=0;

int main(int argc,char * argv[])
{
    ad_set_new_handler();
  ad_exit=&ad_boundf;
  gradient_structure::set_MAX_NVAR_OFFSET(1600);
  gradient_structure::set_GRADSTACK_BUFFER_SIZE(200000);
  gradient_structure::set_NUM_DEPENDENT_VARIABLES(1800); 
  gradient_structure::set_CMPDIF_BUFFER_SIZE(2000000);
  arrmblsize=10000000;
    gradient_structure::set_NO_DERIVATIVES();
#ifdef DEBUG
  #ifndef __SUNPRO_C
std::feclearexcept(FE_ALL_EXCEPT);
  #endif
  auto start = std::chrono::high_resolution_clock::now();
#endif
    gradient_structure::set_YES_SAVE_VARIABLES_VALUES();
    if (!arrmblsize) arrmblsize=15000000;
    model_parameters mp(arrmblsize,argc,argv);
    mp.iprint=10;
    mp.preliminary_calculations();
    mp.computations(argc,argv);
#ifdef DEBUG
  std::cout << endl << argv[0] << " elapsed time is " << std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::high_resolution_clock::now() - start).count() << " microseconds." << endl;
  #ifndef __SUNPRO_C
bool failedtest = false;
if (std::fetestexcept(FE_DIVBYZERO))
  { cerr << "Error: Detected division by zero." << endl; failedtest = true; }
if (std::fetestexcept(FE_INVALID))
  { cerr << "Error: Detected invalid argument." << endl; failedtest = true; }
if (std::fetestexcept(FE_OVERFLOW))
  { cerr << "Error: Detected overflow." << endl; failedtest = true; }
if (std::fetestexcept(FE_UNDERFLOW))
  { cerr << "Error: Detected underflow." << endl; }
if (failedtest) { std::abort(); } 
  #endif
#endif
    return 0;
}

extern "C"  {
  void ad_boundf(int i)
  {
    /* so we can stop here */
    exit(i);
  }
}