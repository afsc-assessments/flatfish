ifdef ComSpec
    RM=del /F /Q
    COPY=copy
else
    RM=rm -rf
    COPY=cp
endif

all: proj 

proj: proj.tpl 
	@admb -f proj.tpl 


clean:
	@$(RM) proj.cpp
	@$(RM) proj.htp
	@$(RM) proj.obj

