#!/bin/bash

# assumes init_new_db.sql is in same directory
# run on database 'postgres'
# ddl = data definition language
# 		i.e. role that can create and use objects
# dml = data modeling language 
# 		i.e. role that can only perform CRUD operations on objects 
# CRUD = Create Replace Update Delete

function usage(){
    echo \
    "$(basename $0) USERNAME DATABASE [OPTIONS]
    
    Required:
        USERNAME    Username for postgres database that has CREATEDB permissions.
        DATABASE    Name of new database to create.
    
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

function generateSql(){
    # $1 = database
    # $2 = ddl password
    # $3 = dml password
    
    timestamp="$(date +%Y%m%d_%H%M%S)"
    fname="/tmp/new_db_tmp_${timestamp}.sql"
    sql_file="init_new_db.sql"
    
    sed -e "s/\${DATABASE}/${1}/" \
        -e "s/\${DEFAULT_DDL_PASSWORD}/${2}/" \
        -e "s/\${DEFAULT_DML_PASSWORD}/${3}/" \
        "$sql_file" > "$fname"
    echo "$fname"
    }

function main(){
    argparse "$@"
    getEnv
    fname="$(generateSql ${2} ${DEFAULT_DML_PASSWORD} ${DEFAULT_DDL_PASSWORD})"
    psql -U "$1" -d postgres -b -f "$fname" && rm "$fname"
    }
    
main "$@"