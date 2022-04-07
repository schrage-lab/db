#!/bin/bash

function usage(){
    echo \
    "$(basename $0) SCHEMA [OPTIONS]
    
    Wrapper to quickly create a new schema in each ETL database.
    
    Required:
        Schema    Name of new schema to create.
    
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

function main(){
    argparse "$@"
    SCHEMA="$1"
    
    DATABASES=("dbraw" "dbstage" "dbprod")
    for db in "${DATABASES[@]}"; do
        ./pg_create_schema.bash "$db" "$SCHEMA"
    done
}

main "$@"
