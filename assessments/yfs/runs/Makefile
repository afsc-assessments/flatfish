SUBDIRS = max0 max1 max2 max3 
#SUBDIRS = withoutce withce Mmatrix Mmatrixce cope copece copeceMmat
#SUBDIRS = base usv usv_vast CA sr1 sr2 sr0 sr3
JOBS:=$(SUBDIRS)

MODS_DESC=Models to be run
ARGS:=

.PHONY: all ${JOBS} 

all: ${JOBS} ; echo "$@ success" ${JOBS} 
	
${JOBS}: job%: ; cd $* ; make ${ARGS} ; cd ..;


