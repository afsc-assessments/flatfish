#!/bin/bash
# set modn=%1
# amak -ind ..\examples\atka\%1.ctl -nox -iprint 100
#for i in `seq 13 13`;
awk '{print $'$1'}' mods.dat >mod.ctl
cp mod.ctl tmp.ctl
for i in `seq 0 10`;
do
  awk -v rrr=$i 'NR==53{print rrr} NR!=53 {print $0}' tmp.ctl >mod.ctl
  ./fm -nox -iprint 400
  cp fm_R.rep retro/ret_R$1_$i.rep
  cp mod.ctl retro/ret$1_$i.ctl
	cp fm.std retro/ret$1_$i.std
	cp fm.rep retro/ret$1_$i.rep
  cp extra_sd.rep retro/ret$1_$i_ABC_OFL.rep
done    
