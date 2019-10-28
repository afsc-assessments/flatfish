#!/bin/bash 
# set modn=%1
# amak -ind ..\examples\atka\%1.ctl -nox -iprint 100
#for i in `seq $1 $2`;
export r=2
echo writing to prof$r
for i in `seq 1 15`;
do
  awk -v rrr=$i '{print $rrr}' m_prof.dat |awk 'NR==2{print "yfs_temp_date_int_cov.dat"} NR!=2{print $0}' >mod.ctl
  fm -nox -iprint 500 
  cp fm_R.rep prof$r/p_R$i.rep
  cp extra_sd.rep prof$r/p_ABC_$i.rep
	cp fm.std prof$r/p_$i.std
	cp fm.rep prof$r/p_$i.rep
done    
