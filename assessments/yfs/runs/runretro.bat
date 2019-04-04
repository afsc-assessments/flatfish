@echo off
:: set exec=..\..\src\build\release\fm.exe 
:: if EXIST %exec% (mklink /D  %exec% fm.exe ) ELSE echo "file missing, compile source code in fm\src directory "
:: %1 %2 %3 %4 %5 %6
:: if EXIST %exec% (copy %exec% fm.exe ) ELSE echo "file missing, compile source code in fm\src directory "
if EXIST mq_retro (
  echo "Saving results in mq_retro directory"
  ) ELSE (
  mkdir mq_retro
)
:: Set up retro year
copy mod.ctl tmpmod.ctl
awk -v rrr=%2 "NR==53{print rrr} NR!=53 {print $0}" tmpmod.ctl >mod.ctl
:: Now run model
del fm.std
fm.exe -nox -iprint 400
:: Now save results
copy extra_sd.rep mq_retro\mq%1_%2_ABC_OFL.rep
copy srecpar.rep mq_retro\mq%1_%2_srec_par.rep
copy fm.par mq_retro\mq%1_%2.par
copy fm.std mq_retro\mq%1_%2.std
copy fm.rep mq_retro\mq%1_%2.rep
copy fm_R.rep mq_retro\mq%1_%2_R.rep
copy mod.ctl mq_retro\mq%1_%2.ctl

