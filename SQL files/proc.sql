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
        if pre_eid is NULL then eid :='E00001';
        else eid := concat('E', right(concat( '00000' ,cast( (cast(pre_eid as INTEGER)+1) as text)) ,5) );
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


create or replace procedure remove_employees(_eid char(20), _depart_time date) as $$
	declare
		index_Administrator integer;
		index_instructor integer;
		index_manager integer;
	begin
		index_Administrator :=0;
		index_instructor :=0;
		index_manager := 0;
		
		select 1 into index_Administrator
		from offerings O
		where O.eid = _eid
		and _depart_time <= date(O.registration_deadline);
		
		select 1 into index_instructor
		from offerings O, conducts _C
		where _C.eid = _eid
		and _C.launch_date = O.launch_date
		and _C.course_id = O.course_id
		and _depart_time <= O.start_date;
		
		select 1 into index_manager
		from manage Ma, course_areas Ca
		where ma.name = ca.name
		and ma.eid = _eid;
		
		if index_Administrator = 1 then 
			raise exception 'the administrator has a incoming registration deadline so he/she can not leave.';
		end if;
		
		if index_instructor = 1 then
			raise exception 'the instructor has a incoming teaching class so he/she can not leave. ';
		end if;
		
		if index_manager = 1 then
			raise exception 'the manager has managed course area so he/she can not leave. ';
		end if;
		
		update employees set depart_date = _depart_date where eid = _eid;
		
	end;
$$ language plpgsql;

create or REPLACE PROCEDURE add_customers (name char(30), phone text, email text, address text, 
										   card_number text, expiry_date date, cvv integer) as $$ 
declare 
	pre_eid char(20);
    eid char(20);
   	BEGIN

    	SELECT max(customers.cust_id) into pre_eid from customers;
        if pre_eid is NULL then eid :='C00001';
        else eid := concat('C', right(concat( '00000' ,cast( (cast(pre_eid as INTEGER)+1) as text)) ,5) );
        end if;
        insert into customers values (eid, name,phone, email, address);
		insert into credit_cards values(card_number, expiry_date, cvv);
		insert into owns values(card_number, eid, current_date);
    end;
	
$$ LANGUAGE plpgsql;


create or REPLACE PROCEDURE update_credit_card (_cust_id text, _card_number text, _expiry_date date, _cvv integer) as $$ 
	declare
		previous_number text;
   	BEGIN
		
		select number into previous_number 
		from owns
		where _cust_id = cust_id;
		
		update credit_cards 
		set number=_card_number, expiry_date = _expiry_date, cvv = _cvv
		where number = previous_number;
		
		update owns
		set number = _card_number, from_date = CURRENT_DATE
		where cust_id = _cust_id;
		
    end;
	
$$ LANGUAGE plpgsql;


create or REPLACE PROCEDURE add_course (tile text, description text, duration integer) as $$ 
	declare 
		pre_eid char(20);
    	eid char(20);
   	BEGIN

    	SELECT max(courses.course_id) into pre_eid from courses;
        if pre_eid is NULL then eid :='K00001';
        else eid := concat('K', right(concat( '00000' ,cast( (cast(pre_eid as INTEGER)+1) as text)) ,5) );
        end if;
		
		insert into courses values (eid, tile, description, duration);
		
    end;
	
$$ LANGUAGE plpgsql;

create or replace function find_rooms (date text, start_time integer, duration integer)
returns table(room_id char(20), location text, seating_capacity integer) as $$
declare
 this_sid char(20);
 this_cid char(20);
begin
 with Sessions1 as (select S.sid as sid, S.course_id as cid
 from Sessions S
 where S.date = date and S.start_time = start_time)

 select course_id into this_cid from Courses C
 where C.course_id = (select cid from Sessions1) and C.duration = duration;

 select sid into this_sid from Sessions1 S
 where S.cid = this_cid;

 select C.room_id into room_id from Conducts C
 where C.course_id = cid and C.sid = this_sid;

 select R.location into location from Rooms R
 where R.room_id = room_id;

 select R.seating_capacity into seating_capacity from Rooms R
 where R.room_id = room_id;
end;
$$ language plpgsql;


create or replace function pay_salary()
returns table(eid char(20), name char(30), status char(10), num_work_days numeric, num_work_hours numeric, hourly_rate numeric, monthly_salary numeric, salary_amount numeric) as $$
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
    eid := r.eid;
    name := r.name;
    if ((select count(*) from Part_time_Emp P where P.eid = r.eid) > 0) then
      status := 'Part time';
      num_work_days := null;
      monthly_salary := null;
      num_work_hours := (select SUM(end_time - start_time) from Conducts C, Sessions S where (C.sid = S.sid) and (C.eid = r.eid));
      --这句话还没测试过
      hourly_rate := (select P.hourly_rate from Part_time_Emp P where P.eid = r.eid);
      salary_amount := num_work_hours * hourly_rate;
      insert into Pay_slips
      values (NOW(), r.eid, salary_amount, num_work_hours, null);
    else
      status := 'Full time';
      num_work_hours := null;
      hourly_rate := null;
      if ((select DATE_PART('year', r.join_date)) = (select DATE_PART('year', NOW()))) and 
      ((select DATE_PART('month', r.join_date)) = (select DATE_PART('month', NOW()))) then
        first_work_day := (select DATE_PART('day', r.join_date));
      else
        first_work_day := 1;
      end if;
      if ((select DATE_PART('year', r.depart_date)) = (select DATE_PART('year', NOW()))) and 
      ((select DATE_PART('month', r.depart_date)) = (select DATE_PART('month', NOW()))) then
        last_work_day := (select DATE_PART('day', r.depart_date));
      else
        last_work_day := day_in_month;
      end if;
      num_work_days := last_work_day - first_work_day + 1;
      monthly_salary := (select F.monthly_salary from Full_time_Emp F where F.eid = r.eid);
      salary_amount := num_work_days * monthly_salary / day_in_month;
      insert into Pay_slips
      values (NOW(), r.eid, salary_amount, null, num_work_days);
    end if;
    return next;
  end loop;
  close curs;
end;
$$ language plpgsql;


create or replace function promote_courses()
returns table(cust_id char(20), cust_name char(30), course_area char(20), course_id char(20), course_title text, launch_date date, registration_ddl date, offering_fee double precision) as $$
declare
begin
end;
$$ language plpgsql;

create or replace function top_packages(IN n int)
returns table(package_id char(20), num_free_sessions int, price double precision, start_date date, end_date date, num_sold int) as $$
declare
begin
end;
$$ language plpgsql;

create or replace function popular_courses()
returns table(course_id char(20), course_area char(20), num_offering int, num_registrations) as $$
declare
begin
end;
$$ language plpgsql;

create or replace function view_summary_report(IN num_months int)
returns table(month int, year int, total_salary numeric, total_sales int, total_fee double precision, total_refunded_fee double precision, num_registration int) as $$
declare
  n int;
  loop_month date;
begin
  n := num_months;
  loop_month := (select DATE_TRUNC('month', NOW()));
  loop
    exit when n = 0;
    month := (select DATE_PART('month', loop_month));
    year := (select DATE_PART('year', loop_month));
    total_salary := (select SUM(amount)
                     from Pay_slips P
                     where DATE_TRUNC('month', P.payment_date) = loop_month);
    total_sales := (select count(*)
                    from Buys B
                    where DATE_TRUNC('month', B.date) = loop_month);
    total_fee := (select SUM(O.fees)
                  from Register R, Sessions S, Offerings O
                  where (DATE_TRUNC('month', R.date) = loop_month)
                  and (R.sid = S.sid)
                  and (S.course_id = O.course_id)
                  and (S.launch_date = O.launch_date));
    total_refunded_fee := (select SUM(O.fees) * 0.9
                           from Cancels C, Sessions S, Offerings O
                           where (DATE_TRUNC('month', C.date) = loop_month)
                           and (C.sid = S.sid)
                           and (S.course_id = O.course_id)
                           and (S.launch_date = O.launch_date));
    num_registration := (select count(*)
                         from Redeems R, Sessions S, Offerings O
                         where (DATE_TRUNC('month', R.date) = loop_month)
                         and (R.sid = S.sid)
                         and (S.course_id = O.course_id)
                         and (S.launch_date = O.launch_date));
    loop_month := month - '1 month'::interval;
    n := n - 1;
  end loop;
  close curs;
end;
$$ language plpgsql;

create or replace function compute_net_registration_fees(IN eid char(20))
returns table(course_id char(20), fee int) as $$
declare
  curs cursor for (select C.course_id from Courses C, Course_areas CA where (CA.name = C.area_name) and (CA.eid = eid));
  r record;
begin
  open curs;
  loop
    fetch curs into r;
    exit when not found;
    course_id := r.course_id;
    fee := (select SUM(O.fees)
            from Courses C, Offerings O, Sessions S, Registers R
            where (O.course_id = C.course_id)
            and ((select DATE_PART('year', O.end_date)) = (select DATE_PART('year', NOW())))
            and (S.course_id = O.course_id)
            and (S.launch_date = O.launch_date)
            and (R.sid = S.sid))
          -(select SUM(O.fees) * 0.9
            from Courses C, Offerings O, Sessions S, Cancels CL
            where (O.course_id = C.course_id)
            and ((select DATE_PART('year', O.end_date)) = (select DATE_PART('year', NOW())))
            and (S.course_id = O.course_id)
            and (S.launch_date = O.launch_date)
            and (CL.sid = S.sid))
          +(select SUM(CP.price / CP.num_free_registrations)
            from Courses C, Offerings O, Sessions S, Course_packages CP, Redeems R
            where (O.course_id = C.course_id)
            and ((select DATE_PART('year', O.end_date)) = (select DATE_PART('year', NOW())))
            and (S.course_id = O.course_id)
            and (S.launch_date = O.launch_date)
            and (R.sid = S.sid)
            and (R.package_id = CP.package_id));

    return next;
  end loop;
  close curs;
end;
$$ language plpgsql;

create or replace function view_manager_report()
returns table(mname char(30), num_course_areas int, num_course_offerings int, total_net_fee double precision, offering_title text) as $$
declare
  curs cursor for (select E.name, E.eid from Managers M, Employees E where M.eid = E.eid order by E.name);
  r record;
  n int;
begin
  open curs;
  loop
    fetch curs into r;
    exit when not found;
    n := (select count(*)
          from Courses C, (select * from compute_net_registration_fees(r.eid)) as X)
          where (C.course_id = X.course_id)
          and (X.fee = (select MAX(fee) from X)));
    loop
      exit when n = 0;
      mname := r.name;
      num_course_areas := (select count(*)
                           from Course_areas C
                           where C.eid = r.eid);
      num_course_offerings := (select count(*)
                               from Course_areas CA, Courses C, Offerings O
                               where (CA.eid = r.eid)
                               and (C.area_name = CA.name)
                               and (O.course_id = C.course_id)
                               and ((select DATE_PART('year', O.end_date)) = (select DATE_PART('year', NOW()))) );
      total_net_fee := (select SUM(X.fee)
                        from (select * from compute_net_registration_fees(r.eid)) as X);

      offering_title := (select C.title
                         from Courses C, (select * from compute_net_registration_fees(r.eid)) as X)
                         where (C.course_id = X.course_id)
                         and (X.fee = (select MAX(fee) from X))
                         offset (n - 1)
                         limit 1);
      return next;
      n := n - 1;
    end loop;
  
  end loop;
  close curs;
end;
$$ language plpgsql;

