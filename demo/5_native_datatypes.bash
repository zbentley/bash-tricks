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


# Arrays!
a=(1 2 3)
echo "$a"
echo "${a[@]}"
a+=(4 5 6)
echo "${a[@]}"
for i in "${a[@]}"; do
  echo next
  echo $i;
done

echo length "${#a[@]}"
a[2]='foo'
echo "${a[@]}"
echo "${a[@]:3}"
echo "${a[@]:3:2}"


# Assertions! Prints to stderr and exits 1
v=
echo "${v:?Must set v}"
v=1
echo "${v:?Must set v}"