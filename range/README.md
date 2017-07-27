# Range

`range.bash` contains polyfill-like functions that allow [Bash](https://tiswww.case.edu/php/chet/bash/bash-intro.html) `{1..10}`-style ranges to contain variables. In regular Bash, ranges are expanded before variable interpolation, so `for i in {$foo..$bar}` doesn't work. These functions make that possible, with a few limitations.

To illustrate the usefulness of these functions, consider that the following `echo` statements are all equivalent:

```bash
source range.bash

echo {1..10}
range {1..10}
one=1 range {$one..10}
one=1 ten=10 range {$one..$ten}
```

These functions also report errors when given invalid (according to Bash) ranges. `for i in {a..0}; do something_scary $i; done` will happily supply the value "`{a..0}`" verbatim to `something_scary`; `for i in $(range {a..0}); do something_scary $i; done` will error instead.

# Usage

The `range.bash` file defines the following public functions:

### `range ARGS`

This function outputs (to STDOUT) a _space-separated_ range of words as specified by `ARGS`.

`ARGS` must be either one or two [word-separated](http://mywiki.wooledge.org/WordSplitting) arguments. Supplying more arguments than that will cause those arguments to be returned verbatim, as in the last case below.

`ARGS` should be one of:

- Two words or variables that expand to words, where each word is something that Bash understands as being part of a range, for example: `range 1 10`, `range 3 -50`, `range a z`, or `range A z`, though that last case may not give the result you expect; try it!
- A single "range statement", consisting of two words or variables that expand to words joined by `..`, and optionally surrounded by curly braces, for example: `range 1..10`, `range {3..-50}`, or `range {z..a}`.
- A fully expanded range, which will handled as it would be by bash normally, for example: `range {1..10}` or `range {Z..a}` expand to the same values, respectively, as `{1..10}` or `{Z..a}`.

This function reports an error (prints an error message to STDERR, prints nothing to STDOUT, and returns a nonzero value) if the supplied arguments are invalid _or_ if the supplied range is invalid according to Bash's rules for ranges. For example, `range {A..z}` is valid, but `range {a..0}` is not. This is determined by Bash, not this function.

Ranges will be "combined" by Bash where possible (see the "Limitations" section for more info). However, if you are using subshells, be aware that ranges combined across a subshell boundary may not produce the result you expect. For example, try `one=1; echo $(range {$one..10}){a..f}`.

### `rangeifs ARGS`

This function works exactly like the `range` function, except its output is delimited by the value of the [`$IFS` pseudovariable](https://bash.cyberciti.biz/guide/$IFS) instead of spaces.

For example, `IFS= rangeifs 1..10` results in `12345678910`, and `IFS=_ rangeifs {1..10}` results in `1_2_3_4_5_6_7_8_9_10`.

All elements of the range will be in the output, even if those elements are delimiters in `IFS`: `IFS=a rangeifs {a..f}` works.

The arguments to this function are handled exactly as they are for `range`, and errors are emitted for the same conditions.

Be aware that [*`IFS` is tricky*](http://mywiki.wooledge.org/BashSheet#Special_Parameters). It is not a delimiter; it is a list of possible delimiters. The behaviors of `IFS=abc rangeifs {1..5}`, ``IFS="\n" rangeifs {1..5}`, and `IFS=$'\n' rangeifs {1..5}` illustrate this. See the "Limitations" section for more info.

### `rangefunc FUNC ARGS`

This function generates a range from `ARGS`, and then calls the supplied Bash (or shell) function `FUNC` once for each element in that range.

Ranges are generated from `ARGS` by the same rules used for the `range` function, so `rangefunc myFunction $foo $bar`, `rangefunc myFunction {1..10}`, and `rangefunc myFunction {$foo..10}` are all valid inputs, provided the variables they contain are valid.

`rangefunc` will report an error if its first argument is not a function defined in the current shell: `f() { echo $1; }; rangefunc f 1..10` will work, but `rangefunc notDefined 1..10` will raise an error (print to STDERR, print nothing to STDOUT, and return a nonzero status).

`FUNC` will be called with a single defined argument (i.e. a `$1` doesn't violate `set -u`, so no need for `"${1:-}"`). `FUNC` will be called with results of the `range` function applied to `ARGS`, _not_ with elements of the range _combined_ from `range ARGS` and any adjacent ranges. In other words, ` a=2; f() { echo -n "$1 "; }; rangefunc f {1..$a}{a..b}` results in `1a 1b 2a 2b`.

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

Since Bash functions are global by default, functions with the same names as those documented for this file will conflict with  (overwrite or be overwritten by) the functions defined in this file. Additionally, any functions or globals whose names start with `_zblocal_` that are not created by code in [the source repository containing this file](https://github.com/zbentley/bash-tricks) may interfere with its behavior.

No environment variables are read or written by any functions in this file.

# Limitations

The goal of these functions is to emulate as much of the native bash range behavior as possible without compromising performance, compatibility, or usability. Not all capabilities of the built-in bash ranges are available. For example, nested ranges like `{{a..z},{1..10}}` cannot be emulated with these functions.

Adjacent "combination" ranges (i.e. `{1..10}{a..z}` generating `1a 1b 1c ...` etc.) work, provided that only the _first_ combined range contains variables or things that Bash wouldn't natively expand: given `a=0`, `range {$a..10}{a..z}` works, but `range {a..z}{$a..10}` does not; neither does `range {$a..10}{10..$a}`.

[Word splitting](http://mywiki.wooledge.org/WordSplitting) may cause the `range` function to do unexpected things in the presence of `IFS` contents which contain data in the range. For example, `IFS=abc first=a; range {$first..z}` results in an error. To prevent such errors, quote some or all of the arguments to `range`. `range "{$first..z}"`, `range "$first" z`, and `range {"$first"..z}` will all work. This behavior isn't related to `range` itself; it applies to the rest of Bash as well; `IFS=abc first=a; echo {$first..z}` illustrates this.

# TODO

This should be enhanced with:

- Thorough automated tests.
- The ability to extend the range syntax, optionally, to encompass `a..0` xor `0..a`.
- `rangefunc` should conserve memory as much as possible. At present it allocates the full range as a string, which may be incompatible with some environments' assumptions.
- CONTRIBUTING guidelines.
- Useful links to other tools.