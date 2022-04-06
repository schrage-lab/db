#!/bin/bash

function usage(){
    echo \
    "$(basename $0) DATABASE SCHEMA [OPTIONS]
    
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

function generateSql(){
    # $1 = schema
    
    timestamp="$(date +%Y%m%d_%H%M%S)"
    sql_file="create_schema.sql"
    tmp_file="/tmp/${sql_file}_tmp_${timestamp}.sql"
    
    sed -e "s/\${SCHEMA}/${2}/" \
        "$sql_file" > "$tmp_file"
    echo "$tmp_file"
}

function main(){
    argparse "$@"
    fname="$(generateSql ${2})"
    psql -d "$1" -b -f "$fname" && rm "$fname"
}

main "$@"
