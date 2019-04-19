#cp mod$1.ctl mod.ctl
if [ ! -d "m$1" ]; then
  # Control will enter here if $DIRECTORY doesn't exist.
	mkdir m$1
fi
if [ ! -e "m$1/mod.ctl" ]; then
  awk '{print $'$1'}' mods.dat > m$1/mod.ctl
fi
#rm fm.std
#./fm -nox -iprint 200
#cp extra_sd.rep arc/mod$1_ABC_OFL.rep
#cp srecpar.rep arc/mod$1_srec_par.rep
#cp sex_ratio.rep arc/mod$1_sex_ratio.rep
#cp fm.par arc/mod$1.par
#cp fm.std arc/mod$1.std
#cp fm_R.rep arc/mod$1_R.rep
#cp mod.ctl arc/mod$1.ctl
#cp fm.rep arc/mod$1.rep

