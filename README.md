Description
-----------

This directory contains files for the analysis
of UVM performance in the area of raising and dropping
objections. It is designed to test various versions
of UVM with large numbers of objections.

How to
------

To run (default):

``
    % make it
``

For more sophisticated runs,

0. Add ./bin to search path

``
    % source setup.profile
``

1. Read documentation:

``
    % perldoc bin/doit
``

2. Use custom make command:

``
    % make it ARGS="-C 1e9 -L 4 -S vcs -T x 1.2r"
``

Or read Makefile documentation:
``
    % make
``

HINT: Use `screen` to run everything in background:

1. To start a job:

``
    % screen -d -m -L make it ARGS="..."
``

alternately:

``
    % ./screenit ...
``

2. To view status:

``
    % screen -ls
``

See manpage on `screen` for more information.

Manifest
--------

- `Makefile` <- specifies source files and basic options
- `Makefile.rules` <- make rules to launch various simulators
- `README.md` <- This text
- `bin/doit` <- bash script to simplify regressions
- `formatn.cpp` <- formats numbers with commas (,) to separate thousands, millions, etc.
- `formatn.svh` <- SystemVerilog DPI import
- `get_time.cpp` <- function to return CPU milliseconds timestamp
- `get_time.svh` <- SystemVerilog DPI import
- `performance.sv` <- This is the main SystemVerilog code

Requirements
------------
The following are required to get this working (some obvious, some not so much):

- Linux (CentOS, RedHat, etc.) capable of supporting simulators
- UVM 1.1b thru 1.2 downloaded from Accellera.org
- SystemVerilog simulator and license.
  + Cadence Incisive
  + Mentor Questa
  + Synopsys VCS
  + others should work with some finnagling, but are untested at present
- C++ compiler
  + gcc 4.1 or better
- bash
- perl5
- git (unless you download the tarball from github)
- screen (if you use it to launch scripts)
- GNU make version 3.81 or better

### That's all folks!
