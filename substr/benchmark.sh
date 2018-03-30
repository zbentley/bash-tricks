#!/usr/bin/env bash

set -euo pipefail

. ./substr.bash

test_start="${2:-}"
test_end="${3:-}"
iterations=30000
str="MoNXZZwU+JPK/nyZgnz/8P4XknxjZREZd5tSb1avuY2n1F1M5a5eKN6hpBaNciHT9OCNQngLaVMs88aUmqq0GvN2/Sxx8Scv+7RHWpul1l+zfc2GEcoPLSTAX8aNIDkaqLrVlQo="
# str="MoNXZZwU+JPKanyZgnza8P4XknxjZREZd5tSb1avuY2n1F1M5a5eKN6hpBaNciHT9OCNQngLaVMs88aUmqq0GvN2aSxx8Scv+7RHWpul1l+zfc2GEcoPLSTAX8aNIDkaqLrVlQo="

exec 3>&1
exec 3> /dev/null


run_test() {
	test_start="${1:?Start is required}"
	test_end="${2:?End is required}"
	iterations="${3:?Iterations is required}"
	count=0
	while [ $count -lt $iterations ]; do
	    count=$(( $count + 1 ))
	    substr "$str" $test_start $test_end >&3
	done
}

run_control() {
	test_start="${1:?Start is required}"
	test_end="${2:?End is required}"
	iterations="${3:?Iterations is required}"
	count=0
	while [ $count -lt $iterations ]; do
	    count=$(( $count + 1 ))
	    echo "${str:$test_start:$test_end}" >&3
	done
}




echo "Testing with ${3:?Iterations is required} iterations"
echo "Control:"
time ( run_control "$@" )
echo
echo "Test:"
time ( run_test "$@" )
