# fmr
[![Build Status](https://travis-ci.org/seacode/gmacs/gmr.svg?branch=develop)](https://travis-ci.org/seacode/gmacs/gmr)

### R code for flatfish models

The `fmr` R package is under development in support of the BSAI flatfish model

The most recent development release of the `fmr` package can be downloaded and installed from Github through R:
```S
install.packages("devtools")
install.packages("shiny")
#to be updated
devtools::install_github("seacode/", subdir = "/fmr", ref = "develop")
```

Once the `fmr` package is installed, it can be loaded in the regular manner:

```S
library(fmr)
````

To install previous release versions of `gmr`, version 1 for example, use:

```S
#to be updated
devtools::install_github("seacode/gmacs/gmr", ref = "V1.0")
````


### Useage note 
> The R code available in this package comes with no warranty or guarantee of accuracy. It merely represents an ongoing attempt to integrate output plotting with statistical and diagnostical analsyses for Gmacs. It is absolutely necessary that prior to use with a new application, the user checks the output manually to verify that there are no plotting or statistical bugs which could incorrectly represent the output files being analyzed.
