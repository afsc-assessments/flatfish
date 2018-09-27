# Name of executable.
OUTPUT:=fm
ifdef ComSpec
    RM=del /F /Q
    COPY=copy
		admb = C:\programs\ADMB\bin\admb.cmd
else
    RM=rm -rf
    COPY=cp
		admb = admb
endif


# Name of text file containing build number.
BUILD_NUMBER_FILE=build-number.txt

# ======================= END OF CONFIGURABLE THINGS ===========================
# Create debug & release list of object files as well as dep files.
# Default to release build.
all: $(OUTPUT) debug release


# Directory targets
build/debug:
	@echo creating debug directory
	@mkdir -p build/debug build/deps

build/release:
	@echo creating release directory
	@mkdir -p build/release build/deps

# Debug route.
.PHONY: debug

debug: $(OUTPUT).tpl build/debug/$(OUTPUT)
build/debug/$(OUTPUT): $(OUTPUT).tpl build/debug $(DEBUG_OBJS)
	@echo 'linking ' build/debug/$(OUTPUT)
	@admb -g $(OUTPUT) 
	@$(COPY) $(OUTPUT) build/debug/$(OUTPUT) 

# Release route.
release: $(OUTPUT).tpl build/release/$(OUTPUT)
build/release/$(OUTPUT): build/release $(RELEASE_OBJS)
	@echo 'linking ' build/release/$(OUTPUT)
	@admb -f $(OUTPUT) 
	@$(COPY) $(OUTPUT) build/release/$(OUTPUT) 

.PHONY: clean
clean:
	@echo 'removing build directory'
	@$(RM) -rf build


