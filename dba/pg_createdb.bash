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

function createDbSql(){
    # $1 = database
    
    timestamp="$(date +%Y%m%d_%H%M%S)"
    sql_file="createdb.sql"
    tmp_file="/tmp/${sql_file}_tmp_${timestamp}.sql"
    
    sed -e "s/\${DATABASE}/${1}/" \
        "$sql_file" > "$tmp_file"
    echo "$tmp_file"
    }
    
function createRwSql(){
    # $1 = database
    # $2 = rw password
    
    timestamp="$(date +%Y%m%d_%H%M%S)"
    sql_file="create_role_rw.sql"
    tmp_file="/tmp/${sql_file}_tmp_${timestamp}.sql"
    
    sed -e "s/\${DATABASE}/${1}/" \
        -e "s/\${DEFAULT_RW_PASSWORD}/${2}/" \
        "$sql_file" > "$tmp_file"
    echo "$tmp_file"
    }
    
function createRoSql(){
    # $1 = database
    # $2 = ro password
    
    timestamp="$(date +%Y%m%d_%H%M%S)"
    sql_file="create_role_ro.sql"
    tmp_file="/tmp/${sql_file}_tmp_${timestamp}.sql"
    
    sed -e "s/\${DATABASE}/${1}/" \
        -e "s/\${DEFAULT_RO_PASSWORD}/${2}/" \
        "$sql_file" > "$tmp_file"
    echo "$tmp_file"
    }

function main(){
    # $1 = username
    # $2 = database
    
    argparse "$@"
    getEnv
    
    # create database
    fname="$(createDbSql ${2})"
    psql -U "$1" -d postgres -b -f "$fname" && rm "$fname"
    
    # create rw role
    fname="$(createRwSql ${2} ${DEFAULT_RW_PASSWORD})"
    psql -U "$1" -d postgres -b -f "$fname" && rm "$fname"
    
    # create ro role
    fname="$(createRoSql ${2} ${DEFAULT_RO_PASSWORD})"
    psql -U "$1" -d postgres -b -f "$fname" && rm "$fname"
    }
    
main "$@"
