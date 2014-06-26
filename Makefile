#!make -f

EXNAME = perf

SRCS = formatn.cpp get_time.cpp performance.sv

INCDIRS = +incdir+.

RUN_OPTS :=\
  '+uvm_set_config_int=*,level,$L' \
  '+uvm_set_config_int=*,drivers,$D' \
  '+uvm_set_config_string=*,count,$C' \
  '+uvm_set_config_int=*,ripple,$R'

EXTRA_QUESTA_OPTS = +define+AUTO_DMA_ON_STARTUP 
EXTRA_QUESTA_RUNOPTS = -cvg63  $(RUN_OPTS)
EXTRA_IUS_OPTS = +define+AUTO_DMA_ON_STARTUP 
EXTRA_IUS_RUNOPTS = -coverage all -covoverwrite  $(RUN_OPTS)
EXTRA_VCS_OPTS = +define+AUTO_DMA_ON_STARTUP 
EXTRA_VCS_RUNOPTS = $(RUN_OPTS)

# Allow for overrides locally, but normally use ${HLDW}/etc
RULEDIRS:= . .. ../.. ../../.. ../../../.. ${HLDW}/etc
RULES := $(addsuffix /etc/Makefile.rules,${RULEDIRS})
RULES += $(addsuffix /Makefile.rules,${RULEDIRS})
RULES := $(firstword $(wildcard ${RULES}))
$(info INFO: Including ${RULES})
include ${RULES}
