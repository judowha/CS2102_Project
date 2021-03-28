create or replace procedure add_manage (name text[],eid char(20)) as $$
	declare
		index_i integer;
		index_j integer;
	begin
		index_i := array_length(name,1);
		index_j := 1;
		loop
        	insert into manage values (name[index_j],eid);
            index_j := index_j+1;
            exit when index_j = index_i+1;
        end loop;
	end;
$$ language plpgsql;


create or replace procedure add_specializes (name text[],eid char(20)) as $$
	declare
		index_i integer;
		index_j integer;
	begin
		index_i := array_length(name,1);
		index_j := 1;
		loop
        	insert into specializes values (eid,name[index_j]);
            index_j := index_j+1;
            exit when index_j = index_i+1;
        end loop;
	end;
$$ language plpgsql;


create or REPLACE PROCEDURE add_employees (name char(30), phone text, email text, address text, salary_inf text,  join_date date, category text, course_area text[]) as $$ 
declare 
	pre_eid char(20);
    eid char(20);
   	BEGIN
		if category = 'administrator' and course_area is not null then
			raise exception 'the course area for administrators should be null';
		end if;
		
		if (category = 'manager' or category = 'administrator') and (left(salary_inf,7) = 'hourly:') then
			raise exception 'managers and administrators must be full time employees';
		end if;
    	SELECT max(employees.eid) into pre_eid from employees;
        if pre_eid is NULL then eid :='00001';
        else eid := right(concat( '00000' ,cast( (cast(pre_eid as INTEGER)+1) as text)) ,5);
        end if;
        insert into employees values (eid, name,phone, email, address, join_date);
		if left(salary_inf,7) = 'hourly:' then 
			insert into part_time_emp values (eid,cast(substring(salary_inf from 9) as numeric));
			insert into instructors values (eid);
			insert into part_time_instructors values (eid);
			call add_specializes(course_area,eid);
		elsif left(salary_inf,7) = 'monthly' then
			insert into full_time_emp values (eid,cast(substring(salary_inf from 10) as numeric));
			if category = 'instructor' then 
				insert into instructors values(eid);
				insert into full_time_instructors values(eid);
				call add_specializes(course_area,eid);
			elsif category = 'managers' then
				insert into managers values (eid);
				call add_manage(course_area,eid);
			elsif category = 'administrator' then		
				insert into administrators values(eid);
			end if;
		end if;
    end;
$$ LANGUAGE plpgsql;


create or replace procedure remove_employees(eid char(20), depart_time date) as $$
	declare
		index_i integer;
		index_j integer;
	begin
		if ()
		
	end;
$$ language plpgsql;


