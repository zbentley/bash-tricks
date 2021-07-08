# shellcheck disable=SC2034,SC2154

_zb_substr() {
    "$_zb_local_polyfill" input="${1:-}"
    "$_zb_local_polyfill" len="${#input}"
    "$_zb_local_polyfill" start="${2:-}"
    "$_zb_local_polyfill" end="${3:-0}"

    if (( start >= 0 )); then
        case "$start" in
            0*)
                echo 'Usage: substr string start offset; start and offset must be numbers, start must be positive.' >&2
                return 127 ;; 
        esac
    else
        echo 'Usage: substr string start offset; start and offset must be numbers, start must be positive.' >&2
        return 127
    fi

    if (( end == end )); then
        # if [ $_zb_has_native ]; then
        #     printf %s "${input:$start:$end}"
        #     return $?
        # fi
        # If $end > len(input): end was negative and ended up before start.
        # If $end < 0: end was positive and beyond the end of the string.
        # Otherwise, it's in the string somewhere; compute the offset from the end.
        case "$end" in
            # A zero offset is kinda pointless, but you can do it if you want.
            0) ;;
            [1-9]*) end=$(( len < start + end ? 0 : len - start - end )) ;; 
            -*) end=$(( end * -1 )) ;;
            *) 
                echo 'Usage: substr string start offset; start and offset must be numbers, start must be positive.' >&2
                return 127 ;;
        esac
    else
        echo 'Usage: substr string start offset; start and offset must be numbers, start must be positive.' >&2
        return 127
    fi

    while (( start > 100 )); do
        eval "input=\"\${input#${_zb_nullcache_100}}\""
        start=$(( start - 100 ))
    done

    eval "start=\"\$_zb_nullcache_${start}\""
    eval "input=\"\${input#${start}}\""

    if ((  end > 100 )); then
        eval "input=\"\${input%%${_zb_nullcache_100}}\""
        end=$(( end % 100 ))
    fi

    eval "end=\"\$_zb_nullcache_$end\""
    eval "input=\"\${input%$end}\""
    printf %s "$input"
}

_zb_setup() {
    _zb_local_polyfill=local

    local a=1 >/dev/null 2>&1 || _zb_local_polyfill=typeset

    # Gotta use a subshell here since dash quits on a parse-failing eval.
    # Fortunately, it's the only subshell used and doesn't execute another
    # program.
    if ! ( a="${_zb_local_polyfill:1:1}"; false ) >/dev/null 2>&1; then
        "$_zb_local_polyfill" _zb_nullcache_size=""
        while (( ${#_zb_nullcache_size} <= 100 )); do
            eval "_zb_nullcache_${#_zb_nullcache_size}='${_zb_nullcache_size}'"
            _zb_nullcache_size="${_zb_nullcache_size}?"
        done
        # Polyfill for function declaration so locals work in ksh:
        eval 'function substr { _zb_substr "$@"; }' >/dev/null 2>&1 || substr=_zb_substr
    fi
    unset _zb_setup
}
_zb_setup



# 
# _zb_function_polyfill=$( command type function )
# case $_zb_function_polyfill in
#     # If the shell supports functions, switch to using them instead of the terse form.
#     *builtin*|*keyword*)
#         _zb_function_polyfill=$( typeset -f substr )
#         # Zsh and bash have the spaces in different spots.
#         _zb_function_polyfill="${_zb_function_polyfill#substr \(\)}"
#         _zb_function_polyfill="function substr ${_zb_function_polyfill#substr\(\)}"
#         # eval "$_zb_function_polyfill"
#         # unset $_zb_function_polyfill
#     ;;
# esac
# echo $_zb_function_polyfill

# Decide whether to activate
# # Check for a zsh-like environment that requires special treatment for
# # nested substitutions:
# if [ "${_zb_local_polyfill%$_zb_nullcache_1}" != "typeset var" ]; then
    
# fi

