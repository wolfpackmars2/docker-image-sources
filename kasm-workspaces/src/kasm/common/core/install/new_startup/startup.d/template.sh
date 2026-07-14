#!/usr/bin/env bash
set -e

#Files in "${STARTUPDIR}/startup.d" must meet ALL the following requirements, or they will be ignored:
# - Owned by root
# - Permission set to 700 (Owner: RWX, Group: ---, Other: ---) or 500 (Owner: R-X, Group: ---, Other: ---)
# - Name begins with 3 digits, 000 to 999 (though it is recommended to use a number no greater than 951)
# - Name must not end with ".insh", which are shell-script include files

source "${STARTUPDIR}/startup.d/__common.insh" # Minimum required script elements

# Source user shell-include (insh) file
if [[ -f "${__SCRIPT_FULLPATH%.sh}.insh" ]]; then
    source "${__SCRIPT_FULLPATH%.sh}.insh"
fi

source "${STARTUPDIR}/startup.d/__common_functions.insh" # common functions and template variables

# ============================================================================
# Customize this section

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  __maximize
#   DESCRIPTION:  Maximize the process window if MAXIMIZE is set to true (1)
#         USAGE:  __maximize
#         NOTES:  This is run after __post_run any time the process is (re)started.
#                 This function can be overridden by the processes .insh file
#-------------------------------------------------------------------------------
if ! declare -f __maximize >/dev/null; then
    __maximize() {
        if [ "${MAXIMIZE:-0}" == "1" ] && [ "${MAXIMIZE_NAME:-}" != "" ]; then
            wmctrl -Fr "${MAXIMIZE_NAME}" -b add,maximized_vert,maximized_horz || wmctrl -r "${MAXIMIZE_NAME}" -b add,maximized_vert,maximized_horz || echo "Failed to maximize window with name ${MAXIMIZE_NAME}"
        fi
    }
fi

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  __pre-run
#   DESCRIPTION:  Perform any actions prior to running "${START_COMMAND}"
#         USAGE:  __pre-run
#         NOTES:  These actions are only run during initial "${START_COMMAND}"
#                 run, and will not be run again if the process is restarted as
#                 part of the keep-alive mechanism.
#                 The placeholder function defined here can be overridden by
#                 defining a function of the same name in a .insh file.
#-------------------------------------------------------------------------------
if ! declare -f __pre-run >/dev/null; then
    __pre-run() {
        : # no-op placeholder
    }
fi

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  __post-run
#   DESCRIPTION:  Perform any actions after running "${START_COMMAND}"
#         USAGE:  __post-run
#         NOTES:  These actions are performed after every invocation of
#                 "${START_COMMAND}" or "${RESTART_COMMAND}".
#                 The placeholder function defined here can be overridden by
#                 defining a function of the same name in a .insh file.
#-------------------------------------------------------------------------------
if ! declare -f __post-run >/dev/null; then
    __post-run() {
        : # no-op placeholder
    }
fi

# Generally, should not need to modify anything below this line
# ============================================================================

source "${STARTUPDIR}/startup.d/__common_startup_script.insh"
