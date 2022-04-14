from psycopg2 import sql
from executor import SqlExecutor


@SqlExecutor()
def create_database(*, database: str) -> sql.Composed:
    return sql.SQL("""
        CREATE 
            DATABASE {database};
        """).format(
                database=sql.Identifier(database)
            )


@SqlExecutor
def revoke_database_defaults(*, database: str) -> sql.Composed:
    return sql.SQL("""
        REVOKE 
            CONNECT 
            ON DATABASE {database} 
            FROM PUBLIC;
        """).format(
                database=sql.Identifier(database)
            )


@SqlExecutor
def create_function_update_modified_column() -> sql.SQL:
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


@SqlExecutor
def create_function_add_modified_column() -> sql.SQL:
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


@SqlExecutor
def create_event_trigger() -> sql.SQL:
    return sql.SQL("""
        CREATE 
            EVENT TRIGGER tr__on_create_table 
            ON ddl_command_end
            EXECUTE FUNCTION public.fn__add_modified_column();
        """)


@SqlExecutor
def create_schema(*, schema: str) -> sql.Composed:
    return sql.SQL("""
        CREATE 
            SCHEMA IF NOT EXISTS {schema};
        """).format(
                schema=sql.Identifier(schema)
            )


@SqlExecutor
def revoke_schema_defaults(*, schema: str) -> sql.Composed:
    return sql.SQL("""
        REVOKE 
            ALL 
            ON SCHEMA {schema} 
            FROM PUBLIC;
        """).format(
                schema=sql.Identifier(schema)
            )


@SqlExecutor
def create_schema_admin_role(*, schema: str) -> sql.Composed:
    # todo: fix string interpolation
    admin_role = f"{schema}_admin"
    return sql.SQL("""
        CREATE 
            ROLE {admin_role};
        GRANT 
            ALL
            ON SCHEMA {schema}
            TO {self.Role};
        GRANT
            ALL
            ON ALL TABLES
            IN SCHEMA {schema}
            TO {admin_role};
        GRANT
            ALL
            ON ALL SEQUENCES
            IN SCHEMA {schema}
            TO {admin_role};
        GRANT
            ALL
            ON ALL FUNCTIONS
            IN SCHEMA {schema}
            TO {admin_role};
        GRANT
            ALL
            ON ALL PROCEDURES
            IN SCHEMA {schema}
            TO {admin_role};
        GRANT
            ALL
            ON ALL ROUTINES
            IN SCHEMA {schema}
            TO {admin_role};
    """).format(
        admin_role=sql.Identifier(admin_role),
        schema=sql.Identifier(schema)
    )


@SqlExecutor
def create_schema_readwrite_role(*, schema: str) -> sql.Composed:
    # todo: fix string interpolation
    rw_role = f"{schema}_rw"
    return sql.SQL("""
        CREATE ROLE {rw_role};
        GRANT 
            ALL
            ON SCHEMA {schema}
            TO {rw_role};
        GRANT
            ALL
            ON ALL TABLES
            IN SCHEMA {schema}
            TO {rw_role};
        GRANT
            ALL
            ON ALL SEQUENCES
            IN SCHEMA {schema}
            TO {rw_role};
        """).format(
        rw_role=sql.Identifier(rw_role),
        schema=sql.Identifier(schema)
    )


@SqlExecutor
def create_schema_readonly_role(*, schema: str):
    # todo: fix string interpolation
    ro_role = f"{schema}_ro"
    return sql.SQL("""
        CREATE 
            ROLE {ro_role};
        GRANT 
            USAGE
            ON SCHEMA {schema}
            TO {ro_ole};
        GRANT
            SELECT
            ON ALL TABLES
            IN SCHEMA {schema}
            TO {ro_role};
        GRANT
            SELECT
            ON ALL SEQUENCES
            IN SCHEMA {schema}
            TO {ro_role};
        """).format(
        ro_role=sql.Identifier(ro_role),
        schema=sql.Identifier(schema)
    )


@SqlExecutor
def table(*, schema: str, table: str) -> sql.Composed:
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
def role(*, role: str) -> sql.Composed:
    return sql.SQL("""
        CREATE
            ROLE IF NOT EXISTS {role};
        """).format(
        role=sql.Identifier(role)
    )


@SqlExecutor
def user(*, user: str) -> sql.Composed:
    return sql.SQL("""
        CREATE
            USER IF NOT EXISTS {user};
    """).format(
        user=sql.Identifier(user)
    )


if __name__ == '__main__':
    import sys
    import parser
    parser.main(sys.argv[:])
