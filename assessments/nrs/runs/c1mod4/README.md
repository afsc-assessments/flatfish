# Northern rocksole sole directory

## Updating fishery ages and wt-age and survey and pop wt-age

j1 is w/out any new data

j2 is with the available data including last year's 1995-97 estimates

j3 is omitting those 1995-97 estimates since nobody can figure out where they come from

j4 is as in j3 but includes wt-age estimates from sampler (as opposed to constant values used previously)

c1 is as in j4 but replaces and adds survey and pop wt-age for 2001 onward (which are the same as each other and empirical with a three-yr rolling avg for ages 15-20)

c1mod4 is 2020 version of Model 18.3 estimating male M and q_sigma wider and selex offset
## Updates to mod.ctl file
mod   is as for 2018 but estimates SRR curve through 2014 (and still uses wt-age through 2012)



## Notes on proceeding from the 2018 assessment

1.  Copy the contents of "orig" directory to a new folder    

2.  modify that folder contents, e.g., update 2018 datafile to 2020      
		
2.  Run model, make a script to do so, modify w/ more scripts, more directories...     


## Core files for running model

| File            | Description          |
|-----------------|----------------------|
| Makefile        | On linux/mac/some windows? will link (symbolically) to executable in src/fm otherwise compile and copy fm.exe here |
| fm.dat          | Datafile containing run name and datafile string (e.g., nrs18_fixed.dat)      |
| nrs18_fixed.dat |MAIN 2018 datafile (pointed to by fm.dat) |
| mod.ctl    |control file containing a number of options (use R now for changing?) |
| fut_temp.dat |  Research aspect to use future temperatures or other index in projections |
| README.md    |  This file  |
| future_catch.dat | iterated string to get Tier 1 ABC/OFL given expected future catches... |
| hdr.csv         | header label file for MCMC (needs updating probably) |
--------------------------------- |

## Notes on some output files 

| File            | Description          |
|-----------------|----------------|
| writeinput.log   |  check on if data etc read in properly (Echoinput.ss?)                            |
| fm.rep           |  Main output file to read into R                            |
| ABC_OFL.rep      |  table for Tier 1 stuff                            |
| future_ABC.rep   |  iterate w/ future_catch.dat to get distribution of Fs given catch stream...say                            |
| param_grads.rep  |  gradients                            |
| sex_ratio.rep    |  another report file                            |
| evalout.rep      |  MCMC report file                            |
| fm_legacy.rep    |  Legacy report file (used to paste into excel...                             |
| -----------------|----------------|

