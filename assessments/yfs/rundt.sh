awk -v c=$2 '{print $c}' growth_runs.dat > mod.ctl; 
./fm -nox -iprint 200
cp extra_sd.rep arc/$1_$2_ABC_OFL.rep
cp srecpar.rep arc/$1_$2_srec_par.rep
cp fm.par arc/$1_$2.par
cp fm.std arc/$1_$2.std
cp fm_R.rep arc/$1_$2_R.rep
cp mod.ctl arc/$1_$2.ctl
cp fm.rep arc/$1_$2.rep
