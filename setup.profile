#!/bin/bash

if perl -e 'exit ($ENV{PATH} =~ m{^[.]/bin:})?1:0;' ; then
  echo "setup"
  PATH=./bin:"$PATH"
fi
