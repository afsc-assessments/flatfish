cp $1.ctl mod.ctl
rm fm.std
./fm -nox -iprint 200
cp extra_sd.rep arc/$1_ABC_OFL.rep
cp srecpar.rep arc/$1_srec_par.rep
cp fm.par arc/$1.par
cp fm.std arc/$1.std
cp fm_R.rep arc/$1_R.rep
cp mod.ctl arc/$1.ctl
cp fm.rep arc/$1.rep
