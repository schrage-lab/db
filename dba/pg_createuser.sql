DO
$fn$
BEGIN
    IF NOT EXISTS(
        SELECT 
            *
        FROM 
            pg_catalog.pg_roles
        WHERE
            rolname = :user
            ) THEN
        CREATE ROLE :user LOGIN PASSWORD CONCAT(:user, '!123')
    END IF;
END
$fn$
