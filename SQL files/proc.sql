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




create or replace function pay_salary()
return table(eid char(20), name char(30), status char(10), num_work_days numeric, num_work_hours numeric, hourly_rate numeric, monthly_salary numeric, salary_amount numeric) as $$
declare
  day_in_month integer;
  curs cursor for (select * from Employees order by eid);
  r record;
  first_work_day integer;
  last_work_day integer;
begin
  day_in_month := (SELECT DATE_PART('days', 
                                    DATE_TRUNC('month', NOW()) 
                                    + '1 MONTH'::INTERVAL 
                                    - '1 DAY'::INTERVAL
                                   ));
  open curs;
  loop
    fetch curs into r;
    exit when not found;
    eid = r.eid;
    name = r.name;
    if exists(select 1 from Part_time_Emp P where P.eid = r.eid) then
      status := 'Part time';
      num_work_days := null;
      monthly_salary := null;
      num_work_hours := 0;
      hourly_rate := (select hourly_rate from Part_time_Emp P where P.eid = r.eid);
      salary_amount := num_work_hours * hourly_rate;
      insert into Pay_slips
      values (select now()::date, r.eid, salary_amount, num_work_hours, null);
    else
      status := 'Full time';
      num_work_hours := null;
      hourly_rate := null;
      if (r.join_date = select DATE_PART('months', NOW())) then
        first_work_day = select DATE_PART('days', r.join_date);
      else
        first_work_day = 1;
      end if;
      if (r.depart_date = select DATE_PART('months', NOW())) then
        last_work_day = select DATE_PART('days', r.depart_date);
      else
        last_work_day = day_in_month;
      end if;
      num_work_days := last_work_day - first_work_day + 1;
      monthly_salary := (select monthly_salary from Full_time_Emp F where F.eid = r.eid);
      salar_amount := num_work_days * monthly_salary / day_in_month;
      insert into Pay_slips
      values (select now()::date, r.eid, salary_amount, null, num_work_days);
    end if;
    return next;
  end loop;
  close curs;
end;
$$ language plpgsql;
