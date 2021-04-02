#!/bin/bash
exec 4>/dev/null

time for i in {1..1000}; do echo foo>&4; done

time for i in {1..1000}; do /bin/echo foo>&4; done

time for i in {1..1000}; do command echo foo>&4; done

echo explain THAT to the duck