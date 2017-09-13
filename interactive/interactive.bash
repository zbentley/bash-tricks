_zblocal_i_interactive=

function _zblocal_f_loginteractive {
    local inc fmt
    inc="${2:-0}"
    if [[ $inc -gt 0 ]]; then
        fmt=yes
    elif [[ -n "${2:-}" ]]; then
        fmt=no
    else
        fmt=n/a
    fi
    printf "%-30s %s\n" "${1:-}:" $fmt
    _zblocal_i_interactive=$(( $_zblocal_i_interactive + $inc ))
}

# Returns: 0: isinteractive, 1: is not, 2: unknown
function _zblocal_f_detectinteractive {
    local yes=0 no=0 pid=$$ IFS= cur
    if [[ -n "${SSH_TTY:-}" ]]; then
        _zblocal_f_loginteractive "ssh-supplied tty" 1
    elif [[ -n "${SSH_CONNECTION:-}" ]]; then
        _zblocal_f_loginteractive "ssh-supplied tty" 0
    else
        _zblocal_f_loginteractive "ssh-supplied tty"
    fi

    if [[ -z "${TERM:-}" ]]; then
         _zblocal_f_loginteractive "TERM is set" 0
    else
        _zblocal_f_loginteractive "TERM is set" 1
    fi

    if [[ -z "${PS1:-}" ]]; then
        _zblocal_f_loginteractive "PS1 is set" 0
    else
        _zblocal_f_loginteractive "PS1 is set" 1
    fi

    if [[ $- == *i* ]]; then
        _zblocal_f_loginteractive "-i on or forced" 1
    else
        _zblocal_f_loginteractive "-i on or forced" 0
    fi

    if [[ $- == *s* ]]; then
        _zblocal_f_loginteractive "-s on or forced" 1
    else
        _zblocal_f_loginteractive "-s on or forced" 0
    fi

    if [[ $0 =~ notty ]]; then
        _zblocal_f_loginteractive "\$0 doesn't say notty" 0
    else
        _zblocal_f_loginteractive "\$0 doesn't say notty" 1
    fi

    if [[ $0 =~ ^[-] ]]; then
        _zblocal_f_loginteractive "\$0 starts with dash" 1
    else
        _zblocal_f_loginteractive "\$0 starts with dash" 1
    fi

    if [[ -f /proc/$pid/cmdline ]]; then
        cur=
        while read cur; do
            if [[ $cur =~ notty ]]; then
                _zblocal_f_loginteractive "cmdline doesn't say notty" 0
                cur=$'\r' # Will never be in that file, probz.
                break
            fi
        done </proc/$pid/cmdline

        if [[ $cur != $'\r' ]]; then
             _zblocal_f_loginteractive "cmdline doesn't say notty" 1
        fi
    else
        _zblocal_f_loginteractive "cmdline doesn't say notty"
    fi

    # ZSH equivalent of the below: [[ -o login ]]
    if shopt -q login_shell; then
        _zblocal_f_loginteractive "Running in a login shell" 1
    else
        _zblocal_f_loginteractive "Running in a login shell" 0
    fi

    for cur in 0STDIN 1STDOUT 2STDERR; do
        if [[ -t "${cur:0:1}" ]]; then
            _zblocal_f_loginteractive "${cur:1} is a tty" 1
        else
            _zblocal_f_loginteractive "${cur:1} is a tty" 0
        fi
    done
}

# Pretty stupid. Checks to see if more indicators than not point towards
# the current shell being interactive. Returns true if so. 
function isinteractive {
    if [[ -z "$_zblocal_i_interactive" ]]; then
        printf "Checking terminal interactivity..."
        _zblocal_f_detectinteractive
    fi
    [[ $_zblocal_i_interactive -gt 0 ]]
    return $?
}