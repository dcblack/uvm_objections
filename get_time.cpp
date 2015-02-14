// FILE: get_time.pp
// INFO: Routines to get CPU and Wall time in seconds as a double.
#ifndef GET_TIME_SELFTEST
#include "svdpi.h"
#endif

////////////////////////////////////////////////////////////////////////////////
//  Windows
#ifdef _WIN32
#include <Windows.h>

extern "C"
double get_wall_time(void)
{
  LARGE_INTEGER time, freq;
  if (!QueryPerformanceFrequency(&freq)){
    //  Handle error
    return 0;
  }
  if (!QueryPerformanceCounter(&time)){
    //  Handle error
    return 0;
  }
  return double(time.QuadPart) / freq.QuadPart;
}

extern "C"
double get_cpu_time(void)
{
  FILETIME a,b,c,d;
  if (GetProcessTimes(GetCurrentProcess(),&a,&b,&c,&d) != 0){
    //  Returns total user time.
    //  Can be tweaked to include kernel times as well.
    return
      double(d.dwLowDateTime |
      ((unsigned long long)d.dwHighDateTime << 32)) * 0.0000001;
  }else{
    //  Handle error
    return 0;
  }
}

////////////////////////////////////////////////////////////////////////////////
//  Posix/Linux
#else
#include <time.h>

extern "C"
double get_wall_time(void)
{
  timespec time;
  int status = clock_gettime(CLOCK_REALTIME,&time);
  if (status != 0) return 0; // Error
  return double(time.tv_sec) + double(time.tv_nsec) * 1.0e-9;
}

extern "C"
double get_cpu_time(void)
{
  timespec time;
  int status = clock_gettime(CLOCK_PROCESS_CPUTIME_ID,&time);
  if (status != 0) return 0; // Error
  return double(time.tv_sec) + double(time.tv_nsec) * 1.0e-9;
}
#endif

//////////////////////////////////////////////////////////////////////////////////
//
//   ####  ##### #     ##### ####### #####  ####  #######                         
//  #    # #     #     #        #    #     #    #    #                            
//  #      #     #     #        #    #     #         #                            
//   ####  ##### #     #####    #    #####  ####     #                            
//       # #     #     #        #    #          #    #                            
//  #    # #     #     #        #    #     #    #    #                            
//   ####  ##### ##### #        #    #####  ####     #                            
//
//////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------------------------------------
#ifdef GET_TIME_SELFTEST
#include <iostream>
#include <iomanip>
#include <string>
#include <sstream>
#include <stdint.h>
using namespace std;
uint64_t mask(uint64_t value) { return value & 0xFFFFFFFFULL; }
char const * const HELP =
"NAME\n"
"  get_time - self-test of the get_cpu_time() and get_wall_time() routines.\n"
"EXAMPLES\n"
"  # To create self-test\n"
"  g++ -DGET_TIME_SELFTEST -lrt -o get_time get_time.cpp && ./get_time 24\n"
"  ./get_time 28\n"
;
int main(int argc, char* argv[])
{
  // Defaults
  unsigned int bits = 28; //< default
  // Parse command-line
  for (int i=1; i<argc; ++i) {
    string arg(argv[i]);
    if (arg.length() > 0 && arg[0] > '0' && arg[0] <= '9') {
      istringstream strin(arg);
      unsigned int temp = bits;
      strin >> temp;
      if (temp > 1 && temp <= 64) {
        bits = temp;
      }
    } else if (arg == "-h") {
      cout << HELP << endl;
      return 0;
    }//endif
  }//endfor

  double wall_start = get_wall_time();
  double cpu_start = get_cpu_time();

  // Do a dummy calculation to cause time elapse
  uint64_t csum = 0xDEADBEEFULL;
  for (uint64_t i = 0ULL; i!=(1ULL<<bits)-1ULL; ++i) {
    csum = mask(csum >> 32) ^ mask(csum) ^ i;
  }
  cout << "Sum: " << hex << csum << dec << endl;
  cout << "CPU  time: " << get_cpu_time() - cpu_start << endl;
  cout << "Wall time: " << get_wall_time() - wall_start << endl;
  return 0;
}
#endif
////////////////////////////////////////////////////////////////////////////////
//EOF
