ifdef ComSpec
    RM=del /F /Q
    COPY=copy
else
    RM=rm -rf
    COPY=cp
endif

all: main 

main: main.tpl 
	@admb -f main.tpl 


clean:
	@$(RM) main.cpp
	@$(RM) main.htp
	@$(RM) main.obj

