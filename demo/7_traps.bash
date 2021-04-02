#!/bin/bash

trap "echo Interrupted; exit" SIGINT
while true; do echo SLEEPING; sleep 1; done

#######
trap "echo Cleaning up" EXIT
echo foo

#######
trap "echo Cleaning up after error" ERR
exit 1

#######
trap "echo Cleaning up after error" ERR
echo foo | grep bar
echo baz

#####
trap "echo resetting state before command" DEBUG
echo foo
echo bar