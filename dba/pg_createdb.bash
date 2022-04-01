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

function generateSql(){
    timestamp="$(date +%Y%m%d_%H%M%S)"
    fname="/tmp/new_db_tmp_${timestamp}.sql"
    sql_file="init_new_db.sql"
    
    sed -e "s/\${VAR}/${1}/" "$sql_file" > "$fname"
    echo "$fname"
    }

function main(){
    argparse "$@"
    
    fname="$(generateSql $2)"
    psql -U "$1" -d postgres -b -f "$fname" && rm "$fname"
    }
    
main "$@"