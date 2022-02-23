#include <RcppArmadillo.h>
// #include <Rcpp.h>

  // [[Rcpp::depends(RcppArmadillo)]]

using namespace Rcpp;
using namespace arma;

// ==============================================================================================

NumericMatrix CalcWcatch(List BasicData, List BasicPars, List RunOptions, NumericMatrix EnvironmentalData, NumericMatrix WcatchInput, int year) {

  // Local variables
  int Nsex, Amax, Nage;
  int WeightOpt, NenvLinks;
  double EnvironEffect;

  // How many environmental links
  WeightOpt = as<int>(RunOptions["WeightOpt"]);             // 0=Pre-specified; 1=related to growth increment; 2=with environmental link
  NenvLinks = as<int>(RunOptions["NenvLinks"]);             // how many linklinks

  // Extract
  Nsex = as<int>(BasicData["Nsex"]);
  Amax = as<int>(BasicData["Amax"]);
  Nage = Amax-1;                                            // Easy to work with

  NumericMatrix Wcatch(Nsex,Amax);
  NumericVector Linf(Nsex);
  NumericVector Kappa(Nsex);
  NumericVector T0(Nsex);
  NumericVector aa(Nsex);
  NumericVector bb(Nsex);
  NumericMatrix Wref(Nsex,Amax);

  Linf = as<NumericVector>(BasicData["Linf"]);
  Kappa = as<NumericVector>(BasicData["Kappa"]);
  T0 = as<NumericVector>(BasicData["T0"]);
  aa = as<NumericVector>(BasicData["aa"]);
  bb = as<NumericVector>(BasicData["bb"]);

  NumericVector EnvPars(NenvLinks);
  EnvPars = as<NumericVector>(BasicPars["EnvPars"]);

  IntegerMatrix EnvLinks(NenvLinks,3);
  EnvLinks = as<IntegerMatrix>(RunOptions["EnvLinks"]);               // links

  if (WeightOpt==0)
   { Wcatch = WcatchInput; }
  if (WeightOpt==1)
   {
    for (int Isex=0;Isex<Nsex;Isex++)
     for (int Iage=0;Iage<=Nage;Iage++)
       Wref(Isex,Iage) = aa(Isex)*pow(Linf(Isex)*(1.0-exp(-Kappa(Isex)*(float(Iage+1)-T0(Isex)))),bb(Isex))/1000;
    Wcatch = Wref;
   }
  if (WeightOpt==2)
   {
    for (int Isex=0;Isex<Nsex;Isex++)
     for (int Iage=0;Iage<=Nage;Iage++)
      Wref(Isex,Iage) = aa(Isex)*pow(Linf(Isex)*(1.0-exp(-Kappa(Isex)*(float(Iage+1)-T0(Isex)))),bb(Isex))/1000;
    for (int Isex=0;Isex<Nsex;Isex++)
     {
      EnvironEffect = 1;
      for (int Ilink=0;Ilink<NenvLinks;Ilink++)
       if (EnvLinks(Ilink,0)==3) EnvironEffect *=  exp(EnvironmentalData(year,EnvLinks(Ilink,1))*EnvPars(Ilink));
      Wcatch(Isex,0) = Wref(Isex,0);
     for (int Iage=Nage;Iage>=1;Iage--)
      Wcatch(Isex,Iage) = WcatchInput(Isex,Iage-1) + (Wref(Isex,Iage)-Wref(Isex,Iage-1))*EnvironEffect;
     }
   }
  //std::cout << Wcatch << std::endl;

  return Wcatch;

}

// ==============================================================================================

double GetRecruit(List BasicPars, List RunOptions, NumericMatrix EnvironmentalData, NumericVector SSB, double SSB0, int year) {

  // Local variables
  double Recruit, Top,Bot, R0, Steepness, SSBuse;
  int SROpt, NenvLinks;

  // Stock-recruitment relationship and how many environmental links
  SROpt = as<int>(RunOptions["SROpt"]);                              // 0=Constant; 1=BH; 1=Ricker;
  NenvLinks = as<int>(RunOptions["NenvLinks"]);                          // how many linklinks

  // Extract parameters
  R0 = as<double>(BasicPars["R0"]);
  Steepness = as<double>(BasicPars["Steep"]);
  NumericVector EnvPars(NenvLinks);
  EnvPars = as<NumericVector>(BasicPars["EnvPars"]);

  IntegerMatrix EnvLinks(NenvLinks,3);
  EnvLinks = as<IntegerMatrix>(RunOptions["EnvLinks"]);               // links
  Recruit = 0;

  // Specify SSB to use
  SSBuse = SSB(year);
  // Check for before density dependence environmental links
  for (int Ilink=0;Ilink<NenvLinks;Ilink++)
   if (EnvLinks(Ilink,0)==1) SSBuse *= exp(EnvironmentalData(year,EnvLinks(Ilink,1))*EnvPars(Ilink));

    // Constant recruitment
  if (SROpt==0) Recruit = R0;

  // Beverton-Holt recruitment
  if (SROpt==1)
   {
    Top = 4.0 * Steepness * R0* SSBuse/SSB0;
    Bot = (1-Steepness) + (5*Steepness-1)*SSBuse/SSB0;
    Recruit = Top/Bot;
   }

  // Ricker recruitment
  if (SROpt==2)
   {
    Top = log(5.0*Steepness)/0.8*(1.0-SSBuse/SSB0);
    Recruit = R0*SSBuse/SSB0*exp(Top);
   }

  // Check for before density dependence environmental links
  for (int Ilink=0;Ilink<NenvLinks;Ilink++)
   if (EnvLinks(Ilink,0)==2) Recruit *= exp(EnvironmentalData(year,EnvLinks(Ilink,1))*EnvPars(Ilink));

  return Recruit;

}

// ==============================================================================================

// [[Rcpp::export]]
double SPR(List BasicData, double F)
{
  // Local variables
  int Nsex, Amax, Nage;
  double spr,spawnfrac;

  // Extract
  Nsex = as<int>(BasicData["Nsex"]);
  Amax = as<int>(BasicData["Amax"]);
  Nage = Amax-1;                                            // Easy to work with
  spawnfrac = as<double>(BasicData["spawnfrac"]);

  // Define the Matrices
  NumericVector Neqn(Amax);
  NumericMatrix Mbase(Nsex,Amax);
  NumericMatrix Sel(Nsex,Amax);
  NumericMatrix Wpristine(Nsex,Amax);
  NumericVector Matur(Amax);

  // Extract material from BasicData (Wpristine is the starting W)
  Mbase = as<NumericMatrix>(BasicData["M"]);
  Wpristine = as<NumericMatrix>(BasicData["Wpristine"]);
  Matur = as<NumericVector>(BasicData["Matur"]);
  Sel = as<NumericMatrix>(BasicData["Sel"]);

  Neqn(0) = 1/float(Nsex);
  for (int Iage=1;Iage<=Nage;Iage++) Neqn(Iage) = Neqn(Iage-1)*exp(-Mbase(0,Iage-1)-F*Sel(0,Iage-1));
  Neqn(Nage) = Neqn(Nage)/(1.0-exp(-Mbase(0,Nage)-F*Sel(0,Nage)));
  spr = 0; for (int Iage=1;Iage<=Nage;Iage++) spr += Neqn(Iage)*Matur(Iage)*Wpristine(0,Iage)*exp(-spawnfrac*Mbase(0,Iage));

  return spr;

}

// ==============================================================================================


// Projection component
// [[Rcpp::export]]
List Project(List BasicData, List BasicPars, List RunOptions, NumericMatrix EnvironmentalData, int Nyear, double FullF) {

  // Local variables
  int Nsex, Amax, Nage;
  double SSB0, R0, Recruit, SigmaR, ExploitRate, spr, spawnfrac;
  double Error;                                   // Temp variables

  // Extract
  Nsex = as<int>(BasicData["Nsex"]);
  Amax = as<int>(BasicData["Amax"]);
  Nage = Amax-1;                                            // Easy to work with
  spawnfrac = as<double>(BasicData["spawnfrac"]);

  // Define the Matrices
  Cube<double> N(Nsex,Amax,Nyear+1);
  Cube<double> Z(Nsex,Amax,Nyear);
  Cube<double> F(Nsex,Amax,Nyear);
  Cube<double> M(Nsex,Amax,Nyear);
  NumericMatrix Wcatch(Nsex,Amax);
  NumericMatrix Sel(Nsex,Amax);
  NumericVector Matur(Amax);
  NumericVector SSB(Nyear);
  NumericVector Neqn(Amax);
  NumericMatrix Mbase(Nsex,Amax);
  NumericVector Catch(Nyear);
  NumericMatrix Ninit(Nsex,Amax);

  // Create a 4D Array
  arma::field<arma::cube> nonstandard_4d_array(5);

  // Fill it with cubes
  nonstandard_4d_array.fill(arma::ones<arma::cube>(2, 3, 4));

  // Extract material from BasicData (Wcatch is the starting W)
  Mbase = as<NumericMatrix>(BasicData["M"]);
  Wcatch = as<NumericMatrix>(BasicData["Wcatch"]);
  Matur = as<NumericVector>(BasicData["Matur"]);
  Sel = as<NumericMatrix>(BasicData["Sel"]);
  Ninit = as<NumericMatrix>(BasicData["Ninit"]);

  // Key parameters
  R0 = as<double>(BasicPars["R0"]);                                   // Nsex is both sexes
  SigmaR = as<double>(BasicPars["SigmaR"]);

  // Initialize the N matrix
  for (int Isex=0;Isex<Nsex;Isex++)
   for (int Iage=0;Iage<=Nage;Iage++)
    N(Isex,Iage,0) = Ninit(Isex,Iage);

  // Set up the unfished SSB
  spr = SPR(BasicData, 0.0);
  SSB0 = R0*spr;
  std::cout << "SSB0 " << spr << " " << R0 << " " << SSB0 << std::endl;

  for (int Iyear=0;Iyear<Nyear;Iyear++)
   {
    // Calculate Weight-at-age
    Wcatch = CalcWcatch(BasicData,BasicPars, RunOptions, EnvironmentalData, Wcatch, Iyear);

    // Calculate F and Z
    for (int Isex=0;Isex<Nsex;Isex++)
     for (int Iage=0;Iage<=Nage;Iage++)
      {
	   M(Isex,Iage,Iyear) = Mbase(Isex,Iage);
	   F(Isex,Iage,Iyear) = FullF*Sel(Isex,Iage);
	   Z(Isex,Iage,Iyear) = M(Isex,Iage,Iyear) + F(Isex,Iage,Iyear);
	  }

    // SSB
    SSB(Iyear) = 0; for (int Iage=0;Iage<=Nage;Iage++) SSB(Iyear) += N(0,Iage,Iyear)*Matur(Iage)*Wcatch(0,Iage)*exp(-spawnfrac*Z(0,Iage,Iyear));

    // Calculate the catch
    Catch(Iyear) = 0;
    for (int Isex=0;Isex<Nsex;Isex++)
     for (int Iage=0;Iage<=Nage;Iage++)
      {
	   ExploitRate = F(Isex,Iage,Iyear)/Z(Isex,Iage,Iyear)*(1.0-exp(-Z(Isex,Iage,Iyear)));
	   Catch(Iyear) += Wcatch(Isex,Iage)*N(Isex,Iage,Iyear)*ExploitRate;
      }

    // Update dynamics
    for (int Isex=0;Isex<Nsex;Isex++)
     {
      for (int Iage=1;Iage<Nage;Iage++)
        N(Isex,Iage,Iyear+1) = N(Isex,Iage-1,Iyear)*exp(-Z(Isex,Iage-1,Iyear));
      N(Isex,Nage,Iyear+1) = N(Isex,Nage-1,Iyear)*exp(-Z(Isex,Nage-1,Iyear)) +  N(Isex,Nage,Iyear)*exp(-Z(Isex,Nage,Iyear));
     }

    // Now generate recruitment (BH)
    Recruit = GetRecruit(BasicPars,RunOptions,EnvironmentalData,SSB,SSB0,Iyear);
    Error = as<double>(rnorm(1,0,SigmaR))-SigmaR*SigmaR/2.0;
    Recruit = Recruit*exp(Error)/float(Nsex);

    // Age zero recruits
    for (int Isex=0;Isex<Nsex;Isex++) N(Isex,0,Iyear+1) = Recruit;

   } // Year loop

  return List::create( _["N"]=N, _["SSB"]=SSB, _["Neqn"]=Neqn, _["SSB0"]=SSB0, _["Catch"]=Catch);

}

// ================================================================================================


