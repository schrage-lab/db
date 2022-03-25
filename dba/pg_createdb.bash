#!/bin/bash
# create database wrapper

function usage(){
    echo "$(basename $0) -u [USER] -d [DATABASE]"
    echo \
    "
    Options:
        -d, --database      database name
        -u, --user          user name
    "
    }
    
function argparse(){
    while [ $# -gt 0 ]; do
        case "$1" in
            -d|--database)
                DATABASE="$2"
                shift
                shift
                ;;
            -u|--user)
                USER="$2"
                shift
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                echo "Invalid argument: $1"
                usage
                exit -1
                ;;
        esac
    done
    
    [ -z "$USER" ] && echo "No user name provided" && usage && exit -1
    [ -z "$DATABASE" ] && echo "No database name provided" && usage && exit -1
    }

function createDbSql(){
    # because this statement cannot exist within a sql function
    DATABASE="$1"
    
    echo \
    "CREATE DATABASE \"$DATABASE\";"
    }

function revokePublicSql(){
    DATABASE="$1"
    
    echo \
    "DO
    \$fn$
    BEGIN
        REVOKE ALL ON DATABASE \"$DATABASE\"
          FROM PUBLIC;
        REVOKE CREATE
          ON SCHEMA public
          FROM PUBLIC;
    END;
    \$fn$"
    }

function main(){
    # define globals/constants
    USER=""
    DATABASE=""
    
    # todo: this is in a subshell so any exit is not picked up here in the main shell
    argparse "$@"
    
    # create db
    sql="$(createDbSql $DATABASE)"
#    ./psql_executor.bash "$USER" "$sql"
    
    # revoke public access
    sql="$(revokePublicSql $DATABASE)"
#   ./psql_executor.bash "$USER" "$sql"
    }
    
main "$@"