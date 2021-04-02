#!/bin/bash

function do_something() {
  local variable=$(echo "the result of something complicated")
  return $variable
}

out=$(do_something)
echo $out

function do_something() {
  local variable=$(echo "the result of something complicated")
  echo $variable
}

out=$(do_something)
echo $out
time for i in {1..1000}; do out=$(do_something); done

_RETVAL=

function do_something() {
  local variable=$(echo "the result of something complicated")
  _RETVAL="$variable"
}

do_something
out="$_RETVAL"
echo out
time for i in {1..1000}; do do_something; out="$_RETVAL"; done


