# $USER $LOGNAME $EUID ${GROUPS[@]}
# Handle 'I have no name!'
# passwd parsing
# awk, perl, python, ruby?

_zblocal_i_returnid=

function _zblocal_f_getid() {
    _zblocal_i_returnid=$("$@")
    if [[ $? -ne 0 || -z $_zblocal_i_returnid ]]; then
        _zblocal_i_returnid=
        echo "${BASH_SOURCE[0]:-}: ${FUNCNAME[1]:-}() line ${BASH_LINENO[0]:-?}: '$@' failed" >&2
        return $?
    fi
}

function _zblocal_f_get_euid() {
    local first probe
    first="${1:-}"
    probe="${first:+1}"
    # If we're asked for the current EUID and have the $EUID global variable,
    # check to make sure it's not exported. If it's exported, or if we don't
    # have it, probe using system commands.
    if [[ -z $probe ]]; then
        if [[ -z "${EUID:-}" ]]; then
            probe=1
        elif ! compgen -e -X '!EUID' >/dev/null; then
            probe=1
        fi
    fi

    if [[ -n $probe ]]; then
        # Return value will either be set or empty with a nonzero return code.
        _zblocal_f_getid "id -u${first:+ $first}"
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
    if [[ -z $probe ]]; then
        if [[ -z "${UID:-}" ]]; then
            probe=1
        elif ! compgen -e -X '!UID' >/dev/null; then
            probe=1
        fi
    fi

    if [[ -n $probe ]]; then
        # Return value will either be set or empty with a nonzero return code.
        _zblocal_f_getid "id -ru${first:+ $first}"
    else
        _zblocal_i_returnid=$UID
    fi
}

function get_uids() {
    _zblocal_f_get_euid "$@"
    [[ $? -ne 0 ]] && return $?
    echo -n "$_zblocal_i_returnid "
    _zblocal_i_returnid=
    _zblocal_f_get_ruid "$@"
    [[ $? -ne 0 ]] && return $?
    echo $_zblocal_i_returnid
    _zblocal_i_returnid=
}