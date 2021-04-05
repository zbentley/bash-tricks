#!/usr/bin/env bash

trap "echo Interrupted; exit" SIGINT
while true; do echo SLEEPING; sleep 1; done

#######
trap "echo Cleaning up" EXIT
echo foo
# What will the exit status of this script be?

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