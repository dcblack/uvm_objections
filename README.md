Description
-----------

This directory contains files for the analysis
of UVM performance in the area of raising and dropping
objections. It is designed to test various versions
of UVM with large numbers of objections.

How to
------

To run (default):

```
    % make it
```

For more sophisticated runs,

0. Add ./bin to search path

```
    % source setup.profile
```

1. Read documentation:

```
    % perldoc bin/doit
```

2. Use custom make command:

```
    % make it ARGS="-C 1e9 -L 4 -V vcs 1.2r"
```

Or read Makefile documentation:
```
    % make
```

Or read Makefile documentation:
``
    % make
``

HINT: Use `screen` to run everything in background:

1. To start a job:

```
    % screen -d -m -L make it ARGS="..."
```

alternately:

```
    % ./screenit ...
```

2. To view status:

```
    % screen -ls
```

See manpage on `screen` for more information.

3. To extract logfile information into a spreadsheet CSV file

```
    % extract -t DIR/* >data.csv
```

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

Output files
------------

When using screenit or doit scripts, the results of a simulation are logged to a
file with a standarized file name. The following are examples with features of
the name spelled out:

```
    v1-1.1d-P1u0r0x1s0b1m1I0W0L03A2.txt                           
    || |    | | | | | | | | | |  |                                
    || |    | | | | | | | | | |  \--A#-> agents                   
    || |    | | | | | | | | | \-----L#-> levels                   
    || |    | | | | | | | | \-------W#-> warnings                 
    || |    | | | | | | | \---------I#-> information messages     
    || |    | | | | | | \-----------m#-> use monitor if 1         
    || |    | | | | | \-------------b#-> use bfm if 1             
    || |    | | | | \---------------x#-> shape 0=>wide, 1=>narrow 
    || |    | | | \-----------------x#-> use switching if 1       
    || |    | | \-------------------r#-> burst length             
    || |    | \---------------------u#-> use full sequence        
    || |    \-----------------------P#-> propagate if 1           
    || \--------------------------UVM#-> UVM version 1.1a..1.2    
    |\-------------------------------#-> simulation run 1..N      
    \--------------------------------?-> simulation vendor (*)    

    * vendors: a=>ALDEC, i=>Cadence, q=>Mentor, v=>Synopsys 
```

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
- C++ compiler (compatible with your simulator(s))
  + gcc 4.1 or better
- bash
- perl5
- git (unless you download the tarball from github)
- screen (if you use it to launch scripts)
- GNU make version 3.81 or better

### That's all folks!
