#!/usr/bin/env bash

# Get the path to this script regardless of where it was executed from
ENTRY_PATH="$( cd "$(dirname "$0")" ; pwd -P )/$(basename "$0")"
if [[ -L $ENTRY_PATH ]]; then
    ENTRY_PATH=$(readlink "$ENTRY_PATH")
fi
ENTRY_PATH=$(dirname "$ENTRY_PATH")
APP_ROOT=$ENTRY_PATH/..;

# Import all of the required helpers/utility scripts and functions.
#
# Import all these files when this entry point is accessed ensures all sub commands that are executed are fully
# bootstrapped and able to call any of it's needed requirements/extensions. Another benefit of this initial
# bootstrapping allows functions to have nested requirements that will all be met when the function is finally
# executed (ie/ post inclusion).
#
# NOTE TO DEVELOPERS: If planning on using the src files outside of this entrypoint then requirements must be
# handled externally and manually.
importDirs=("src/util" "src/functions")
for importDir in "${importDirs[@]}"; do
    for file in $APP_ROOT/$importDir/*.sh; do
        # shellcheck source=/dev/null
        source "$file";
    done;
done


# If no commands received show help
if [[ $# == 0 ]]; then
    cat "$APP_ROOT/src/help/homebrew-lemp.txt"
    exit 1
fi

# Handle the display of help pages if required
# The following command structures can be used to trigger help:
#     $ homebrew-lemp help [command]
#     $ homebrew-lemp <command> --help
#     $ homebrew-lemp <command> -h
if string_ending "$*" "--help" || string_ending "$*" "-h" || [ "$1" == "help" ]; then
    if [[ $1 == "help" ]]; then
        shift 1

        # If only help command provided
        if [[ $# == 0 ]]; then
            cat "$APP_ROOT/src/help/homebrew-lemp.txt"
            exit 0
        fi
    fi

    if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
        cat "$APP_ROOT/src/help/homebrew-lemp.txt"
        exit 0;
    fi

    # Loop over the remaining sections of the command to find and include the help file
    helpSearchPath="$APP_ROOT/src/help"
    while [ $# -gt 0 ]; do
        helpStub=$1
        shift 1

        if [[ -f $helpSearchPath/$helpStub.txt ]]; then
            cat "$helpSearchPath/$helpStub.txt"
            exit 0
        elif [[ -d $helpSearchPath/$helpStub ]]; then
            helpSearchPath=$helpSearchPath/$helpStub
        else
            error "Failed to find help output"
            cat "$APP_ROOT/src/help/homebrew-lemp.txt"
            exit 1
        fi
    done
fi

# Not displaying help, route to command
# Loop over all of the commands passed to a file
commandFilePath="$APP_ROOT/src/commands"
while [ $# -gt 0 ]; do
    # Grab currently processed command, shift everything along
    commandStub=$1
    shift 1

    # If a command represents a command file name, include and execute it
    # Else if it's a sub directory update the commandFilePath variable so it is searched within on the next loop
    # If all else fails, show an unhandled command error
    if [[ -f $commandFilePath/$commandStub.sh ]]; then
        # shellcheck disable=SC1090
        . "$commandFilePath/$commandStub.sh"
    elif [[ -d $commandFilePath/$commandStub ]]; then
        commandFilePath=$commandFilePath/$commandStub
    else
        error "Unhandled Command"
        exit 1
    fi
done
