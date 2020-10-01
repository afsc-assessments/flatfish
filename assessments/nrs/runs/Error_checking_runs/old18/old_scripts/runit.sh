#!/bin/bash
# Iterate runs to get future catch = to future ABCs
# syntax "runit.sh 2 5" means run model 2 5 times
for i in `seq 1 $2`; do
  run.sh $1
  cat future_ABC.rep >future_catch.dat
done
