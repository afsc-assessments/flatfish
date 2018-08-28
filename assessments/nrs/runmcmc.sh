#rt.sh 0
awk '{print $'$1'}' mods.dat >mod.ctl
rm fm.std
rm extra_sd.rep
fm -nox -iprint 100 -mcmc 1000000 -mcsave 500
fm -nox -iprint 100 -mceval
#cp extra_sd.rep arc/mod$1_extra.rep
cp evalout.rep arc/mod$1_evalout.rep
cp fm.psv arc/mod$1.psv
cp extra_sd.rep arc/mod$1_ABC_OFL.rep
cp srecpar.rep arc/mod$1_srec_par.rep
cp fm.par arc/mod$1.par
cp fm.std arc/mod$1.std
cp fm_R.rep arc/mod$1_R.rep
cp mod.ctl arc/mod$1.ctl
cp fm.rep arc/mod$1.rep
