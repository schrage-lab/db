#!/bin/bash

# usage: pg_createuser -a|-r|-s -d --schema
# an option of -a, -r, or -s must be selected to denote the type of user role being created
# 

function argparse(){
	local ROLE=""
	local DATABASE=""
	local SCHEMA=""

	while [[ $# -gt 0 ]]; do
		case $1 in
			-a|--admin)
				ROLE="admin"
				shift
				;;
			-d|--database)
				DATABASE="$2"
				shift
				shift
				;;
			-r|--read)
				ROLE="read"
				shift
				;;
			-s|--super)
				ROLE="superuser"
				shift
				;;
			--schema)
				SCHEMA="$2"
				shift
				shift
				;;
			# todo: add handler for any other flag/arg passed
		esac
	done
	
	# package args into array
	local return=("$ROLE" "$DATABASE" "$SCHEMA")
	echo "${return[@]}"
}

function grantPermissionsToDb(){
	# $1 = database
	# $2 = role/user
	# $3 = admin

	echo \
	"DO 
	\$fn$
    DECLARE
        myschema RECORD;
    BEGIN
        GRANT ALL ON DATABASE $1 TO $2;
        FOR myschema IN (
			SELECT schema_name 
			FROM information_schema.schemata 
			WHERE schema_name NOT LIKE 'pg_%' 
			AND schema_name <> 'information_schema'
			)
        LOOP
            EXECUTE format ('GRANT ALL ON SCHEMA %I TO $2', myschema.schema_name);
            EXECUTE format ('GRANT ALL ON ALL TABLES IN SCHEMA %I TO $2', myschema.schema_name);
            EXECUTE format ('GRANT ALL ON ALL SEQUENCES IN SCHEMA %I TO $2', myschema.schema_name);
            EXECUTE format ('GRANT ALL ON ALL FUNCTIONS IN SCHEMA %I TO $2', myschema.schema_name);
        END LOOP;
        ALTER DEFAULT PRIVILEGES FOR ROLE $3 GRANT ALL ON SCHEMAS TO $2;
        ALTER DEFAULT PRIVILEGES FOR ROLE $3 GRANT ALL ON TABLES TO $2;
        ALTER DEFAULT PRIVILEGES FOR ROLE $3 GRANT ALL ON SEQUENCES TO $2;
        ALTER DEFAULT PRIVILEGES FOR ROLE $3 GRANT ALL ON FUNCTIONS TO $2;
    END;
    \$fn$"
}

function createRole(){
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
			CREATE ROLE '$1' LOGIN PASSWORD '$2'
		END IF;
	END
	\$fn$"
}

function raiseException(){
	case $1 in
		1)
			echo "Error: Unknown option"
			exit 1
			;;
		101)
			echo "Error: A database and schema must be provided when a role of ${2} is selected."
			exit 101
			;;
		102)
			echo "Error: A role must be selected"
			exit 102
			;;
	esac
}

function psqlExecutor(){
	# $1 = username
	# $2 = sql statement
	# $3 = database (if applicable)
	
	psql -U "$uid" -d "$DB" -c "$sql"
}

function main(){
	# parse command line
	args=($(argparse "$@"))
	
	# arguments are returned in the order of ROLE, DATABASE, SCHEMA
	local ROLE="${args[0]}"
	local DATABASE="${args[1]}"
	local SCHEMA="${args[2]}"
	
	# check that role is not empty
	if [ -z "$ROLE" ]; then
		raiseException 102
	fi
	
	# check the role selected
	if [[ "$ROLE" != "superuser" ]]; then
		# check that -d and --schema flags were provided
		if [ -z "$DATABASE" ] || [ -z "$SCHEMA" ]; then
			raiseException 101 "$ROLE"
		fi
	fi
	
	# get admin credentials
	read -p 'Admin Username: ' _uid
	# read -sp 'Admin Password: ' _pass
	echo
	
	# get new user credentials
	read -p 'New Username: ' _uid_new
	read -sp 'Password: ' _pass_new
	echo
	
	# render sql statement for creating role
	sql="$(createRole $_uid_new $_pass_new)"
	
	psqlExecutor "$_uid" "$_pass" "$sql"
	
	# # get database names depending on role 
	# if [ $ROLE == "admin" | "superuser" ] > get list of databases and loop
	# else > check if database exists
	# # DATABASE_NAMES=$(psql -U "$uid" -t -c “SELECT datname FROM pg_database WHERE datistemplate = false AND datname <> ‘postgres’;”)
	
	
	
	# DATABASE_NAMES=("db1" "db2")
	# # loop
	# for DB in $DATABASE_NAMES
	# do
		# echo "$DB"
		# # render sql
		# sql=$(sql "$DB")
		# # psql -U "$uid" -d "$DB" -c "$sql"
	# done
}

main "$@"