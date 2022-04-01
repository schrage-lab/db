#!/bin/bash

function usage(){
    echo "$(basename $0) [USER] [SQL]" && exit 0
}

function argparse(){
    while [ $# -gt 0 ]; do
        case $1 in
            -h | --help)
                usage
                ;;
            *)
                shift
                ;;
        esac
    done
    }

function main(){
    # $1 = user
    # $2 = sql statement
    
    argparse "$@"
    psql -U "$1" -c "$2" || exit -1
    }
    
main "$@"
