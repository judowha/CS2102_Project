create or REPLACE PROCEDURE add_employees (name char(30), phone text, email text, address text, join_date date) as $$ 
declare 
	pre_eid char(20);
    eid char(20);
   	BEGIN
    	SELECT max(employees.eid) into pre_eid from employees;
        if pre_eid is NULL then eid :='00001';
        else eid := right(concat( '00000' ,cast( (cast(pre_eid as INTEGER)+1) as text)) ,5);
        end if;
        insert into employees values (eid, name,phone, email, address, join_date);
    end;
    
$$ LANGUAGE plpgsql;