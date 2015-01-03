#!make -f

EXNAME = perf

SRCS = get_env.cpp formatn.cpp get_time.cpp notify.sv performance.sv

LOGFILE?=$(firstword $(shell /bin/ls -1t [aiqv]1.[0-9]*.txt))
export LOGFILE
JOB = ${LOGFILE}
export JOB

INCDIRS = +incdir+.

RUN_OPTS+=$d 
RUN_OPTS+=$o 
ifdef L
  RUN_OPTS+='+uvm_set_config_int=*,level,$L' 
endif
ifdef I
  RUN_OPTS+='+uvm_set_config_string=*,messages,$I' 
endif
ifdef W
  RUN_OPTS+='+uvm_set_config_string=*,warnings,$W' 
endif
ifdef A
  RUN_OPTS+='+uvm_set_config_int=*,agents,$A' 
endif
ifdef B
  RUN_OPTS+='+uvm_set_config_int=*,bfm_object,$B' 
endif
ifdef M
  RUN_OPTS+='+uvm_set_config_int=*,use_monitor,$M' 
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
  RUN_OPTS+='+uvm_set_config_int=*,propagate,$P' 
endif
ifdef S
  RUN_OPTS+='+uvm_set_config_int=*,shape,$S' 
endif
ifdef X
  RUN_OPTS+='+uvm_set_config_string=*,switching,$X' 
endif
ifdef OPTS
  RUN_OPTS+=${OPTS}
endif
ifdef PERIOD
  VERILOG_DEFINES+=+define+PERIOD=${PERIOD} 
endif
ifdef BITS
  VERILOG_DEFINES+=+define+BITS=${BITS} 
endif
ifdef BUSY
  VERILOG_DEFINES+=+define+BUSY=${BUSY} 
endif
ifdef USE_RTL
  VERILOG_DEFINES+=+define+USE_RTL=${USE_RTL} 
endif
ifdef USE_MONITOR
  VERILOG_DEFINES+=+define+USE_MONITOR=${USE_MONITOR} 
endif
ifdef USE_CLOCKING
  VERILOG_DEFINES+=+define+USE_CLOCKING=${USE_CLOCKING} 
endif
ifdef RTL_NOISE
  VERILOG_DEFINES+=+define+RTL_NOISE=${RTL_NOISE} 
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

The following targets are available:

=over

=item B<help>

Displays documentation from Makefile describing options & variations on rules.

This is the default target.

=item B<rules>

Displays documentation from this file describing the rules.

=item B<it>

Run default set of tests. Also calls B<starting>, B<finished>, B<notify>.

=item B<starting>

Wall clock timestamp with label "Starting at".

=item B<finished>

Wall clock timestamp with label "Finished at".

=item B<notify>

Announces completion, and sends e-mail if MAILTO is defined.

=item B<ius>

Run UVM under Cadence Incisive simulator for $(SRCS).

=item B<ius_debug>

Run UVM under Cadence Incisive simulator in debug mode (GUI) for $(SRCS).

=item B<ius_std>

Run UVM under Cadence Incisive simulator for $(SRCS) using $(UVM_HOME) instead of built-in UVM.

=item B<ius_std_debug>

Run UVM under Cadence Incisive simulator in debug mode (GUI) for $(SRCS) using $(UVM_HOME) instead of built-in UVM.

=item B<questa>

Run UVM under Mentor Questasim simulator for $(SRCS).

=item B<questa_debug>

Run UVM under Mentor Questasim simulator in debug mode (GUI) for $(SRCS).

=item B<questa_std>

Run UVM under Mentor Questasim simulator for $(SRCS) using $(UVM_HOME) instead of built-in UVM.

=item B<questa_std_debug>

Run UVM under Mentor Questasim simulator in debug mode (GUI) for $(SRCS) using $(UVM_HOME) instead of built-in UVM.

=item B<vcs>

Run UVM under Synopsys VCS simulator for $(SRCS).

=item B<vcs_debug>

Run UVM under Synopsys VCS simulator in debug mode (GUI) for $(SRCS).

=item B<vcs_std>

Run UVM under Synopsys VCS for $(SRCS) using $(UVM_HOME) instead of built-in UVM.

=item B<clean>

Remove automatically generated files and libraries from (old) simulations.

=item B<version>

Display UVM version

=back

The following options are available:

=over

=item B<L="LIST">

Sets -L option of ./doit script with LIST, which is a space or comma separated list of integer levels.

=item B<I="LIST">

Sets -I option of ./doit script with LIST, which is a space or comma separated list of info counts.

=item B<W="LIST">

Sets -W option of ./doit script with LIST, which is a space or comma separated list of warning counts.

=item B<A="LIST">

Sets -A option of ./doit script with LIST, which is a space or comma separated
list of the number of agents to instantiate.

=item B<B="LIST">

Sets -B option of ./doit script with LIST, which is a space or comma separated
list of 0/1 specifying whether to use BFM objections.

=item B<M="LIST">

Sets -M option of ./doit script with LIST, which is a space or comma separated
list of 0/1 specifying whether to use the monitor.

=item B<U="LIST">

Sets -U option of ./doit script with LIST, which is a space or comma separated
list of 0/1 specifying whether to use a full sequence (1) or a short 1ps
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

=item B<S=BOOLEAN>

Sets -S option of ./doit script with BOOL, which specifies the shape of the agent/uvc
arrays {SHAPE_WIDE=0, SHAPE_NARROW=1}.

=item B<X="LIST">

Sets -X option of ./doit script with LIST, which is a space or comma separated
list specifying context switching choice. 0 means to raise/lower objections with
no delays between transactions driven. 1 means to add #1 delay between raise to
lower on every transaction driven.

=back

=head1 ENVIRONMENT

If the environment variable or macro MAILTO is defined, the notify target will send e-mail announcing
comletion.

UVM_VER may be set to a numeric value to specify the desired version of UVM (e.g. 1.1).

UVM_HOME (points to the UVM home installation directory (overriding any UVM_VER).

HOST_ARCH may be specified or automatically detected.

TARGET_ARCH defaults to HOST_ARCH, but may be overridden. FORCE_ARCH may be used to override even this.

MODEL_TECH overrides QUESTA_HOME

=head1 EXAMPLE

make it A="2 1" L="4"; # 2 agents

=head1 AUTHOR

David.Black@Doulos.com

=cut

endef

################################################################################
# END DOCUMENTATION
################################################################################

