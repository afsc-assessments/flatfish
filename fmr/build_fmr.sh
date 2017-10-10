R CMD BATCH update-fmr.R
cd ../
R CMD build fmr
R CMD INSTALL fmr_*.tar.gz
rm fmr_*.tar.gz
cd fmr
chmod 777 DESCRIPTION
