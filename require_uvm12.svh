// Include the following where you would write normal UVM code as appropriate.

// Better than just checking UVM_VERSION_1_2
`ifndef UVM_POST_VERSION_1_1
  // UVM 1.1 and earlier here
  // or if you don't support it:
  assert(0) else `uvm_fatal("","This code requires UVM version 1.2 or later.")
`else
  // UVM 1.2 stuff here
`endif
