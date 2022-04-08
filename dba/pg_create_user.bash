#!/bin/bash

function usage(){
    echo \
    "$(basename $0) USERNAME [OPTIONS]
    
    Required:
        USERNAME    Username of new user.
    
    Options:
        -h, --help  Show this help dialogue and exit.
    "
}

function argparse(){
    if [ "$#" -lt 1 ]; then
        usage
        exit -1
    fi
        
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            *)
                shift
        esac
    done
}
    
function createUser(){
    # $1 = user
    
    echo \
    """
    CREATE
        USER ${1}
        PASSWORD;
    """
}

function main(){
    # define globals
    USR="$1"
    
    # parse args
    argparse "$@"
    
    # create user
    sql="$(createUser ${USR})"
    psql -d postgres -c "$sql"
}

main "$@"
