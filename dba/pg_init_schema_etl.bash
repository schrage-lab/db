#!/bin/bash

function usage(){
    echo \
    "$(basename $0) DATABASE SCHEMA [OPTIONS]
    
    Wrapper to quickly create new schemas for ETL.
    
    Required:
        Schema    Name of new schema to create. Five schemas will be created:
                    SCHEMA_raw
                    SCHEMA_stage
                    SCHEMA_prod
                    SCHEMA_meta
                    SCHEMA_lookup
    
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
    argparse "$@"
    
    DATABASE="$1"
    SCHEMA="$2"
    
    suffixes=("raw" "stage" "prod" "meta" "lookup")
    for suffix in "${suffixes[@]}"; do
        ./pg_create_schema.bash "$DATABASE" "${SCHEMA}_${suffix}"
    done
}

main "$@"
