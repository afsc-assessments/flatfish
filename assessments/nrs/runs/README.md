# Northern rocksole sole runs directory

In 2020, c1mod4 was selected as the preferred model used for advice.

fm.dat in subdirectory gives "model_name" as one word (no spaces) and datafile locale and name. This was previously in mod.ctl files.

Structure set up to parse mods.dat (taken from [flatfish models](https://docs.google.com/spreadsheets/d/1Jw--X8M61LFjPUFNv5vFXozBwmQCpf7FwIDhQFs38lM/edit#gid=1701376339) for a description)

Previously ran `run.sh ctl#` (where `ctl#` is the column number from the mods.dat file) which copied things in the subdirectory "arc\" with the names such as "mod1.rep, mod1.std, ... etc"

**Now:** running each model in separate directory, first line of mod.ctl is the "title" for the model run, 2nd line points to datafile location which is in ../data/nrs_2018.dat, e.g.. or if in local directory, just nrs_2018.dat (like a poor man's starter.ss)

