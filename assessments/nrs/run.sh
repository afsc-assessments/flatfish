cp mod$1.ctl mod.ctl
rm fm.std
./fm -nox -iprint 200
cp extra_sd.rep arc/mod$1_ABC_OFL.rep
cp srecpar.rep arc/mod$1_srec_par.rep
cp fm.par arc/mod$1.par
cp fm.std arc/mod$1.std
cp fm_R.rep arc/mod$1_R.rep
cp mod.ctl arc/mod$1.ctl
cp fm.rep arc/mod$1.rep
