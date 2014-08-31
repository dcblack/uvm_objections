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

################################################################################
# BEGIN DOCUMENTATION
################################################################################
define MAKEFILE_DOCUMENTATION

################################################################################
#                                                                              #
#    ---->>>  To read this use: 'perldoc Makefile' or 'make help'  <<<----     #
#                                                                              #
################################################################################

=pod

=head1 NAME

B<Makefile> - Makefile for automation of performance tests

=head1 SYNOPSIS

B<make> {:TARGET:} {:OPTIONS:}

NOTE 1: Some local installations of GNU make rename it to B<gmake>.

NOTE 2: For help on the various target rules, use 'make rules' or 'perldoc Makefile.rules'

=head1 DESCRIPTION

This file, Makefile, sets up variables for and running the UVM performance tests under *NIX.
It uses Makefile.rules for most of the automation.

=head1 USAGE

The following options are available:

=over

=item B<L="LIST">

Sets -L option of ./doit script with LIST, which is a space or comma separated list of integer levels.

=item B<A="LIST">

Sets -A option of ./doit script with LIST, which is a space or comma separated
list of the number of agents to instantiate.

=item B<U="LIST">

Sets -U option of ./doit script with LIST, which is a space or comma separated
list of 0/1 specifing whether to use a full sequence (1) or a short 1ps
sequence.

=item B<R="LIST">

Sets -R option of ./doit script with LIST, which is a space or comma separated
list specifying the transaction lengths to use. This has a special format using
one hex digit for each driver. Example: 3_2_1 means a length of 3ps for driver
2, 2ps for driver 1, and 1ps for driver 0.  Unspecified drivers get a value of 1ps.

=item B<C=COUNT>

Sets -C option of ./doit script with COUNT, which is the number of times to
repeat inner loop.

=item B<P=BOOLEAN>

Sets -P option of ./doit script with BOOL, which specifies whether to propagate
objections (1) or not (0) -- affects 1.2 and above only.

=item B<X="LIST">

Sets -X option of ./doit script with LIST, which is a space or comma separated
list specifying context switching choice. 0 means to raise/lower objections with
no delays between transactions driven. 1 means to add #1 delay between raise to
lower on every transaction driven.

=back

=head1 ENVIRONMENT

If the environment variable or macro MAILTO is defined, the notify target will send e-mail announcing
comletion.

=EXAMPLE

make it A="2 1" L="4"; # 2 agents

=head1 AUTHOR

David.Black@Doulos.com

=cut

endef

################################################################################
# END DOCUMENTATION
################################################################################

