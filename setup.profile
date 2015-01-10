#!/bin/bash
#
#$Info: Source this file to setup appropriate environment. $

# Add modules if available
if [[ "$MODULESHOME" != "" ]]; then
  sim="questa"
  for m in flexlm devtools $sim; do
    if modulecmd bash avail $m 2>&1 | grep --silent $m; then
      module add $m
    fi
  done
fi

# Add full pathname of local ./bin to PATH unless it is already specified
DOTBIN="$(perl -MCwd'(abs_path)' -le 'print &abs_path(q{./bin})')"
if perl -e 'exit ($ENV{PATH} =~ m{^'"$DOTBIN"':})?1:0;' ; then
  PATH=$DOTBIN:"$PATH"
fi
