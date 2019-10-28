#!/bin/bash
rm extra_sd.rep
cp arc/mod$1.ctl mod.ctl
cp arc/mod$1.psv fm.psv
fm -nox -iprint 100 -mceval
cp evalout.rep arc/mod$1_evalout.rep
