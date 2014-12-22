//File: defines.svh

`ifndef USE_HDW
  `define USE_HDW
`endif

// DESCRIPTION:
//   This code is designed to test relative runtime performance of various UVM
//   versions, implementations, and associated simulators.
//
// Conventions used in this code:
// 1. All modules, interfaces, packages, and classes have capitalized names.
//    Classes furthermore have an _t suffix to indicate they represent a data type.
// 2. Member data other than ports use m_ prefix.

// This code has the following run-time configuration variables:
//
// +uvm_set_config_int=*,agents,NUMBER specifies how many agents to instantiate
// +uvm_set_config_int=*,bfm_object,BIT specifies if driver/monitor should raise/drop objections
// +uvm_set_config_int=*,level,NUMBER specifies depth of hierarchy to agents
// +uvm_set_config_int=*,reports,NUMBER specifies the number of reports to send (default 0)
// +uvm_set_config_int=*,ripple,BIT specifies for UVM 1.2 whether to propagate objections
// +uvm_set_config_int=*,shape,BIT specifies where agents split
// +uvm_set_config_int=*,switching,NUMBER specifies context switching variations
// +uvm_set_config_int=*,use_monitor,BIT specifies use of monitor
// +uvm_set_config_int=*,use_seq,BIT specifies if sequence is long (1) or short (0)
// +uvm_set_config_string=*,count,NUMBER specifies how many transactions to run
// +uvm_set_config_string=*,messages,NUMBER specifies if info messages to be enabled (0)
// +uvm_set_config_string=*,tr_len,HEX specifies transaction lengths in nybbles
// +uvm_set_config_string=*,warnings,NUMBER specifies if warning messages to be enabled (0)

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

typedef logic [`BITS:0] Data_t; // Used for hardware data register size

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
////////////////////////////////////////////////////////////////////////////////
// Display `define status
//Include: defines.svh
module Elaborate;
  //----------------------------------------------------------------------------
  timeunit 1ps;
  timeprecision 1ps;
  //----------------------------------------------------------------------------
  initial begin
    $display("HDW_INFO: CLOCK_PERIOD=%0t",`CLOCK_PERIOD);
    $display("HDW_INFO: BUSY=%0d",`BUSY);
    $display("HDW_INFO: BITS=%0d",`BITS);
    `ifdef USE_HDW
    $display("HDW_INFO: USE_HDW defined");
    `else
    $display("HDW_INFO: No using HDW");
    `endif
    `ifdef USE_CLOCKING
    $display("HDW_INFO: USE_CLOCKING defined");
    `else
    $display("HDW_INFO: No using clocking block");
    `endif
    `ifdef USE_DO
    $display("HDW_INFO: USE_DO defined enable use of uvm_do macros");
    `else
    $display("HDW_INFO: No uvm_do macros");
    `endif
    `ifdef HDW_NOISE
    $display("HDW_INFO: HDW_NOISE defined to show initial %0d clocks of HDW activity",`HDW_NOISE);
    `else
    $display("HDW_INFO: HDW silent");
    `endif
  end
endmodule

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
////////////////////////////////////////////////////////////////////////////////
//Include: defines.svh
interface My_intf ( input bit clock );
  logic  reset;
  logic  is_busy;
  Data_t data;
  Data_t result;
  modport hdw_mp(output reset, input is_busy, input data, input clock, input result);
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
////////////////////////////////////////////////////////////////////////////////
//Include: defines.svh
// NOTE: Uses typedef Data_t; otherwise, normal HDW style design
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
  always @(data or reset) begin : FF
    #1ps;
    @(posedge clock);
    if (reset) begin
      result <= 0;
      busy(`BUSY);
    end else begin
      result <= #((`BUSY-1)*`CLOCK_PERIOD) result ^ data; // Propagation delay
      busy(`BUSY);
    end
  end : FF
  `ifdef HDW_NOISE
  // Generate lots of data to show operation (normally off)
  initial begin
    $display("HDW: reset clock is_busy data result");
    $monitor("HDW: %t %b %b %b %h %h",$time,reset,clock,is_busy,data,result);
    repeat (`HDW_NOISE) @(posedge clock);
    $monitoroff;
    $display("HDW: end of noise");
  end
  `endif
endmodule : Design

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

  `ifdef UVM_POST_VERSION_1_1
  typedef uvm_integral_t integral_t;
  `else
  typedef uvm_bitstream_t integral_t;
  `endif
  typedef integral_t tr_len_t;
  //typedef enum bit { SHAPE_WIDE, SHAPE_NARROW } shape_t;
  typedef shortint shape_t;
  const shape_t SHAPE_WIDE=0, SHAPE_NARROW=1;

  longint unsigned measured_objections = 0;

  function automatic void bound_tr_len(ref tr_len_t tr_len, input shortint id);
      tr_len = (tr_len >> (4*id)) & 'hF;
      if (tr_len <= 0) begin 
        tr_len = 1; // always at least one
      end//if
  endfunction : bound_tr_len

//IFile: my_transaction.svh
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
    rand bit     m_reset = 0;
    rand integer m_data  = 'hDEADBEEF;
    `uvm_object_utils_begin(My_transaction_t)
      `uvm_field_int(m_reset, UVM_DEFAULT)
      `uvm_field_int(m_data,  UVM_DEFAULT)
    `uvm_object_utils_end
    //--------------------------------------------------------------------------
    // Constructor
    function new(string name="");
      super.new(name);
    endfunction
    //--------------------------------------------------------------------------
    function string convert2string;
      return $sformatf("{R=%s D=%0h}",m_reset,m_data);
    endfunction
    //--------------------------------------------------------------------------
    constraint reset_constraint { m_reset dist { 0 := 99, 1 := 1 }; }
    //--------------------------------------------------------------------------
  endclass : My_transaction_t

//IFile: my_sequencer.svh
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

//IFile: my_sequence.svh
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
    shortint m_id     = -1;
    tr_len_t m_tr_len = 1;
    longint  m_count  = 0;
    longint  m_reps;
    //--------------------------------------------------------------------------
    // Constructor
    function new(string name="");
      super.new(name);
    endfunction
    //--------------------------------------------------------------------------
    extern task pre_start;
    extern task body;
    extern task post_start;
    //--------------------------------------------------------------------------
  endclass : My_sequence_t

//IFile: my_sequence.sv
  //----------------------------------------------------------------------------
  task My_sequence_t::pre_start;
    assert(m_id >= 0);
    assert(uvm_config_db#(longint) ::get(p_sequencer, "", "count",  m_count));
    assert(uvm_config_db#(tr_len_t)::get(p_sequencer, "", "tr_len", m_tr_len));
    bound_tr_len(m_tr_len, m_id);
    m_reps = m_count/m_tr_len;
    `uvm_info("DEBUG",$sformatf("Starting %0d for %0d repetitions",m_id,m_reps), UVM_DEBUG)
  endtask : My_sequence_t::pre_start
  //----------------------------------------------------------------------------
  task My_sequence_t::body;
    // Perform a simple reset when starting
    `ifdef USE_DO
    `uvm_do_with(req,{m_reset == 1;})
    `else
    req = My_transaction_t::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {m_reset == 1;}) `uvm_error("Performance","Unable to randomize reset transaction")
    finish_item(req);
    `endif
    repeat (m_reps) begin
      `ifdef USE_DO
      `uvm_do(req)
      `else
      req = My_transaction_t::type_id::create("req");
      start_item(req);
      if (!req.randomize()) `uvm_error("Performance","Unable to randomize reset transaction")
      finish_item(req);
      `endif
    end
  endtask : My_sequence_t::body
  //----------------------------------------------------------------------------
  task My_sequence_t::post_start;
    `uvm_info("DEBUG",$sformatf("Ending %0d",m_id), UVM_DEBUG)
  endtask : My_sequence_t::post_start

//IFile: my_driver.svh
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
    uvm_event_pool  m_global_event_pool;
    uvm_event       m_starting_event;
    virtual My_intf m_vif;
    bit             m_object   = 1;
    longint         m_count    = 0;
    longint         m_messages = 0;
    shortint        m_id       = 0;
    longint         m_switching;
    tr_len_t        m_tr_len;
    //--------------------------------------------------------------------------
    // Constructor
    function new(string name, uvm_component parent);
      super.new(name, parent);
      m_global_event_pool = uvm_event_pool::get_global_pool();
    endfunction : new
    //--------------------------------------------------------------------------
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    //--------------------------------------------------------------------------
  endclass : My_driver_t

//IFile: my_driver.sv
  //----------------------------------------------------------------------------
  function void My_driver_t::connect_phase(uvm_phase phase);
    `uvm_info("", "Created", UVM_NONE)
    m_starting_event = m_global_event_pool.get("starting");
    assert(uvm_config_db#(bit)     ::get(this, "", "bfm_object", m_object));
    assert(uvm_config_db#(longint) ::get(this, "", "messages",   m_messages));
    assert(uvm_config_db#(longint) ::get(this, "", "switching",  m_switching));
    assert(uvm_config_db#(tr_len_t)::get(this, "", "tr_len",     m_tr_len));
    bound_tr_len(m_tr_len, m_id);
  endfunction : My_driver_t::connect_phase
  //----------------------------------------------------------------------------
  task My_driver_t::run_phase(uvm_phase phase);
    string obj_name = $sformatf("driver[%0d]",m_id);
    if (m_object) phase.raise_objection(this, "Raise to get off zero");
    #1; // Get off zero
    if (m_object) phase.drop_objection(this, "Drop and wait to start");
    measured_objections += m_count/m_tr_len;
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
    forever begin
      seq_item_port.get(req);
      if (m_object) phase.raise_objection(this, obj_name);
      if (m_switching == 1) begin // normal context switching
        repeat (m_tr_len) begin
          #1ps;
          if (m_id == 0 && m_messages > 0) begin
            `uvm_info("run_phase",$sformatf("Data=%h",req.m_data),UVM_MEDIUM)
            --m_messages;
          end
          `ifdef USE_HDW
          m_vif.reset <= req.m_reset;
          m_vif.data  <= req.m_data;
          @(posedge m_vif.is_busy); // Wait for data to be taken
          m_vif.reset <= 0;
          m_vif.data  <= 0;
          @(negedge m_vif.is_busy); // Wait for design to become ready
          `endif
        end //repeat
      end //if
      if (m_object) phase.drop_objection(this, obj_name);
    end//forever
  endtask : My_driver_t::run_phase
  //----------------------------------------------------------------------------

//IFile: my_monitor.svh
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
    uvm_event_pool  m_global_event_pool;
    uvm_event       m_starting_event;
    bit             m_monitor  = 1;
    bit             m_object   = 1;
    longint         m_count    = 0;
    longint         m_warnings = 0;
    shortint        m_id       = 0;
    virtual My_intf m_vif;
    //--------------------------------------------------------------------------
    // Constructor
    function new(string name, uvm_component parent);
      super.new(name, parent);
      m_global_event_pool = uvm_event_pool::get_global_pool();
    endfunction : new
    //--------------------------------------------------------------------------
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    //--------------------------------------------------------------------------
  endclass : My_monitor_t

//IFile: my_monitor.sv
  //----------------------------------------------------------------------------
  function void My_monitor_t::connect_phase(uvm_phase phase);
    `uvm_info("build_phase", "Created", UVM_NONE)
    m_starting_event = m_global_event_pool.get("starting");
    assert(uvm_config_db#(bit)    ::get(this, "", "use_monitor", m_monitor));
    assert(uvm_config_db#(bit)    ::get(this, "", "bfm_object",  m_object));
    assert(uvm_config_db#(longint)::get(this, "", "count",       m_count));
    assert(uvm_config_db#(longint)::get(this, "", "warnings",    m_warnings));
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
    if (m_monitor) begin
      forever begin
        @(posedge m_vif.is_busy);
        if (m_object) phase.raise_objection(this, obj_name);
        if (m_id == 0 && m_warnings > 0) begin
          `uvm_warning("Driver","<warn>")
          --m_warnings;
        end
        @(negedge m_vif.is_busy);
        if (m_object) phase.drop_objection(this, obj_name);
      end//repeat
    end
  endtask : My_monitor_t::run_phase
  //----------------------------------------------------------------------------

//IFile: my_agent.svh
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

//IFile: my_agent.sv
  //----------------------------------------------------------------------------
  function void My_agent_t::build_phase(uvm_phase phase);
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

//IFile: my_env.svh
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
    // Class member data
    shortint   m_toplevel = 0;
    shortint   m_level = -1; // invalid
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
    //--------------------------------------------------------------------------
  endclass : My_env_t

//IFile: my_env.sv
  //----------------------------------------------------------------------------
  function void My_env_t::build_phase(uvm_phase phase);
    string inst_nm;
    shortint unsigned width = 1;
    void'(uvm_config_db#(shape_t)::get(this, "", "shape", m_shape));
    assert(uvm_config_db#(shortint)::get(this, "", "agents", width))
    else `uvm_error("Performance","Missing agent configuration")
    if (m_level == m_toplevel) begin
      if (m_shape == SHAPE_NARROW) width = 1;
      inst_nm = $sformatf("uvc_l%0d",m_level);
      m_uvc = new[width];
      for (shortint unsigned i=0; i!=width; i++) begin
        m_uvc[i] = My_env_t::type_id::create($sformatf("%s[%0d]",inst_nm,i),this);
        m_uvc[i].m_level = this.m_level-1;
      end
    end else if (m_level > 0) begin
      inst_nm = $sformatf("uvc_l%0d",m_level);
      m_uvc = new[1];
      m_uvc[0] = My_env_t::type_id::create(inst_nm,this);
      m_uvc[0].m_level = this.m_level-1;
    end else begin // Bottom
      if (m_shape == SHAPE_WIDE) width = 1;
      m_agent = new[width];
      for (shortint unsigned i=0; i!=width; i++) begin
        m_agent[i] = My_agent_t::type_id::create($sformatf("m_agent[%0d]",i),this);
        m_agent[i].m_id = i%($bits(tr_len_t)/4);
        m_agent[i].m_level = this.m_level;
      end
    end
  endfunction : My_env_t::build_phase
  //----------------------------------------------------------------------------

//IFile: my_test.svh
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
    uvm_event_pool   m_global_event_pool;
    uvm_event        m_starting_event;
    real             m_cpu_starting_time,  m_cpu_finished_time;
    real             m_wall_starting_time, m_wall_finished_time;
    string           m_features = "";
    //--------------------------------------------------------------------------
    // Constructor
    function new(string name, uvm_component parent);
      super.new(name, parent);
      m_global_event_pool = uvm_event_pool::get_global_pool();
    endfunction
    //--------------------------------------------------------------------------
    extern function void build_phase(uvm_phase phase);
    extern task reset_phase(uvm_phase phase);
    extern task main_phase(uvm_phase phase);
    extern task shutdown_phase(uvm_phase phase);
    extern function void extract_phase(uvm_phase phase);
    extern function void report_phase(uvm_phase phase);
    //--------------------------------------------------------------------------
  endclass : My_test_t

//IFile: my_test.sv
  //----------------------------------------------------------------------------
  function void My_test_t::build_phase(uvm_phase phase);
    longint  count          = 1e6; //< default
    longint  switching      = 1;   //< default
    bit      use_seq        = 1;   //< default
    bit      use_monitor    = 1;   //< default
    bit      bfm_object     = 1;   //< default
    shortint levels         = 2;   //< default
    shortint agents         = 1;   //< default
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
    void'(uvm_config_db#(integral_t)::get(this, "", "level", levels)); //<allow from command-line
    uvm_config_db#(shortint)::set(uvm_top, "*", "level", levels);
    `uvm_info("build_phase",$sformatf("levels=%0d",levels), UVM_NONE);

    void'(uvm_config_db#(integral_t)::get(this, "", "agents", agents)); //<allow from command-line
    uvm_config_db#(shortint)::set(uvm_top, "*", "agents", agents);
    `uvm_info("build_phase",$sformatf("agents=%0d",agents), UVM_NONE);

    // Using a string option allows numeric values such as 1e6 or 1.5e3 instead
    // of raw integers on command-line
    tempstr = "";
    void'(uvm_config_db#(string)::get(this, "", "count", tempstr)); //<allow from command-line
    if (tempstr != "") begin
      real t;
      assert($sscanf(tempstr,"%g",t));
      count = 0 + t;
    end
    uvm_config_db#(longint)::set(uvm_top, "*", "count", count);
    `uvm_info("build_phase",$sformatf("count=%0d",count), UVM_NONE);

    // Using a string option allows numeric values such as 1e6 or 1.5e3 instead
    // of raw integers on command-line
    tempstr = "";
    void'(uvm_config_db#(string)::get(this, "", "messages", tempstr)); //<allow from command-line
    if (tempstr != "") begin
      real t;
      assert($sscanf(tempstr,"%g",t));
      messages = 0 + t;
    end
    uvm_config_db#(longint)::set(uvm_top, "*", "messages", messages);
    `uvm_info("build_phase",$sformatf("messages=%0d",messages), UVM_NONE);

    // Using a string option allows numeric values such as 1e6 or 1.5e3 instead of raw integers
    tempstr = "";
    void'(uvm_config_db#(string)::get(this, "", "warnings", tempstr)); //<allow from command-line
    if (tempstr != "") begin
      real t;
      assert($sscanf(tempstr,"%g",t));
      warnings = 0 + t;
    end
    uvm_config_db#(longint)::set(uvm_top, "*", "warnings", warnings);
    `uvm_info("build_phase",$sformatf("warnings=%0d",warnings), UVM_NONE);

    void'(uvm_config_db#(integral_t)::get(this, "", "use_monitor", use_monitor)); //<allow from command-line
    uvm_config_db#(bit)::set(uvm_top, "*", "use_monitor", use_monitor);
    `uvm_info("build_phase",$sformatf("use_monitor=%0d",use_monitor), UVM_NONE);

    void'(uvm_config_db#(integral_t)::get(this, "", "bfm_object", bfm_object)); //<allow from command-line
    uvm_config_db#(bit)::set(uvm_top, "*", "bfm_object", bfm_object);
    `uvm_info("build_phase",$sformatf("bfm_object=%0d", bfm_object), UVM_NONE);

    void'(uvm_config_db#(integral_t)::get(this, "", "use_seq", use_seq)); //<allow from command-line
    uvm_config_db#(bit)::set(uvm_top, "*", "use_seq", use_seq);
    `uvm_info("build_phase",$sformatf("use_seq=%0d", use_seq), UVM_NONE);

    // Transaction-length specified in HEX to distinguish the nybbles
    tempstr = "";
    void'(uvm_config_db#(string)::get(this, "", "tr_len", tempstr)); //<allow from command-line
    if (tempstr != "") begin
      assert($sscanf(tempstr,"%h", tr_len));
    end
    uvm_config_db#(tr_len_t)::set(uvm_top, "*", "tr_len", tr_len);
    `uvm_info("build_phase",$sformatf("tr_len=%0d", tr_len), UVM_NONE);

    // Context-switching 0 or 1 only
    tempstr = "";
    void'(uvm_config_db#(string)::get(this, "", "switching", tempstr)); //<allow from command-line
    if (tempstr != "") begin
      assert($sscanf(tempstr,"%d", switching));
    end
    uvm_config_db#(longint)::set(uvm_top, "*", "switching", switching);
    `uvm_info("build_phase",$sformatf("switching=%0d", switching), UVM_NONE);

    // Instantiate environment
    m_env = My_env_t::type_id::create("m_env", this);
    m_env.m_toplevel = levels;
    `uvm_info("", $sformatf("Created %s", get_full_name()), UVM_NONE)
  endfunction : My_test_t::build_phase

  //----------------------------------------------------------------------------
  task My_test_t::reset_phase(uvm_phase phase);
    `uvm_info("build_phase",$sformatf("%s\nRUNNING\n%s", SEP1, SEP2), UVM_NONE);
  endtask : My_test_t::reset_phase

  //----------------------------------------------------------------------------
  task My_test_t::main_phase(uvm_phase phase);
    longint  count;
    longint  switching;
    time     delay;
    tr_len_t tr_len;
    shortint agents;
    bit      use_seq = 1;
    bit      bfm_object = 1;
    bit      shape = SHAPE_WIDE;
    bit      use_monitor = 1;
    bit      mode = 1; //< default old way
    longint  messages = 0;
    longint  warnings = 0;
    uvm_objection objection;
    uvm_component seqrs[$];
    uvm_top.find_all("*m_sequencer*", seqrs);
    assert(uvm_config_db#(longint)  ::get(this, "", "count",       count));
    assert(uvm_config_db#(bit     ) ::get(this, "", "use_seq",     use_seq));
    assert(uvm_config_db#(bit     ) ::get(this, "", "bfm_object",  bfm_object));
    void' (uvm_config_db#(bit     ) ::get(this, "", "shape",       shape));
    assert(uvm_config_db#(bit     ) ::get(this, "", "use_monitor", use_monitor));
    assert(uvm_config_db#(tr_len_t) ::get(this, "", "tr_len",      tr_len));
    assert(uvm_config_db#(shortint) ::get(this, "", "agents",      agents));
    assert(uvm_config_db#(longint)  ::get(this, "", "switching",   switching));
    assert(uvm_config_db#(longint)  ::get(this, "", "messages",    messages));
    assert(uvm_config_db#(longint)  ::get(this, "", "warnings",    warnings));
    // just in case
    assert(count    >= 10);
    assert(agents   >= 1);
    assert(messages >= 0);
    assert(warnings >= 0);
    objection = phase.get_objection();
    `ifdef UVM_POST_VERSION_1_1
    void'(uvm_config_db#(integral_t)::get(this, "", "ripple", mode));
    objection.set_propagate_mode(mode);
    `endif
    // Create brief string describing the features used
    if (use_seq == 0)     m_features = {m_features, "; short-seq"}; else m_features = {m_features, "; long-seq"};
    if (bfm_object == 0)  m_features = {m_features, "; no-bfm-objections"}; else m_features = {m_features, "; bfm-objections"};
    if (shape == 0)       m_features = {m_features, "; wide"}; else m_features = {m_features, "; narrow"};
    if (use_monitor == 0) m_features = {m_features, "; no-monitor"}; else m_features = {m_features, "; monitor"};
    if (tr_len != 0)      m_features = {m_features, $sformatf("; tr%0X", tr_len)};
    if (mode == 0)        m_features = {m_features, "; non-prop"}; else m_features = {m_features, "; propagate"};
    if (switching == 0)   m_features = {m_features, "; limited-switching"};
    if (messages != 0)    m_features = {m_features, $sformatf("; Info%0d", messages)};
    if (warnings != 0)    m_features = {m_features, $sformatf("; Warn%0d", warnings)};
    objection.set_drain_time(uvm_top, 2*`CLOCK_PERIOD);
    uvm_top.set_timeout(1000ms);
    phase.raise_objection(this, "raising to allow setup"); // allow setup
    m_starting_event = m_global_event_pool.get("starting");
    #2ps; // get ahead of drivers and monitors
    `uvm_info("main_phase", $sformatf("Running %0d x %s iterations%s", agents, formatn(count), m_features), UVM_NONE)
    phase.drop_objection(this, "lowering after setup");
    measured_objections += 1;
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
    m_starting_event.trigger();
    m_cpu_starting_time  = get_cpu_time();
    m_wall_starting_time = get_wall_time();
    phase.raise_objection(this, "raising to start top sequence"); // simulate sequence start
    begin
      foreach (seqrs[i]) begin
        My_sequencer_t seqr;
        My_sequence_t seq;
        if (!$cast(seqr, seqrs[i])) continue; // skip accidently named non-sequencers
        seq = My_sequence_t::type_id::create($sformatf("seq[%0d]", i));
        seq.m_id = seqr.m_id;
        fork 
          shortint id = i;
          begin
            `uvm_info("DEBUG",$sformatf("Starting %0d", seq.m_id), UVM_DEBUG)
            seq.start(seqr);
          end
        join_none
        #1;
      end
      wait fork;
      `uvm_info("DEBUG","All forked processes completed", UVM_DEBUG)
    end
    phase.drop_objection(this, "lowering at end of top sequence"); // simulate sequence done
    #1ps;
  endtask : My_test_t::main_phase
  //--------------------------------------------------------------------------
  task My_test_t::shutdown_phase(uvm_phase phase);
    phase.raise_objection(this, "raising to extend driver time"); // simulate sequence start
    #(10*`CLOCK_PERIOD);
    phase.drop_objection(this, "lowering to end extension"); // simulate sequence done
  endtask : My_test_t::shutdown_phase
  //--------------------------------------------------------------------------
  function void My_test_t::extract_phase(uvm_phase phase);
    m_cpu_finished_time  = get_cpu_time();
    m_wall_finished_time = get_wall_time();
  endfunction : My_test_t::extract_phase
  //--------------------------------------------------------------------------
  function void My_test_t::report_phase(uvm_phase phase);
    longint cpu_ms, wall_ms;
    cpu_ms  = 1000 * ( m_cpu_finished_time   - m_cpu_starting_time  );
    wall_ms = 1000 * ( m_wall_finished_time  - m_wall_starting_time );
    `uvm_info("report_phase"
             , $sformatf("RESULT: %s objected %s times in %s ms CPU %s ms WALL%s"
                        , `UVM_VERSION_STRING
                        , formatn(measured_objections)
                        , formatn(cpu_ms)
                        , formatn(wall_ms)
                        , m_features
                        )
             , UVM_NONE
             )
  endfunction : My_test_t::report_phase
  //--------------------------------------------------------------------------

//Continue: performance_pkg.sv
endpackage : Performance_pkg

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

//EOF
