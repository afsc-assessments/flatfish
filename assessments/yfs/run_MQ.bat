@ECHO off
if EXIST mq_profile (
  echo "Saving results in mq_retro directory"
  ) ELSE (
  mkdir mq_profile
)
:: Batchfile to profile M and q (mods.dat) and for each run retro and save.
:: first the M and q runs, then the peels
set exec=..\..\src\build\release\fm.exe 
if EXIST %exec% (copy %exec% fm.exe ) ELSE echo "file missing, compile source code in fm\src directory "
for /L %%L IN (1,1,40) DO (
  :: Get model configurations (one of 40 combinations of M and q)
  awk "{print $"%%L"}" modqM.dat > mod.ctl 
  fm -nox -iprint 400
  copy extra_sd.rep mq_profile\mod%%L_ABC_OFL.rep
  copy srecpar.rep mq_profile\mod%%L_srec_par.rep
  copy sex_ratio.rep mq_profile\mod%%L_sex_ratio.rep
  copy fm.par mq_profile\mod%%L.par
  copy fm.std mq_profile\mod%%L.std
  copy fm.rep mq_profile\mod%%L.rep
  copy fm_R.rep mq_profile\mod%%L_R.rep
  copy mod.ctl mq_profile\mod%%L.ctl
)

