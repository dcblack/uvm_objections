`ifndef GET_TIME_SVH
`define GET_TIME_SVH
import "DPI-C" pure get_cpu_time = function real get_cpu_time();
import "DPI-C" pure get_wall_time = function real get_wall_time();
`endif
