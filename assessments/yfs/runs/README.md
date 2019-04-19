# Yellowfin sole runs directory

Structure set up to parse mods.dat (taken from [flatfish models](https://docs.google.com/spreadsheets/d/1Jw--X8M61LFjPUFNv5vFXozBwmQCpf7FwIDhQFs38lM/edit#gid=1701376339) for a description)

Previously ran `run.sh ctl#` (where `ctl#` is the column number from the mods.dat file) which copied things in the subdirectory "arc\" with the names such as "mod1.rep, mod1.std, ... etc"

**Now:** running each model in separate directory, first line of mod.ctl is the "title" for the model run, 2nd line points to datafile location which is in ../data/yfs_2018.dat, e.g..

