#ifndef DEBUG_GET_ENV
#include "svdpi.h"
#endif
#include <cstdlib>
#include <string>
#include <cstring>
using namespace std;

//-----------------------------------------------------------------------------
// A utility to return the value of an environment variable.
extern "C" const char* get_env(const char* s)
{
  static const char* NULLSTR = "";
  char* result = std::getenv(s);
  if (result == 0) result = const_cast<char*>(NULLSTR);
  return const_cast<const char*>(result);
}

#ifdef DEBUG_GET_ENV
#include <iostream>
int main(int argc, char** argv)
{
  cout << "HOME      => \"" << get_env("HOME")      << "\""<< endl;
  cout << "USER      => \"" << get_env("USER")      << "\""<< endl;
  cout << "UNDEFINED => \"" << get_env("UNDEFINED") << "\""<< endl;
  cout << "EMPTY     => \"" << get_env("EMPTY")     << "\""<< endl;
  return 0;
}
#endif
