////////////////////////////////////////////////////////////////////////////////////////////////////
// DESCRIPTION
//   Send e-mail notification at the end of simulation
//
// LICENSE
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//--------------------------------------------------------------------------------------------------
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
