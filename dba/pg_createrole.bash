#!/bin/bash

# available roles (from most to least priveleges):
#   -db admin
#   -schema creator, user (create within schema e.g. tables, functions)
#   -read/write (read/write on tables only)
#   -read only (read tables only)

#   role     | schema creation  | create within schema  |   write on tables |   read on tables
#   --------------------------------------------------------------------------------
#   db admin |      TRUE        |       TRUE            |       TRUE        |       TRUE
#   creator  |      FALSE       |       TRUE            |       TRUE        |       TRUE
#   w        |      FALSE       |       FALSE           |       TRUE        |       TRUE
#   r        |      FALSE       |       FALSE           |       FALSE       |       TRUE

function usage(){
    echo "$(basename $0) [USER] [DATABASE] [OPTIONS]" 
    echo \
    "
    Roles:
        -a, --admin         admin; all privileges on database
        -c, --creator       schema creator; privileges to create within a schema
        -d, --database      database name
        -r, --readonly      read only; privilege to read from within a schema
        -s, --schema        schema name
        -u, --user          user name
        -w, --readwrite     read/write; privileges to read and write from within a schema
        
    If -c, -r, or -w is selected, the -s must be used and a valid schema name provided
    " \
    && exit 0
    }

function argparse(){
    ROLE=""
    SCHEMA=""
    while [ $# -gt 0 ]; do
        case "$1" in
            -a|--admin)
                ROLE="admin"
                break
                ;;
            -c|--creator)
                ROLE="creator"
                shift
                ;;
            -d|--database)
                if [ -z "$2" ]; then 
                    echo "Invalid database name"
                    exit -1
                else
                    DATABASE="$2"
                fi
                shift
                shift
                ;;
            -r|--readonly)
                ROLE="readonly"
                shift
                ;;
            -s|--schema)
                SCHEMA="$2"
                shift
                shift
                ;;
            -u|--user)
                if [ -z "$2" ]; then 
                    echo "Invalid user name"
                    exit -1
                else
                    USER="$2"
                fi
                shift
                shift
                ;;
            -w|--readwrite)
                ROLE="readwrite"
                shift
                ;;
            -h | --help)
                usage
                ;;
            *)
                echo "Invalid argument: $1"
                usage
                exit -1
                ;;
        esac
    done
    }

function sql(){
	# $1 = user role
	# $2 = user password
	echo \
	"DO
	\$fn$
	BEGIN
		IF NOT EXISTS(
			SELECT 
				*
			FROM 
				pg_catalog.pg_roles
			WHERE
				rolname = '$1'
				) THEN
			CREATE ROLE '$1'
		END IF;
	END
	\$fn$"
    }

function main(){
    argparse "$@"
    }
    
main "$@"
