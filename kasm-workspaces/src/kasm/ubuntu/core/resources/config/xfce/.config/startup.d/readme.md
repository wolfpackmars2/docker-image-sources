# Introduction

This workspace uses an improved startup system. When the workspace starts, the startup system will incorporate any executable files from this directory into the startup routine. This allows the user to easily add personal startup actions from their personal profile.

# Guide

File names should follow the format "???-startup_description" where "??? is a 3 digit zero-padded number. This number will determine the script startup position. If an item with the same number exists in the startup sequence, items in this directory will be assigned the NEXT available number in the sequence.

For example, if the system "${STARTUPDIR}/startup.d" directory contains the following files as part of the workspace image
 - 000.sh
 - 010-gnome_keyring.sh
 - 300-Start_docker_in_docker
 - 900-Custom_startup.sh

And the user "~/.config/startup.d" directory contains
 - 300-Add_ssh_keys_to_agent

The resulting startup order will be
 - 000.sh
 - 010-gnome_keyring.sh
 - 300-Start_docker_in_docker
 - 301-Add_ssh_keys_to_agent
 - 900-Custom_startup.sh

File extensions are optional. For this reason, files must be executable, and must include a valid bash shebang line. Additionally, executable file names must begin with 3 digits.

Files in "${STARTUPDIR}/startup.d" must meet ALL the following requirements, or they will be ignored:
 - Owned by the same user as ~/.config
 - Permission set to 700 (Owner: RWX, Group: ---, Other: ---) or 500 (Owner: R-X, Group: ---, Other: ---)
 - Name begins with 3 digits, 000 to 999 (though it is recommended to use a number no greater than 951)
 - Name must not end with ".insh", which are shell-script include files
 - Fourth character must be -

If the startup system finds valid startup items, it will create the directory "/tmp/.startup.d" and create soft links named using the calculated startup id followed by the original file name, linked to the original file in ~/.config/startup.d. For example:
 - /tmp/.startup.d/301-Add_ssh_keys_to_agent -> ~/.config/startup.d/300-Add_ssh_keys_to_agent

The following is an example bash script template
Note: A more complete example is provided in
      ${STARTUPDIR}/startup.d/template.sh and
      ${STARTUPDIR}/startup.d/template.insh
================================================

#!/usr/bin/env bash
set -e

# Example file name: ~/.config/startup.d/300-my_startup_action
# File permissions should be 500 or 700
# File should be owned by kasm-user or uid:gid 1000:1000

#DEV=1 # Uncomment to force debugging output

_TRUE=1
_FALSE=0

source "${STARTUPDIR}/startup.d/__common.insh"
source "${STARTUPDIR}/startup.d/__common_functions.insh"

# ============================================================================
# Set the folowing variables for the startup item
# TITLE: string title for the process being started
TITLE="Change-Me"
# DESCRIPTION: string description of the process being started
DESCRIPTION="${TITLE}"
# START_COMMAND: command line to start the process. Note: START_COMMAND should be non-blocking
START_COMMAND="echo 'Change-Me' &"
# PID_SEARCH_STRING: string to search for in process list to find the PID
PID_SEARCH_STRING="change-me"
# KEEPALIVE: set to $_TRUE (1) to enable automatic restarting of the process if it exits, or $_FALSE (0) to disable
KEEPALIVE=$_TRUE
# MAXIMIZE: set to $_TRUE (1) to attempt to maximize the process window on start; set to $_FALSE to disable
MAXIMIZE=$_FALSE
# RESTART_COMMAND: command to restart the process. If different from START_COMMAND, specify the command line here. Otherwise use "${START_COMMAND}" to use the same command line for starting and restarting.
RESTART_COMMAND="${START_COMMAND}"
# Set PID to either 0 or $__SCRIPT_PID. If 0, __PID will be set elsewhere in the startup script using PID_SEARCH_STRING. If set to anything other than 0, __PID will use the value set here
PID=0
# ============================================================================

``` bash
if [[ -f "${__SCRIPT_FULLPATH%.sh}.insh" ]]; then
    # This file is optional. One possible use is to separate script variables, such as those defined above, in a separate .insh file. A sample file is provided: "__sample_config.insh".
    # Example file name: ~/.config/startup.d/300-my_startup_action.insh
    source "${__SCRIPT_FULLPATH%.sh}.insh"
fi

if [[ -f "${__SCRIPT_DIR}/__common_functions.insh" ]]; then
    # Example file name: ~/.config/startup.d/__common_functions.insh. It's use is optional.
    source "${__SCRIPT_DIR}/__common_functions.insh"
fi

# ============================================================================
# Customize this section
# Note: __pre_run is only run during __start, while __post-run is run during both __start and __restart

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  __pre-run
#   DESCRIPTION:  Perform any actions prior to running "${START_COMMAND}"
#         USAGE:  __pre-run
#         NOTES:  These actions are only run during initial "${START_COMMAND}"
#                 run, and will not be run again if the process is restarted as
#                 part of the keep-alive mechanism
#-------------------------------------------------------------------------------
__pre-run() {
    # Perform any actions prior to running "${START_COMMAND}"
    # These actions are only run during initial "${START_COMMAND}" run, and will not be run again if the process is restarted as part of the keep-alive mechanism
    #/usr/bin/filter_ready
    #/usr/bin/desktop_ready
    : # This line does nothing
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  __post-run
#   DESCRIPTION:  Perform any actions after running "${START_COMMAND}"
#         USAGE:  __post-run
#         NOTES:  These actions are performed after every invocation of
#                 "${START_COMMAND}" or "${RESTART_COMMAND}"
#-------------------------------------------------------------------------------
__post-run() {
    # Perform any actions after running "${START_COMMAND}"
    # These actions are performed after every invocation of "${START_COMMAND}" or "${RESTART_COMMAND}"
    #sleep 5 # give dockerd some time to start before trying to run any commands that depend on it
    : # This line does nothing
}

# Generally, should not need to modify anything below this line
# ============================================================================

source "${STARTUPDIR}/startup.d/__basic_startup_script.insh"
```