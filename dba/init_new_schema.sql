-- run as user postgres on the given database
-- ddl = data definition language
-- 		i.e. role that can create and use objects
-- dml = data modeling language 
-- 		i.e. role that can only perform CRUD operations on objects 
-- CRUD = Create Replace Update Delete

-- revoke from public
REVOKE 
    CREATE 
    ON SCHEMA public 
    FROM PUBLIC;

-- create schema
CREATE 
    SCHEMA IF NOT EXISTS ${SCHEMA};

-- grant schema and sequence privileges to ddl
GRANT
    USAGE,
    CREATE
    ON SCHEMA ${SCHEMA}
    TO ${DATABASE}_ddl_role;

GRANT
    ALL
    ON ALL SEQUENCES 
    IN SCHEMA ${SCHEMA}
    TO ${DATABASE}_ddl_role;
    
GRANT 
    ALL
    ON ALL FUNCTIONS 
    IN SCHEMA ${SCHEMA} 
    TO ${DATABASE}_ddl_role;

-- grant schema and sequence privileges to dml
GRANT
    USAGE
    ON SCHEMA ${SCHEMA}
    TO ${DATABASE}_dml_role;

GRANT
    USAGE,
    SELECT
    ON ALL SEQUENCES 
    IN SCHEMA ${SCHEMA}
    TO ${DATABASE}_dml_role;

GRANT 
    ALL
    ON ALL FUNCTIONS 
    IN SCHEMA ${SCHEMA} 
    TO ${DATABASE}_dml_role;

-- create base flyway user
CREATE 
    USER ${DATABASE}_${SCHEMA}_flywayuser
    WITH ENCRYPTED PASSWORD '${FLYWAYUSER_PASSWORD}';

GRANT 
    ${DATABASE}_ddl_role
    TO ${DATABASE}_${SCHEMA}_flywayuser;
