### PROGS = rhic2hbook
### MPROGS = onliplot.kumac pvector.kumac pvector.pl lr_spinpat.pl online_polar.pl rampplot.kumac repol.sh repol.kumac
###
### include ../include/common.mk
### 
### install::
###	@if [ ! -f $(CNIPOL_DIR)/bin/analyze.sh ]; then ln -s `pwd`/test.sh $(CNIPOL_DIR)/bin/analyze.sh; fi
###
### CERNLIB_DIR=/usr/local/cern
### INC_PATHS += -I$(CERNLIB_DIR)/include/cfortran
### LIB_PATHS += -L$(CERNLIB_DIR)/lib

#CXXFLAGS += $(shell root-config --cflags)
#CFLAGS += $(shell root-config --cflags)
#LIBS += $(shell root-config --ldflags --libs)

### rhic2hbook : rhic2hbook.o rdatautilp.o rdatautil.o
###	$(FC) $^ -Wno-globals -m32 -o $@ $(LIB_PATHS) -lpacklib -lkernlib -lmathlib -lcdev -lm -ldl -lstdc++ $(LIBS)

CERNDIR = /home/cfsd/alekseev/proj/cernlib_2023/cern/new/

include /vobs/libs/makefiles/MakeStd.inc

NAME = rhic2hbook

USESOLIBS = yes
INC = -I../include -I$(CERNDIR)/include -I$(CERNDIR)/include/cfortran
USER_FFLAGS = -m32 -ffixed-form -ffixed-line-length-none
USER_CXXFLAGS = -Wno-unused-function
#USER_CXXFLAGS = $(shell $(CERNDIR)/bin/root-config --cflags) -Wno-unused-function
#LDFLAGS = -m32 -L$(CERNDIR)/lib $(shell $(CERNDIR)/bin/root-config --libs) -lstdc++
LDFLAGS = -m32 -L$(CERNDIR)/lib -lstdc++
##LDFLAGS = -L$(CERNDIR)/lib $(shell $(CERNDIR)/bin/root-config --libs)

PROG1 = rhic2hbook
SRCS1 = rhic2hbook.f rdatautilp.cpp rdatautil.cpp
LIBS1 = cdevCns cdev includeCdev GenData rhicError Async setHist
#LD1 = g77
LD1 = gfortran
FC = gfortran
FF = gfortran
#SYSLIBS1 = packlib kernlib mathlib  gfortranbegin gfortran g2c
SYSLIBS1 = packlib kernlib mathlib

include $(MAKEDIR)/MakeApp.inc
