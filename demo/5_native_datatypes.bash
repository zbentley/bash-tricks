#!/usr/bin/env bash

# String manipulation!
str=FooBarBazQuux
echo "${str,,}" # Lower case
echo "${str^^}" # Upper case
echo "${str:4:7}" # Slice
echo "${str#*B}" # Prefix snip: remove from the left until the first match of *B
echo "${str##*B}" # Be greedy: remove from the left until the last match of *B
echo "${str%u*}" # Suffix snip: remove from the right after the first match of u*
echo "${str%%u*}"  # Be greedy: remove from the right after the last match of u*

# Assertions and defaults!
foo=
var="${foo:-DEFAULT VALUE}"
echo "$var"

var="${bar:-DEFAULT VALUE}"
echo "$var"

# But how do I check if it's defined or not?
[ -v foo ] && echo THERE || echo NOT THERE