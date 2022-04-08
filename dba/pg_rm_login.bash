#!/bin/bash

function usage(){
    echo \
    "$(basename $0) ROLE [OPTIONS]
    
    Wrapper to revoke login attributes from a role.
    Intended to be used following automated creation of schema and associated rw and ro roles.
    
    Required:
        ROLE        Name of role to revoke login.
    
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

function rmLogin(){
    # $1 = role
    
    echo \
    """
    ALTER 
        ROLE ${1}
        NOLOGIN;
    """
}

function main(){
    # define globals
    ROLE_NAME="$1"
    
    # parse args
    argparse "$@"
    
    # rm login attribute
    sql="$(rmLogin ${1})"
    psql -d postgres -c "$sql"
}

main "$@"
