#!/bin/bash

function usage(){
    echo \
    "$(basename $0) DATABASE SCHEMA [OPTIONS]
    
    Wrapper to quickly create new schemas for ETL.
    
    Required:
        DATABASE    Name of databse to create schema.
        SCHEMA      Name of new schema to create. Five schemas will be created:
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

function createMainRole(){
    # aggregate rw or ro roles for each schema belonging to an ETL process (e.g. raw, stage, prod...) 
    # for easier and more robust role granting
    
    # $1 = role
    
    echo \
    """
    CREATE
        ROLE ${1};
    """
}

function grantSubRoleToMain(){
    # $1 = sub-role
    # $2 = main role
    
    echo \
    """
    GRANT
        ${1}
        TO ${2};
    """
}

function main(){
    # define globals
    DATABASE="$1"
    SCHEMA="$2"

    # parse args
    argparse "$@"
    
    # create main rw role for the ETL process
    MAIN_RW_ROLE="${SCHEMA}_main_rw"
    sql="$(createMainRole ${MAIN_RW_ROLE})"
    psql -d postgres -c "$sql"
    
    # create main ro role for the ETL process
    MAIN_RO_ROLE="${SCHEMA}_main_ro"
    sql="$(createMainRole ${MAIN_RO_ROLE})"
    psql -d postgres -c "$sql"
    
    # create schemas and associated rw and ro roles for each
    # and grant those sub-roles to the main role
    suffixes=("raw" "stage" "prod" "meta" "lookup")
    for _suffix in "${suffixes[@]}"; do
        ./pg_create_schema.bash "$DATABASE" "${SCHEMA}_${_suffix}"
        
        # grant SCHEMA_rw to *_main_rw
        _subrole="${SCHEMA}_${suffix}_rw"
        sql="$(grantSubRoleToMain ${_subrole} ${MAIN_RW_ROLE})"
        psql -d postgres -c "$sql"
        
        # grant SCHEMA_ro to *_main_ro
        _subrole="${SCHEMA}_${suffix}_ro"
        sql="$(grantSubRoleToMain ${_subrole} ${MAIN_RO_ROLE})"
        psql -d postgres -c "$sql"
    done    
}

main "$@"
