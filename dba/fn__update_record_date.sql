-- only need to run this 1x/database

CREATE OR REPLACE 
    FUNCTION update_record_date()
    RETURNS 
        TRIGGER AS $$
            BEGIN
               NEW.record_date = now(); 
               RETURN NEW;
            END;
        $$ 
        LANGUAGE 'plpgsql';
