Description
-----------

This directory contains files for the analysis
of UVM performance in the area of raising and dropping
objections. It is designed to test various versions
of UVM with large numbers of objections.

How to
------

To run (default):

    % make it

For more sophisticated runs,

1. Read documentation:

    % perldoc doit

2. Use custom make command:

    % make it ARGS="-C 1e9 -L 4 -S vcs -T x 1.2r"

HINT: Use `screen` to run everything in background:

1. To start a job:

    % screen -d -m -L make it ARGS="..."

alternately:

    % ./screenit ...

2. To view status:

    % screen -ls

See manpage on `screen` for more information.

Manifest
--------

- `Makefile` <- specifies source files and basic options
- `Makefile.rules` <- make rules to launch various simulators
- `README.md` <- This text
- `doit` <- bash script to simplify regressions
- `formatn.cpp` <- formats numbers with commas (,) to separate thousands, millions, etc.
- `formatn.svh` <- SystemVerilog DPI import
- `get_time.cpp` <- function to return CPU milliseconds timestamp
- `get_time.svh` <- SystemVerilog DPI import
- `performance.sv` <- This is the main SystemVerilog code
- `questa+uvm-1.1b.log` -- results for Questa with UVM 1.1b
- `questa+uvm-1.1c.log` -- results for Questa with UVM 1.1c
- `questa+uvm-1.1d.log` -- results for Questa with UVM 1.1d
- `questa+uvm-1.2.log`  -- results for Questa with UVM 1.2
- `questa+uvm-1.2r.log` -- results for Questa with UVM 1.2

That's all folks!
