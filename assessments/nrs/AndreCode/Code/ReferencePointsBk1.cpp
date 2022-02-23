#include <Rcpp.h>

using namespace Rcpp;

//' @title yprC calculates the YPR and SPR for an input Fully selected F (internal routine; Tier 2)
//'
//' @description yprC calculates the the yield-per-recruit and spawning
//'     potential ratio for a particular input fully selected instantaneous
//'     fishing mortality. In all cases where there are two sexes females are in
//'     column 0 (the first column). This is implemented in C++ for speed.
//'
//' @param FF is a fully-selected instantaneous fishing mortality
//' @param BasicData is List with all the key parameters
//' @return a list containing the numbers-at-age, the spawning biomass-per-recruit, and the yield-per-recruit, in that order
//' @export
// [[Rcpp::export]]
List yprC(List BasicData, double FF) {

   // Local variables
   int Nsex, Amax, Nage;
   double spawnfrac;

   // Extract
   Nsex = as<int>(BasicData["Nsex"]);
   Amax = as<int>(BasicData["Amax"]);
   Nage = Amax-1;                                            // Easy to work with
   spawnfrac = as<double>(BasicData["spawnfrac"]);

   NumericMatrix M(Nsex,Amax);
   NumericMatrix Sel(Nsex,Amax);
   NumericMatrix Wcatch(Nsex,Amax);
   NumericVector Matur(Amax);
   M = as<NumericMatrix>(BasicData["M"]);
   Wcatch = as<NumericMatrix>(BasicData["Wcatch"]);
   Matur = as<NumericVector>(BasicData["Matur"]);
   Sel = as<NumericMatrix>(BasicData["Sel"]);

   NumericMatrix N(Nsex,Amax);
   NumericMatrix Z(Nsex,Amax);
   NumericMatrix FA(Nsex,Amax);
   double YPR;
   double SPR;
   double CA;

   // Find F and Z
   for (int Isex=0; Isex < Nsex; Isex++)
      for (int Iage=0; Iage <=Nage; Iage++) {
         FA(Isex,Iage) = Sel(Isex,Iage)*FF;
         Z(Isex,Iage) = FA(Isex,Iage) + M(Isex,Iage);
   }

   // Specify the N matrix (includes a plus-group)
   for (int Isex=0; Isex < Nsex; Isex++) {
      N(Isex,0) = 1.0/float(Nsex);
      for (int Iage=1; Iage < Amax; Iage++) N(Isex,Iage) = N(Isex,Iage-1) * exp(-Z(Isex,Iage-1));
      N(Isex,Amax-1) = N(Isex,Amax-1) / (1.0 - exp(-Z(Isex,Amax-1)));
   }

   // Calculate YPR
   YPR = 0;
   for (int Isex=0; Isex < Nsex; Isex++)
      for (int Iage=0; Iage < Amax; Iage++) {
         CA = FA(Isex,Iage)/Z(Isex,Iage)*N(Isex,Iage)*(1.0-exp(-Z(Isex,Iage)));
         YPR = YPR + Wcatch(Isex,Iage)*CA;
   }

   // Calculate SPR
   SPR = 0;
   for (int Iage=0; Iage < Amax; Iage++) SPR = SPR + Matur(Iage)*N(0,Iage)*exp(-spawnfrac*Z(0,Iage));
   return List::create(_["N"]=N, _["SPR"]=SPR, _["YPR"]=YPR);
}

// ==============================================================================================

//' @title RecC calculates equilibrum recruitment according to a Beverton-Holt stock recruitment relationship (internal routine; Tier 2)
//'
//' @description RecC calculates equilibrium recruitment for a Beverton-Holt stock recruitment
//'     relationship from the steepness and the spawning biomass-per-recruit, which
//'     latter value can be obtained using the ypr function, although this
//'     requires estimates of fecundity at age (weight-at-age may be used
//'     as a proxy if maturity is also accounted for)
//'
//' @param SPR is the spawning biomass-per-recruit = numbers * fecundity-at-age
//' @param SPRF0 is the unfished spawning biomass-per-recruitment
//' @param B0 is the unfished spawning biomass
//' @param Steep is the Beverton-Holt curve steepness
//' @return the recruitment corresponding to the specified SPR value
//' @export
// [[Rcpp::export]]
double RecC(double SPR, double SPRF0, double B0, double Steep) {
   double Top, Bot, Recr;

   Top = 4*Steep*SPR/SPRF0+Steep-1;
   Bot = 5*Steep-1;
   Recr = B0/SPR*(Top/Bot);
   return Recr;
}

//' @title DerivC calculates the gradient of the yield curve at the input Ftarg (internal routine; Tier 2)
//'
//' @description DerivC is used when conducting an age-structured analysis. It
//'     calculates the gradient of the yield curve at the input Ftarg.
//'
//' @param Ftarg a input fishing mortality
//' @param Nsex is the number of sexes for which biological data are available
//' @param Amax is the number of age classes + 1
//' @param M is a matrix of natural mortality where age = rows and sex = cols
//' @param Sel is a matrix of selectivity where age = rows and sex = cols
//' @param Wcatch is a matrix of weight-at-age where age = row and sex = cols
//' @param Fec a vector of fecundity-at-age needed to calculate the spawning
//'         potential ratio; sometimes given as the same as weight-at-age
//' @param Steep is the Beverton-Holt curve steepness
//' @param SPRF0 is the unfished spawning biomass-per-recruit
//' @return the gradient of the yield curve at the Ftarg value
//' @export
// [[Rcpp::export]]
double DerivC(List BasicData, List BasicPars, double Ftarg, double SPRF0) {
   List Outs;
   double Steepness, B0, Recr,  Deriv;

   // Extract steepness
   Steepness = as<double>(BasicPars["Steep"]);
   B0 = as<double>(BasicPars["B0"]);

   // Add a small constant to the F
   Outs = yprC(BasicData,Ftarg+0.001);
   double SPR1 = as<double>(Outs[1]);
   Recr = RecC(SPR1,SPRF0,B0,Steepness);
   double Yield1 = as<double>(Outs[2]);
   Yield1 = Yield1 * Recr;

   // Subtract a small constant from the F
   Outs = yprC(BasicData,Ftarg-0.001);
   double SPR2 = as<double>(Outs[1]);
   Recr = RecC(SPR2,SPRF0,B0,Steepness);
   double Yield2 = as<double>(Outs[2]);
   Yield2 = Yield2 * Recr;

   printf("%f %f %f\n",Ftarg,Yield1,Yield2);
   Deriv = (Yield1-Yield2)/0.002;
   return Deriv;
}

//' @title DoGetMSYC calculates MSY, BMSY, and FMSY (internal routine; Tier 2)
//'
//' @description DoGetMSYC is used to calculate MSY, BMSY, and FMSY.The solution for FMSY involves solving for dY/dF=0
//'
//' @param Nsex is the number of sexes for which biological data are available
//' @param Amax is the number of age classes + 1
//' @param M is a matrix of natural mortality where age = rows and sex = cols
//' @param Sel is a matrix of selectivity where age = rows and sex = cols
//' @param Wcatch is a matrix of weight-at-age where age = rows and sex = cols
//' @param Fec a vector of fecundity-at-age needed to calculate the spawning
//'        potential ratio; sometimes given as the same as weight-at-age
//' @param Steep is the Beverton-Holt curve steepness
//' @return a list containing MSY, BMSY, and FMSY in that order
//' @export
// [[Rcpp::export]]
List DoGetMSYC(List BasicData, List BasicPars, double q, double Price, double Cost) {

   // Local variables
   int Nsex, Amax, Nage;
   List Outs;
   double spawnfrac, Steep, R0;
   double SPRF0,SPR1,Recr,YieldMax,Fmin,Fmax,Ftarg,Yield,Deriv2,FMSY,MSY,BMSY,F35,B0;
   double FMEY,MEY,BMEY,CMEY,Profit1,Profit2;
   int II;

   Nsex = as<int>(BasicData["Nsex"]);
   Amax = as<int>(BasicData["Amax"]);
   Nage = Amax-1;                                            // Easy to work with
   spawnfrac = as<double>(BasicData["spawnfrac"]);
   R0 = as<double>(BasicPars["R0"]);
   B0 = as<double>(BasicPars["B0"]);

   NumericMatrix Sel(Nsex,Amax);
   Sel = as<NumericMatrix>(BasicData["Sel"]);
   NumericVector Matur(Amax);
   Matur = as<NumericVector>(BasicData["Matur"]);
   NumericMatrix M(Nsex,Amax);
   M = as<NumericMatrix>(BasicData["M"]);

   // Find SPRF0
   Outs = yprC(BasicData, 0.0);
   SPRF0 =  as<double>(Outs[1]);
   B0 = R0*SPRF0;

   // First pass to find  limits for bisection
   YieldMax = -1;  Fmax = -1;
   for (II=0;II<=500;II++) {
      Ftarg = II*0.01;
      Outs = yprC(BasicData,Ftarg);
      SPR1 = as<double>(Outs[1]);
      Recr = RecC(SPR1,SPRF0,B0,Steep);
      Yield = as<double>(Outs[2]);
      Yield = Yield * Recr;
      printf("%f %f \n",Ftarg,Yield);
      if (Yield > YieldMax) { YieldMax = Yield; Fmax = Ftarg; }
   }

   // Appy bisection 20x to find MSY
   Fmin = Fmax - 0.01;
   Fmax = Fmax + 0.01;
   for (II=0; II<30; II++) {
      Ftarg = (Fmin+Fmax)/2.0;
      Deriv2 = DerivC(BasicData,BasicPars,Ftarg,SPRF0);
      if (Deriv2 > 0) Fmin = Ftarg; else Fmax = Ftarg;
   }
   if (abs(Deriv2) > 0.0001) printf("DoGetMSYC may not have converged on MSY\n");
   FMSY = Ftarg;

   // Extract MSY and FMSY and BMSY
   Outs = yprC(BasicData,FMSY);
   SPR1 = as<double>(Outs[1]);
   Recr = RecC(SPR1,SPRF0,B0,Steep);
   Yield = as<double>(Outs[2]);
   MSY = Yield*Recr;
   BMSY = SPR1*Recr;

   // Find F35%
   Fmin = 0.0001;
   Fmax = 5.0;
   for (int JJ=0;JJ<=20;JJ++)
    {
     Ftarg = (Fmin+Fmax)/2.0;
     Outs = yprC(BasicData,Ftarg);
     SPR1 = as<double>(Outs[1]);
     if (SPR1 > 0.35*SPRF0) Fmin=Ftarg; else Fmax = Ftarg;
	}
   F35 = Ftarg;

   // Find FMEY
   Fmin = 0.0001;
   Fmax = FMSY;
   for (II=0; II<30; II++) {
     Ftarg = (Fmin+Fmax)/2.0;
     Outs = yprC(BasicData,Ftarg+0.001);
     SPR1 = as<double>(Outs[1]);
     Recr = RecC(SPR1,SPRF0,B0,Steep);
     Yield = as<double>(Outs[2]);
     Profit1 = Price*Yield*Recr - Cost*q*(Ftarg+0.001);
     Outs = yprC(BasicData, Ftarg-0.001);
     SPR1 = as<double>(Outs[1]);
     Recr = RecC(SPR1,SPRF0,B0,Steep);
     Yield = as<double>(Outs[2]);
     Profit2 = Price*Yield*Recr - Cost*q*(Ftarg-0.001);
     Deriv2 = (Profit1-Profit2)/0.0002;
     if (Deriv2 > 0) Fmin = Ftarg; else Fmax = Ftarg;
   }
   // Compute FMEY
   FMEY = Ftarg;
   Outs = yprC(BasicData,Ftarg+0.001);
   SPR1 = as<double>(Outs[1]);
   Recr = RecC(SPR1,SPRF0,B0,Steep);
   Yield = as<double>(Outs[2]);
   MEY = Price*Yield*Recr - Cost*q*Ftarg;
   CMEY = Yield*Recr;
   BMEY = SPR1*Recr;

   // Yield function
   NumericVector Fs(100);
   NumericVector SSBs(100);
   NumericVector Yields(100);
   NumericVector SPRs(100);
   NumericVector Efforts(100);
   NumericVector Costs(100);
   NumericVector Profits(100);
   double FFF;
   for (int JJ=0;JJ<=99;JJ++)
    {
     FFF = FMSY*float(JJ)/30.0;
     Outs = yprC(BasicData,FFF);
     SPR1 = as<double>(Outs[1]);
     Recr = RecC(SPR1,SPRF0,B0,Steep);
     Yield = as<double>(Outs[2]);
	 Fs(JJ) = FFF;
	 SSBs(JJ) = SPR1*Recr;
	 Yields(JJ) = Yield*Recr;
	 SPRs(JJ) = SPR1;
	 Efforts(JJ) = q*FFF;
	 Costs(JJ) = Cost*Efforts(JJ);
	 Profits(JJ) = Price*Yields(JJ) - Costs(JJ);
	}

   return List::create(_["MSY"]=MSY, _["BMSY"]=BMSY, _["FMSY"]=FMSY,_["Fs"]=Fs,_["SSBs"]=SSBs,_["Yields"]=Yields,_["SPRs"]=SPRs,_["F35"]=F35,_["Efforts"]=Efforts,_["Costs"]=Costs,_["Profits"]=Profits,_["FMEY"]=FMEY,_["MEY"]=MEY,_["BMEY"]=BMEY,_["CMEY"]=CMEY);
}
