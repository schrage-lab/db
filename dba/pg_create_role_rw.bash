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
    # $1 = database
    # $2 = schema
    
    echo \
    """
    CREATE
        ROLE ${1}_${2}_rw
        LOGIN
        PASSWORD '${DEFAULT_RW_PASSWORD}';
    """
}

function grantDbPrivileges(){
    # $1 = database
    # $2 = schema
    
    echo \
    """
    GRANT 
        CONNECT,
        TEMPORARY
        ON DATABASE ${1}
        TO ${1}_${2}_rw;
    """
}

function grantSchemaPrivileges(){
    # $1 = database
    # $2 = schema
    
    echo \
    """
    GRANT
        USAGE,
        CREATE
        ON SCHEMA ${2}
        TO ${1}_${2}_rw;
        
    GRANT
        ALL
        ON ALL SEQUENCES ${2}
        TO ${1}_${2}_rw;
    """
}

function main(){
    argparse "$@"
    getEnv
    
    # create role
    sql="$(createRole ${1} ${2})"
    sql_file="$(./generate_sql.bash "${sql}" create_role_rw)"
    # psql -d postgres -b -f "$sql_file"
    
    # grant database privileges to role
    sql="$(grantDbPrivileges ${1} ${2})"
    sql_file="$(./generate_sql.bash "${sql}" grant_db_privileges_rw)"
    # psql -d postgres -b -f "$sql_file"
    
    # grant schema privileges
    sql="$(grantSchemaPrivileges ${1} ${2})"
    sql_file="$(./generate_sql.bash "${sql}" grant_schema_privileges_rw)"
    # psql -d "$1" -b -f "$sql_file"
}

main "$@"
