@echo off
set exec=..\..\src\build\release\fm.exe 
:: if EXIST %exec% (mklink /D  %exec% fm.exe ) ELSE echo "file missing, compile source code in fm\src directory "
:: %1 %2 %3 %4 %5 %6
if EXIST %exec% (copy %exec% fm.exe ) ELSE echo "file missing, compile source code in fm\src directory "
awk '{print $'%1'}' mods.dat >mod.ctl
:: del fm.std
:: fm -nox -iprint 400 -mcmc 1000000 -mcsave 200
if EXIST arc\mod%1.psv (echo "Running mceval on  arc\mod%1.psv ) ELSE echo ("file missing, compile source code in fm\src directory "; goto end)
copy arc\mod%1.psv fm.psv arc\mod%1.psv
fm -mceval
copy evalout.rep arc\mod%1_evalout.rep
end:
