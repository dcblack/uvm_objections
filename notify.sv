`include "get_env.svh"
module Notify;
  timeunit 1ps;
  timeprecision 1ps;
  final begin
    string email;
    string job;
    string file;
    string cmnd;
    email = get_env("EMAIL");
    if (email != "") begin
      job = get_env("JOB");
      if (job   == "") job = "simulation";
      file = get_env("MESSAGE");
      if (file   == "") file = "/dev/null";
      cmnd = $sformatf("mail -s 'Finished %s' %s <%s",job,email,file);
      $system(cmnd);
    end
  end
endmodule
