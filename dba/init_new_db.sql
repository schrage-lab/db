-- run as user 'postgres' on database 'postgres'
-- used in conjunction with "pg_createdb.bash" which will replace all instances of ${VAR} with the provided database name
-- ddl = data definition language
-- 		i.e. role that can create and use objects
-- dml = data modeling language 
-- 		i.e. role that can only perform CRUD operations on objects 
-- CRUD = Create Replace Update Delete

CREATE DATABASE ${VAR};

-- revoke 'public' access
REVOKE ALL 
	ON DATABASE ${VAR}
	FROM PUBLIC;

REVOKE CREATE 
	ON SCHEMA public 
	FROM PUBLIC;

-- create ddl role
-- i.e. role that can create objects
CREATE ROLE db_${VAR}_ddl;

GRANT
    CONNECT
    ON DATABASE ${VAR}
   	TO db_${VAR}_ddl;

GRANT
    TEMPORARY
    ON DATABASE ${VAR} 
   	TO db_${VAR}_ddl;

-- create dml role
-- i.e. one that only has CRUD options on objects
CREATE ROLE db_${VAR}_dml;

GRANT
    CONNECT
    ON DATABASE ${VAR} 
   	TO db_${VAR}_dml;

GRANT
    TEMPORARY
    ON DATABASE ${VAR} 
	TO db_${VAR}_dml;