# Name of executable.
OUTPUT:=fm

# Portable makefiles (http://skramm.blogspot.com/2013/04/writing-portable-makefiles.html)
# Windows users: download http://gnuwin32.sourceforge.net/packages/make.htm
ifdef ComSpec
    RM=del /F /Q
    COPY=copy
    CXX:=g++
else
    RM=rm -rf
    CXX:=clang++
    COPY=cp
endif 


# Path to ADMB distribution directory if ADMB_HOME is not declared in your evironment variables
# export ADMB_HOME=/Users/stevenmartell1/admb-trunk/build/dist
# export ADMB_HOME=/Users/jim/admb/build/dist

# Compiler
# CXX:=clang++

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
debug: CXXFLAGS+= $(DEBUG_CXXFLAGS)
debug: LDFLAGS+= $(DEBUG_LDFLAGS)
debug: build/debug/$(OUTPUT)

build/debug/$(OUTPUT): $(OUTPUT).tpl build/debug $(DEBUG_OBJS)
	@echo 'linking ' build/debug/$(OUTPUT)
	@admb -g $(OUTPUT) 
	@$(COPY) $(OUTPUT) build/debug/$(OUTPUT) 

# Release route.
release: $(OUTPUT).tpl build/release/$(OUTPUT)
build/release/$(OUTPUT): build/release $(RELEASE_OBJS)
	@echo 'linking ' build/release/$(OUTPUT)
	@admb -g $(OUTPUT) 
	@$(COPY) $(OUTPUT) build/release/$(OUTPUT) 

.PHONY: clean
clean:
	@echo 'removing build directory'
	@$(RM) -rf build
