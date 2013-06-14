# vim:set path+=/usr/include/blitz:

# Author: Sameer Sheorey, University of Maryland, College Park and Toyota 
# Technological Institute at Chicago.

# Use if blitz++ is installed locally
#BASE=/home/ssameer/Documents/UMD_research/Code/blitz-0.9 # Change this !
#INC=$(BASE)
#LIB=$(BASE)/lib/.libs
CPP=g++
CPPFLAGS=-ansi -march=core2 -Wall -Wno-sign-compare # -frepo -Weffc++
# -frepo ensures that template code is not instantiated each time you change a 
#  line of code and recompile. Reduces subsequent compilation time at the cost 
#  of longer first compilation. Instantiated templates are stored in .rpo
#  Add this if you need to recompile frequently.
#  You may need to change -march for your architecture.
LDFLAGS=
OPTIM=-O3 -fstrict-aliasing -ffast-math
DEBUG=-g -DBZ_DEBUG		# enabled for the targets ending in _d

# debug test so that assert() works
all: test_d wemdn_mex	

test: test.cpp lift
	$(CPP) -c -o $@.o -I$(INC) $(CPPFLAGS) $(OPTIM) test.cpp
	$(CPP) -o $@ -L$(LIB) $(LDFLAGS) $(OPTIM) -lblitz -lm $@.o

test_d: test.cpp lift
	$(CPP) -c -o $@.o -I$(INC) $(CPPFLAGS) $(DEBUG) test.cpp
	$(CPP) -o $@ -L$(LIB) $(LDFLAGS) $(DEBUG) -lblitz -lm $@.o

wemdn_mex: wemd.h wemd_impl.h wemdn_mex.cpp lift
	mex -c -largeArrayDims CXXFLAGS='$$CXXFLAGS $(CPPFLAGS) $(OPTIM) \
	-I$(INC)' wemdn_mex.cpp
	mex -cxx -largeArrayDims CXXFLAGS='$$CXXFLAGS $(CPPFLAGS) $(OPTIM) \
	  -I$(INC)' CXXLIBS='$$CXXLIBS -lblitz' $@.o

wemdn_mex_d: wemd.h wemd_impl.h wemdn_mex.cpp lift
	mex -g -largeArrayDims CXXFLAGS='$$CXXFLAGS -ansi -march=core2 -Wall \
	-Wno-sign-compare -DBZ_DEBUG' CXXLIBS='$$CXXLIBS -lblitz' wemdn_mex.cpp


lift: lift.h lift_impl.h blitz_util_SS.h

clean:
	rm -f *.o *.rpo test test_d
