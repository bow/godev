#!/usr/bin/env sh
#
# Shell functions for easier Go development
#
#
# Copyright (c) 2013 by Wibowo Arindrarto <bow@bow.web.id>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

export GODEV_VERSION=0.1.dev

_godev_help() {
cat << EOF
Usage: godev {add,cd,help,start,stop,version}

Subcommands:
    add      Symlinks the given directory into active development directory
    cd       Change working directory to active development directory
    help     Show this help message
    start    Starts a new GOPATH environment
    stop     Revert to the default system GOPATH
    version  Show version
EOF
}

# _godev_stop reverts to the default system settings
_godev_stop() {
    if [ -n "$_godev_old_GOPATH" ]; then
        export GOPATH=$_godev_old_GOPATH
    fi
    if [ -n "$_godev_old_PATH" ]; then
        export PATH=$_godev_old_PATH
    fi
    if [ -n "$_godev_old_PS1" ]; then
        export PS1=$_godev_old_PS1
    fi
    if [ -n "$GODEV_ACTIVE" ]; then
        unset _godev_old_GOPATH _godev_old_PATH _godev_old_PS1 GODEV_NAME \
            GODEV_ACTIVE GODEV_DIR
    fi
}

# _godev_start sets up an active development directory
_godev_start() {
    if [ -z "$GODEV_ROOT" ]; then
        echo "Error: GODEV_ROOT environment variable not set. Exiting." >&2
        return 1
    # create directory if it doesn't exist
    elif [ ! -d "$GODEV_ROOT" ]; then
        mkdir -p $GODEV_ROOT
    fi

    # if we're already in a GODEV, reset it first to obtain system defaults
    _godev_stop

    # capture first argument as env name
    if [ -z "$1" ]; then
        echo "Error: missing environment name. Exiting." >&2
        return 1
    fi
    export GODEV_NAME=$1
    shift
    export GODEV_DIR=$GODEV_ROOT/$GODEV_NAME

    # create GODEV_DIR if it doesn't exist
    if [ ! -d "$GODEV_DIR" ]; then
        mkdir -p $GODEV_DIR
    fi
    # make sure GODEV_DIR has the canonical GOPATH directories
    _gopath_dirs=( src bin pkg )
    for req_dir in "${_gopath_dirs[@]}"
    do
        if [ ! -d "$GODEV_DIR/$req_dir" ]; then
            mkdir -p $GODEV_DIR/$req_dir
        fi
    done

    # set default flag values
    godev_dir_append=false
    # try to parse any optional flag
    while getopts "a" OPT "$@"
    do
        case $OPT in
            # whether to append GODEV_DIR to existing GOPATH dirs
            # or to use GODEV_DIR as the only GOPATH dir
            a) godev_dir_append=true;;
        esac
    done

    # store old variables
    export _godev_old_GOPATH=$GOPATH
    export _godev_old_PATH=$PATH
    export _godev_old_PS1=$PS1

    # modify with new addition
    if $godev_dir_append; then
        export GOPATH=$GODEV_DIR:$GOPATH
    else
        export GOPATH=$GODEV_DIR
    fi
    export PATH=$GODEV_DIR/bin:$PATH
    export PS1="\[\033[00;44m\] $GODEV_NAME \[\033[00m\] $PS1"

    # and set flag to mark we're in active development mode
    export GODEV_ACTIVE=true
    return 0
}

# _godev_add symlinks the given source directories into the src directory in the
# active development directory
_godev_add() {
    if [ -z $GODEV_ACTIVE ]; then
        echo "Error: 'godev add' can only be used during an active godev session" >&2
        return 1
    fi
    for src_dir in $@
    do
        ln -s `realpath $src_dir` $GODEV_DIR/src/`basename $src_dir`
    done
}

# _godev_cd cds into the active development directory
_godev_cd() {
    if [ -z $GODEV_ACTIVE ]; then
        echo "Error: 'godev cd' can only be used during an active godev session" >&2
        return 1
    fi
    cd $GODEV_DIR
}

godev() {
    subcmd=$1
    shift
    case $subcmd in
        add)
            _godev_add $@ || return 1 ;;
        cd)
            _godev_cd $@ || return 1 ;;
        help | "--help" | "-help" | "-h" | "")
            _godev_help || return 1 ;;
        start)
            _godev_start $@ || return 1 ;;
        stop)
            _godev_stop $@ || return 1 ;;
        version)
            echo $GODEV_VERSION && return 0 ;;
        *)
            echo "Error: unknown subcommand: $subcmd"
            _godev_help || return 1 ;;
    esac
    return 0
}
