`include "uvm_macros.svh"

`define USE_RTL

// DESCRIPTION:
//   This code is designed to test relative runtime performance of various UVM
//   versions, implementations, and associated simulators.

// This code has the following run-time configuration variables:
//
// +uvm_set_config_int=*,level,NUMBER specifies depth of hierarchy to agents
// +uvm_set_config_int=*,agents,NUMBER specifies how many agents to instantiate
// +uvm_set_config_int=*,use_seq,BIT specifies if sequence is long (1) or short (0)
// +uvm_set_config_string=*,tr_len,HEX specifies transaction lengths in nybbles
// +uvm_set_config_string=*,count,NUMBER specifies how many transactions to run
// +uvm_set_config_string=*,messages,NUMBER specifies if info messages to be enabled (0)
// +uvm_set_config_string=*,warnings,NUMBER specifies if warning messages to be enabled (0)
// +uvm_set_config_int=*,ripple,BIT specifies for UVM 1.2 whether to propagate objections
// +uvm_set_config_int=*,switching,NUMBER specifies context switching variations
// +uvm_set_config_int=*,reports,NUMBER specifies the number of reports to send (default 0)

// The following affect the static design
`ifndef PERIOD
  `define PERIOD 4ns
`endif
`ifndef BUSY
  `define BUSY 4 /*clocks*/
`endif
`ifndef BITS
  `define BITS 32
`endif

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
module Elaborate;
  //----------------------------------------------------------------------------
  timeunit 1ps;
  timeprecision 1ps;
  //----------------------------------------------------------------------------
  initial begin
    $display("RTL_INFO: PERIOD=%0t",`PERIOD);
    $display("RTL_INFO: BUSY=%0d",`BUSY);
    $display("RTL_INFO: BITS=%0d",`BITS);
    `ifdef USE_RTL
    $display("RTL_INFO: USE_RTL defined");
    `else
    $display("RTL_INFO: No using RTL");
    `endif
    `ifdef USE_MONITOR
    $display("RTL_INFO: USE_MONITOR defined");
    `else
    $display("RTL_INFO: No using active monitor");
    `endif
    `ifdef USE_CLOCKING
    $display("RTL_INFO: USE_CLOCKING defined");
    `else
    $display("RTL_INFO: No using clocking block");
    `endif
    `ifdef USE_DO
    $display("RTL_INFO: USE_DO defined enable use of uvm_do macros");
    `else
    $display("RTL_INFO: No uvm_do macros");
    `endif
    `ifdef RTL_NOISE
    $display("RTL_INFO: RTL_NOISE defined to show initial %0d clocks of RTL activity",`RTL_NOISE);
    `else
    $display("RTL_INFO: RTL silent");
    `endif
  end
endmodule

typedef logic [`BITS:0] Data_t; // Used for hardware data register size

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
interface My_intf ( input bit clk );
  logic  reset;
  logic  busy;
  Data_t data;
  Data_t result;
  modport rtl_mp(output reset, input busy, input data, input clk, input result);
`ifdef USE_CLOCKING
  clocking cb @(posedge clk);
    output #1step data;
    input  #0     result;
    input  #0     busy;
  endclocking : cb
  modport test_mp(output reset, clocking cb);
`else
  modport test_mp(output reset, data, input clk, busy, result);
`endif
endinterface : My_intf

////////////////////////////////////////////////////////////////////////////////
//
//  #####  ####### #    
//  #    #    #    #    
//  #    #    #    #    
//  #####     #    #    
//  #  #      #    #    
//  #   #     #    #    
//  #    #    #    #####
//
////////////////////////////////////////////////////////////////////////////////
// NOTE: Uses typedef Data_t; otherwise, normal RTL style design
module VerilogDesign
        ( input reset
        , input clk
        , input Data_t data
        , output var Data_t result
        , output var busy
        );
  //----------------------------------------------------------------------------
  timeunit 1ps;
  timeprecision 1ps;
  //----------------------------------------------------------------------------
  task Busy(int unsigned cycles);
    busy <= 1;
    repeat (cycles) @(posedge clk);
    busy <= 0;
  endtask : Busy
  always_ff @(posedge clk) begin : FF
    if (reset) begin
      result <= 0;
      Busy(`BUSY);
    end
    else begin
      result <= result + data;
      Busy(`BUSY);
    end
  end : FF
  `ifdef RTL_NOISE
  initial begin
    $display("RTL: reset clk busy data result");
    $monitor("RTL: %t %b %b %b %h %h",$time,reset,clk,busy,data,result);
    repeat (`RTL_NOISE) @(posedge clk);
    $monitoroff;
    $display("RTL: end of noise");
  end
  `endif
endmodule : VerilogDesign

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
module Harness;
  //----------------------------------------------------------------------------
  timeunit 1ps;
  timeprecision 1ps;
  //----------------------------------------------------------------------------
  bit clk = 0;
  `ifdef USE_RTL
  always #(`PERIOD/2) ++clk;
  `endif
  // TODO: genvar loop to create many dut/interface pairs
  My_intf if1 ( .clk );
  VerilogDesign dut1
                ( .reset(if1.reset)
                , .clk
                , .data(if1.data)
                , .result(if1.result)
                , .busy(if1.busy)
                );
endmodule : Harness
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
package performance_pkg;

  timeunit 1ps;
  timeprecision 1ps;

  import uvm_pkg::*;
  `include "get_time.svh"
  `include "formatn.svh"

  // Convenience strings to make output more distinct in the log file.
  string SEP1 = {122{"#"}};
  string SEP2 = {120{"="}};

  typedef uvm_integral_t tr_len_t;

  longint unsigned measured_objections = 0;

  function automatic void bound_tr_len(ref tr_len_t tr_len, input shortint id);
      tr_len = (tr_len >> (4*id)) & 'hF;
      if (tr_len <= 0) tr_len = 1; // always at least one
  endfunction : bound_tr_len

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
    // TODO: Measure field automation macros
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
  endclass : My_transaction_t

  //typedef uvm_event_pool       Event_pool_t;
  //typedef uvm_event            Event_t;

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
    shortint m_id   = -1;
    tr_len_t m_tr_len = 1;
    longint  m_count  = 0;
    longint  m_reps;
    //--------------------------------------------------------------------------
    // Constructor
    function new(string name="");
      super.new(name);
    endfunction
    //--------------------------------------------------------------------------
    task pre_start;
      assert(m_id >= 0);
      assert(uvm_config_db#(longint) ::get(p_sequencer, "", "count", m_count));
      assert(uvm_config_db#(tr_len_t)::get(p_sequencer, "", "tr_len", m_tr_len));
      bound_tr_len(m_tr_len, m_id);
      m_reps = m_count/m_tr_len;
      `uvm_info("DEBUG",$sformatf("Starting %0d for %0d repetitions",m_id,m_reps), UVM_DEBUG)
    endtask : pre_start
    //--------------------------------------------------------------------------
    task body;
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
    endtask : body
    //--------------------------------------------------------------------------
    task post_start;
      `uvm_info("DEBUG",$sformatf("Ending %0d",m_id), UVM_DEBUG)
    endtask : post_start
    //--------------------------------------------------------------------------
  endclass : My_sequence_t

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
    uvm_event_pool    global_event_pool;
    uvm_event         starting_event;
    longint           count    = 0;
    longint           messages = 0;
    shortint          m_id     = 0;
    virtual My_intf   vif;
    //--------------------------------------------------------------------------
    // Constructor
    function new(string name, uvm_component parent);
      super.new(name, parent);
      global_event_pool = uvm_event_pool::get_global_pool();
    endfunction : new
    //--------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
      `uvm_info("", "Created", UVM_NONE)
    endfunction : build_phase
    //--------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
      tr_len_t tr_len;
      longint  switching;
      string   obj_name = $sformatf("driver[%0d]",m_id);
      phase.raise_objection(this, "Begin reset");
      #1; // Get off zero
      phase.drop_objection(this, "End reset");
      starting_event = global_event_pool.get("starting");
      assert(uvm_config_db#(longint)::get(this, "", "messages", messages));
      assert(uvm_config_db#(longint)::get(this, "", "switching", switching));
      assert(uvm_config_db#(tr_len_t)::get(this, "", "tr_len", tr_len));
      bound_tr_len(tr_len, m_id);
      measured_objections += count/tr_len;
      starting_event.wait_trigger();
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
      if (switching == 0) #1;
      forever begin
        seq_item_port.get(req);
        phase.raise_objection(this, obj_name);
        if (switching == 1) repeat (tr_len) begin
          #1;
          if (m_id == 0 && messages > 0) begin
            `uvm_info("Driver",$sformatf("Data=%h",req.m_data),UVM_MEDIUM)
            --messages;
          end
          `ifdef USE_RTL
          vif.reset <= req.m_reset;
          vif.data  <= req.m_data;
          @(posedge vif.clk);
          #1;
          vif.reset <= 0; // remove reset
          vif.data  <= 0;
          @(posedge vif.clk);
          `endif
        end
        phase.drop_objection(this, obj_name);
      end//repeat
    endtask : run_phase
    //--------------------------------------------------------------------------
  endclass : My_driver_t

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
    uvm_event_pool    global_event_pool;
    uvm_event         starting_event;
    longint           count    = 0;
    longint           warnings = 0;
    shortint          m_id     = 0;
    virtual My_intf   vif;
    //--------------------------------------------------------------------------
    // Constructor
    function new(string name, uvm_component parent);
      super.new(name, parent);
      global_event_pool = uvm_event_pool::get_global_pool();
    endfunction : new
    //--------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
      `uvm_info("", "Created", UVM_NONE)
    endfunction : build_phase
    //--------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
      string   obj_name = $sformatf("monitor[%0d]",m_id);
      starting_event = global_event_pool.get("starting");
      assert(uvm_config_db#(longint)::get(this, "", "count", count));
      assert(uvm_config_db#(longint)::get(this, "", "warnings", warnings));
      starting_event.wait_trigger();
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
      `ifdef USE_MONITOR
      forever begin
        @(posedge vif.busy);
        phase.raise_objection(this, obj_name);
        if (warnings) begin
          `uvm_warning("Driver","<warn>")
          --warnings;
        end
        @(negedge vif.busy);
        phase.drop_objection(this, obj_name);
      end//repeat
      `endif
    endtask : run_phase
    //--------------------------------------------------------------------------
  endclass : My_monitor_t

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
    shortint        m_id = 0;
    My_sequencer_t m_sequencer;
    My_driver_t    m_driver;
    My_monitor_t   m_monitor;
    //--------------------------------------------------------------------------
    // Constructor
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    //--------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
      m_sequencer = My_sequencer_t::type_id::create($sformatf("m_sequencer[%0d]",m_id),this);
      m_driver    = My_driver_t   ::type_id::create($sformatf("m_driver[%0d]",m_id),this);
      m_monitor   = My_monitor_t  ::type_id::create($sformatf("m_monitor[%0d]",m_id),this);
    endfunction : build_phase
    //--------------------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
      virtual My_intf vif;
      assert( uvm_config_db#(virtual My_intf)::get(this, "", "vif", vif) );
      m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
      // Connect BFM's to hardware interface
      m_driver.vif   = vif;
      m_monitor.vif  = vif;
      // Set each component to know it's own id
      m_driver.m_id    = m_id;
      m_monitor.m_id   = m_id;
      m_sequencer.m_id = m_id;
    endfunction : connect_phase
    //--------------------------------------------------------------------------
  endclass : My_agent_t

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
    shortint        m_level;
    My_env_t       m_uvc;
    My_agent_t  m_agent[];
    //--------------------------------------------------------------------------
    // Constructor
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    //--------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
      assert(uvm_config_db#(shortint)::get(this, "", "level", m_level));
      if (m_level > 0) begin
        string instance_name = "subenv";
        if (m_level > 1) instance_name = $sformatf("uvc_l%0d",m_level);
        uvm_config_db#(shortint)::set(uvm_top, "*", "level", m_level-1);
        m_uvc = My_env_t::type_id::create(instance_name,this);
      end else begin
        shortint unsigned agents = 1;
        void'(uvm_config_db#(shortint)::get(this, "", "agents", agents));
        m_agent = new[agents];
        for (shortint unsigned i=0; i!=agents; i++) begin
          m_agent[i] = My_agent_t::type_id::create($sformatf("m_agent[%0d]",i),this);
          m_agent[i].m_id = i%($bits(tr_len_t)/4);
        end
      end
    endfunction : build_phase
    //--------------------------------------------------------------------------
  endclass : My_env_t

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
    My_env_t        m_env;
    uvm_event_pool   global_event_pool;
    uvm_event        starting_event;
    real             cpu_starting_time,  cpu_finished_time;
    real             wall_starting_time, wall_finished_time;
    string           features = "";
    //--------------------------------------------------------------------------
    // Constructor
    function new(string name, uvm_component parent);
      super.new(name, parent);
      global_event_pool = uvm_event_pool::get_global_pool();
    endfunction
    //--------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
      longint  count     = 1e6; //< default
      longint  switching = 1;   //< default
      bit      use_seq   = 1;   //< default
      shortint levels    = 2;   //< default
      shortint agents    = 1;   //< default
      tr_len_t tr_len    = 0;   //< default (0 = equal; else each nibble)
      longint  messages  = 0;
      longint  warnings  = 0;
      string   tempstr   = "";
      int      status;
      // Manage configuration

      void'(uvm_config_db#(uvm_bitstream_t)::get(this, "", "level", levels)); //<allow from command-line
      uvm_config_db#(shortint)::set(uvm_top, "*", "level", levels);
      `uvm_info("build_phase",$sformatf("levels=%0d",levels), UVM_NONE);

      void'(uvm_config_db#(uvm_bitstream_t)::get(this, "", "agents", agents)); //<allow from command-line
      uvm_config_db#(shortint)::set(uvm_top, "*", "agents", agents);
      `uvm_info("build_phase",$sformatf("agents=%0d",agents), UVM_NONE);

      // Using a string option allows numeric values such as 1e6 or 1.5e3 instead of raw integers
      void'(uvm_config_db#(string)::get(this, "", "count", tempstr)); //<allow from command-line
      if (tempstr != "") begin
        real t;
        assert($sscanf(tempstr,"%g",t));
        count = 0 + t;
      end
      uvm_config_db#(longint)::set(uvm_top, "*", "count", count);
      `uvm_info("build_phase",$sformatf("count=%0d",count), UVM_NONE);

      // Using a string option allows numeric values such as 1e6 or 1.5e3 instead of raw integers
      void'(uvm_config_db#(string)::get(this, "", "messages", tempstr)); //<allow from command-line
      if (tempstr != "") begin
        real t;
        assert($sscanf(tempstr,"%g",t));
        messages = 0 + t;
      end
      uvm_config_db#(longint)::set(uvm_top, "*", "messages", messages);
      `uvm_info("build_phase",$sformatf("messages=%0d",messages), UVM_NONE);

      // Using a string option allows numeric values such as 1e6 or 1.5e3 instead of raw integers
      void'(uvm_config_db#(string)::get(this, "", "warnings", tempstr)); //<allow from command-line
      if (tempstr != "") begin
        real t;
        assert($sscanf(tempstr,"%g",t));
        warnings = 0 + t;
      end
      uvm_config_db#(longint)::set(uvm_top, "*", "warnings", warnings);
      `uvm_info("build_phase",$sformatf("warnings=%0d",warnings), UVM_NONE);

      void'(uvm_config_db#(uvm_integral_t)::get(this, "", "use_seq", use_seq)); //<allow from command-line
      uvm_config_db#(bit)::set(uvm_top, "*", "use_seq", use_seq);
      `uvm_info("build_phase",$sformatf("use_seq=%0d",use_seq), UVM_NONE);

      void'(uvm_config_db#(string)::get(this, "", "tr_len", tempstr)); //<allow from command-line
      if (tempstr != "") begin
        assert($sscanf(tempstr,"%h",tr_len));
      end
      uvm_config_db#(tr_len_t)::set(uvm_top, "*", "tr_len", tr_len);
      `uvm_info("build_phase",$sformatf("tr_len=%0d",tr_len), UVM_NONE);

      void'(uvm_config_db#(string)::get(this, "", "switching", tempstr)); //<allow from command-line
      if (tempstr != "") begin
        assert($sscanf(tempstr,"%d",switching));
      end
      uvm_config_db#(longint)::set(uvm_top, "*", "switching", switching);
      `uvm_info("build_phase",$sformatf("switching=%0d",switching), UVM_NONE);

      // Instantiate environment
      m_env = My_env_t::type_id::create("m_env",this);
      `uvm_info("", $sformatf("Created %s", get_full_name()), UVM_NONE)
    endfunction : build_phase
    //--------------------------------------------------------------------------
    task reset_phase(uvm_phase phase);
      `uvm_info("build_phase",$sformatf("%s\nRUNNING\n%s",SEP1,SEP2), UVM_NONE);
    endtask : reset_phase
    //--------------------------------------------------------------------------
    task main_phase(uvm_phase phase);
      longint  count;
      longint  switching;
      time     delay;
      tr_len_t tr_len;
      shortint agents;
      bit      use_seq;
      bit      mode = 1; //< default old way
      longint  messages = 0;
      longint  warnings = 0;
      uvm_objection objection;
      assert(uvm_config_db#(longint)  ::get(this, "", "count",     count));
      assert(uvm_config_db#(bit     ) ::get(this, "", "use_seq",   use_seq));
      assert(uvm_config_db#(tr_len_t) ::get(this, "", "tr_len",    tr_len));
      assert(uvm_config_db#(shortint) ::get(this, "", "agents",    agents));
      assert(uvm_config_db#(longint)  ::get(this, "", "switching", switching));
      assert(uvm_config_db#(longint)  ::get(this, "", "messages",  messages));
      assert(uvm_config_db#(longint)  ::get(this, "", "warnings",  warnings));
      // just in case
      assert(count    >= 10);
      assert(agents   >= 1);
      assert(messages >= 0);
      assert(warnings >= 0);
      objection = phase.get_objection();
      `ifdef UVM_POST_VERSION_1_1
      void'(uvm_config_db#(uvm_integral_t)::get(this, "", "ripple", mode));
      objection.set_propagate_mode(mode);
      `endif
      if (use_seq == 0)   features = {features, "; short-seq"}; else features = {features, "; long-seq"};
      if (tr_len != 0)    features = {features, $sformatf("; tr%0X",tr_len)};
      if (mode == 0)      features = {features, "; non-prop"}; else features = {features, "; propagate"};
      if (switching == 0) features = {features, "; limited-switching"};
      if (messages != 0)  features = {features, $sformatf("; Info%0d",messages)};
      if (warnings != 0)  features = {features, $sformatf("; Warn%0d",warnings)};
      objection.set_drain_time(uvm_top,10ns);
      uvm_top.set_timeout(1000ms);
      phase.raise_objection(this, "raising to allow setup"); // allow setup
      starting_event = global_event_pool.get("starting");
      #1ps;
      `uvm_info("test1:performance", $sformatf("Running %0d x %s iterations%s", agents, formatn(count),features), UVM_NONE)
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
      starting_event.trigger();
      cpu_starting_time = get_cpu_time();
      wall_starting_time = get_wall_time();
      phase.raise_objection(this, "raising to start top sequence"); // simulate sequence start
      begin
        uvm_component seqrs[$];
        uvm_top.find_all("*m_sequencer*",seqrs);
        foreach (seqrs[i]) begin
          My_sequencer_t seqr;
          My_sequence_t seq;
          if (!$cast(seqr, seqrs[i])) continue;
          seq = My_sequence_t::type_id::create($sformatf("seq[%0d]",i));
          seq.m_id = seqr.m_id;
          fork 
            shortint id = i;
            begin
              `uvm_info("DEBUG",$sformatf("Starting %0d",seq.m_id), UVM_DEBUG)
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
    endtask : main_phase
    //--------------------------------------------------------------------------
    function void report_phase(uvm_phase phase);
      longint cpu_ms, wall_ms;
      cpu_finished_time = get_cpu_time();
      wall_finished_time = get_wall_time();
      cpu_ms = 1000*(cpu_finished_time-cpu_starting_time);
      wall_ms = 1000*(wall_finished_time-wall_starting_time);
      `uvm_info("test1:objections"
               , $sformatf("RESULT: %s objected %s times in %s ms CPU %s ms WALL%s"
                          , `UVM_VERSION_STRING
                          , formatn(measured_objections)
                          , formatn(cpu_ms)
                          , formatn(wall_ms)
                          , features
                          )
               , UVM_NONE
               )
    endfunction : report_phase
    //--------------------------------------------------------------------------
  endclass : My_test_t

endpackage : performance_pkg

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
module top;
  //----------------------------------------------------------------------------
  timeunit 1ps;
  timeprecision 1ps;
  //----------------------------------------------------------------------------
  import uvm_pkg::*;
  import performance_pkg::*;
  //----------------------------------------------------------------------------
  initial begin
    uvm_top.enable_print_topology = 1;
    uvm_config_db#(virtual My_intf)::set(null,"*","vif",Harness.if1);
    // TODO: genvar loop to hookup interface pairs
    run_test("My_test_t");
  end

endmodule

//EOF
