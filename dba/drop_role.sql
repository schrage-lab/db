REASSIGN
    OWNED
    BY "${ROLE}"
    TO postgres;
    
DROP
    OWNED
    BY "${ROLE}";
    
DROP
    ROLE "${ROLE}";