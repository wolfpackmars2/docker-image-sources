#!/usr/bin/env bash
set -e

_DEV=0
if [[ "${DEV:-0}" == "1" ]]; then
    # enable early debugging with `DEV=1 __SCRIPTNAME`
    _DEV=1
    set -x
    PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
fi

_TRUE=1
_FALSE=0

__SCRIPTPID=$$
__SCRIPTARGS="$*"
__SCRIPTFULLNAME=$(realpath "$0")
__SCRIPTNAME=$(basename "${__SCRIPTFULLNAME}")
__SCRIPTFULLPATH=$(dirname "${__SCRIPTFULLNAME}")

# ============================================================================
## Do not modify anything above this line

# Set __PID to either 0 or $__SCRIPTID. If 0, __PID will be set elsewhere in the startup script using PID_SEARCH_STRING
__PID=0

# Set the folowing variables for the startup item
# TITLE: string title for the process being started
TITLE="gnome-keyring-daemon"
# DESCRIPTION: string description of the process being started
DESCRIPTION="${__TITLE}"
# START_COMMAND: command line to start the process
START_COMMAND="gnome-keyring-daemon --daemonize --components=secrets"
# PID_SEARCH_STRING: string to search for in process list to find the PID
PID_SEARCH_STRING="gnome-keyring-daemon"
# KEEPALIVE: set to $_TRUE (1) to enable automatic restarting of the process if it exits, or $_FALSE (0) to disable
KEEPALIVE=$_TRUE
# MAXIMIZE: set to $_TRUE (1) to have the process window maximized on start, or $_FALSE (0) to leave it as is
MAXIMIZE=$_FALSE
# RESTART_COMMAND: command to restart the process. If different from START_COMMAND, specify the command line here. Otherwise use "${START_COMMAND}" to use the same command line for restarting as starting.
RESTART_COMMAND="${START_COMMAND}"

# ============================================================================
# Define any custom functions here. They will need to be called in either __pre-run or __post-run
#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  __generate_default_keyring
#   DESCRIPTION:  Generate a default keyring if it doesn't exist
#         USAGE:  __generate_default_keyring
#-------------------------------------------------------------------------------
__generate_default_keyring() {
    # keyring directory check
    if [ ! -d "${HOME}/.local/share/keyrings" ]; then
        echo "Creating keyrings directory..."
        mkdir -p "${HOME}/.local/share/keyrings"
    fi
    # default keyring reference file check
    if [ ! -f "${HOME}/.local/share/keyrings/default" ]; then
        echo "Creating default keyring reference file..."
        echo -n "Default_keyring" > "${HOME}/.local/share/keyrings/default"
        chown $(id -u):$(id -g) "${HOME}/.local/share/keyrings/default"
        chmod 644 "${HOME}/.local/share/keyrings/default"
    fi
    # default keyring file check
    __KEYRING_FILE="$(cat ${HOME}/.local/share/keyrings/default).keyring"
    if [ ! -f "${HOME}/.local/share/keyrings/${__KEYRING_FILE}" ]; then
        echo "Keyring file not found. Creating blank keyring..."
        # Create a blank keyring file
        echo -e "[keyring]\ndisplay-name=Default keyring\nctime=$(date +%s)\nmtime=0\nlock-on-idle=false\nlock-after=false" > "${HOME}/.local/share/keyrings/${__KEYRING_FILE}"
        chown $(id -u):$(id -g) "${HOME}/.local/share/keyrings/${__KEYRING_FILE}"
        chmod 600 "${HOME}/.local/share/keyrings/${__KEYRING_FILE}"
    fi
}

# Modify __pre-run and __post-run as needed. Note: __pre_run is only run during __start, while __post-run is run during both __start and __restart
__pre-run() {
    # any pre-run setup can be done here. If nothing is needed, this function can be left empty or removed
    __generate_default_keyring
}

__post-run() {
    # any post-run setup can be done here. If nothing is needed, this function can be left empty or removed
    :
}

# Generally, should not need to modify anything below this line
# ============================================================================

__get_pid() {
    # Check if ${PID_SEARCH_STRING} is running and return its PID
    pgrep -nf "${PID_SEARCH_STRING}" || echo -n "0"
}

__start() {
    echo "Starting ${TITLE}..."
    sh -c "${START_COMMAND}"
    #__PID=$(__get_pid)
}

#__restart() {
#    echo "Stopping ${TITLE}..."
#    kill ${RESTART_PID} || true
#    __start
#}

#if [[ -n ${RESTART_PID+x} && ${RESTART_PID} -gt 0 ]]; then
#    __restart
#    __post-run
#else
#    __pre-run
#    __start
#    __post-run
#fi
if [[ -z "${RESTART+x}" || "${RESTART}" -ne "$_TRUE" ]]; then
    __pre-run
fi
__start
__post-run
i=0
while true; do
    if [ $i -gt 5 ]; then
        echo "Failed to start ${TITLE} after $i attempts. Exiting."
        __RETURNVAL="$_FALSE:0"
        #echo -n "$_FALSE:0" # This will signal to the startup system that the process failed to start, so it won't keep trying to restart it
        #exit 0
        break
    fi
    __PID=$(__get_pid)
    if [ "$__PID" -eq 0 ]; then
        sleep 5 # give the process some time to start and update the PID file or process list
    else
        echo "${TITLE} is running with PID ${__PID}"
        __RETURNVAL="${KEEPALIVE}:${__PID}"
        #echo -n "$KEEPALIVE:$__PID"
        #exit 0
        break
    fi
    i=$((i + 1))
done
echo "${__RETURNVAL}"
if [[ -n "${OUTPUT:-}" && -w $(dirname "${OUTPUT}") ]]; then
    # Output format: $KEEPALIVE:$__PID
    echo -n "${__RETURNVAL}" > "${OUTPUT}"
fi
#echo -n "$KEEPALIVE:$__PID"
