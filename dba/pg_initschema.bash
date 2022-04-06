#!/bin/bash

function usage(){
    echo \
    "$(basename $0) DATABASE INIT [OPTIONS]
    
    Initialize a schema with basic tables and triggers.
    
    Required:
        DATABASE    Name of database.
        INIT        Initialization type. Options: '-base', '-stage', '-prod'.
    
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
            -base)
                SQL_FILE="init_base_schema.sql"
                shift
                ;;
            -stage)
                SQL_FILE="init_stage_schema.sql"
                shift
                ;;
            -prod)
                SQL_FILE="init_prod_schema.sql"
                shift
                ;;
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
    # globals
    SQL_FILE=""

    argparse "$@"
    
    # create function on database
    psql -d "$1" -b -f "fn__update_altered_column.sql"
    
    # init schema
    psql -d "$1" -b -f "$SQL_FILE"
}

main "$@"
