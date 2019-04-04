#cp mod$1.ctl mod.ctl
awk '{print $'$1'}' mods.dat >mod.ctl
rm fm.std
./fm -nox -iprint 200
./archit.sh $1
