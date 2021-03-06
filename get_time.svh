`ifndef GET_TIME_SVH
`define GET_TIME_SVH

  import "DPI-C" get_cpu_time  // elapsed in CPU seconds
                    = function real get_cpu_time();
  import "DPI-C" get_wall_time // wall clock in seconds
                    = function real get_wall_time();

`endif
