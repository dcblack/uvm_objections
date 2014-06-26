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

1. Read documentation

    % perldoc doit

2. Use custom make command:

    % make it ARGS="-C 1e9 -L 4 -S vcs -T x 1.2r"

Manifest
--------

- `Makefile`
- `Makefile.rules`
- `README.md` <- This text
- `doit` <- bash script to simplify regressions
- `formatn.cpp`
- `formatn.svh`
- `get_time.cpp`
- `get_time.svh`
- `performance.sv`
- `questa+uvm-1.1b.log` -- results for Questa with UVM 1.1b
- `questa+uvm-1.1c.log` -- results for Questa with UVM 1.1c
- `questa+uvm-1.1d.log` -- results for Questa with UVM 1.1d
- `questa+uvm-1.2.log`  -- results for Questa with UVM 1.2
- `questa+uvm-1.2r.log` -- results for Questa with UVM 1.2

That's all folks!
