//File: ABOUT.txt
////////////////////////////////////////////////////////////////////////////////////////////////////
// DESCRIPTION
//
// This code is designed to test relative runtime performance of various UVM
// versions, implementations, and associated simulators.
//
//File: CONVENTIONS.txt
// CONVENTIONS
//
// Code formatting conventions used in this file are:
//
//   1. All modules, interfaces, packages, and classes use word capitalization (e.g. Design)
//      Classes furthermore have an _t suffix to indicate they represent a data type.
//   2. Member data other than ports use m_ prefix.
//   3. Global variables use g_ prefix.
//   4. Static variables use s_ prefix.
//   5. Typedefs and classes use _t suffix.
//   6. First letter of class is uppercase. Separate words within with underscores.
//
// The original file combines what would normally be multiple files into one; however, file
// boundaries have been marked with specially setup comments:
//
//   //File: FILENAME -- introduces a new file
//   //IFile: FILENAME -- introduces a new file replaced with `include in the containing file
//   //Include: FILENAME -- should be replaced with a proper include if separate files
//   //Inline: FILENAME -- pulls a file back in
//   //Continue: FILENAME -- resumes a file
//   //`endif /*GUARDNAME*/ -- ends a header file
//   //EOF: FILENAME -- ends a non-header file
//
// Also, filenames ending in `.svh` or `.svi` are header files intended to be included; whereas,
// `.sv` indicates potentially separate compilation units. Exception: `.sv` implementations are
// included in packages since packages are considered to be separately compiled with their contents.
// The `.svi` designation is intended for "implementations" separated from their corresponding
// `.svh` header files to make it easier to simply view the header without the distracting content.

//File: CONFIGURATION.txt
// CONFIGURATION
//
// This code has the following run-time configuration variables:
//
// +uvm_set_config_int=*,agents,NUMBER specifies how many agents to instantiate
// +uvm_set_config_int=*,bfm_object,BIT specifies if driver/monitor should raise/drop objections
// +uvm_set_config_int=*,level,NUMBER specifies depth of hierarchy to agents
// +uvm_set_config_int=*,reports,NUMBER specifies the number of reports to send (default 0)
// +uvm_set_config_int=*,propagate,BIT specifies for UVM 1.2 whether to propagate objections
// +uvm_set_config_int=*,shape,BIT specifies where agents split
// +uvm_set_config_int=*,switching,NUMBER specifies context switching variations
// +uvm_set_config_int=*,use_monitor,BIT specifies use of monitor
// +uvm_set_config_int=*,use_seq,BIT specifies if sequence is long (1) or short (0)
// +uvm_set_config_string=*,count,NUMBER specifies how many transactions to run
// +uvm_set_config_string=*,messages,NUMBER specifies if info messages to be enabled (0)
// +uvm_set_config_string=*,tr_len,HEX specifies transaction lengths in nybbles
// +uvm_set_config_string=*,warnings,NUMBER specifies if warning messages to be enabled (0)

//File: COPYRIGHT.txt
//--------------------------------------------------------------------------------------------------
// COPYRIGHT
//
// This code and accompanying files is Copyright (C) 2015 Doulos Inc.
//
// LICENSE
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//File: defines.svh
`ifndef DEFINES_SVH
`define DEFINES_SVH

`ifndef USE_HDW
  `define USE_HDW
`endif
`ifndef USE_FIELD_MACROS
  `define USE_FIELD_MACROS
`endif

// The following affect the static design
`ifndef CLOCK_PERIOD
  `define CLOCK_PERIOD 4ns
`endif
`ifndef BUSY
  `define BUSY 3 /*clocks*/
`endif
`ifndef BITS
  `define BITS 32
`endif

typedef logic [`BITS-1:0] Data_t; // Used for hardware data register size

`endif
//File: elablorate.sv
////////////////////////////////////////////////////////////////////////////////
//
//  ##### #        #    #####   ####  #####     #    ####### ##### 
//  #     #       # #   #    # #    # #    #   # #      #    #     
//  #     #      #   #  #    # #    # #    #  #   #     #    #     
//  ##### #     #     # #####  #    # #####  #     #    #    ##### 
//  #     #     ####### #    # #    # #  #   #######    #    #     
//  #     #     #     # #    # #    # #   #  #     #    #    #     
//  ##### ##### #     # #####   ####  #    # #     #    #    ##### 
//
//Inline: COPYRIGHT.txt
////////////////////////////////////////////////////////////////////////////////
// Display `define status
//Include: defines.svh
module Elaborate;
  //----------------------------------------------------------------------------
  timeunit 1ps;
  timeprecision 1ps;
  //----------------------------------------------------------------------------
  initial begin
    $display("HDW_INFO CLOCK_PERIOD=%0t",`CLOCK_PERIOD);
    $display("HDW_INFO BUSY=%0d",`BUSY);
    $display("HDW_INFO BITS=%0d",`BITS);
    `ifdef USE_HDW
    $display("HDW_INFO USE_HDW defined");
    `else
    $display("HDW_INFO No using HDW");
    `endif
    `ifdef USE_CLOCKING
    $display("HDW_INFO USE_CLOCKING defined");
    `else
    $display("HDW_INFO No using clocking block");
    `endif
    `ifdef USE_FIELD_MACROS
    $display("HDW_INFO USE_FIELD_MACROS defined to enable use of field automation macros");
    `else
    $display("HDW_INFO No field macros");
    `endif
    `ifdef HDW_NOISE
    $display("HDW_INFO HDW_NOISE defined to show initial %0d clocks of HDW activity",`HDW_NOISE);
    `else
    $display("HDW_INFO HDW silent");
    `endif
  end
endmodule

//EOF: elaborate.sv
//File: my_intf.sv
////////////////////////////////////////////////////////////////////////////////
//
//  ### #     # ####### ##### #####  #####    #     ####  #####
//   #  ##    #    #    #     #    # #       # #   #    # #    
//   #  # #   #    #    #     #    # #      #   #  #      #    
//   #  #  #  #    #    ##### #####  ##### #     # #      #####
//   #  #   # #    #    #     #  #   #     ####### #      #    
//   #  #    ##    #    #     #   #  #     #     # #    # #    
//  ### #     #    #    ##### #    # #     #     #  ####  #####
//
//Inline: COPYRIGHT.txt
////////////////////////////////////////////////////////////////////////////////
//Include: defines.svh
interface My_intf ( input bit clock );
  logic  reset;
  logic  is_busy;
  Data_t data;
  Data_t result;
  modport hdw_mp(input reset, input is_busy, input data, input clock, output result);
  `ifdef USE_CLOCKING
  clocking cb @(posedge clock);
    output #1step data;
    input  #0     result;
    input  #0     is_busy;
  endclocking : cb
  modport test_mp(output reset, clocking cb);
  `else
  modport test_mp(output reset, data, input clock, is_busy, result);
  `endif
endinterface : My_intf

//EOF: my_intf.sv
//File: design.sv
////////////////////////////////////////////////////////////////////////////////
//
//  #    #    #    #####  ####   #     #    #    #####  #####
//  #    #   # #   #    # #   #  #  #  #   # #   #    # #    
//  #    #  #   #  #    # #    # #  #  #  #   #  #    # #    
//  ###### #     # #####  #    # #  #  # #     # #####  #####
//  #    # ####### #  #   #    # #  #  # ####### #  #   #    
//  #    # #     # #   #  #   #  #  #  # #     # #   #  #    
//  #    # #     # #    # ####    ## ##  #     # #    # #####
//
//Inline: COPYRIGHT.txt
////////////////////////////////////////////////////////////////////////////////
//Include: defines.svh
// NOTE: Uses typedef Data_t; otherwise, this is normal Verilog, but NOT RTL
//
// Description:
//   A change in data or reset results in the respective operation which is
//   synchronized to the clock. is_busy goes high for `BUSY clock cycles, which
//   indicates operation.
//
module Design ( input reset, input clock
        , input Data_t data, output var Data_t result
        , output var bit is_busy );
  //----------------------------------------------------------------------------
  timeunit 1ps;
  timeprecision 1ps;
  //----------------------------------------------------------------------------
  task busy(int unsigned cycles);
    is_busy <= 1;
    repeat (cycles) @(posedge clock);
    is_busy <= 0;
  endtask : busy
  always @(data or reset) begin : BEHAVIOR // NOT RTL
    #1ps;
    @(posedge clock);
    if (reset) begin
      result <= 0;
      busy(`BUSY);
    end else begin
      result <= #((`BUSY-1)*`CLOCK_PERIOD) result ^ data; // Propagation delay
      busy(`BUSY);
    end
  end : BEHAVIOR
  `ifdef HDW_NOISE
  // Generate lots of data to show operation (normally off)
  initial begin
    $display("HDW_INFO reset clock is_busy data result");
    $monitor("HDW_INFO %t %b %b %b %h %h",$time,reset,clock,is_busy,data,result);
    repeat (`HDW_NOISE) @(posedge clock);
    $monitoroff;
    $display("HDW_INFO end of noise");
  end
  `endif
endmodule : Design

//EOF: design.sv
//File: harness.sv
////////////////////////////////////////////////////////////////////////////////
//
//  #    #    #    #####  #     # #####  ####   #### 
//  #    #   # #   #    # ##    # #     #    # #    #
//  #    #  #   #  #    # # #   # #     #      #     
//  ###### #     # #####  #  #  # #####  ####   #### 
//  #    # ####### #  #   #   # # #          #      #
//  #    # #     # #   #  #    ## #     #    # #    #
//  #    # #     # #    # #     # #####  ####   #### 
//
//Inline: COPYRIGHT.txt
////////////////////////////////////////////////////////////////////////////////
//Include: defines.svh
module harness;
  //----------------------------------------------------------------------------
  timeunit 1ps;
  timeprecision 1ps;
  //----------------------------------------------------------------------------
  bit clock = 0;
  `ifdef USE_HDW
  always #(`CLOCK_PERIOD/2) ++clock; // Generate clock
  `endif
  // FUTURE: genvar loop to create many dut/interface pairs
  My_intf if1 ( .clock );
  Design dut1
         ( .reset(if1.reset)
         , .clock
         , .data(if1.data)
         , .result(if1.result)
         , .is_busy(if1.is_busy)
         );
endmodule : harness

//EOF: harness.sv
//File: performance_pkg.sv
////////////////////////////////////////////////////////////////////////////////
//
//  #####     #     ####  #    #     #     ####  ##### 
//  #    #   # #   #    # #   #     # #   #    # #     
//  #    #  #   #  #      #  #     #   #  #      #     
//  #####  #     # #      ###     #     # #  ### ##### 
//  #      ####### #      #  #    ####### #    # #     
//  #      #     # #    # #   #   #     # #    # #     
//  #      #     #  ####  #    #  #     #  ####  ##### 
//
//Inline: COPYRIGHT.txt
////////////////////////////////////////////////////////////////////////////////
//Include: defines.svh
`include "uvm_macros.svh"
package Performance_pkg;

  timeunit 1ps;
  timeprecision 1ps;

  import uvm_pkg::*;
  `include "get_time.svh"
  `include "formatn.svh"

  // Convenience strings to make output more distinct in the log file.
  string SEP1 = {122{"#"}};
  string SEP2 = {120{"="}};
  string SEP3 = {120{"v"}};
  string SEP4 = {120{"^"}};
  string SEP5 = {120{"-"}};
  string SEP6 = {120{"%"}};

  `ifdef UVM_POST_VERSION_1_1
  typedef uvm_integral_t integral_t;
  `else
  typedef uvm_bitstream_t integral_t;
  `endif
  `ifdef UVM_POST_VERSION_1_1
  typedef class My_transaction_t;
  typedef uvm_event                    my_event_t;
  typedef uvm_event_pool               my_event_pool_t;
  `else
  typedef uvm_event                    my_event_t;
  typedef uvm_event_pool               my_event_pool_t;
  `endif
  typedef integral_t tr_len_t;
  typedef enum bit { SHAPE_WIDE, SHAPE_NARROW } shape_t;
  typedef class My_env_t;

  longint unsigned g_measured_objections = 0;
  shortint unsigned g_extended = 0;
  shortint unsigned g_next_id = 0;

  function automatic void bound_tr_len(ref tr_len_t tr_len, input shortint id);
      tr_len = (tr_len >> (4*id)) & 'hF;
      if (tr_len <= 0) begin 
        tr_len = 1; // always at least one
      end//if
  endfunction : bound_tr_len

  function automatic string delete_chars(input string s, cset=",_");
    for (int i=0; i!= s.len(); ++i) begin
      for (int j=0; j!= cset.len(); ++j) begin
        if (s[i] == cset[j]) begin
          int lpos = s.len()-1;
          if (lpos == 0) return "";
          else if (i == 0)    s = s.substr(1,lpos);
          else if (i == lpos) s = s.substr(0,lpos-1);
          else                s = {s.substr(0,i-1),s.substr(i+1,s.len()-1)};
        end//if
      end//for
    end//for
    return s;
  endfunction : delete_chars

//IFile: my_transaction.svh
`ifndef  MY_TRANSACTION_SVH
`define  MY_TRANSACTION_SVH
  //////////////////////////////////////////////////////////////////////////////
  //
  //  ####### #####     #    #     #  #### 
  //     #    #    #   # #   ##    # #    #
  //     #    #    #  #   #  # #   # #     
  //     #    #####  #     # #  #  #  #### 
  //     #    #  #   ####### #   # #      #
  //     #    #   #  #     # #    ## #    #
  //     #    #    # #     # #     #  #### 
  //
  //////////////////////////////////////////////////////////////////////////////
  class My_transaction_t extends uvm_sequence_item;
    // FUTURE: Measure field automation macros
    //--------------------------------------------------------------------------
    // Class member data
    static longint s_count = 0;
    rand bit       m_reset = 0;
    rand integer   m_data  = 'hDEADBEEF;
    `ifdef USE_FIELD_MACROS
    `uvm_object_utils_begin(My_transaction_t)
      `uvm_field_int(m_reset, UVM_DEFAULT)
      `uvm_field_int(m_data,  UVM_DEFAULT)
    `uvm_object_utils_end
    `else
    `uvm_object_utils(My_transaction_t)
    `endif
    //--------------------------------------------------------------------------
    // Constructor
    function new(string name="");
      super.new(name);
      s_count++;
    endfunction : new
    //--------------------------------------------------------------------------
    function string convert2string;
      return $sformatf("{R=%s D=%0h}",m_reset,m_data);
    endfunction : convert2string
    //--------------------------------------------------------------------------
    constraint reset_constraint { m_reset dist { 0 := 99, 1 := 1 }; }
    //--------------------------------------------------------------------------
    `ifndef USE_FIELD_MACROS
    //FUTURE: define do_copy and do_compare
    `endif
  endclass : My_transaction_t

`endif /*MY_TRANSACTION_SVH*/
//IFile: my_sequencer.svh
`ifndef  MY_SEQUENCER_SVH
`define  MY_SEQUENCER_SVH
  //////////////////////////////////////////////////////////////////////////////
  //
  //   ####  #####  ####  ##### 
  //  #    # #     #    # #    #
  //  #      #     #    # #    #
  //   ####  ##### #    # ##### 
  //       # #     #  # # #  #  
  //  #    # #     #   #  #   # 
  //   ####  #####  ### # #    #
  //
  //////////////////////////////////////////////////////////////////////////////
  class My_sequencer_t extends uvm_sequencer#(My_transaction_t);
    //--------------------------------------------------------------------------
    `uvm_component_utils(My_sequencer_t)
    // Class member data
    shortint m_id = 0;
    //--------------------------------------------------------------------------
    // Constructor
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    //--------------------------------------------------------------------------
  endclass : My_sequencer_t

`endif /*MY_SEQUENCER_SVH*/
//IFile: my_sequence.svh
`ifndef  MY_SEQUENCE_SVH
`define  MY_SEQUENCE_SVH
  //////////////////////////////////////////////////////////////////////////////
  //
  //   ####  #####  ####  #    # ##### #     #  ####  ##### 
  //  #    # #     #    # #    # #     ##    # #    # #     
  //  #      #     #    # #    # #     # #   # #      #     
  //   ####  ##### #    # #    # ##### #  #  # #      ##### 
  //       # #     #  # # #    # #     #   # # #      #     
  //  #    # #     #   #  #    # #     #    ## #    # #     
  //   ####  #####  ### #  ####  ##### #     #  ####  ##### 
  //
  //////////////////////////////////////////////////////////////////////////////
  class My_sequence_t extends uvm_sequence#(My_transaction_t);
    //--------------------------------------------------------------------------
    `uvm_object_utils(My_sequence_t)
    `uvm_declare_p_sequencer(My_sequencer_t)
    // Class member data
    shortint m_level  = -1;
    shortint m_id     = -1;
    bit      m_use_do = 0;
    tr_len_t m_tr_len = 1;
    longint  m_count  = 0;
    longint  m_reps;
    //--------------------------------------------------------------------------
    // Constructor
    function new(string name="");
      super.new(name);
    endfunction : new
    //--------------------------------------------------------------------------
    extern task pre_start;
    extern task body;
    extern task post_start;
    //--------------------------------------------------------------------------
  endclass : My_sequence_t

`endif /*MY_SEQUENCE_SVH*/
//IFile: my_sequence.svi
//Include: my_sequence.svh
  //----------------------------------------------------------------------------
  task My_sequence_t::pre_start;
    assert(m_id >= 0);
    assert(uvm_config_db#(longint) ::get(p_sequencer, "", "count",  m_count));
    assert(uvm_config_db#(tr_len_t)::get(p_sequencer, "", "tr_len", m_tr_len));
    void' (uvm_config_db#(bit)     ::get(p_sequencer, "", "use_do", m_use_do));
    bound_tr_len(m_tr_len, m_id);
    m_reps = m_count/m_tr_len;
    `uvm_info("DEBUG",$sformatf("Starting %0d.%0d for %0d repetitions", m_level, m_id, m_reps), UVM_DEBUG)
  endtask : My_sequence_t::pre_start
  //----------------------------------------------------------------------------
  task My_sequence_t::body;
    // Perform a simple reset when starting
    if (m_use_do) begin
      `uvm_do_with(req,{m_reset == 1;})
    end else begin
      req = My_transaction_t::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {m_reset == 1;}) `uvm_error("Performance","Unable to randomize reset transaction")
      finish_item(req);
    end//if
    repeat (m_reps-1/*account for reset*/) begin
      if (m_use_do) begin
        `uvm_do(req)
      end else begin
        req = My_transaction_t::type_id::create("req");
        start_item(req);
        if (!req.randomize()) `uvm_error("Performance","Unable to randomize reset transaction")
        finish_item(req);
      end//if
    end
  endtask : My_sequence_t::body
  //----------------------------------------------------------------------------
  task My_sequence_t::post_start;
    `uvm_info("DEBUG",$sformatf("Ending %0d",m_id), UVM_DEBUG)
  endtask : My_sequence_t::post_start

//EOF: my_sequence.sv
//IFile: my_driver.svh
`ifndef  MY_DRIVER_SVH
`define  MY_DRIVER_SVH
  //////////////////////////////////////////////////////////////////////////////
  //
  //  ####   #####  ### #     # ##### ##### 
  //  #   #  #    #  #  #     # #     #    #
  //  #    # #    #  #  #     # #     #    #
  //  #    # #####   #  #     # ##### ##### 
  //  #    # #  #    #   #   #  #     #  #  
  //  #   #  #   #   #    # #   #     #   # 
  //  ####   #    # ###    #    ##### #    #
  //
  //////////////////////////////////////////////////////////////////////////////
  class My_driver_t extends uvm_driver#(My_transaction_t);
    //--------------------------------------------------------------------------
    `uvm_component_utils(My_driver_t)
    // Class member data
    my_event_pool_t m_global_event_pool;
    my_event_t      m_starting_event;
    virtual My_intf m_vif;
    bit             m_bfm_objects = 1;
    longint         m_count       = 0;
    shortint        m_id          = 0;
    bit             m_busy        = 0;
    longint         m_switching;
    tr_len_t        m_tr_len;
    //--------------------------------------------------------------------------
    // Constructor
    function new(string name, uvm_component parent);
      super.new(name, parent);
      m_global_event_pool = my_event_pool_t::get_global_pool();
    endfunction : new
    //--------------------------------------------------------------------------
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern function void phase_ready_to_end(uvm_phase phase);
    //--------------------------------------------------------------------------
  endclass : My_driver_t

`endif /*MY_DRIVER_SVH*/
//IFile: my_driver.svi
//Include: my_driver.svh
  //----------------------------------------------------------------------------
  function void My_driver_t::connect_phase(uvm_phase phase);
    `uvm_info("connect_phase", "Created driver", UVM_NONE)
    m_starting_event = m_global_event_pool.get("starting");
    assert(uvm_config_db#(bit)     ::get(this, "", "bfm_object", m_bfm_objects));
    assert(uvm_config_db#(longint) ::get(this, "", "switching",  m_switching));
    assert(uvm_config_db#(tr_len_t)::get(this, "", "tr_len",     m_tr_len));
    bound_tr_len(m_tr_len, m_id);
  endfunction : My_driver_t::connect_phase
  //----------------------------------------------------------------------------
  task My_driver_t::run_phase(uvm_phase phase);
    string obj_name = $sformatf("driver[%0d]",m_id);
    if (m_bfm_objects) phase.raise_objection(this, "Raise to get off zero");
    #1; // Get off zero
    if (m_bfm_objects) phase.drop_objection(this, "Drop and wait to start");
    if (!m_bfm_objects) g_measured_objections += m_count/m_tr_len;
    m_starting_event.wait_trigger();
    //////////////////////////////////////////////////////////////////////////
    //
    //   ####  #######    #    #####  #######
    //  #    #    #      # #   #    #    #
    //  #         #     #   #  #    #    #
    //   ####     #    #     # #####     #
    //       #    #    ####### #  #      #
    //  #    #    #    #     # #   #     #
    //   ####     #    #     # #    #    #
    //
    //////////////////////////////////////////////////////////////////////////
    if (m_switching == 0) #1ps; // no context-switching
    forever begin : DRIVING
      seq_item_port.get(req);
      m_busy = 1;
      if (m_bfm_objects) begin
        phase.raise_objection(this, $sformatf("%s begin transmit",obj_name));
        g_measured_objections++;
      end
      if (m_switching == 1) begin // normal context switching
        repeat (m_tr_len) begin
          #1ps;
          if (My_env_t::s_messages > 0) begin
            `uvm_info("run_phase",$sformatf("injected Data=%h",req.m_data),UVM_MEDIUM)
            --My_env_t::s_messages;
          end
          `ifdef USE_HDW
          m_vif.reset <= req.m_reset;
          m_vif.data  <= req.m_data;
          @(posedge m_vif.is_busy); // Wait for data to be taken
          m_vif.reset <= 0;
          m_vif.data  <= 0;
          @(negedge m_vif.is_busy); // Wait for design to become ready
          `endif
        end//repeat
      end//if
      if (m_bfm_objects) phase.drop_objection(this, $sformatf("%s end transmit",obj_name));
      m_busy = 0;
    end//forever
  endtask : My_driver_t::run_phase
  //----------------------------------------------------------------------------
  function void My_driver_t::phase_ready_to_end(uvm_phase phase);
    if ( phase.is(uvm_run_phase::get()) && (m_busy == 1)) begin
      phase.raise_objection(this , "Extending driver's run_phase" );
      g_extended++; //< monitor how many times this is called
      fork begin
        wait(m_busy == 0); //< possibly add timeout
        phase.drop_objection(this , "Driver's extension succeeded");
      end join_none
    end
  endfunction : My_driver_t::phase_ready_to_end
  //----------------------------------------------------------------------------

//EOF: my_driver.sv
//IFile: my_monitor.svh
`ifndef  MY_MONITOR_SVH
`define  MY_MONITOR_SVH
  //////////////////////////////////////////////////////////////////////////////
  //
  //  #     #  ####  #     # ### #######  ####  ##### 
  //  ##   ## #    # ##    #  #     #    #    # #    #
  //  # # # # #    # # #   #  #     #    #    # #    #
  //  #  #  # #    # #  #  #  #     #    #    # ##### 
  //  #     # #    # #   # #  #     #    #    # #  #  
  //  #     # #    # #    ##  #     #    #    # #   # 
  //  #     #  ####  #     # ###    #     ####  #    #
  //
  //////////////////////////////////////////////////////////////////////////////
  class My_monitor_t extends uvm_monitor;
    //--------------------------------------------------------------------------
    `uvm_component_utils(My_monitor_t)
    // Class member data
    my_event_pool_t m_global_event_pool;
    my_event_t      m_starting_event;
    bit             m_use_monitor = 1;
    bit             m_bfm_objects = 1;
    shortint        m_id          = 0;
    bit             m_busy        = 0;
    virtual My_intf m_vif;
    //--------------------------------------------------------------------------
    // Constructor
    function new(string name, uvm_component parent);
      super.new(name, parent);
      m_global_event_pool = my_event_pool_t::get_global_pool();
    endfunction : new
    //--------------------------------------------------------------------------
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern function void phase_ready_to_end(uvm_phase phase);
    //--------------------------------------------------------------------------
  endclass : My_monitor_t

`endif /*MY_MONITOR_SVH*/
//IFile: my_monitor.svi
//Include: my_monitor.svh
  //----------------------------------------------------------------------------
  function void My_monitor_t::connect_phase(uvm_phase phase);
    `uvm_info("connect_phase", "Created monitor", UVM_NONE)
    m_starting_event = m_global_event_pool.get("starting");
    assert(uvm_config_db#(bit)    ::get(this, "", "use_monitor", m_use_monitor));
    assert(uvm_config_db#(bit)    ::get(this, "", "bfm_object",  m_bfm_objects));
  endfunction : My_monitor_t::connect_phase
  //----------------------------------------------------------------------------
  task My_monitor_t::run_phase(uvm_phase phase);
    string   obj_name = $sformatf("monitor[%0d]",m_id);
    m_starting_event.wait_trigger();
    //////////////////////////////////////////////////////////////////////////
    //
    //   ####  #######    #    #####  #######
    //  #    #    #      # #   #    #    #
    //  #         #     #   #  #    #    #
    //   ####     #    #     # #####     #
    //       #    #    ####### #  #      #
    //  #    #    #    #     # #   #     #
    //   ####     #    #     # #    #    #
    //
    //////////////////////////////////////////////////////////////////////////
    if (m_use_monitor) begin
      forever begin : MONITORING
        @(posedge m_vif.is_busy);
        m_busy = 1;
        if (m_bfm_objects) begin
          phase.raise_objection(this, $sformatf("%s begin observation",obj_name));
          g_measured_objections++;
        end
        if (My_env_t::s_warnings > 0) begin
          `uvm_warning("Monitor","<injected>")
          --My_env_t::s_warnings;
        end
        @(negedge m_vif.is_busy);
        if (m_bfm_objects) phase.drop_objection(this, $sformatf("%s end observation",obj_name));
        m_busy = 0;
      end//repeat
    end
  endtask : My_monitor_t::run_phase
  //----------------------------------------------------------------------------
  function void My_monitor_t::phase_ready_to_end(uvm_phase phase);
    if ( phase.is(uvm_run_phase::get()) && m_busy) begin
      phase.raise_objection(this , "Extending monitor's run_phase" );
      g_extended++; //< monitor how many times this is called
      fork begin
        wait(m_busy == 0);
        phase.drop_objection(this , "Monitor's extension succeeded");
      end join_none
    end
  endfunction : My_monitor_t::phase_ready_to_end
  //----------------------------------------------------------------------------

//EOF: my_monitor.sv
//IFile: my_agent.svh
`ifndef  MY_AGENT_SVH
`define  MY_AGENT_SVH
  //////////////////////////////////////////////////////////////////////////////
  //
  //     #     ####  ##### #     # #######
  //    # #   #    # #     ##    #    #   
  //   #   #  #      #     # #   #    #   
  //  #     # #  ### ##### #  #  #    #   
  //  ####### #    # #     #   # #    #   
  //  #     # #    # #     #    ##    #   
  //  #     #  ####  ##### #     #    #   
  //
  //////////////////////////////////////////////////////////////////////////////
  class My_agent_t extends uvm_agent;
    //--------------------------------------------------------------------------
    `uvm_component_utils(My_agent_t)
    // Class member data
    shortint       m_id = 0;
    shortint       m_level = -1;
    My_sequencer_t m_sequencer;
    My_driver_t    m_driver;
    My_monitor_t   m_monitor;
    //--------------------------------------------------------------------------
    // Constructor
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    //--------------------------------------------------------------------------
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    //--------------------------------------------------------------------------
  endclass : My_agent_t

`endif /*MY_AGENT_SVH*/
//IFile: my_agent.svi
//Include: my_agent.svh
  //----------------------------------------------------------------------------
  function void My_agent_t::build_phase(uvm_phase phase);
    m_id = g_next_id++;
    m_sequencer = My_sequencer_t::type_id::create($sformatf("m_sequencer[%0d]",m_id),this);
    m_driver    = My_driver_t   ::type_id::create($sformatf("m_driver[%0d]",m_id),this);
    m_monitor   = My_monitor_t  ::type_id::create($sformatf("m_monitor[%0d]",m_id),this);
  endfunction : My_agent_t::build_phase
  //----------------------------------------------------------------------------
  function void My_agent_t::connect_phase(uvm_phase phase);
    virtual My_intf vif;
    assert( uvm_config_db#(virtual My_intf)::get(this, "", "vif", vif) );
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    // Connect BFM's to hardware interface
    m_driver.m_vif   = vif;
    m_monitor.m_vif  = vif;
    // Set each component to know it's own id
    m_driver.m_id    = m_id;
    m_monitor.m_id   = m_id;
    m_sequencer.m_id = m_id;
  endfunction : My_agent_t::connect_phase
  //----------------------------------------------------------------------------

//EOF: my_agent.sv
//IFile: my_env.svh
`ifndef  MY_ENV_SVH
`define  MY_ENV_SVH
  //////////////////////////////////////////////////////////////////////////////
  //
  //  ##### #     # #     #
  //  #     ##    # #     #
  //  #     # #   # #     #
  //  ##### #  #  # #     #
  //  #     #   # #  #   # 
  //  #     #    ##   # #  
  //  ##### #     #    #   
  //
  //////////////////////////////////////////////////////////////////////////////
  class My_env_t extends uvm_env;
    //--------------------------------------------------------------------------
    `uvm_component_utils(My_env_t)
    // Class static data
    static longint unsigned s_messages = 0;
    static longint unsigned s_warnings = 0;
    // Class member data
    shortint   m_level = -1; // invalid
    shortint   m_id    = -1; // invalid
    shape_t    m_shape = SHAPE_WIDE;
    My_env_t   m_uvc[];
    My_agent_t m_agent[];
    //--------------------------------------------------------------------------
    // Constructor
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    //--------------------------------------------------------------------------
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    //--------------------------------------------------------------------------
  endclass : My_env_t

`endif /*MY_ENV_SVH*/
//IFile: my_env.svi
//Include: my_env.svh
  //----------------------------------------------------------------------------
  function void My_env_t::build_phase(uvm_phase phase);
    string inst_nm;
    shortint unsigned width = 1;
    My_env_t  parent;
    m_id = g_next_id++;
    void'(uvm_config_db#(shape_t)::get(this, "", "shape", m_shape));
    assert(uvm_config_db#(shortint)::get(this, "", "agents", width))
    else `uvm_error("Performance","Missing agent configuration")
    assert(uvm_config_db#(shortint)::get(this, "", "level", m_level))
    else `uvm_error("Performance","Missing level configuration")
    if ($cast(parent,get_parent())) begin
      m_level = parent.m_level - 1;
    end
    `uvm_info("DEBUG",$sformatf("env.id=%0d agents/width=%0d shape=%s level=%0d", m_id, width, m_shape.name, m_level), UVM_DEBUG)
    if (m_level > 0 && parent == null) begin
      // Build the width
      if (m_shape == SHAPE_NARROW) width = 1;
      inst_nm = $sformatf("uvc_T%0d",m_level);
      m_uvc = new[width];
      for (shortint unsigned i=0; i!=width; i++) begin
        m_uvc[i] = My_env_t::type_id::create($sformatf("%s[%0d]", inst_nm, g_next_id+i*m_level),this);
      end
    end else if (m_level > 0) begin
      inst_nm = $sformatf("uvc_L%0d[%0d]", m_level, g_next_id);
      m_uvc = new[1];
      m_uvc[0] = My_env_t::type_id::create(inst_nm,this);
    end else begin // Bottom
      if (parent != null && m_shape == SHAPE_WIDE) width = 1;
      m_agent = new[width];
      for (shortint unsigned i=0; i!=width; i++) begin
        m_agent[i] = My_agent_t::type_id::create($sformatf("m_agent[%0d]", g_next_id+i),this);
        m_agent[i].m_level = this.m_level;
      end
    end
  endfunction : My_env_t::build_phase
  //----------------------------------------------------------------------------
  function void My_env_t::connect_phase(uvm_phase phase);
    assert(uvm_config_db#(longint) ::get(this, "", "messages", s_messages));
    assert(uvm_config_db#(longint) ::get(this, "", "warnings", s_warnings));
  endfunction : My_env_t::connect_phase
  //----------------------------------------------------------------------------

//EOF: my_env.sv
//IFile: my_test.svh
`ifndef  MY_TEST_SVH
`define  MY_TEST_SVH
  //////////////////////////////////////////////////////////////////////////////
  //
  //  ####### #####  ####  #######
  //     #    #     #    #    #   
  //     #    #     #         #   
  //     #    #####  ####     #   
  //     #    #          #    #   
  //     #    #     #    #    #   
  //     #    #####  ####     #   
  //
  //////////////////////////////////////////////////////////////////////////////
  class My_test_t extends uvm_test;
    //--------------------------------------------------------------------------
    `uvm_component_utils(My_test_t)
    // Class member data
    My_env_t         m_env;
    my_event_pool_t  m_global_event_pool;
    my_event_t       m_starting_event;
    real             m_cpu_starting_time,  m_cpu_finished_time;
    real             m_wall_starting_time, m_wall_finished_time;
    bit              m_propagate = 1; //< default old way
    string           m_features = "";
    //--------------------------------------------------------------------------
    // Constructor
    function new(string name, uvm_component parent);
      super.new(name, parent);
      m_global_event_pool = my_event_pool_t::get_global_pool();
    endfunction : new
    //--------------------------------------------------------------------------
    extern function void build_phase(uvm_phase phase);
    extern function void phase_started(uvm_phase phase);
    extern task reset_phase(uvm_phase phase);
    extern task main_phase(uvm_phase phase);
    extern function void extract_phase(uvm_phase phase);
    extern function void report_phase(uvm_phase phase);
    //--------------------------------------------------------------------------
  endclass : My_test_t

`endif /*MY_TEST_SVH*/
//IFile: my_test.svi
//Include: my_test.svh
  //----------------------------------------------------------------------------
  // Set drain-time and propagation mode for all run-time (task based) phases
  function void My_test_t::phase_started(uvm_phase phase);
    uvm_task_phase task_phase;
    if ($cast(task_phase,phase.get_imp())) begin
      uvm_objection objection;
      objection = phase.get_objection();
      `ifdef UVM_POST_VERSION_1_1
      objection.set_propagate_mode(m_propagate);
      `endif
      objection.set_drain_time(uvm_top, 2*`CLOCK_PERIOD);
    end
  endfunction : My_test_t::phase_started
  //----------------------------------------------------------------------------
  function void My_test_t::build_phase(uvm_phase phase);
    `ifdef UVM_POST_VERSION_1_1
    typedef uvm_enum_wrapper#(shape_t) shape_wrapper_t;
    `else
    `endif
    longint  count          = 1e6; //< default
    longint  switching      = 1;   //< default
    int      use_seq        = 1;   //< default
    bit      use_do         = 0;   //< default
    bit      use_monitor    = 1;   //< default
    bit      bfm_object     = 1;   //< default
    shortint levels         = 2;   //< default
    shortint agents         = 1;   //< default
    shape_t  shape          = SHAPE_WIDE; //< default
    tr_len_t tr_len         = 0;   //< default (0 = equal; else each nibble)
    longint  messages       = 0;
    longint  warnings       = 0;
    string   tempstr        = "";
    int      status;

    ////////////////////////////////////////////////////////////////////////////
    //
    //   ####   ####  #     # ##### ###  ####  #    # #####  #####
    //  #    # #    # ##    # #      #  #    # #    # #    # #    
    //  #      #    # # #   # #      #  #      #    # #    # #    
    //  #      #    # #  #  # #####  #  #  ### #    # #####  #####
    //  #      #    # #   # # #      #  #    # #    # #  #   #    
    //  #    # #    # #    ## #      #  #    # #    # #   #  #    
    //   ####   ####  #     # #     ###  ####   ####  #    # #####
    //
    ////////////////////////////////////////////////////////////////////////////
    // Manage configuration
    void'(uvm_config_db#(uvm_bitstream_t)::get(this, "", "level", levels)); //<allow from command-line
    uvm_config_db#(shortint)::set(uvm_top, "*", "level", levels);
    `uvm_info("build_phase",$sformatf("levels=%0d",levels), UVM_NONE)

    void'(uvm_config_db#(uvm_bitstream_t)::get(this, "", "agents", agents)); //<allow from command-line
    if (agents <=0) begin
      `uvm_warning("build_phase",$sformatf("Detected agents <= 0 (%d); forcing to 1.",agents))
      agents = 1;
    end
    uvm_config_db#(shortint)::set(uvm_top, "*", "agents", agents);
    `uvm_info("build_phase",$sformatf("agents=%0d",agents), UVM_NONE)

    void'(uvm_config_db#(string)::get(this, "", "shape", tempstr)); //<allow from command-line
    if      (tempstr == "0") shape = shape_t'(0);
    else if (tempstr == "1") shape = shape_t'(1);
    `ifdef UVM_POST_VERSION_1_1
    else assert(shape_wrapper_t::from_name(tempstr, shape))
         else `uvm_error("build_phase",$sformatf("Illegal shape enum: '%s' from command-line", tempstr))
    `else
    else if (tempstr == "SHAPE_WIDE")   shape = SHAPE_WIDE;
    else if (tempstr == "SHAPE_NARROW") shape = SHAPE_NARROW;
    else `uvm_error("build_phase",$sformatf("Illegal shape enum: '%s' from command-line", tempstr))
    `endif
    uvm_config_db#(shape_t)::set(uvm_top, "*", "shape", shape);
    `uvm_info("build_phase",$sformatf("shape=%0d",shape), UVM_NONE)

    // Using a string option allows numeric values such as 1e6 or 1.5e3 instead
    // of raw integers on command-line
    tempstr = "";
    void'(uvm_config_db#(string)::get(this, "", "count", tempstr)); //<allow from command-line
    if (tempstr != "") begin
      real t;
      assert($sscanf(delete_chars(tempstr),"%g",t));
      count = 0 + t;
    end
    uvm_config_db#(longint)::set(uvm_top, "*", "count", count/agents);
    `uvm_info("build_phase",$sformatf("count=%0d",count), UVM_NONE)

    // Using a string option allows numeric values such as 1e6 or 1.5e3 instead
    // of raw integers on command-line
    tempstr = "";
    void'(uvm_config_db#(string)::get(this, "", "messages", tempstr)); //<allow from command-line
    if (tempstr != "") begin
      real t;
      assert($sscanf(delete_chars(tempstr),"%g",t));
      messages = 0 + t;
    end
    uvm_config_db#(longint)::set(uvm_top, "*", "messages", messages);
    `uvm_info("build_phase",$sformatf("messages=%0d",messages), UVM_NONE)

    // Using a string option allows numeric values such as 1e6 or 1.5e3 instead of raw integers
    tempstr = "";
    void'(uvm_config_db#(string)::get(this, "", "warnings", tempstr)); //<allow from command-line
    if (tempstr != "") begin
      real t;
      assert($sscanf(delete_chars(tempstr),"%g",t));
      warnings = 0 + t;
    end
    uvm_config_db#(longint)::set(uvm_top, "*", "warnings", warnings);
    `uvm_info("build_phase",$sformatf("warnings=%0d",warnings), UVM_NONE)

    void'(uvm_config_db#(uvm_bitstream_t)::get(this, "", "use_monitor", use_monitor)); //<allow from command-line
    uvm_config_db#(bit)::set(uvm_top, "*", "use_monitor", use_monitor);
    `uvm_info("build_phase",$sformatf("use_monitor=%0d",use_monitor), UVM_NONE)

    void'(uvm_config_db#(uvm_bitstream_t)::get(this, "", "bfm_object", bfm_object)); //<allow from command-line
    uvm_config_db#(bit)::set(uvm_top, "*", "bfm_object", bfm_object);
    `uvm_info("build_phase",$sformatf("bfm_object=%0d", bfm_object), UVM_NONE)

    void'(uvm_config_db#(uvm_bitstream_t)::get(this, "", "use_do", use_do)); //<allow from command-line
    uvm_config_db#(bit)::set(uvm_top, "*", "use_do", use_do);
    `uvm_info("build_phase",$sformatf("use_do=%0d", use_do), UVM_NONE)

    void'(uvm_config_db#(uvm_bitstream_t)::get(this, "", "use_seq", use_seq)); //<allow from command-line
    uvm_config_db#(int)::set(uvm_top, "*", "use_seq", use_seq);
    `uvm_info("build_phase",$sformatf("use_seq=%0d", use_seq), UVM_NONE)

    // Transaction-length specified in HEX to distinguish the nybbles
    tempstr = "";
    void'(uvm_config_db#(string)::get(this, "", "tr_len", tempstr)); //<allow from command-line
    if (tempstr != "") begin
      assert($sscanf(delete_chars(tempstr),"%h", tr_len));
    end
    uvm_config_db#(tr_len_t)::set(uvm_top, "*", "tr_len", tr_len);
    `uvm_info("build_phase",$sformatf("tr_len=%0d", tr_len), UVM_NONE)

    // Context-switching 0 or 1 only
    tempstr = "";
    void'(uvm_config_db#(string)::get(this, "", "switching", tempstr)); //<allow from command-line
    if (tempstr != "") begin
      assert($sscanf(tempstr,"%d", switching));
    end
    uvm_config_db#(longint)::set(uvm_top, "*", "switching", switching);
    `uvm_info("build_phase",$sformatf("switching=%0d", switching), UVM_NONE)

    // Propagate
    void'(uvm_config_db#(uvm_bitstream_t)::get(this, "", "propagate", m_propagate));
    `uvm_info("build_phase",$sformatf("propagate=%0d", m_propagate), UVM_NONE)

    // Instantiate environment
    m_env = My_env_t::type_id::create("m_env", this);
    `uvm_info("build_phase", $sformatf("Created %s", get_full_name()), UVM_NONE)
  endfunction : My_test_t::build_phase

  //----------------------------------------------------------------------------
  task My_test_t::reset_phase(uvm_phase phase);
    `uvm_info("build_phase",$sformatf("\n%s\nPREPARING\n%s", SEP1, SEP2), UVM_NONE)
  endtask : My_test_t::reset_phase

  //----------------------------------------------------------------------------
  task My_test_t::main_phase(uvm_phase phase);
    longint  count;
    longint  switching;
    time     delay;
    tr_len_t tr_len;
    shortint agents;
    int      use_seq = 1;
    bit      bfm_object = 1;
    shape_t  shape = SHAPE_WIDE;
    bit      use_monitor = 1;
    longint  messages = 0;
    longint  warnings = 0;
    uvm_component seqrs[$];
    uvm_top.set_timeout(1000ms);
    uvm_top.find_all("*m_sequencer*", seqrs);
    assert(uvm_config_db#(longint)  ::get(this, "", "count",       count));
    assert(uvm_config_db#(int     ) ::get(this, "", "use_seq",     use_seq));
    assert(uvm_config_db#(bit     ) ::get(this, "", "bfm_object",  bfm_object));
    void' (uvm_config_db#(shape_t ) ::get(this, "", "shape",       shape));
    assert(uvm_config_db#(bit     ) ::get(this, "", "use_monitor", use_monitor));
    assert(uvm_config_db#(tr_len_t) ::get(this, "", "tr_len",      tr_len));
    assert(uvm_config_db#(shortint) ::get(this, "", "agents",      agents));
    assert(uvm_config_db#(longint)  ::get(this, "", "switching",   switching));
    assert(uvm_config_db#(longint)  ::get(this, "", "messages",    messages));
    assert(uvm_config_db#(longint)  ::get(this, "", "warnings",    warnings));
    // just in case
    assert(count    >= 0);
    assert(agents   >= 1);
    assert(messages >= 0);
    assert(warnings >= 0);
    // Create brief string describing the features used
    if (use_seq == 0)        m_features = {m_features, "; short-seq"}; else m_features = {m_features, "; long-seq"};
    if (bfm_object == 0)     m_features = {m_features, "; no-bfm-objections"}; else m_features = {m_features, "; bfm-objections"};
    if (shape == SHAPE_WIDE) m_features = {m_features, "; wide"}; else m_features = {m_features, "; narrow"};
    if (use_monitor == 0)    m_features = {m_features, "; no-monitor"}; else m_features = {m_features, "; monitor"};
    if (tr_len != 0)         m_features = {m_features, $sformatf("; tr%0X", tr_len)};
    if (m_propagate == 0)    m_features = {m_features, "; non-prop"}; else m_features = {m_features, "; propagate"};
    if (switching == 0)      m_features = {m_features, "; limited-switching"};
    if (messages != 0)       m_features = {m_features, $sformatf("; Info%0d", messages)}; else m_features = {m_features, "; No runtime-info"};
    if (warnings != 0)       m_features = {m_features, $sformatf("; Warn%0d", warnings)}; else m_features = {m_features, "; No warnings"};
    phase.raise_objection(this, "raising to allow setup"); // allow setup
    m_starting_event = m_global_event_pool.get("starting");
    #2ps; // get ahead of drivers and monitors
    `uvm_info("main_phase", $sformatf("Running %0d x %s iterations%s", agents, formatn(count), m_features), UVM_NONE)
    phase.drop_objection(this, "lowering after setup");
    //////////////////////////////////////////////////////////////////////////
    //
    //   ####  #######    #    #####  #######
    //  #    #    #      # #   #    #    #
    //  #         #     #   #  #    #    #
    //   ####     #    #     # #####     #
    //       #    #    ####### #  #      #
    //  #    #    #    #     # #   #     #
    //   ####     #    #     # #    #    #
    //
    //////////////////////////////////////////////////////////////////////////
    `uvm_info("main_phase",$sformatf("\n%s\nRUNNING\n%s", SEP2, SEP3), UVM_NONE)
    m_starting_event.trigger();
    m_cpu_starting_time  = get_cpu_time();
    m_wall_starting_time = get_wall_time();
    phase.raise_objection(this, "raising to start top sequence"); // simulate sequence start
    g_measured_objections++;
    if (use_seq == 1) begin
      foreach (seqrs[i]) begin
        My_sequencer_t seqr;
        My_agent_t agent;
        if (!$cast(seqr, seqrs[i])) continue; // skip accidently named non-sequencers
        $cast(agent,seqr.get_parent());
        `uvm_info("DEBUG",$sformatf("Found sequencer[%0d] %0d.%0d", i, agent.m_level, seqr.m_id), UVM_DEBUG)
        fork 
          shortint id = i;
          begin
            My_agent_t     agent;
            My_sequencer_t seqr;
            My_sequence_t  seq;
            $cast(seqr, seqrs[id]);
            $cast(agent,seqr.get_parent());
            seq = My_sequence_t::type_id::create($sformatf("seq[%0d]", id));
            seq.m_id = seqr.m_id;
            seq.m_level = agent.m_level;
            `uvm_info("DEBUG",$sformatf("Starting %0d.%0d", seq.m_level, seq.m_id), UVM_DEBUG)
            seq.start(seqr);
          end
        join_none
        #1;
      end
      wait fork;
    end else begin // Don't run a normal sequence
      repeat (count) begin
        phase.raise_objection(this, "raising");
        #(`BUSY*`CLOCK_PERIOD);
        if (messages > 0) begin
          `uvm_info("run_phase","DUMMY data",UVM_MEDIUM)
          --messages;
        end
        phase.drop_objection(this, "lowering");
      end//repeat
    end
    phase.drop_objection(this, "lowering at end of top sequence"); // simulate sequence done
    #1ps;
  endtask : My_test_t::main_phase
  //--------------------------------------------------------------------------
  function void My_test_t::extract_phase(uvm_phase phase);
    m_cpu_finished_time  = get_cpu_time();
    m_wall_finished_time = get_wall_time();
    `uvm_info("main_phase",$sformatf("\n%s\nENDING\n%s", SEP4, SEP5), UVM_NONE)
  endfunction : My_test_t::extract_phase
  //--------------------------------------------------------------------------
  function void My_test_t::report_phase(uvm_phase phase);
    longint cpu_ms, wall_ms;
    string sep1, sep2, summary;
    sep1 = {"\n",SEP6, "\n"};
    cpu_ms  = 1000 * ( m_cpu_finished_time   - m_cpu_starting_time  );
    wall_ms = 1000 * ( m_wall_finished_time  - m_wall_starting_time );
    summary =           $sformatf(  "#   %s transactions created", formatn(My_transaction_t::s_count));
    summary = {summary, $sformatf("\n#   Normal objections: %0d", g_measured_objections)};
    summary = {summary, $sformatf("\n#   Extend objections: %0d", g_extended)};
    summary = {summary, $sformatf("\n#   CPU  starting time: %f", m_cpu_starting_time)};
    summary = {summary, $sformatf("\n#   CPU  finished time: %f", m_cpu_finished_time)};
    summary = {summary, $sformatf("\n#   Wall starting time: %f", m_wall_starting_time)};
    summary = {summary, $sformatf("\n#   Wall finished time: %f", m_wall_finished_time)};
    summary = {summary, $sformatf("\n#   RESULT: %s objected %s times in %s ms CPU %s ms WALL%s"
                        , `UVM_VERSION_STRING
                        , formatn(g_measured_objections + g_extended)
                        , formatn(cpu_ms)
                        , formatn(wall_ms)
                        , m_features
                        )
              };
    `uvm_info("report_phase", $sformatf("\n%s\nSUMMARY:\n%s\n%s", sep1, summary, sep2), UVM_NONE)
  endfunction : My_test_t::report_phase
  //--------------------------------------------------------------------------

//EOF: my_test.sv
//Continue: performance_pkg.sv
endpackage : Performance_pkg

//EOF: performance_pkg.sv
//File: top.sv
////////////////////////////////////////////////////////////////////////////////
//
//  #######  ####  ##### 
//     #    #    # #    #
//     #    #    # #    #
//     #    #    # ##### 
//     #    #    # #     
//     #    #    # #     
//     #     ####  #     
//
//Inline: COPYRIGHT.txt
////////////////////////////////////////////////////////////////////////////////
//Include: defines.svh
//Include: uvm_macros.svh
module Top;
  //----------------------------------------------------------------------------
  timeunit 1ps;
  timeprecision 1ps;
  //----------------------------------------------------------------------------
  import uvm_pkg::*;
  import Performance_pkg::*;
  //----------------------------------------------------------------------------
  initial begin
    uvm_top.enable_print_topology = 1;
    uvm_config_db#(virtual My_intf)::set(null,"*","vif", harness.if1);
    // FUTURE: genvar loop to hookup interface pairs
    run_test("My_test_t");
  end

endmodule : Top

//EOF: top.sv
