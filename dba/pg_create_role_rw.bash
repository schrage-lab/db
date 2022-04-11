#!/bin/bash

function usage(){
    echo \
    "$(basename $0) DATABASE SCHEMA [OPTIONS]
    
    Wrapper to create a read-write role on a given schema.
    
    Required:
        DATABASE    Name of database.
        SCHEMA      Name of schema.
    
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

function getEnv(){
    export $(grep -v '^#' .env | xargs)
    }

function createRole(){
    # $1 = role
    
    echo \
    """
    CREATE
        ROLE ${1}
        LOGIN
        PASSWORD '${DEFAULT_RW_PASSWORD}';
    """
}

function grantDbPrivileges(){
    # $1 = database
    # $2 = role
    
    echo \
    """
    GRANT 
        CONNECT,
        TEMPORARY
        ON DATABASE ${1}
        TO ${2};
    """
}

function grantSchemaPrivileges(){
    # $1 = schema
    # $2 = role
    
    echo \
    """
    GRANT
        CREATE,
        USAGE
        ON SCHEMA ${1}
        TO ${2};
        
    GRANT
        ALL
        ON ALL TABLES
        IN SCHEMA ${1}
        TO ${2};
        
    GRANT
        ALL
        ON ALL SEQUENCES 
        IN SCHEMA ${1}
        TO ${2};
        
    GRANT
        ALL
        ON ALL FUNCTIONS
        IN SCHEMA ${1}
        TO ${2};
        
    GRANT
        ALL
        ON ALL PROCEDURES
        IN SCHEMA ${1}
        TO ${2};
        
    GRANT
        ALL
        ON ALL ROUTINES
        IN SCHEMA ${1}
        TO ${2};        
    """
}

function main(){
    # set globals
    DATABASE="$1"
    SCHEMA="$2"
    ROLE_NAME="${SCHEMA}_rw"
    
    # parse args & get env variables
    argparse "$@"
    getEnv
    
    # create role
    sql="$(createRole ${ROLE_NAME})"
    psql -d postgres -c "$sql"
    
    # grant database privileges to role
    sql="$(grantDbPrivileges ${DATABASE} ${ROLE_NAME})"
    psql -d postgres -c "$sql"
    
    # grant schema privileges
    sql="$(grantSchemaPrivileges ${SCHEMA} ${ROLE_NAME})"
    psql -d "$1" -c "$sql"
}

main "$@"
