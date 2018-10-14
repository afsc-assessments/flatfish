@ECHO off
:: Batchfile to profile M and q (mods.dat) and for each run retro and save.
:: first the M and q runs, then the peels
for /L %%L IN (1,1,40) DO (
  :: Get model configurations (one of 40 combinations of M and q)
  awk "{print $"%%L"}" modqM.dat > mod.ctl 
  :: Peels
  for /L %%R IN (0,1,10) DO (
    call runretro.bat %%L %%R 
  )
)
:: DO call run.bat %%:w
