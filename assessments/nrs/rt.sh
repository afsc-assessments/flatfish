cp mod$1.ctl mod.ctl
rm fm.std
rm extra_sd.rep
fm -nox -iprint 100
cp extra_sd.rep arc/mod$1_extra.rep
cp For_R.dat arc/mod$1_R.rep
cp fm.par arc/mod$1.par
cp fm.std arc/mod$1.std
cp fm.rep arc/mod$1.rep
cp srecpar.dat arc/mod$1_srec.rep
cleanad
