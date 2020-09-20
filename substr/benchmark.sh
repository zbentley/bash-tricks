#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source substr.bash

str="MoNXZZwU+JPK/nyZgnz/8P4XknxjZREZd5tSb1avuY2n1F1M5a5eKN6hpBaNciHT9OCNQngLaVMs88aUmqq0GvN2/Sxx8Scv+7RHWpul1l+zfc2GEcoPLSTAX8aNIDkaqLrVlQo="
# str="MoNXZZwU+JPKanyZgnza8P4XknxjZREZd5tSb1avuY2n1F1M5a5eKN6hpBaNciHT9OCNQngLaVMs88aUmqq0GvN2aSxx8Scv+7RHWpul1l+zfc2GEcoPLSTAX8aNIDkaqLrVlQo="

exec 3>&1
exec 3> /dev/null

run_test() {
	test_start="${1:?Start is required}"
	test_end="${2:?End is required}"
	iterations="${3:?Iterations is required}"
	for (( count=0; count < iterations; ++count )); do
	    substr "$str" "$test_start" "$test_end" >&3
	done
}

run_control() {
	test_start="${1:?Start is required}"
	test_end="${2:?End is required}"
	iterations="${3:?Iterations is required}"
	for (( count=0; count < iterations; ++count )); do
	    echo "${str:$test_start:$test_end}" >&3
	done
}

echo "Testing \${str:${1}:${2}} with ${3:?Iterations is required} iterations"
echo "Control:"
time ( run_control "$@" )
echo
echo "Test:"
time ( run_test "$@" )
