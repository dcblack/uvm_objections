#!make -f

EXNAME = perf

SRCS = formatn.cpp get_time.cpp performance.sv

INCDIRS = +incdir+.

ifdef L
  RUN_OPTS+='+uvm_set_config_int=*,level,$L' 
endif
ifdef A
  RUN_OPTS+='+uvm_set_config_int=*,drivers,$A' 
endif
ifdef U
  RUN_OPTS+='+uvm_set_config_int=*,use_seq,$U' 
endif
ifdef R
  RUN_OPTS+='+uvm_set_config_string=*,tr_len,$R' 
endif
ifdef C
  RUN_OPTS+='+uvm_set_config_string=*,count,$C' 
endif
ifdef P
  RUN_OPTS+='+uvm_set_config_int=*,ripple,$P' 
endif
ifdef X
  RUN_OPTS+='+uvm_set_config_int=*,switching,$X' 
endif

EXTRA_QUESTA_OPTS := 
EXTRA_QUESTA_RUNOPTS := $(RUN_OPTS)
EXTRA_IUS_OPTS := 
EXTRA_IUS_RUNOPTS := $(RUN_OPTS)
EXTRA_VCS_OPTS := 
EXTRA_VCS_RUNOPTS := $(RUN_OPTS)

# Find Makefiles.rules either in etc/ or in ./ somewhere in hierarchy
RULE_DIRS:= . .. ../.. ../../.. ../../../..
RULES := $(addsuffix /etc/Makefile.rules,${RULE_DIRS})
RULES += $(addsuffix /Makefile.rules,${RULE_DIRS})
RULES := $(firstword $(wildcard ${RULES}))
$(info INFO: Including ${RULES})
include ${RULES}
