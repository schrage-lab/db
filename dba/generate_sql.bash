#!/bin/bash

function usage(){
    echo \
    "$(basename $0) SQL PREFIX [OPTIONS]
    
    Wrapper to take a SQL query and write to a temporary, timestamped file with a prefix.
    
    Required:
        SQL         SQL string.
        PREFIX      Temporary file name prefix.
    
    Options:
        -h, --help  Show this help dialogue and exit.
    "
}

function argparse(){
    if [ "$#" -lt 2 ]; then
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

function main(){
    # $1 = sql
    # $2 = prefix
    
    timestamp="$(date +%Y%m%d_%H%M%S)"
    tmp_file="/tmp/${2}_tmp_${timestamp}.sql"
    echo "$1" > "$tmp_file"
    
    # return
    echo "$tmp_file"
}

main "$@"
