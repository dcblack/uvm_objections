`include "uvm_macros.svh"

// This code has the following run-time configuration variables:
//
// +uvm_set_config_int=*,level,NUMBER specifies depth of hierarchy to drivers
// +uvm_set_config_int=*,drivers,NUMBER specifies how many drivers to instantiate
// +uvm_set_config_int=*,use_seq,BIT specifies if sequence is long (1) or short (0)
// +uvm_set_config_string=*,tr_len,HEX specifies transaction lengths in nybbles
// +uvm_set_config_string=*,count,NUMBER specifies how many 1ps transactions to run
// +uvm_set_config_int=*,ripple,BIT specifies for UVM 1.2 whether to propagate objections
// +uvm_set_config_int=*,switching,NUMBER specifies context switching variations

package performance_pkg;

  timeunit 1ps;
  timeprecision 1ps;

  import uvm_pkg::*;
  `include "get_time.svh"
  `include "formatn.svh"

  string SEP1 = {122{"#"}};
  string SEP2 = {120{"="}};

  typedef longint tr_len_t;

  longint unsigned measured_objections = 0;

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
  class Obj_driver_t extends uvm_agent;
    //--------------------------------------------------------------------------
    `uvm_component_utils(Obj_driver_t)
    uvm_event_pool   global_event_pool;
    uvm_barrier_pool global_barrier_pool;
    uvm_event        starting_event;
    uvm_barrier      finished_barrier;
    longint          count = 0;
    shortint         id = 0;
    //--------------------------------------------------------------------------
    function new(string name, uvm_component parent);
      super.new(name, parent);
      global_event_pool   = uvm_event_pool::get_global_pool();
      global_barrier_pool = uvm_barrier_pool::get_global_pool();
    endfunction : new
    //--------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
      `uvm_info("", "Created", UVM_NONE)
    endfunction : build_phase
    //--------------------------------------------------------------------------
    task reset_phase(uvm_phase phase);
      phase.raise_objection(this, "Begin reset");
      #1; // Get off zero
      phase.drop_objection(this, "End reset");
    endfunction : reset_phase
    //--------------------------------------------------------------------------
    task main_phase(uvm_phase phase);
      tr_len_t tr_len;
      longint  switching;
      starting_event = global_event_pool.get("starting");
      finished_barrier = global_barrier_pool.get("finished");
      assert(uvm_config_db#(longint)::get(this, "", "count", count));
      assert(uvm_config_db#(tr_len_t)::get(this, "", "tr_len", tr_len));
      assert(uvm_config_db#(longint)::get(this, "", "switching", switching));
      tr_len >>= (4*id);
      tr_len &= 'hF;
      if (tr_len <= 0) tr_len = 1; // always at least one
      measured_objections += count/tr_len;
      starting_event.wait_trigger();
      if (switching == 0) #1;
      repeat (count/tr_len) begin
        phase.raise_objection(this, "raising");
        if (switching == 1) repeat (tr_len) #1;
        phase.drop_objection(this, "lowering");
      end//repeat
      finished_barrier.wait_for();
    endtask : main_phase
    //--------------------------------------------------------------------------
  endclass : Obj_driver_t

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
  class Obj_env_t extends uvm_env;
    //--------------------------------------------------------------------------
    `uvm_component_utils(Obj_env_t)
    shortint    level;
    Obj_env_t   uvc;
    Obj_driver_t driver[];
    //--------------------------------------------------------------------------
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    //--------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
      assert(uvm_config_db#(shortint)::get(this, "", "level", level));
      if (level > 0) begin
        string instance_name = "agent";
        if (level > 1) instance_name = $sformatf("uvc_l%0d",level);
        uvm_config_db#(shortint)::set(null, "*", "level", level-1);
        uvc = Obj_env_t::type_id::create(instance_name,this);
      end else begin
        shortint unsigned drivers = 1;
        void'(uvm_config_db#(shortint)::get(this, "", "drivers", drivers));
        driver = new[drivers];
        for (shortint unsigned i=0; i!=drivers; i++) begin
          driver[i] = Obj_driver_t::type_id::create($sformatf("driver[%0d]",i),this);
          driver[i].id = i%($bits(tr_len_t)/4);
        end
      end
    endfunction : build_phase
    //--------------------------------------------------------------------------
  endclass : Obj_env_t

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
  class Obj_test_t extends uvm_test;
    //--------------------------------------------------------------------------
    `uvm_component_utils(Obj_test_t)
    Obj_env_t        env;
    uvm_event_pool   global_event_pool;
    uvm_barrier_pool global_barrier_pool;
    uvm_event        starting_event;
    uvm_barrier      finished_barrier;
    //--------------------------------------------------------------------------
    function new(string name, uvm_component parent);
      super.new(name, parent);
      global_event_pool   = uvm_event_pool::get_global_pool();
      global_barrier_pool = uvm_barrier_pool::get_global_pool();
    endfunction
    //--------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
      longint  count     = 1e6; //< default
      longint  switching = 1;   //< default
      bit      use_seq   = 1;   //< default
      shortint levels    = 2;   //< default
      shortint drivers   = 1;   //< default
      tr_len_t tr_len    = 0;   //< default (0 = equal; else each nibble)
      string   tempstr   = "";
      int      status;
      // Manage configuration

      void'(uvm_config_db#(uvm_bitstream_t)::get(this, "", "level", levels)); //<allow from command-line
      $display("levels=%0d",levels);

      uvm_config_db#(shortint)::set(null, "*", "level", levels);
      void'(uvm_config_db#(uvm_bitstream_t)::get(this, "", "drivers", drivers)); //<allow from command-line
      $display("drivers=%0d",drivers);

      uvm_config_db#(shortint)::set(null, "*", "drivers", drivers);
      void'(uvm_config_db#(string)::get(this, "", "count", tempstr)); //<allow from command-line
      if (tempstr != "") begin
        real t;
        assert($sscanf(tempstr,"%g",t));
        count = 0 + t;
      end
      $display("count=%0d",count);

      uvm_config_db#(longint)::set(null, "*", "count", count);
      void'(uvm_config_db#(uvm_bitstream_t)::get(this, "", "use_seq", use_seq)); //<allow from command-line
      uvm_config_db#(bit)::set(null, "*", "use_seq", use_seq);
      $display("use_seq=%0d",use_seq);

      void'(uvm_config_db#(string)::get(this, "", "tr_len", tempstr)); //<allow from command-line
      if (tempstr != "") begin
        assert($sscanf(tempstr,"%h",tr_len));
      end
      uvm_config_db#(longint)::set(null, "*", "tr_len", tr_len);
      $display("tr_len=%0d",tr_len);

      void'(uvm_config_db#(string)::get(this, "", "switching", tempstr)); //<allow from command-line
      if (tempstr != "") begin
        assert($sscanf(tempstr,"%d",switching));
      end
      uvm_config_db#(longint)::set(null, "*", "switching", switching);
      $display("switching=%0d",switching);

      // Instantiate environment
      env = Obj_env_t::type_id::create("env",this);
      `uvm_info("", $sformatf("Created %s", get_full_name()), UVM_NONE)
    endfunction : build_phase
    //--------------------------------------------------------------------------
    task reset_phase(uvm_phase phase);
      $display("%s\nRUNNING\n%s",SEP1,SEP2);
    endtask : reset_phase
    //--------------------------------------------------------------------------
    task main_phase(uvm_phase phase);
      longint count;
      time     delay;
      tr_len_t tr_len;
      longint  start, finish;
      shortint waiters;
      shortint drivers;
      bit      use_seq;
      bit      mode = 1; //< default old way
      string   features = "";
      uvm_objection objection;
      assert(uvm_config_db#(longint)  ::get(this, "", "count",   count));
      assert(uvm_config_db#(bit     ) ::get(this, "", "use_seq", use_seq));
      assert(uvm_config_db#(tr_len_t) ::get(this, "", "tr_len", tr_len));
      assert(uvm_config_db#(shortint) ::get(this, "", "drivers", drivers));
      objection = phase.get_objection();
      `ifdef UVM_POST_VERSION_1_1
      void'(uvm_config_db#(uvm_bitstream_t)::get(this, "", "ripple", mode));
      objection.set_propagate_mode(mode);
      `endif
      if (use_seq == 0) features = {features, "; short-seq"};
      if (tr_len != 0)  features = {features, $sformatf("; tr%0X",tr_len)};
      if (mode == 0)    features = {features, "; non-propagating"};
      objection.set_drain_time(uvm_top,10ns);
      uvm_top.set_timeout(1000ms);
      phase.raise_objection(this, "raising to allow setup"); // allow setup
      starting_event = global_event_pool.get("starting");
      finished_barrier = global_barrier_pool.get("finished");
      #1ps;
      waiters = starting_event.get_num_waiters();
      finished_barrier.set_threshold(waiters+1);
      `uvm_info("test1:objections", $sformatf("Running %0d x %s iterations%s", drivers, formatn(count),features), UVM_NONE)
      delay = (count-2);
      phase.drop_objection(this, "lowering after setup");
      measured_objections += 1;
      starting_event.trigger();
      start = get_time();
      phase.raise_objection(this, "raising to start main sequence"); // simulate sequence start
      #1ps;
      if (use_seq) #(delay);
      phase.drop_objection(this, "lowering at end of main sequence"); // simulate sequence done
      finished_barrier.wait_for();
      finish = get_time();
      `uvm_info("test1:objections"
               , $sformatf("RESULT: %s objected %s times in %s ms CPU%s"
                          , `UVM_VERSION_STRING
                          , formatn(measured_objections)
                          , formatn(finish-start)
                          , features
                          )
               , UVM_NONE
               )
    endtask : main_phase
    //--------------------------------------------------------------------------
  endclass : Obj_test_t

endpackage

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

  timeunit 1ps;
  timeprecision 1ps;

  import uvm_pkg::*;
  import performance_pkg::*;

  initial begin
    run_test("Obj_test_t");
  end

endmodule

//EOF
