-- helper script to quickly get a base schema up and populated

-- create schema
CREATE
    SCHEMA IF NOT EXISTS base;

-- create tables

CREATE
    TABLE IF NOT EXISTS base.eligibility(
        
    );

CREATE
    TABLE IF NOT EXISTS base.sexes(
        sex_id      INT PRIMARY KEY,
        sex         VARCHAR(255) NOT NULL,
        record_date TIMESTAMP NOT NULL
    );
    
CREATE
    TABLE IF NOT EXISTS base.races(
        race_id     INT PRIMARY KEY,
        race        VARCHAR(255) NOT NULL,
        record_date TIMESTAMP NOT NULL
    );
    
CREATE
    TABLE IF NOT EXISTS base.ethnicities(
        ethnicity_id    INT PRIMARY KEY,
        ethnicity       VARCHAR(255) NOT NULL,
        record_date     TIMESTAMP NOT NULL
    );
    
CREATE
    TABLE IF NOT EXISTS base.eligibility(
        eligibility_id  INT PRIMARY KEY,
        eligibility     VARCHAR(255) NOT NULL,
        record_date     TIMESTAMP NOT NULL
    );

CREATE 
    TABLE IF NOT EXISTS base.laterality(
        laterality_id   INT PRIMARY KEY,
        laterality      VARCHAR(255) NOT NULL,
        record_date     TIMESTAMP NOT NULL
    );
    
CREATE 
    TABLE IF NOT EXISTS base.scans(
        scan_id         INT PRIMARY KEY,
        scan            VARCHAR(255) NOT NULL,
        record_date     TIMESTAMP NOT NULL
    );
    
