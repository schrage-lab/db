-- do this for each table in DATABASE

CREATE 
    TRIGGER update_${TABLE}_record_date
    BEFORE UPDATE
    ON "${TABLE}"
    FOR EACH ROW 
        EXECUTE PROCEDURE fn__update_record_date();
