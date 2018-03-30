# `range.bash`

## Overview

`range.bash` contains polyfill-like functions that improve on [Bash](https://tiswww.case.edu/php/chet/bash/bash-intro.html) `{1..10}`-style ranges (aka [sequence expressions](https://www.gnu.org/software/bash/manual/html_node/Brace-Expansion.html)). These functions allow the detection of invalid ranges, and allow ranges to contain variables.

In regular Bash, ranges are expanded before variable interpolation, so `for i in {$foo..$bar}` doesn't work. These functions make that possible, with a few limitations.

## Examples

The following statements are all equivalent:

```bash
one=1 ten=10 

echo {1..10}
range {1..10}
range {$one..10}
range {$one..$ten}
```

Output can be formatted via `IFS`. The following are equivalent:

```bash
for i in {1..10}; do echo $i; done
rangeifs {$one..$ten}
```

Output can be looped over with or without subshells (see the "Subshells" section for more info). The following calls to `myfunc()` are equivalent:

```bash
myfunc() { echo $1; }
one=1 ten=10

for i in {1..10}; do myfunc $i; done
for i in $(range {$one..$ten}); do myfunc $i; done
rangefunc myfunc {$one..$ten}
```

## Errors

Unlike Bash's built-in ranges, functions in this file will report errors when given invalid (according to Bash) ranges. For example, consider this loop:

```bash
for i in {a..0}; do
	something_scary $i;
done
```

Since the range from "a" to "0" is invalid, Bash will happily supply the value "`{a..0}`" verbatim to `something_scary`. This can cause unexpected or dangerous behavior. Looping over `$(range {a..0})`, or using `rangefunc` to invoke `something_scary` will error instead, protecting code from unexpected input patterns.

# Usage

The `range.bash` file defines three public functions: `range`, `rangeifs`, and `rangefunc`.

To use these functions, download `range.bash` and do `source range.bash`.

### `range ARGS`

This function outputs (to STDOUT) a _space-separated_ range of words as specified by `ARGS`.

`ARGS` must be either one or two [word-separated](http://mywiki.wooledge.org/WordSplitting) arguments. Supplying more arguments than that will cause those arguments to be returned verbatim, as in the last case below.

The value of `IFS` does not affect this function's behavior in any way.

`ARGS` should be one of:

- Two words or variables that expand to words, where each word is something that Bash understands as being part of a range, for example: `range 1 10`, `range 3 -50`, `range a z`, or `range A z`, though that last case may not give the result you expect; try it!
- A single "range statement", consisting of two words or variables that expand to words joined by `..`, and optionally surrounded by curly braces, for example: `range 1..10`, `range {3..-50}`, or `range {z..a}`.
- A fully expanded range, which will handled as it would be by bash normally, for example: `range {1..10}` or `range {Z..a}` expand to the same values, respectively, as `{1..10}` or `{Z..a}`.

This function reports an error (prints an error message to STDERR, prints nothing to STDOUT, and returns a nonzero value) if the supplied arguments are invalid _or_ if the supplied range is invalid according to Bash's rules for ranges. For example, `range {A..z}` is valid, but `range {a..0}` is not. This is determined by Bash, not this function.

Ranges will be "combined" by Bash where possible, so behavior like `{$one..10}{a..z}` is possible, but requires all brace expressions after the first one to be quoted. See the "Limitations" section for more info.g

### `rangeifs ARGS`

This function works exactly like the `range` function, except its output is delimited by the separator derived from the [`$IFS` pseudovariable](https://bash.cyberciti.biz/guide/$IFS) instead of spaces.

Native Bash ranges are _not_ delimited by IFS: if you want one number per line, `IFS=$'\n' rangeifs {1..10}` will not work, you'll need a loop. `IFS=$'\n' rangeifs {1..10}` will work as expected.

For example, `IFS= rangeifs 1..10` results in `12345678910`, and `IFS=_ rangeifs {1..10}` results in `1_2_3_4_5_6_7_8_9_10`.

All elements of the range will be in the output, even if those elements are delimiters in `$IFS`: `IFS=a rangeifs {a..c}` prints `aabac`.

`ARGS` handling and error conditions behave exactly the same as they do for `range`.

Be aware that [*`IFS` is tricky*](http://mywiki.wooledge.org/BashSheet#Special_Parameters). It is not a delimiter; it is a list of possible delimiters. The behaviors of the following statements illustrate these pitfalls:
```
IFS=abc rangeifs {1..5}
IFS="\n" rangeifs {1..5}
IFS=$'\n' rangeifs {1..5}
```

See the "Limitations" section for more info.

### `rangefunc FUNC ARGS`

This function generates a range from `ARGS`, and then calls the supplied Bash (or shell) function `FUNC` once for each element in that range.

Ranges are generated from `ARGS` by the same rules used for the `range` function, so `rangefunc myFunction $foo $bar`, `rangefunc myFunction {1..10}`, and `rangefunc myFunction {$foo..10}` are all valid inputs, provided the variables they contain are valid range components.

`rangefunc` will report an error if its first argument is not a function defined in the current shell: `f() { echo $1; }; rangefunc f 1..10` will work, but `rangefunc notDefined 1..10` will raise an error (print to STDERR, print nothing to STDOUT, and return a nonzero status).

`FUNC` will be called with a single defined argument (i.e. a `$1` which will never violate `set -u`, so no need for `"${1:-}"`). `FUNC` will be called with results of the `range` function applied to `ARGS`, _not_ with elements of the range _combined_ from `range ARGS` and any adjacent ranges. In other words, ` a=2; f() { echo -n "$1 "; }; rangefunc f {1..$a}{a..b}` results in `1a 1b 2a 2b`.

Many users find it semantically useful to `alias` `rangefunc` to `map`. The `map` keyword is not used by default due to its presence in other Bash libraries.

# Interoperability

## Compatibility

All functions in this file work with any combination of the `-e` and `-u` interpreter flags. No subprocesses other than bash are created, and no pipes are used, so options like `pipefail` do not affect these functions' behavior.

The functions in this file have been tested to work with Bash 3 and 4. Specifically, I have tested them on:

- Bash 3.2.57 on OSX
- Bash 4.4.12 on OSX
- Bash 4.1.2 on RHEL/CentOS/OEL Linux derivatives

## Subshells

No [subshells](http://tldp.org/LDP/abs/html/subshells.html) are spawned by any functions in this file.

A subshell is necessary to capture the return value of the `range` function, as in `for item in $(range {$foo..bar})`. To avoid subshells altogether, use the `rangefunc` function.

Spawning subshells, even to invoke built-in bash functions or simple programs like `true`, is surprisingly expensive. For more information on the performance impact of using subshells, see [this link](http://rus.har.mn/blog/2010-07-05/subshells/).

## Global State

Since Bash functions are global by default, functions with the same names as those documented for this file will conflict with  (overwrite or be overwritten by) the functions defined in this file. Additionally, any functions or globals whose names start with `_zblocal_` that are not created by code from [the source repository containing this file](https://github.com/zbentley/bash-tricks) may interfere with its behavior.

No environment variables are read or written by any functions in this file.

# Limitations

The goal of these functions is to emulate as much of the native bash range behavior as possible without compromising performance, compatibility, or usability. Not all capabilities of the built-in bash ranges are available. For example, nested ranges like `{{a..z},{1..10}}` cannot be emulated with these functions.

Adjacent "combination" ranges (i.e. `{1..10}{a..z}` generating `1a 1b 1c ...` etc.) will work, if all ranges after the first are enclosed in quotes, and only the _first_ combined range contains variables or things that Bash wouldn't natively expand. `one=1 range {$one..10}{a..f}` doesnt' do what you expect, but `range {$one..10}'{a..f}'` does.

If you are using subshells, be aware that ranges combined across a subshell boundary may not produce the result you expect. For example, try `one=1; echo $(range {$one..10}){a..f}`.

[Word splitting](http://mywiki.wooledge.org/WordSplitting) may cause the `range` function to do unexpected things in the presence of `IFS` contents which contain data in the range. For example, `IFS=abc first=a; range {$first..z}` results in an error. To prevent such errors, quote some or all of the arguments to `range`. `range "{$first..z}"`, `range "$first" z`, and `range {"$first"..z}` will all work. This behavior isn't related to `range` itself; it applies to the rest of Bash as well; `IFS=abc first=a; echo {$first..z}` illustrates this.

# TODO

This should be enhanced with:

- Thorough automated tests.
- Check/document compatibility with `-oposix`.
- The ability to extend the range syntax, optionally, to encompass `a..0` xor `0..a`.
- `rangefunc` should conserve memory as much as possible. At present it allocates the full range as a string, which may be incompatible with some environments' assumptions.
- CONTRIBUTING guidelines.
- Useful links to other tools.
