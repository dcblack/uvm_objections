#ifndef DEBUG_FORMATN
#include "svdpi.h"
#endif
#include <string>
#include <cstring>
#include <sstream>
#include <iomanip>
using namespace std;

//-----------------------------------------------------------------------------
// A utility to convert unsigned to string with commas to separate
// thousands, millions, billions and make number more readable.
extern "C" const char* formatn(long long int n)
{
  string temp;
  { // Convert n to string
    ostringstream sout;
    sout << fixed << n;
    temp = sout.str();
  }
  if (temp.length() > 3) { // Insert commas
    int o = temp.length()%3;
    if (o == 0) o = 3;
    for (int i=int((temp.length()-1)/3); i!=0; --i) {
      temp.insert(o,",");
      o+=4;
    }//endfor
  }//endif
  char* result = new char[temp.size()+1];
  memcpy(result, temp.c_str(),temp.size()+1);
  return result;
}

#ifdef DEBUG_FORMATN
#include <iostream>
#include <vector>
int main(int argc, char** argv)
{
  vector<long long int> v = { 1LL, 25LL, 342LL, 8009LL, 100000000LL, 2450001021LL, 49LL };
  for (auto n : v) {
    cout << n << " => " << formatn(n) << endl;
  }//endfor
}
#endif
