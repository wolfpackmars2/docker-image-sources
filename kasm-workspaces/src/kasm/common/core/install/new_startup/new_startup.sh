#!/usr/bin/env bash
set -e

# I am new_startup.sh

#export DEV=1 # uncomment to enable debugging for this script and all scripts run by it. All output will be logged to "/tmp/${__TMPDIR}/MASTER.log"

__TMPDIR=$(mktemp -d)
_DEV=0
if [[ "${DEV:-0}" == "1" ]]; then
    # enable early debugging with `DEV=1 __SCRIPTNAME`
    _DEV=1
    __LOGFILE="${__TMPDIR}/MASTER.log"
    exec > >(tee -a "${__LOGFILE}") 2>&1
    set -x
    PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
fi

_TRUE=1
_FALSE=0

__SCRIPTARGS="$*"
__SCRIPTFULLNAME=$(realpath "$0")
__SCRIPTNAME=$(basename "${__SCRIPTFULLNAME}")
__SCRIPTFULLPATH=$(dirname "${__SCRIPTFULLNAME}")

declare -A __STARTUP_PROCS

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  __run
#   DESCRIPTION:  Run a command if it exists and is executable
#         USAGE:  __run <command>
#-------------------------------------------------------------------------------
__start() {
    if [ -f "$1" ] && [ -x "$1" ]; then
        echo "Running command: $1"
        #"$1" &
        __OUTPUT="${1##*/}"
        __OUTPUT="${__TMPDIR}/${__OUTPUT%.*}.out"
        if [ -f "${__OUTPUT}" ]; then
            rm "${__OUTPUT}"
            #touch "${__OUTPUT}"
        fi
        OUTPUT="${__OUTPUT}" sh -c "$1"
        if [ -f "${__OUTPUT}" ]; then
            __STARTUP_PROCS["$1"]=$(cat "${__OUTPUT}")
        else
            echo "Output file ${__OUTPUT} not found. Command may not have run correctly."
            __STARTUP_PROCS["$1"]="$_FALSE:0"
        fi
        #__STARTUP_PROCS["$1"]=$(cat "${__OUTPUT}")
    else
        echo "Command $1 not found or not executable"
    fi
}

__restart() {
    if [ -f "$1" ] && [ -x "$1" ]; then
        echo "Restarting command: $1"
        # restart the command
        __OUTPUT="${1##*/}"
        __OUTPUT="${__TMPDIR}/${__OUTPUT%.*}.out"
        if [ -f "${__OUTPUT}" ]; then
            rm "${__OUTPUT}"
            #touch "${__OUTPUT}"
        fi
        OUTPUT="${__OUTPUT}" RESTART=$_TRUE sh -c "$1"
        if [ -f "${__OUTPUT}" ]; then
            __STARTUP_PROCS["$1"]=$(cat "${__OUTPUT}")
        else
            echo "Output file ${__OUTPUT} not found. Command may not have run correctly."
            __STARTUP_PROCS["$1"]="$_FALSE:0"
        fi
        #__STARTUP_PROCS["$1"]=$(cat "${__OUTPUT}")
    else
        echo "Command $1 not found or not executable"
    fi
}

# run all scripts in startup.d
if [ -d "${STARTUPDIR}/startup.d" ]; then
    for script in "${STARTUPDIR}/startup.d/"*; do
        __start "$script"
    done
fi

# Start the keepalive loop
while :
do
    # Check all keys in __STARTUP_PROCS. ! gets the key name without the associated value.
    if [[ "${DEV:-0}" == "1" ]]; then
        echo "Current startup processes and PIDs:"
        for __cmd in "${!__STARTUP_PROCS[@]}"; do
            echo "Command: ${__cmd}, RESULT: ${__STARTUP_PROCS[${__cmd}]}"
        done
        echo "Variable values: "
        set | sort
    fi
    for __cmd in "${!__STARTUP_PROCS[@]}"; do
        if [ "${__STARTUP_PROCS[${__cmd}]:0:1}" == "$_TRUE" ]; then
            __TMP_PID="${__STARTUP_PROCS[${__cmd}]:2}"
            __PID="${__TMP_PID%%:*}"
            if [ ${__PID} -gt 0 ] && ! kill -0 ${__PID} 2>/dev/null; then
                echo "Process ${__PID} has exited, restarting..."
                __restart "${__cmd}" "${__PID}"
                # restart the process and update the PID in __STARTUP_PROCS
                #__STARTUP_PROCS["$__cmd"]="$_TRUE:$($RESTART_COMMAND)"
            fi
        fi
    done
    sleep 5
done
