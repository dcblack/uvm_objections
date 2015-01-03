// Send e-mail notification at the end of simulation
`include "get_env.svh"
module Notify;
  timeunit 1ps;
  timeprecision 1ps;
  final begin
    string email;
    string subject;
    string mailfile;
    string cmnd;
    email = get_env("EMAIL");
    if (email != "") begin
      subject = get_env("JOB");
      if (subject   == "") subject = "simulation";
      mailfile = get_env("MAILFILE");
      if (mailfile   == "") mailfile = "/dev/null";
      cmnd = $sformatf("mail -s 'Finished %s' %s <%s",subject,email,mailfile);
      $system(cmnd);
    end
  end
endmodule
