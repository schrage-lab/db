#!/bin/bash

function usage(){
    echo \
    "$(basename $0) ROLE [OPTIONS]
    
    Required:
        ROLE        Role to drop.
    
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

function dropRole(){
    # $1 = role
    
    echo \
    """
    REASSIGN 
        OWNED 
        BY ${1]
        TO postgres;

    DROP 
        OWNED 
        BY ${1};
        
    DROP
        ROLE ${1};
    """
}

function main(){
    # define globals
    ROLE="$1"
    
    # parse args
    argparse "$@"
    
    sql="$(dropRole ${ROLE})"
    
    psql -d postgres -c "$sql"
}

main "$@"
