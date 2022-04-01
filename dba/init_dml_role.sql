-- run as flywayuser for the given schema on the given database

ALTER
    DEFAULT PRIVILEGES
    IN SCHEMA ${SCHEMA}
    GRANT 
        SELECT, 
        INSERT, 
        UPDATE, 
        DELETE 
        ON TABLES 
        TO ${DATABASE}_dml_role;
