@echo off
set exec=..\..\src\build\release\fm.exe 
:: if EXIST %exec% (mklink /D  %exec% fm.exe ) ELSE echo "file missing, compile source code in fm\src directory "
:: %1 %2 %3 %4 %5 %6
if EXIST %exec% (copy %exec% fm.exe ) ELSE echo "file missing, compile source code in fm\src directory "
copy mod%1.ctl mod.ctl
del fm.std
fm -nox -iprint 400
copy extra_sd.rep arc\mod%1_ABC_OFL.rep
copy srecpar.rep arc\mod%1_srec_par.rep
copy fm.par arc\mod%1.par
copy fm.std arc\mod%1.std
copy fm.rep arc\mod%1.rep
copy fm_R.rep arc\mod%1_R.rep
copy mod.ctl arc\mod%1.ctl
