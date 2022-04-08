#!/bin/bash

function usage(){
    echo \
    "$(basename $0) DATABASE SCHEMA [OPTIONS]
    
    Wrapper to create a schema and set some defaults.
    Default settings include:
        *create a read-write role
        *create a read-only role
    
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

function createSchema(){
    # $1 = schema

    echo \
    """
    CREATE
        SCHEMA IF NOT EXISTS $1;
    """
}

function revokeFromPublic(){
    # $1 = schema
    
    echo \
    """
    REVOKE
        ALL
        ON SCHEMA $1
        FROM PUBLIC;
    """
}

function main(){
    # $1 = database
    # $2 = schema
    
    argparse "$@"
    
    # create schema
    sql="$(createSchema ${2})"
    psql -d "$1" -c "$sql"
    
    # revoke public privileges on schema
    sql="$(revokeFromPublic ${2})"
    psql -d "$1" -c "$sql"
}

main "$@"
