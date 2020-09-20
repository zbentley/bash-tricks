# $USER $LOGNAME $EUID ${GROUPS[@]}
# Handle 'I have no name!'
# passwd parsing
# awk, perl, python, ruby?

_zblocal_i_returnid=

function _zblocal_f_getid() {
    if ! _zblocal_i_returnid=$("$@") || [[ -z "$_zblocal_i_returnid" ]]; then
        _zblocal_i_returnid=
        echo "${BASH_SOURCE[0]:-}: ${FUNCNAME[1]:-}() line ${BASH_LINENO[0]:-?}: '$*' failed" >&2
        return 1
    fi
}

function _zblocal_f_get_euid() {
    local first probe
    first="${1:-}"
    probe="${first:+1}"
    # If we're asked for the current EUID and have the $EUID global variable,
    # check to make sure it's not exported. If it's exported, or if we don't
    # have it, probe using system commands.
    if [[ -z "$probe" ]]; then
        if [[ -z "${EUID:-}" ]] || ! compgen -e -X '!EUID' >/dev/null; then
            probe=1
        fi
    fi

    if [[ -n "$probe" ]]; then
        # Return value will either be set or empty with a nonzero return code.
        _zblocal_f_getid id -u ${first:+"$first"} # pass $first only if non-empty
    else
        _zblocal_i_returnid=$EUID
    fi
}

function _zblocal_f_get_ruid() {
    local first probe
    first="${1:-}"
    probe="${first:+1}"
    # If we're asked for the current UID and have the $UID global variable,
    # check to make sure it's not exported. If it's exported, or if we don't
    # have it, probe using system commands.
    if [[ -z "$probe" ]]; then
        if [[ -z "${UID:-}" ]] || ! compgen -e -X '!UID' >/dev/null; then
            probe=1
        fi
    fi

    if [[ -n "$probe" ]]; then
        # Return value will either be set or empty with a nonzero return code.
        _zblocal_f_getid id -ru ${first:+"$first"} # pass $first only if non-empty
    else
        _zblocal_i_returnid=$UID
    fi
}

function get_uids() {
    _zblocal_f_get_euid "$@" || return
    printf '%s ' "$_zblocal_i_returnid"
    _zblocal_i_returnid=
    _zblocal_f_get_ruid "$@" || return
    printf '%s\n' "$_zblocal_i_returnid"
    _zblocal_i_returnid=
}