#!/bin/bash

function usage(){
    echo \
    "$(basename $0) DATABASE [OPTIONS]
    
    Required:
        DATABASE    Name of new database to create.
    
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

function createDb(){
    # $1 = database

    echo \
    """
    CREATE
        DATABASE \"$1\";
    """
    }

function revokePublicFromDb(){
    # $1
    
    echo \
    """
    REVOKE 
        ALL
        ON DATABASE \"$1\"
        FROM PUBLIC;
    """
}

function revokePublicFromSchema(){
    # $1
    
    echo \
    """
    REVOKE
        ALL
        ON SCHEMA public
        FROM PUBLIC;
    """
}

function main(){
    # $1 = database
    
    argparse "$@"
    
    # create database
    sql="$(createDb "${1}")"
    psql -d postgres -c "$sql"
    
    # revoke public privileges on database
    sql="$(revokePublicFromDb "${1}")"
    psql -d postgres -c "$sql"
    
    # revoke public privileges on public schema
    sql="$(revokePublicFromSchema "${1}")"
    psql -d "$1" -c "$sql"
    }
    
main "$@"
