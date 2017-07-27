# Range ARGS
#
# Polyfill-like function that allows bash `{1..10}`-style ranges to
# contain variables. By default, bash ranges are expanded before variable
# interpolation, so `{$foo..$bar}` doesn't work.
#
# This function reports an error when a range is invalid/cannot be expanded.
# It outputs a range separated by spaces, regardless of `IFS`. To output a range
# separated by IFS delimiters, use `rangeifs`.
#
# It makes no subshells and invokes no external programs by default. However,
# unlike native Bash ranges, its output cannot be used unless you capture it with
# a subshell, e.g. `for i in $(range {$foo..$bar})`. To avoid subshells, use the
# `rangefunc` function, which takes as its first argument a function to call for
# each element of the range.
#
# This function works with any combination of the `-e` and `-u` interpreter flags.
#
# Accepts:
# - A fully expanded range, which will just be returned.
#	e.g. `range {1..10}` === `{1..10}`
# - A pair of numbers or characters, which will create a range. Arguments can be
#	expressed separately, or in bash-range form (with or without curly braces).
#	e.g. given `foo=10` and `bar=a`, the following are equivalent:
#	- `{10..1}` === `range $foo 1` === `range $foo..1` == `range {$foo..1}`
#	- `{a..z}` === `range $bar z` === `range $bar..z` == `range {$bar..z}`
#
# More info/documentation: https://github.com/zbentley/bash-tricks/range/
function range {
	if [[ -n "${3:-}" ]]; then
		_zblocal_f_rangeoutput "$@"
	else
		local from to range elt
		declare -a rv # Local by default
		
		from="${1:-}"
		if [[ "${from}" =~ ^(.+)[.][.](.+)$ ]]; then
			if [[ -n "${2:-}" ]]; then
				_zblocal_f_errorf "Unexpected second argument. Arguments: '${1:-}', '${2:-}'."
				return 1
			fi
			from="${BASH_REMATCH[1]}"
			to="${BASH_REMATCH[2]}"
		else
			to="${2:-}"
		fi

		range="{${from#\{}..${to%\}}}"
		eval "for elt in $range;"' do rv+=("$elt"); done'

		if [[ "${rv[0]}" == "$range" ]]; then
			_zblocal_f_errorf "Could not calculate range '${range}'. Arguments: '${1:-}', '${2:-}'."
			return 1
		else
			_zblocal_f_rangeoutput "${rv[@]}"
		fi
	fi
}

function _zblocal_f_errorf {
	echo "${BASH_SOURCE[0]:-}: ${FUNCNAME[1]:-}() line ${BASH_LINENO[0]:-?}: ${1:-}" >&2
}

function rangeifs {
	local _zblocal_useifs=1
	range "$@"
}

function rangefunc {
	declare -F "${1:-}" > /dev/null

	if [[ $? -gt 0 ]]; then
		_zblocal_f_errorf "Requires a function argument; '${1:-}' is not a function."
		return 1
	else
		local _zblocal_usefunc
		_zblocal_usefunc="$1"
		shift
		range "$@"
	fi
}

function _zblocal_f_rangeoutput {
	if [[ -n "${_zblocal_useifs:-}" ]]; then
		echo "$*"
	elif [[ -n "${_zblocal_usefunc:-}" ]]; then
		for arg; do
			$_zblocal_usefunc "$arg"
		done
	else
		echo "$@"
	fi
}