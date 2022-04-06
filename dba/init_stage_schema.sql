CREATE
    SCHEMA IF NOT EXISTS stage;
    

CREATE
    TABLE IF NOT EXISTS stage.subjects(
        subject_id      SERIAL PRIMARY KEY,
        subject         VARCHAR(255),
        sex_id          INT,
        race_id         INT,
        ethnicity_id    INT,
        eligible_id     INT,
        record_date     datetime NOT NULL,
    );

CREATE
    TABLE IF NOT EXISTS stage.visits(
        id SERIAL PRIMARY KEY,
        
        FK__subjects_visits INT NOT NULL REFERENCES subjects
        
    );
