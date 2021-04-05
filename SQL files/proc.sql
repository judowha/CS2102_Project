create or replace procedure add_manage (_name text[],_eid char(20)) as $$
	declare
		index_i integer;
		index_j integer;
		_index integer;
	begin
		index_i := array_length(_name,1);
		index_j := 1;
		--raise notice 'get into';
		loop
			exit when index_j > index_i;
			--raise notice'check loop';
			_index := 0;
			select 1 into _index
			from course_areas Ca
			where Ca.name = _name[index_j];
			
			if _index = 1 then
        		update course_areas set eid=_eid where name = _name[index_j];
				raise notice 'The manage information is updated';
			else 
				insert into course_areas values (_name[index_j], _eid);
				raise notice 'new course area is inserted';
			end if;
            index_j := index_j+1;
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
        else eid := concat('E', right(concat( '00000' ,cast( (cast(right(pre_eid ,5)as INTEGER)+1) as text)) ,5) );
        end if;
        insert into employees values (eid, name, phone, email, address, join_date);
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
			elsif category = 'manager' then
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
		from offerings O, sessions S
		where S.eid = _eid
		and S.launch_date = O.launch_date
		and S.course_id = O.course_id
		and _depart_time <= O.start_date;
		
		select 1 into index_manager
		from course_areas Ca
		where Ca.eid = _eid;
		
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
	pre_cid char(20);
    cid char(20);
   	BEGIN

    	SELECT max(customers.cust_id) into pre_cid from customers;
        if pre_cid is NULL then cid :='C00001';
        else cid := concat('C', right(concat( '00000' ,cast( (cast(right (pre_cid,5) as INTEGER)+1) as text)) ,5) );
        end if;
        insert into customers values (cid, name,phone, email, address);
		insert into credit_cards values(card_number, cid, current_date, expiry_date, cvv);
    end;
	
$$ LANGUAGE plpgsql;


create or REPLACE PROCEDURE update_credit_card (_cust_id text, _card_number text, _expiry_date date, _cvv integer) as $$ 
	declare
		previous_number text;
   	BEGIN
		
		select number into previous_number 
		from credit_cards
		where _cust_id = cust_id;
		
		update credit_cards 
		set number=_card_number, expiry_date = _expiry_date, cvv = _cvv, from_date = CURRENT_DATE
		where number = previous_number
		and cust_id = _cust_id;
		
    end;
$$ LANGUAGE plpgsql;


create or REPLACE PROCEDURE add_course (tile text, description text, areas text, duration integer) as $$ 
	declare 
		pre_eid char(20);
    	eid char(20);
   	BEGIN

    	SELECT max(courses.course_id) into pre_eid from courses;
        if pre_eid is NULL then eid :='K00001';
        else eid := concat('E', right(concat( '00000' ,cast( (cast(right(pre_eid ,5)as INTEGER)+1) as text)) ,5) );
        end if;
		insert into courses values (eid, tile, description, duration, areas);
    end;
$$ LANGUAGE plpgsql;

create or replace function find_instructors(_course_id char(20),session_date date, start_hour integer )
	returns table(eid char(20), name text) as $$
	declare 
		curs cursor for (select * from instructors);
		curs2 cursor for (select * from sessions S);
		r1 record;
		r2 record;
		isTeaching integer;
		isAvailable integer;
	begin
		OPEN curs;
		Loop
			fetch curs into r1;
			exit when not found;

			isTeaching :=0;
			select 1 into isTeaching
			from sessions s
			where s.course_id = _course_id
			and s.eid = r1.eid;
			
			if(isTeaching = 1)
			then
				eid := r1.eid;
				select e.name into name
				from employees e
				where e.eid = r1.eid;
				OPEN curs2;
				isAvailable := 1;
				loop
					fetch curs2 into r2;
					exit when not found;
					if r2.eid = eid and r2.date = session_date then
						if start_hour >= r2.start_time-1 and start_hour <=r2.end_time then
							isAvailable := 0;
						end if;
					end if;
				end loop;
				close curs2;
				if isAvailable = 1 then
					return next;
				end if;
			end if;
		end loop;
		close curs;
	end;
$$ language plpgsql;

create or replace function get_available_instructors(_course_id char(20),_start_date date, _end_date date )
	returns table(eid char(20), name text, totalHour integer, freeDate date, freeHour integer[]) as $$
	declare 
		curs cursor for (select * from instructors);
		curs2 cursor for (select * from sessions S);
		this_date date;
		r1 record;
		r2 record;
		isTeaching integer;
		possible_freeHour integer[];
		_length integer;
		index_i integer;
	begin
		OPEN curs;
		Loop
			fetch curs into r1;
			exit when not found;
			
			isTeaching :=0;
			select 1 into isTeaching
			from sessions s
			where s.course_id = _course_id
			and s.eid = r1.eid;
			
			if(isTeaching = 1)
			then
				eid := r1.eid;
				select e.name into name
				from employees e
				where e.eid = r1.eid;
				
				select sum(end_time) - sum(start_time) into totalHour
				from sessions s
				where s.eid = r1.eid
				and  date_part('month',s.date) = date_part('month',_start_date)
				and s.course_id = _course_id;
				this_date := _start_date;
				Loop
					exit when this_date > _end_date;
					freeDate := this_date;
					freeHour = array[9,10,11,14,15,16,17];
					OPEN curs2;
					loop
						fetch curs2 into r2;
						exit when not found;
						raise notice 'test';
						if r2.eid = eid and r2.date = this_date then
							raise notice 'get into';
							index_i := r2.start_time-1;
							loop
								exit when index_i > r2.end_time;
								select array_remove(freeHour,index_i) into freeHour;
								index_i := index_i + 1;
							end loop;
						end if;
					end loop;
					close curs2;
					return next;
					this_date := this_date + 1;
				end loop;
			end if;
		end loop;
		close curs;
	end;
$$ language plpgsql;



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


create or REPLACE PROCEDURE remove_session(IN course_id char(20), IN launch_date date, IN number char(20))  as $$
declare
  num_registration int;
  new_offering_start_date date;
  new_offering_end_date date;
begin
  num_registration := (select count(*)
                       from Registers R, Sessions S
                       where (R.sid = S.sid)
                       and (S.sid = number)
                       and (S.course_id = course_id)
                       and (S.launch_date = launch_date))
                     -(select count(*)
                       from Cancels C, Sessions S
                       where (C.sid = S.sid)
                       and (S.sid = number)
                       and (S.course_id = course_id)
                       and (S.launch_date = launch_date));
  if num_registrations = 0 then
    delete from Sessions
    where (S.sid = number)
    and (S.course_id = course_id)
    and (S.launch_date = launch_date);
    
    new_offering_start_date := (select MIN(S.date)
                                from Sessions S
                                where (S.course_id = course_id)
                                and (S.launch_date = launch_date));
    new_offering_start_date := (select MAX(S.date)
                                from Sessions S
                                where (S.course_id = course_id)
                                and (S.launch_date = launch_date));
    update Offering O
    set O.start_date = new_offering_start_date;
    update Offering O
    set O.end_date = new_offering_end_date;
  end if;
end;
$$ language plpgsql;

create or REPLACE PROCEDURE add_session(IN course_id char(20), IN launch_date date, IN number char(20), IN day date, IN start_hour int, IN intructor_id char(20), IN room_id char(20))  as $$
declare
  end_hour int;
  deadline date;
begin
  end_hour := start_hour + (select duration from Courses C where C.course_id = course_id);
  deadline := (select registration_deadline from Offerings O where (O.course_id = course_id) and (O.launch_date = launch_date));
  if ((day < deadline) and ((start_hour >= 9) and (end_hour <= 12)) or ((start_hour >= 14) and (end_hour <= 18))) then
    insert into Sessions
    values (number, day, start_hour, end_hour, launch_date, course_id, room_id, instructor_id);
    if (select start_date from Offerings O where (O.course_id = course_id) and (O.launch_date = launch_date)) > day then
      update Offerings O
      set O.start_date = day
      where (O.course_id = course_id) and (O.launch_date = launch_date);
    end if;
    if (select end_date from Offerings O where (O.course_id = course_id) and (O.launch_date = launch_date)) < day then
      update Offerings O
      set O.end_date = day
      where (O.course_id = course_id) and (O.launch_date = launch_date);
    end if;
  end if;
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
      values (CURRENT_DATE, r.eid, salary_amount, num_work_hours, null);
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
      values (CURRENT_DATE, r.eid, salary_amount, null, num_work_days);
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
  loop_month := (select DATE_TRUNC('month', CURRENT_DATE));
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
          -(select SUM(CL.refund_amt)
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

create or replace function add_course_package
(pname text, num integer, start_date date, end_date date, price double precision) as $$
declare
 pre_pid char(20);
 pid char(20);
begin
 SELECT max(package_id) into pre_pid from Course_packages;
 if pre_pid is NULL then pid :='P00001';
 else pid := concat('P', right(concat( '00000' ,cast( (cast(pre_pid as INTEGER)+1) as text)) ,5) );
 end if;
 insert into Course_packages values (pid, price, num, name, start_date, end_date);
end;
$$ language plpgsql;

create or replace function get_available_rooms (start_date date, end_date date)
returns table (room_id char(20), seating_capacity integer, rday date, hours integer[]) as $$
declare
 curs CURSOR FOR (select room_id from Rooms order by room_id);
 r RECORD;
 period integer;
 this_date date;
begin
 OPEN curs;
 LOOP
  FETCH curs into r;
  EXIT WHEN NOT FOUND;
  this_date = start_date;
  LOOP
   EXIT WHEN this_date = end_date;
   with Sessions1 as (select S.sid from Sessions S where S.room_id = r.room_id)
   select sum (end_time - start_time) into period from Sessions S where S.sid = Sessions1.sid and S.session_date = this_date;
   room_id = r.room_id;
   seating_capacity = select seating_capacity from Rooms Rm where Rm.room_id = r.room_id;
   rday = this_date;
   hours[cast(this_date) as integer] = period;
  END LOOP
  RETURN NEXT;
 END LOOP;
 CLOSE curs;
end;
$$ language plpgsql;

create or replace function add_course_offering
(course_id char(20), fees double precision, launch_date date, registration_deadline date, eid char(20), session_date date, start_time int, room_id char(20)) as $$

$$ language plpgsql;

create or replace function get_available_course_packages ()
returns table (pname text, num_free_registrations integer, end_date date, price double precision) as $$
declare
 curs CURSOR FOR (select * from Course_packages);
 r RECORD;
begin
 OPEN curs;
 LOOP
  FETCH curs INTO r;
  EXIT WHEN NOT FOUND;
  pname = r.name;
  num_free_registrations = r.num_free_registrations;
  end_date = r.sale_end_date;
  price = r.price;
  RETURN NEXT;
 END LOOP;
 CLOSE curs;

end;
$$ language plpgsql;