import argparse
import dba

"""
pattern: dba.py [create | drop | alter | grant | revoke] [database | schema | table | role | user] OPTIONS

|--CREATE
|--DATABASE
    |--NAME
|--SCHEMA
    |--DATABASE NAME
    |--SCHEMA NAME
|--TABLE
    |--DATABASE NAME
    |--SCHEMA NAME
    |--TABLE NAME
|--ROLE
    |--NAME
|--USER
    |--NAME

|--DROP
|--DATABASE
    |--NAME
|--SCHEMA
    |--DATABASE NAME
    |--SCHEMA NAME
|--TABLE
    |--DATABASE NAME
    |--SCHEMA NAME
    |--TABLE NAME
|--ROLE
    |--NAME
|--USER
    |--NAME

|--ALTER
|--DATABASE
    |--NAME
|--SCHEMA
    |--DATABASE NAME
    |--SCHEMA NAME
|--TABLE
    |--DATABASE NAME
    |--SCHEMA NAME
    |--TABLE NAME
|--ROLE
    |--NAME
|--USER
    |--NAME

|--GRANT
    |--ROLE

|--REVOKE
    |--ROLE

TODO: 04/14/2022: add 'ALTER' functionality
"""


def create_parser():
    # main parser
    parser = argparse.ArgumentParser(
        prog="DBA helper",
        description="Helper module for uniform DBA actions.",
    )

    # make action subparser i.e. first command
    action_subparser = parser.add_subparsers(
        title="Main command",
        description="What to do on the database",
        required=True,
        dest="action"
    )

    # parse arguments when 'create' is passed
    create_action_parser = action_subparser.add_parser(
        "create",
        help="Create a given database object."
    )

    create_action_subparser = create_action_parser.add_subparsers(
        title="Create Command",
        description="Create what",
        dest="object",
        required=True
    )

    # create: database
    create_database_parser = create_action_subparser.add_parser(
        "database",
        help="Create a database."
    )

    create_database_parser.add_argument(
        "--database",
        type=str,
        required=True,
        help="Name of database"
    )

    # create: schema
    create_schema_parser = create_action_subparser.add_parser(
        "schema",
        help="Create a schema"
    )

    create_schema_parser.add_argument(
        "--database",
        type=str,
        required=True,
        help="Name of database"
    )

    create_schema_parser.add_argument(
        "--schema",
        type=str,
        required=True,
        help="Name of schema"
    )

    # create: table
    create_table_parser = create_action_subparser.add_parser(
        "table",
        help="Create a basic table. Will only create the table with columns 'id' and 'modified'."
    )

    create_table_parser.add_argument(
        "--database",
        type=str,
        required=True,
        help="Name of database"
    )

    create_table_parser.add_argument(
        "--schema",
        type=str,
        required=True,
        help="Name of schema"
    )

    create_table_parser.add_argument(
        "--table",
        type=str,
        required=True,
        help="Name of table"
    )

    # create: role
    create_role_parser = create_action_subparser.add_parser(
        "role",
        help="NOT YET IMPLEMENTED: Create a role."
    )

    create_role_parser.add_argument(
        "--role",
        type=str,
        required=True,
        help="Name of role"
    )

    # create: user
    create_user_parser = create_action_subparser.add_parser(
        "user",
        help="NOT YET IMPLEMENTED: Create a user"
    )

    create_user_parser.add_argument(
        "--user",
        type=str,
        required=True,
        help="Name of user"
    )

    # drop command
    drop_action_parser = action_subparser.add_parser(
        "drop",
        help="Drop a given database object"
    )

    # alter command
    alter_action_parser = action_subparser.add_parser(
        "alter",
        help="Alter a given database object"
    )

    # grant command
    grant_action_parser = action_subparser.add_parser(
        "grant",
        help="Grant a role to a another role or user."
    )

    # revoke command
    revoke_action_parser = action_subparser.add_parser(
        "revoke",
        help="Revoke a role from another role or user."
    )

    return parser


def main(argin: list):
    parser = create_parser()
    args = parser.parse_args()

    if args.action == "create":
        if args.object == "database":
            # when a database is created, connection from role public is revoked, a function is created in the public
            # schema to create a modified column in a table supplied as a parameter, and an event trigger is created
            # on the database such that new tables will get the modified column via the aforementioned function
            # create database -> revoke defaults -> create fn__update_modified_column -> create
            # fn__add_modified_column -> -> create event trigger
            dba.create_database(
                database=args.database
            )
            dba.revoke_database_defaults(
                database=args.database
            )
            dba.create_function_update_modified_column(
                database=args.database
            )
            dba.create_function_add_modified_column(
                database=args.database
            )
            dba.create_event_trigger(
                database=args.database
            )
        if args.object == "schema":
            """
            when a schema is created, all privileges on the schema are revoked from role public, and three default roles
            are created:
                1) admin
                2) read-write
                3) read-only
            """
            dba.create_schema(
                database=args.database,
                schema=args.schema
            )
            dba.create_schema_admin_role(
                database=args.database,
                schema=args.schema
            )
            dba.create_schema_readwrite_role(
                database=args.database,
                schema=args.schema
            )
            dba.alter_default_privileges_readwrite(
                database=args.database,
                schema=args.schema
            )
            dba.create_schema_readonly_role(
                database=args.database,
                schema=args.schema
            )
            dba.alter_default_privileges_readonly(
                database=args.database,
                schema=args.schema
            )
        if args.object == "table":
            dba.create_table(
                database=args.database,
                schema=args.schema,
                table=args.table
            )
        if args.object == "role":
            dba.create_role(
                role=args.role
            )
        if args.object == "user":
            dba.create_user(
                user=args.user
            )
    elif args.action == "drop":
        if args.object == "database":
            print("drop database")
        if args.object == "schema":
            print("drop schema")
        if args.object == "table":
            print("drop table")
        if args.object == "role":
            print("drop role")
        if args.object == "user":
            print("drop user")
    elif args.action == "alter":
        if args.object == "database":
            print("alter database")
        if args.object == "schema":
            print("alter schema")
        if args.object == "table":
            print("alter table")
        if args.object == "role":
            print("alter role")
        if args.object == "user":
            print("alter user")
    elif args.action == "grant":
        print("grant")
    elif args.action == "revoke":
        print("revoke")


