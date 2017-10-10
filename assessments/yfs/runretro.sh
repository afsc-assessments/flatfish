#!/bin/bash
# set modn=%1
# amak -ind ..\examples\atka\%1.ctl -nox -iprint 100
#for i in `seq 13 13`;
for i in `seq 0 10`;
do
  awk -v rrr=$i 'NR==54{print rrr} NR!=54 {print $0}' mod1.ctl >mod.ctl
  fmr -est -nox -iprint 400
  cp For_R.rep retro/r_R$i.rep
	cp fm.std retro/r_$i.std
	cp fm.rep retro/r_$i.rep
done    
