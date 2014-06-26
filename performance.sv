`include "uvm_macros.svh"

package performance_pkg;

  timeunit 1ns;
  timeprecision 1ps;

  import uvm_pkg::*;
  `include "get_time.svh"
  `include "formatn.svh"

  string SEP1 = {122{"#"}};
  string SEP2 = {120{"="}};

  //////////////////////////////////////////////////////////////////////////////
  class Obj_driver_t extends uvm_agent;
    //--------------------------------------------------------------------------
    `uvm_component_utils(Obj_driver_t)
    uvm_event_pool   global_event_pool;
    uvm_barrier_pool global_barrier_pool;
    uvm_event        starting_event;
    uvm_barrier      finished_barrier;
    longint count = 0;
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
    task main_phase(uvm_phase phase);
      starting_event = global_event_pool.get("starting");
      finished_barrier = global_barrier_pool.get("finished");
      assert(uvm_config_db#(longint)::get(this, "", "count", count));
      starting_event.wait_trigger();
      repeat (count) begin
        phase.raise_objection(this, "raising");
        #1ps;
        phase.drop_objection(this, "lowering");
      end//repeat
      finished_barrier.wait_for();
    endtask
    //--------------------------------------------------------------------------
  endclass : Obj_driver_t

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
        end
      end
    endfunction : build_phase
    //--------------------------------------------------------------------------
  endclass : Obj_env_t

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
      longint  count  = 1e6; //< default
      shortint levels = 2;    //< default
      shortint drivers = 1;    //< default
      string countstr = "";
      void'(uvm_config_db#(uvm_bitstream_t)::get(this, "", "level", levels)); //<allow from command-line
      $display("levels=%0d",levels);
      uvm_config_db#(shortint)::set(null, "*", "level", levels);
      void'(uvm_config_db#(uvm_bitstream_t)::get(this, "", "drivers", drivers)); //<allow from command-line
      $display("drivers=%0d",drivers);
      uvm_config_db#(shortint)::set(null, "*", "drivers", drivers);
      void'(uvm_config_db#(string)::get(this, "", "count", countstr)); //<allow from command-line
      if (countstr != "") begin
        count = 0 + countstr.atoreal();
      end
      $display("count=%0d",count);
      uvm_config_db#(longint)::set(null, "*", "count", count);
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
      longint start, finish;
      shortint waiters;
      bit mode = 1; //< default old way
      string mode_string = "";
      uvm_objection objection;
      assert(uvm_config_db#(longint)::get(this, "", "count", count));
      `uvm_info("test1:objections", $sformatf("Running %s iterations", formatn(count)), UVM_NONE)
      objection = phase.get_objection();
      `ifdef UVM_POST_VERSION_1_1
      void'(uvm_config_db#(int)::get(this, "", "ripple", mode));
      objection.set_propagate_mode(mode);
      `endif
      objection.set_drain_time(uvm_top,10ns);
      uvm_top.set_timeout(1000ms);
      phase.raise_objection(this, "raising"); // allow setup
      starting_event = global_event_pool.get("starting");
      finished_barrier = global_barrier_pool.get("finished");
      #1ps;
      waiters = starting_event.get_num_waiters();
      finished_barrier.set_threshold(waiters+1);
      phase.drop_objection(this, "lowering");
      starting_event.trigger();
      start = get_time();
      phase.raise_objection(this, "raising"); // simulate sequence start
      #10ns;
      phase.drop_objection(this, "lowering"); // simulate sequence done
      finished_barrier.wait_for();
      finish = get_time();
      if (mode == 0) mode_string = " without propagation";
      `uvm_info("test1:objections"
               , $sformatf("RESULT: %s objected %s times in %s ms%s"
                          , `UVM_VERSION_STRING
                          , formatn(count)
                          , formatn(finish-start)
                          , mode_string
                          )
               , UVM_NONE
               )
    endtask
    //--------------------------------------------------------------------------
  endclass : Obj_test_t

endpackage

////////////////////////////////////////////////////////////////////////////////
module top;

  timeunit 1ns;
  timeprecision 1ps;

  import uvm_pkg::*;
  import performance_pkg::*;

  initial begin
    run_test("Obj_test_t");
  end

endmodule
