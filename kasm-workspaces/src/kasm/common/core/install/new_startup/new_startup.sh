#!/usr/bin/env bash
set -e
shopt -s extglob

# I am new_startup.sh

#export DEV=1 # uncomment to enable debugging for this script and all scripts run by it. All output will be logged to "/tmp/${__TMPDIR}/MASTER.log"

__TMPDIR=$(mktemp -d)
__LOGFILE="${__TMPDIR}/MASTER.log"
exec > >(tee -a "${__LOGFILE}") 2>&1

_DEV=0
if [[ "${DEV:-0}" == "1" ]]; then
    _DEV=1
    set -x
    PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
    echo "Running in: $BASH_VERSION"
    echo -n "Running: "
    ls -l /proc/$$/exe # log the shell interpreter for this script
fi

_TRUE=1
_FALSE=0

__SCRIPTARGS="$*"
__SCRIPTFULLNAME=$(realpath "$0")
__SCRIPTNAME=$(basename "${__SCRIPTFULLNAME}")
__SCRIPTFULLPATH=$(dirname "${__SCRIPTFULLNAME}")

declare -A __STARTUP_PROCS

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  __start
#   DESCRIPTION:  Run a command if it exists and is executable
#         USAGE:  __start <command>
#-------------------------------------------------------------------------------
__start() {
    if [ -f "$1" ] && [ -x "$1" ]; then
        echo "Running command: $1"
        #"$1" &
        __OUTPUT="${1##*/}"
        __OUTPUT="${__TMPDIR}/${__OUTPUT%.*}.out"
        if [ -f "${__OUTPUT}" ]; then
            rm "${__OUTPUT}"
        fi
        OUTPUT="${__OUTPUT}" sh -c "$1"
        if [ -f "${__OUTPUT}" ]; then
            __STARTUP_PROCS["$1"]=$(cat "${__OUTPUT}")
        else
            echo "Output file ${__OUTPUT} not found. Command may not have run correctly."
            __STARTUP_PROCS["$1"]="$_FALSE:0"
        fi
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
        fi
        OUTPUT="${__OUTPUT}" RESTART=$_TRUE sh -c "$1"
        if [ -f "${__OUTPUT}" ]; then
            __STARTUP_PROCS["$1"]=$(cat "${__OUTPUT}")
        else
            echo "Output file ${__OUTPUT} not found. Command may not have run correctly."
            __STARTUP_PROCS["$1"]="$_FALSE:0"
        fi
    else
        echo "Command $1 not found or not executable"
    fi
}

__get_startup_items() {
    local sys_dir="/dockerstartup/startup.d"
    local user_dir="${HOME}/.config/startup.d"
    local tmp_dir="/tmp/.startup.d"
    local files=()
    declare -A used_ids

    # Fresh start for the temp directory
    rm -rf "$tmp_dir" && mkdir -p "$tmp_dir"

    process_dir() {
        local dir="$1"
        # Match 3 digits, hyphen, excludes .insh
        for file in "$dir"/[0-9][0-9][0-9]-!(*.insh); do
            [[ -f "$file" && -x "$file" ]] || continue

            local filename=$(basename "$file")
            local id="${filename:0:3}"
            local target_name="$filename"

            # 1. Collision Handling
            if [[ -n "${used_ids[$id]}" ]]; then
                local next_id=$(( 10#$id + 1 ))
                while [[ -n "${used_ids[$(printf "%03d" $next_id)]}" && $next_id -le 999 ]]; do
                    ((next_id++))
                done
                [[ $next_id -gt 999 ]] && continue
                id=$(printf "%03d" $next_id)
                target_name="${id}-${filename:4}"
            fi

            # 2. Create the Script Symlink in /tmp
            local tmp_script_path="$tmp_dir/$target_name"
            ln -sf "$file" "$tmp_script_path"

            # 3. Mirror the .insh file (Crucial Step)
            # We look for the .insh in the same directory as the source file
            local source_insh="${dir}/${filename%.*}.insh"
            if [[ -f "$source_insh" ]]; then
                ln -sf "$source_insh" "${tmp_dir}/${target_name%.*}.insh"
            fi

            used_ids["$id"]=1
            files+=("$tmp_script_path")
        done
    }

    # Process system then user (user will trigger collision logic)
    process_dir "$sys_dir"
    process_dir "$user_dir"

    # Sort the resulting /tmp paths by filename (ID)
    printf "%s\n" "${files[@]}" | sort
}

__STARTUP_SCRIPTS=( $(__get_startup_items) )
if [[ "${DEV:-0}" == "1" ]]; then
    echo "Startup scripts to run in order:"
    for script in "${__STARTUP_SCRIPTS[@]}"; do
        echo "$script"
    done
fi
for script in "${__STARTUP_SCRIPTS[@]}"; do
    __start "$script"
done

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
                if [[ "${_DEV}" == "1" ]]; then
                    echo "DEV mode: Process ${__PID} (${__cmd##*/}) has exited. Auto-restart disabled."
                else
                    echo "Process ${__PID} has exited, restarting..."
                    __restart "${__cmd}" "${__PID}"
                fi
            fi
        fi
    done
    sleep 5
done
