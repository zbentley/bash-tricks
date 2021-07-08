_zblocal_i_interactive=

function _zblocal_f_loginteractive {
    local inc fmt=n/a
    inc="${2:-0}"
    if (( inc > 0 )); then
        fmt=yes
    elif [[ -n "${2:-}" ]]; then
        fmt=no
    fi
    printf "%-30s %s\n" "${1:-}:" "$fmt"
    _zblocal_i_interactive=$(( _zblocal_i_interactive + inc ))
}

# Returns: 0: isinteractive, 1: is not, 2: unknown
function _zblocal_f_detectinteractive {
    local pid=$$ IFS=
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

    if [[ "$-" == *i* ]]; then
        _zblocal_f_loginteractive "-i on or forced" 1
    else
        _zblocal_f_loginteractive "-i on or forced" 0
    fi

    if [[ "$-" == *s* ]]; then
        _zblocal_f_loginteractive "-s on or forced" 1
    else
        _zblocal_f_loginteractive "-s on or forced" 0
    fi

    if [[ "$0" == *notty* ]]; then
        _zblocal_f_loginteractive "\$0 doesn't say notty" 0
    else
        _zblocal_f_loginteractive "\$0 doesn't say notty" 1
    fi

    if [[ "$0" == -* ]]; then
        _zblocal_f_loginteractive "\$0 starts with dash" 1
    else
        _zblocal_f_loginteractive "\$0 starts with dash" 1
    fi

    if [[ -f "/proc/${pid}/cmdline" ]]; then
        local line seen_notty=
        while read -r line; do
            if [[ "$line" == *notty* ]]; then
                _zblocal_f_loginteractive "cmdline doesn't say notty" 0
                seen_notty=1
                break
            fi
        done <"/proc/${pid}/cmdline"

        if [[ -n "$seen_notty" ]]; then
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

    local descriptors=(STDIN STDOUT STDERR)
    for cur in "${!descriptors[@]}"; do
        if [[ -t "$cur" ]]; then
            _zblocal_f_loginteractive "${descriptors[cur]} is a tty" 1
        else
            _zblocal_f_loginteractive "${descriptors[cur]}} is a tty" 0
        fi
    done
}

# Pretty stupid. Checks to see if more indicators than not point towards
# the current shell being interactive. Returns true if so. 
function isinteractive {
    if [[ -z "$_zblocal_i_interactive" ]]; then
        echo "Checking terminal interactivity..."
        _zblocal_f_detectinteractive
    fi
    (( _zblocal_i_interactive > 0 ))
}