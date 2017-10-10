copy mod%1.ctl mod.ctl
del fm.std
fm -nox -iprint 200
copy extra_sd.rep arc\mod%1.par
copy fm.par arc\mod%1.par
copy fm.std arc\mod%1.std
copy fm.rep arc\mod%1.rep


