#!/bin/bash

# assumes init_new_schema.sql is in same directory
# run on the specific database provided
# ddl = data definition language
# 		i.e. role that can create and use objects
# dml = data modeling language 
# 		i.e. role that can only perform CRUD operations on objects 
# CRUD = Create Replace Update Delete

function usage(){
    echo \
    "$(basename $0) USERNAME DATABASE SCHEMA [OPTIONS]
    
    Required:
        USERNAME    Username for postgres database with proper permissions.
        DATABASE    Name of database to create schema.
        SCHEMA      Name of schema to be created.
    
    Options:
        -h, --help  Show this help dialogue and exit.
    "
}

function argparse(){
    if [ "$#" -lt 3 ]; then
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

function generateSql1(){
    # $1 = database
    # $2 = schema
    # $3 = flywayuser password
    
    timestamp="$(date +%Y%m%d_%H%M%S)"
    fname="/tmp/new_schema_tmp_${timestamp}.sql"
    sql_file="init_new_schema.sql"
    
    sed -e "s/\${DATABASE}/${1}/" \
        -e "s/\${SCHEMA}/${2}/" \
        -e "s/\${FLYWAYUSER_PASSWORD}/${3}/" \
        "$sql_file" > "$fname"
    echo "$fname"
    }

function generateSql2(){
    # $1 = database
    # $2 = schema
    
    timestamp="$(date +%Y%m%d_%H%M%S)"
    fname="/tmp/init_dml_role_tmp_${timestamp}.sql"
    sql_file="init_dml_role.sql"
    
    sed -e "s/\${DATABASE}/${1}/" \
        -e "s/\${SCHEMA}/${2}/" \
        "$sql_file" > "$fname"
    echo "$fname"
    }

function main(){
    argparse "$@"
    getEnv
    fname="$(generateSql1 ${2} ${3} ${FLYWAYUSER_PASSWORD})"
    psql -U "$1" -d "$2" -b -f "$fname" && rm "$fname"
    
    fname="$(generateSql2 ${2} ${3})"
    psql -U "${2}_${3}_flywayuser" -d "$2" -b -f "$fname" && rm "$fname"
    }
     
main "$@"
