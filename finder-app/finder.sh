#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  finder.sh
#
#         USAGE:  finder.sh <directory_to_search> <search_string>
#
#   DESCRIPTION: Searches all files within a user specified directory for a user
#                specified string.
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

arg_filesdir="${1:-""}"
arg_searchstr="${2:-""}"

usage()
{
    printf "\n"
    printf "%s\n" "USAGE:"
    printf "    %s\n" "$SCRIPT_NAME <path_to_directory> <search_string>"
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


print_result()
{
    local nfiles
    local nlines
    nfiles="$1"
    nlines="$2"
    msg "The number of files are $nfiles and the number of matching lines are $nlines"
}


count_number_of_matches()
{
    local result
    result=$(find "$arg_filesdir" -type f -exec grep -Hin "$arg_searchstr" {} \; | wc -l)
    echo "$result"
}


count_number_of_files()
{
    local result
    result=$(find "$arg_filesdir" -type f | wc -l)
    echo "$result"
}


validate_args()
{
    exit_if_empty_arg "$arg_filesdir" "Must supply directory to search."
    exit_if_empty_arg "$arg_searchstr" "Search string empty"
    [ -d "$arg_filesdir" ] || errexit "Directory '$arg_filesdir' does not exist"
}


main()
{
    validate_args
    print_result "$(count_number_of_files)" "$(count_number_of_matches)"
    exit 0
}

main
