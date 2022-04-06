#!/bin/bash

function usage(){
    echo \
    "$(basename $0) ROLE [OPTIONS]
    
    Required:
        ROLE        Role to drop.
    
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

function generateSql(){
    # $1 = role
    
    timestamp="$(date +%Y%m%d_%H%M%S)"
    sql_file="drop_role.sql"
    tmp_file="/tmp/${sql_file}_tmp_${timestamp}.sql"
    
    sed -e "s/\${ROLE}/${1}/" \
        "$sql_file" > "$tmp_file"
    echo "$tmp_file"
}

function main(){
    argparse "$@"
    fname="$(generateSql ${1})"
    psql -d postgres -b -f "$fname" && rm "$fname"
}

main "$@"