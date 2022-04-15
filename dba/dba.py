from psycopg2 import sql
from executor import SqlExecutor


@SqlExecutor
def create_database(*, database: str, **kwargs) -> sql.Composed:
    """
    Create database.
    Connects to default database as default user as defined in the .env file.

    :param database: Name of new database.
    :type database: str
    :return: Generated SQL statement.
    :rtype: sql.Composed object
    """

    return sql.SQL("""
        CREATE 
            DATABASE {database};
        """).format(
                database=sql.Identifier(database)
            )


@SqlExecutor(default_dbname=False)
def revoke_database_defaults(*, database: str, **kwargs) -> sql.Composed:
    """
    Revoke database defaults. Currently revokes connection from public.
    Connects to default database as default user as defined in the .env file.

    :param database: Name of database.
    :type database: str
    :return: Generated SQL statement.
    :rtype: sql.Composed object
    """

    return sql.SQL("""
        REVOKE 
            CONNECT 
            ON DATABASE {database} 
            FROM PUBLIC;
        """).format(
                database=sql.Identifier(database)
            )


@SqlExecutor(default_dbname=False)
def create_function_update_modified_column(**kwargs) -> sql.SQL:
    """
    Create a function in the public schema that will update the column 'modified' in a given table with the current
    timestamp for a row that was inserted or updated.

    :param: None
    :return: Generated SQL statement.
    :rtype: sql.SQL object
    """

    return sql.SQL("""
        CREATE 
            FUNCTION public.fn__update_modified_column()
            RETURNS trigger
        LANGUAGE plpgsql
        AS $$
            BEGIN
                NEW.modified = now();
                RETURN NEW;   
            END;
        $$;
        """)


@SqlExecutor(default_dbname=False)
def create_function_add_modified_column(**kwargs) -> sql.SQL:
    """
    Create a function in the public schema that will add the column 'modified' in a given table and create a table
    trigger for updating the timestamp upon inserting or updating a row.

    :param: None
    :return: Generated SQL statement.
    :rtype: sql.SQL object
    """

    return sql.SQL("""
        CREATE OR REPLACE 
            FUNCTION public.fn__add_modified_column()
            RETURNS event_trigger
            LANGUAGE plpgsql
            AS $$
                DECLARE
                    obj record;
                    identity text[];
                BEGIN
                    FOR obj IN SELECT * FROM pg_event_trigger_ddl_commands()
                    LOOP
                        IF obj.command_tag = 'CREATE TABLE' THEN 
                            -- schema, table := identity[1], identity[2]
                            identity := string_to_array(obj.object_identity, '.');
                            EXECUTE format('ALTER TABLE %s ADD COLUMN IF NOT EXISTS modified TIMESTAMP NOT NULL;', obj.object_identity);
                            EXECUTE format('CREATE TRIGGER update_modified_%s BEFORE INSERT OR UPDATE ON %s FOR EACH ROW EXECUTE PROCEDURE public.fn__update_modified_column();', IDENTITY[2], obj.object_identity);
                        END IF;
                    END LOOP;
                END
            $$;
        """)


@SqlExecutor(default_dbname=False)
def create_event_trigger(**kwargs) -> sql.SQL:
    """
    Create an event trigger on the database that will fire upon new tables being created. Upon creation of a new table
    in the database, the table will get a new column 'modified' added and an associated trigger created.

    :param: None
    :return: Generated SQL statement.
    :rtype: sql.SQL object
    """

    return sql.SQL("""
        CREATE 
            EVENT TRIGGER tr__on_create_table 
            ON ddl_command_end
            EXECUTE FUNCTION public.fn__add_modified_column();
        """)


@SqlExecutor(default_dbname=False)
def create_schema(*, database: str, schema: str, **kwargs) -> sql.Composed:
    """
    Create a schema in a given database.

    :param database: Database name within which to create the schema.
    :type database: str
    :param schema: New schema name.
    :type schema: str
    :return: Generated SQL statement.
    :rtype: sql.Composed object
    """

    return sql.SQL("""
        CREATE 
            SCHEMA IF NOT EXISTS {schema};
        """).format(
                schema=sql.Identifier(schema)
            )


@SqlExecutor(default_dbname=False)
def revoke_schema_defaults(*, database: str, schema: str, **kwargs) -> sql.Composed:
    """
    Revoke schema defaults. Currently revokes all privileges from role public.

    :param database: Database name that contains the schema.
    :type database: str
    :param schema: Schema name.
    :type schema: str
    :return: Generated SQL statement.
    :rtype: sql.Composed object
    """

    return sql.SQL("""
        REVOKE 
            ALL 
            ON SCHEMA {schema} 
            FROM PUBLIC;
        """).format(
                schema=sql.Identifier(schema)
            )


@SqlExecutor(default_dbname=False)
def create_schema_admin_role(*, database: str, schema: str, **kwargs) -> sql.Composed:
    """
    Create schema admin role. Will have all privileges on schema and all associated objects. Will serve as the creator.

    :param database: Database name that contains the schema.
    :type database: str
    :param schema: Schema name.
    :type schema: str
    :return: Generated SQL statement.
    :rtype: sql.Composed object
    """

    # note to self: string interpolation is ok here as the variable will then be passed into the query via the
    # sql.Identifier class which does escaping
    role = f"{schema}_admin"
    return sql.SQL("""
        CREATE 
            ROLE {role};
        GRANT
            CONNECT,
            TEMPORARY
            ON DATABASE {database} 
            TO {role};
        GRANT
            ALL
            ON SCHEMA {schema}
            TO {role};
        GRANT
            ALL
            ON ALL TABLES
            IN SCHEMA {schema}
            TO {role};
        GRANT
            ALL
            ON ALL SEQUENCES
            IN SCHEMA {schema}
            TO {role};
        GRANT
            ALL
            ON ALL FUNCTIONS
            IN SCHEMA {schema}
            TO {role};
        GRANT
            ALL
            ON ALL PROCEDURES
            IN SCHEMA {schema}
            TO {role};
        GRANT
            ALL
            ON ALL ROUTINES
            IN SCHEMA {schema}
            TO {role};
    """).format(
        database=sql.Identifier(database),
        role=sql.Identifier(role),
        schema=sql.Identifier(schema)
    )


@SqlExecutor(default_dbname=False)
def create_schema_readwrite_role(*, database: str, schema: str, **kwargs) -> sql.Composed:
    """
    Create schema read-write role. Will have temp table privileges, read-write privileges for tables, and read-use
    privileges for sequences.

    :param database: Database name that contains the schema.
    :type database: str
    :param schema: Schema name.
    :type schema: str
    :return: Generated SQL statement.
    :rtype: sql.Composed object
    """

    # note to self: string interpolation is ok here as the variable will then be passed into the query via the
    # sql.Identifier class which does escaping
    role = f"{schema}_rw"
    return sql.SQL("""
        CREATE 
            ROLE {role};
        GRANT
            CONNECT,
            TEMPORARY
            ON DATABASE {database} 
            TO {role};
        GRANT 
            USAGE
            ON SCHEMA {schema}
            TO {role};
        GRANT
            SELECT,
            INSERT,
            UPDATE,
            DELETE
            ON ALL TABLES
            IN SCHEMA {schema}
            TO {role};
        GRANT
            SELECT,
            USAGE
            ON ALL SEQUENCES
            IN SCHEMA {schema}
            TO {role};
        """).format(
        database=sql.Identifier(database),
        role=sql.Identifier(role),
        schema=sql.Identifier(schema)
    )


@SqlExecutor(default_dbname=False)
def create_schema_readonly_role(*, database: str, schema: str, **kwargs):
    """
    Create schema read-only role. Will have temp table privileges, and only USAGE privileges on schema and SELECT for
    tables and sequences.

    :param database: Database name that contains the schema.
    :type database: str
    :param schema: Schema name.
    :type schema: str
    :return: Generated SQL statement.
    :rtype: sql.Composed object
    """

    # note to self: string interpolation is ok here as the variable will then be passed into the query via the
    # sql.Identifier class which does escaping
    role = f"{schema}_ro"
    return sql.SQL("""
        CREATE 
            ROLE {role};
        GRANT
            CONNECT,
            TEMPORARY
            ON DATABASE {database} 
            TO {role};
        GRANT 
            USAGE
            ON SCHEMA {schema}
            TO {role};
        GRANT
            SELECT
            ON ALL TABLES
            IN SCHEMA {schema}
            TO {role};
        GRANT
            SELECT
            ON ALL SEQUENCES
            IN SCHEMA {schema}
            TO {role};
        """).format(
        database=sql.Identifier(database),
        role=sql.Identifier(role),
        schema=sql.Identifier(schema)
    )


@SqlExecutor(default_dbname=False)
def create_table(*, database: str, schema: str, table: str, **kwargs) -> sql.Composed:
    """
    Create a table in a given schema. Currently, the table is very rudimentary and will only be initialized with:
        column | type | constraints
        ----------------------------
        id     | serial | not null primary key

    :param database: Database name that contains the schema.
    :type database: str
    :param schema: Schema name.
    :type schema: str
    :param table: New table name.
    :type table: str
    :return: Generated SQL statement.
    :rtype: sql.Composed object
    """

    return sql.SQL("""
        CREATE 
            TABLE IF NOT EXISTS {schema}.{table}(
                id  SERIAL NOT NULL PRIMARY KEY
            );
        """).format(
        schema=sql.Identifier(schema),
        table=sql.Identifier(table)
    )


@SqlExecutor
def create_role(*, role: str, **kwargs) -> sql.Composed:
    """
    Create a role on the server.

    :param role: New role name.
    :type role: str
    :return: Generated SQL statement.
    :rtype: sql.Composed object.
    """

    return sql.SQL("""
        CREATE
            ROLE IF NOT EXISTS {role};
        """).format(
        role=sql.Identifier(role)
    )


@SqlExecutor
def create_user(*, user: str, **kwargs) -> sql.Composed:
    """
    Create a user on the server.

    :param user: New user name.
    :type user: str
    :return: Generated SQL statement.
    :rtype: sql.Composed object.
    """

    return sql.SQL("""
        CREATE
            USER IF NOT EXISTS {user};
    """).format(
        user=sql.Identifier(user)
    )


@SqlExecutor(default_dbname=False)
def alter_default_privileges_readwrite(*, database: str, schema: str, grantor: str = None, grantee: str = None, **kwargs) -> sql.Composed:
    """
    Grant read-write privileges on future objects to read-write role.

    :param database: Database name.
    :type database: str
    :param schema: Schema to apply this privilege.
    :type schema: str
    :param grantor: Role that will own the tables in the schema.
    :type grantor: str
    :param grantee: Role that will be given the privilege.
    :type grantee: str
    :return: Generated SQL statement.
    :rtype: sql.Composed object.
    """

    # note to self: string interpolation is ok here as the variable will then be passed into the query via the
    # sql.Identifier class which does escaping
    if not grantor:
        grantor = f"{schema}_admin"

    if not grantee:
        grantee = f"{schema}_rw"

    return sql.SQL("""           
        ALTER 
            DEFAULT PRIVILEGES
            FOR ROLE {grantor}
            IN SCHEMA {schema}
        GRANT
            SELECT,
            INSERT,
            UPDATE,
            DELETE
            ON TABLES
            TO {grantee};

        ALTER 
            DEFAULT PRIVILEGES
            FOR USER {grantor}
            IN SCHEMA {schema}
        GRANT
            SELECT,
            USAGE
            ON SEQUENCES
            TO {grantee};
    """).format(
        schema=sql.Identifier(schema),
        grantor=sql.Identifier(grantor),
        grantee=sql.Identifier(grantee)
    )


@SqlExecutor(default_dbname=False)
def alter_default_privileges_readonly(*, database: str, schema: str, grantor: str = None, grantee: str = None, **kwargs) -> sql.Composed:
    """
    Grant read-only privileges on future tables to read-only role.

    :param database: Database name.
    :type database: str
    :param schema: Schema to apply this privilege.
    :type schema: str
    :param grantor: Role that will own the tables in the schema. If None, then it is assumed that there exists an admin
                    role for the schema with the name pattern of [schema]_admin. Default = None.
    :type grantor: str
    :param grantee: Role that will be given the privilege. If None, then it is assumed that there exists a read-only
                    role for the schema with the name pattern of [schema]_ro. Default = None.
    :type grantee: str
    :return: Generated SQL statement.
    :rtype: sql.Composed object.
    """

    # note to self: string interpolation is ok here as the variable will then be passed into the query via the
    # sql.Identifier class which does escaping
    if not grantor:
        grantor = f"{schema}_admin"

    if not grantee:
        grantee = f"{schema}_ro"

    return sql.SQL("""
        ALTER 
            DEFAULT PRIVILEGES
            FOR USER {grantor}
            IN SCHEMA {schema}
        GRANT
            SELECT
            ON TABLES
            TO {grantee};
            
        ALTER 
            DEFAULT PRIVILEGES
            FOR USER {grantor}
            IN SCHEMA {schema}
        GRANT
            SELECT
            ON SEQUENCES
            TO {grantee};
    """).format(
        schema=sql.Identifier(schema),
        grantor=sql.Identifier(grantor),
        grantee=sql.Identifier(grantee)
    )


def drop_role(*, role: str) -> sql.Composed:
    """

    :param role:
    :return:
    """

    return sql.SQL("""
        
    """).format(

    )

if __name__ == '__main__':
    import sys
    import parser
    parser.main(sys.argv[:])
