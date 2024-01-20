#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  writer.sh
#
#         USAGE:  writer.sh <path_to_file> <string_to_write>
#
#   DESCRIPTION: Writes a user specified string to a user specified file.
#
#       OPTIONS: ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  Written for assignment-1
#        AUTHOR:  Chad Bartlett, bartsblues@hotmail.com
#       COMPANY:  ---
#       VERSION:  0.1
#       CREATED:  Fri 19 Jan 2024 04:26:56 PM PST
#      REVISION:  ---
#===============================================================================
# Ref: http://redsymbol.net/articles/unofficial-bash-strict-mode/

# Immediately exit of any command has a non-zero status
set -e
# Error when referencing any variables not previously defined
set -u
# If any command in a pipeline fails, that return code will be used for the
# entire pipeline.
set -o pipefail
# Word Splitting. Happens only on newlines and tab characters. By default, Bash
# sets this to `$' \n\t'` - space, newline, tab - which is too eager.
IFS=$'\n\t'

ORIG_PATH="$(pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE:-0}")"
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE:-0}")")"

arg_writefile="${1:-""}"
arg_writestr="${2:-""}"

usage()
{
    printf "\n"
    printf "%s\n" "USAGE:"
    printf "    %s\n" "$SCRIPT_NAME <path_to_file> <write_string>"
    printf "\n"
}


msg()
{
    local timestamp
    local script
    local function
    local lineno
    local msg
    local theStackTraceOffset

    theStackTraceOffset=${2:-0}
    timestamp=$(date +'%F %T.%M')
    script=$(basename "${BASH_SOURCE[2]}")
    function="${FUNCNAME[((2 + theStackTraceOffset))]}"
    lineno="${BASH_LINENO[((1 + theStackTraceOffset))]}"
    msg="$1"

    theMsgStr="$timestamp [$script:$function:$lineno] $msg"
    printf "%s\n" "$theMsgStr"
}


errexit()
{
    local msg
    msg="${1:-""}"

    msg "ERROR: $msg"
    cd "$ORIG_PATH"
    exit 1
}


exit_if_empty_arg()
{
    local arg
    local msg
    arg="${1:-""}"
    msg="${2:-""}"

    if [ -z "$arg" ]; then
        usage
        errexit "$msg"
    fi
}


write_file()
{
    echo "$arg_writestr" >> "$arg_writefile"
    return "${PIPESTATUS[0]}"
}


create_file()
{
    local dir

    rm -rf "$arg_writefile" > /dev/null 2>&1
    dir="$(dirname "$arg_writefile")"
    mkdir -p "$dir" || errexit "Failed to create '$dir'"
    touch "$arg_writefile"

    return $?
}


validate_args()
{
    exit_if_empty_arg "$arg_writefile" "Must supply full path to file to write."
    exit_if_empty_arg "$arg_writestr"  "Must supply string to write to file."
}


main()
{
    validate_args
    create_file || errexit "Could not create '$arg_writefile'"
    write_file || errexit "Failed to write '$arg_writestr' to '$arg_writefile'"
    exit 0
}

main
