#!/bin/bash
# set modn=%1
# amak -ind ..\examples\atka\%1.ctl -nox -iprint 100
#for i in `seq 13 13`;
cp mod.ctl tmp.ctl
for i in `seq 0 10`;
do
  awk -v rrr=$i 'NR==84{print rrr} NR!=84 {print $0}' tmp.ctl >mod.ctl # New Base
  ./fm -nox -iprint 400
  cp fm_R.rep retro/r_R$i.rep
  cp mod.ctl retro/r_$i.ctl
	cp fm.std retro/r_$i.std
	cp fm.rep retro/r_$i.rep
	cp fm.par retro/r_$i.par
done   
cp tmp.ctl mod.ctl
