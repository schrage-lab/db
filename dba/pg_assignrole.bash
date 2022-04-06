#!/bin/bash

function usage(){
    echo \
    "$(basename $0) USERNAME DATABASE ROLE [OPTIONS]
    
    Required:
        USERNAME    Username to be assigned role.
        DATABASE    Name of database.
        ROLE        Role to assign for the database. Options: '-rw', '-ro'.
    
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
            -rw)
                ROLE="rw"
                shift
                ;;
            -ro)
                ROLE="ro"
                shift
                ;;
            *)
                shift
        esac
    done
    }

function generateSql(){
    # $1 = user
    # $2 = database
    # $3 = role
    
    timestamp="$(date +%Y%m%d_%H%M%S)"
    sql_file="assign_role.sql"
    tmp_file="/tmp/${sql_file}_tmp_${timestamp}.sql"
    
    role="${2}_${3}"
    
    sed -e "s/\${ROLE}/${role}/" \
        -e "s/\${USER}/${1}/" \
        "$sql_file" > "$tmp_file"
    echo "$tmp_file"
}

function main(){
    # globals
    ROLE=""
    
    argparse "$@"
    fname="$(generateSql ${1} ${2} ${ROLE})"
}

main "$@"
