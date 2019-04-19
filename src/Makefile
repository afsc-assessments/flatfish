ifdef ComSpec
    RM=del /F /Q
    COPY=copy
else
    RM=rm -rf
    COPY=cp
endif

all: fm 

fm: fm.tpl 
	@admb -f fm.tpl 


clean:
	@$(RM) fm.cpp
	@$(RM) fm.htp
	@$(RM) fm.obj

