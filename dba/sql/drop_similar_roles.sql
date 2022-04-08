select 
    'DROP ROLE ' || rolname || ';' 
from 
    pg_roles 
where 
    rolname 
    like 
        'irb_2019_0361%';