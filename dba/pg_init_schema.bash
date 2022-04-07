#!/bin/bash

function usage(){
    echo \
    "$(basename $0) DATABASE SCHEMA [OPTIONS]
    
    Initialize a schema with basic tables commonly used in studies and triggers.
    
    Required:
        DATABASE    Name of database.
        SCHEMA      Name of schema to create.
    
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

function generateSql(){
    echo
}


function main(){
    argparse "$@"
    
    # create function on database
    psql -d "$1" -b -f "fn__update_altered_column.sql"
    
    # init schema
    psql -d "$1" -b -f "$SQL_FILE"
}

main "@"
