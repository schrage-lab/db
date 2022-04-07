#!/bin/bash

function usage(){
    echo \
    "$(basename $0) DATABASE SCHEMA [OPTIONS]
    
    Wrapper to create a read-only role on a given schema.
    
    Required:
        DATABASE    Name of database.
        SCHEMA      Name of schema.
    
    Options:
        -r, --role  Name of read-write role to grant privileges on schema 
                    (default = DATABASE_SCHEMA_rw)
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
            -r|--role)
                RW_ROLE="$2"
                shift
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

function getEnv(){
    export $(grep -v '^#' .env | xargs)
    }

function createRole(){
    # $1 = database
    # $2 = schema
    
    echo \
    """
    CREATE
        ROLE ${1}_${2}_ro
        LOGIN
        PASSWORD '${DEFAULT_RO_PASSWORD}';
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
        TO ${1}_${2}_ro;
    """
}

function grantSchemaPrivileges(){
    # $1 = database
    # $2 = schema
    
    echo \
    """
    GRANT
        USAGE
        ON SCHEMA ${2}
        TO ${1}_${2}_ro;
        
    GRANT
        USAGE,
        SELECT
        ON ALL SEQUENCES ${2}
        TO ${1}_${2}_ro;
    """
}

function alterDefaultPrivileges(){
    # $1 = database
    # $2 = schema
    
    echo \
    """
    ALTER 
        DEFAULT PRIVILEGES 
        IN SCHEMA ${2}
    GRANT 
        SELECT, 
        INSERT, 
        UPDATE, 
        DELETE 
        ON TABLES 
        TO ${1}_${2}_ro;
    """
}

function main(){
    # define globals
    RW_ROLE="${1}_${2}_rw"

    argparse "$@"
    getEnv
    
    # create role
    sql="$(createRole ${1} ${2})"
    sql_file="$(./generate_sql.bash "${sql}" create_role_ro)"
    # psql -d postgres -b -f "$sql_file"
    
    # grant database privileges to role
    sql="$(grantDbPrivileges ${1} ${2})"
    sql_file="$(./generate_sql.bash "${sql}" grant_db_privileges_ro)"
    # psql -d postgres -b -f "$sql_file"
    
    # grant schema privileges
    sql="$(grantSchemaPrivileges ${1} ${2})"
    sql_file="$(./generate_sql.bash "${sql}" grant_schema_privileges_ro)"
    # psql -d "$1" -b -f "$sql_file"
    
    # alter default privileges
    sql="$(alterDefaultPrivileges ${1} ${2})"
    sql_file="$(./generate_sql.bash "${sql}" alter_default_privileges_ro)"
    # psql -U "$RW_ROLE" -d "$1" -b -f "$sql_file"
}

main "$@"
