#!/bin/bash
# set modn=%1
# amak -ind ..\examples\atka\%1.ctl -nox -iprint 100
#for i in `seq 13 13`;
for i in `seq 0 10`;
do
  #awk -v rrr=$i 'NR==53{print rrr} NR!=53 {print $0}' arc/mod2.ctl >mod.ctl # New Base
  awk -v rrr=$i 'NR==53{print rrr} NR!=53 {print $0}' arc/mod6.ctl >mod.ctl
  ./fm -nox -iprint 400
  cp fm_R.rep retro/r_mod6_R$i.rep
	cp fm.std retro/r_mod6_$i.std
	cp fm.rep retro/r_mod6_$i.rep
done    
