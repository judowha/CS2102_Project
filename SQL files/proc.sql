
create or replace procedure add_manage (_name text[],_eid char(20)) as $$
	declare
		index_i integer;
		index_j integer;
		_index integer;
	begin
		index_i := array_length(_name,1);
		index_j := 1;
		loop
			exit when index_j > index_i;
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

--<1>
create or REPLACE PROCEDURE add_employees (name char(30), phone text, email text,
							address text, salary_inf text,  join_date date, 
							category text, course_area text[]) as $$ 
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

--<2>
create or replace procedure remove_employees(_eid char(20), _depart_time date) as $$
	begin
		update employees set depart_date = _depart_time where eid = _eid;
	end;
$$ language plpgsql;

--<3>
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

--<4>
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

--<5>
create or REPLACE PROCEDURE add_course (tile text, description text, areas text, duration integer) as $$ 
	declare 
		pre_eid char(20);
    	eid char(20);
   	BEGIN

    	SELECT max(courses.course_id) into pre_eid from courses;
        if pre_eid is NULL then eid :='K00001';
        else eid := concat('K', right(concat( '00000' ,cast( (cast(right(pre_eid ,5)as INTEGER)+1) as text)) ,5) );
        end if;
		insert into courses values (eid, tile, description, duration, areas);
    end;
$$ LANGUAGE plpgsql;

--<6>
create or replace function find_instructors(_course_id char(20),_session_date date, start_hour integer )
	returns table(eid char(20), name text) as $$
	declare 
		curs cursor for (select * from instructors);
		curs2 cursor for (select * from sessions S);
		r1 record;
		r2 record;
		isTeaching integer;
		isAvailable integer;
		area text;
	begin
		OPEN curs;
		Loop
			fetch curs into r1;
			exit when not found;

			select area_name into area
			from courses
			where course_id = _course_id;
			
			isTeaching :=0;
			select 1 into isTeaching
			from specializes s
			where s.name = area
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
					if r2.eid = eid and r2.session_date = _session_date then
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

--<7>
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
		area text;
	begin
		OPEN curs;
		Loop
			fetch curs into r1;
			exit when not found;
			
			select area_name into area
			from courses
			where course_id = _course_id;
			
			isTeaching :=0;
			select 1 into isTeaching
			from specializes s
			where s.name = area
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
				and  date_part('month',s.session_date) = date_part('month',_start_date)
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
						if r2.eid = eid and r2.session_date = this_date then
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

		      
create or REPLACE PROCEDURE remove_session(IN in_course_id char(20), IN in_launch_date date, IN in_number char(20))  as $$
declare
  num_registration int;
  new_offering_start_date date;
  new_offering_end_date date;
  new_seat_cap int;
begin
  num_registration := (select count(*)
                       from Registers R, Sessions S
                       where (R.sid = S.sid)
                       and (S.sid = in_number)
                       and (S.course_id = in_course_id)
                       and (S.launch_date = in_launch_date))
                     -(select count(*)
                       from Cancels C, Sessions S
                       where (C.sid = S.sid)
                       and (S.sid = in_number)
                       and (S.course_id = in_course_id)
                       and (S.launch_date = in_launch_date));
  if num_registration = 0 then
    delete from Sessions
    where (sid = in_number)
    and (course_id = in_course_id)
    and (launch_date = in_launch_date);
    
    new_offering_start_date := (select MIN(session_date)
                                from Sessions
                                where (course_id = in_course_id)
                                and (launch_date = in_launch_date));
    new_offering_end_date := (select MAX(session_date)
                                from Sessions
                                where (course_id = in_course_id)
                                and (launch_date = in_launch_date));
    new_seat_cap := (select SUM(R.seating_capacity)
                     from Rooms R, Sessions S
                     where (S.course_id = in_course_id)
                     and (S.launch_date = in_launch_date)
                     and (R.room_id = S.rid));
    update Offerings
    set start_date = new_offering_start_date,
        end_date = new_offering_end_date,
        seating_capacity = new_seat_cap
    where (course_id = in_course_id)
    and (launch_date = in_launch_date);
  end if;
end;
$$ language plpgsql;

			  
create or REPLACE PROCEDURE add_session(IN in_course_id char(20), IN in_launch_date date, IN in_number char(20), IN in_day date, IN start_hour int, IN instructor_id char(20), IN in_room_id char(20))  as $$
declare
  end_hour int;
  deadline date;
  new_offering_start_date date;
  new_offering_end_date date;
  new_seat_cap int;
begin
  end_hour := start_hour + (select duration from Courses where course_id = in_course_id);
  deadline := (select registration_deadline from Offerings where (course_id = in_course_id) and (launch_date = in_launch_date));
  
  if ((in_day < deadline) and ((start_hour >= 9) and (end_hour <= 12)) or ((start_hour >= 14) and (end_hour <= 18))) then
    insert into Sessions
    values (in_number, in_day, start_hour, end_hour, in_launch_date, in_course_id, in_room_id, instructor_id);
    new_offering_start_date := (select MIN(session_date)
                                from Sessions
                                where (course_id = in_course_id)
                                and (launch_date = in_launch_date));
    new_offering_end_date := (select MAX(session_date)
                                from Sessions
                                where (course_id = in_course_id)
                                and (launch_date = in_launch_date));
    new_seat_cap := (select SUM(R.seating_capacity)
                     from Rooms R, Sessions S
                     where (S.course_id = in_course_id)
                     and (S.launch_date = in_launch_date)
                     and (R.room_id = S.rid));
    update Offerings
    set start_date = new_offering_start_date,
        end_date = new_offering_end_date,
        seating_capacity = new_seat_cap
    where (course_id = in_course_id)
    and (launch_date = in_launch_date);
  end if;
end;
$$ language plpgsql;

			  
create or replace function pay_salary()
returns table(eid char(10), name char(30), status char(10), num_work_days numeric, num_work_hours numeric, hourly_rate numeric, monthly_salary numeric, salary_amount numeric) as $$
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
  curs cursor for (select C.package_id, count(*) cnt
                   from Course_packages C, Buys B
                   where (C.package_id = B.package_id)
                   and ((select DATE_PART('year', B.buy_date)) = (select DATE_PART('year', CURRENT_DATE)))
                   group by C.package_id
                   order by (count(*), C.price) desc
                   limit n);
  r record;
  temp record;
begin
  open curs;
  loop
    fetch curs into r;
    exit when not found;
    package_id := r.package_id;
    --temp := (select * from Course_packages C where C.package_id = r.package_id);
    --num_free_sessions := temp.num_free_sessions;
    num_free_sessions := (select C.num_free_registrations from Course_packages C where C.package_id = r.package_id);
    --price := temp.price;
    price := (select C.price from Course_packages C where C.package_id = r.package_id);
    --start_date := temp.sale_start_date;
    --end_date := temp.sale_end_date;
    start_date := (select C.sale_start_date from Course_packages C where C.package_id = r.package_id);
    end_date := (select C.sale_end_date from Course_packages C where C.package_id = r.package_id);
    num_sold := r.cnt;
    return next;
  end loop;
  close curs;
end;
$$ language plpgsql;

								  
create or replace function popular_courses_init()
returns table(course_id char(20), course_title text, course_area char(20), num_offering int, num_registrations int) as $$
declare
  curs cursor for (select C.course_id
                   from Courses C, Offerings O
                   where (C.course_id = O.course_id)
                   and ((select DATE_PART('year', O.start_date))=(select DATE_PART('year', CURRENT_DATE)))
                   group by C.course_id
                   having count(*) >= 2);
  
  re record;
begin
  open curs;
  loop
    fetch curs into re;
    exit when not found;
    if (with X as (select O.course_id, O.launch_date, O.start_date, count(*) cnt
                   from Offerings O ,Registers R
                   where (O.course_id = re.course_id)
                   and (R.course_id = O.course_id)
                   and (R.launch_date = O.launch_date)
                   group by O.course_id, O.launch_date
                   union
                   select O.course_id, O.launch_date, O.start_date, 0
                   from Offerings O
                   where (not exists (select 1 
                                     from  Registers R
                                     where (R.course_id = O.course_id)
                                     and (R.launch_date = O.launch_date)))
                   and (O.course_id = re.course_id))
        select count(*)
        from X X1, X X2
        where (X1.start_date > X2.start_date)
        and (X1.cnt <= X2.cnt)) = 0 then
    
      course_id := re.course_id;
      course_title := (select C.title from Courses C where C.course_id = re.course_id);
      course_area := (select C.area_name from Courses C where C.course_id = re.course_id);
      num_offering := (select count(*)
                       from Offerings O
                       where (O.course_id = re.course_id)
                       and ((select DATE_PART('year', O.start_date))=(select DATE_PART('year', CURRENT_DATE))));
      num_registrations := (select count(*)
                            from Offerings O, Registers R
                            where (O.start_date >= all(select O.start_date
                                                   from Offerings O
                                                   where O.course_id = re.course_id))
                            and (O.course_id = re.course_id)
                            and (R.course_id = re.course_id)
                            and (R.launch_date = O.launch_date));
      return next;
    end if;
  end loop;
  close curs;
end;
$$ language plpgsql;

				 
create or replace function popular_courses()
returns table(course_id char(20), course_title text, course_area char(20), num_offering int, num_registrations int) as $$
begin
  return QUERY
  select * from popular_courses_init() P order by P.num_registrations desc, P.course_id;
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
    total_salary := (select coalesce((select SUM(amount)
                     from Pay_slips P
                     where DATE_TRUNC('month', P.payment_date) = loop_month), 0));
    total_sales := (select count(*)
                    from Buys B
                    where DATE_TRUNC('month', B.buy_date) = loop_month);
    total_fee := (select coalesce((select SUM(O.fees)
                  from Registers R, Sessions S, Offerings O
                  where (DATE_TRUNC('month', R.registers_date) = loop_month)
                  and (R.sid = S.sid)
                  and (S.course_id = O.course_id)
                  and (S.launch_date = O.launch_date)), 0));
    total_refunded_fee := (select coalesce((select SUM(C.refund_amt)
                           from Cancels C
                           where DATE_TRUNC('month', C.cancels_date) = loop_month), 0));
    num_registration := (select count(*)
                         from Redeems R
                         where DATE_TRUNC('month', R.redeem_date) = loop_month);
    loop_month := loop_month - '1 month'::interval;
    n := n - 1;
    return next;
  end loop;
end;
$$ language plpgsql;

		       
create or replace function compute_net_registration_fees(IN in_eid char(20))
returns table(course_id char(20), fee int) as $$
declare
  curs cursor for (select C.course_id from Courses C, Course_areas CA where (CA.name = C.area_name) and (CA.eid = in_eid));
  re record;
begin
  open curs;
  loop
    fetch curs into re;
    exit when not found;
    course_id := re.course_id;
    fee := (select coalesce((select SUM(O.fees)
            from Offerings O, Sessions S, Registers R
            where (O.course_id = re.course_id)
            and ((select DATE_PART('year', O.end_date)) = (select DATE_PART('year', NOW())))
            and (S.course_id = O.course_id)
            and (S.launch_date = O.launch_date)
            and (R.sid = S.sid)),0))
          -(select coalesce((select SUM(CL.refund_amt)
            from Offerings O, Sessions S, Cancels CL
            where (O.course_id = re.course_id)
            and ((select DATE_PART('year', O.end_date)) = (select DATE_PART('year', NOW())))
            and (S.course_id = O.course_id)
            and (S.launch_date = O.launch_date)
            and (CL.sid = S.sid)),0))
          +(select coalesce((select SUM(CP.price / CP.num_free_registrations)
            from Offerings O, Sessions S, Course_packages CP, Redeems R
            where (O.course_id = re.course_id)
            and ((select DATE_PART('year', O.end_date)) = (select DATE_PART('year', NOW())))
            and (S.course_id = O.course_id)
            and (S.launch_date = O.launch_date)
            and (R.sid = S.sid)
            and (R.package_id = CP.package_id)),0));

    return next;
  end loop;
  close curs;
end;
$$ language plpgsql;
		 
		 
create or replace function view_manager_report()
returns table(mname char(30), num_course_areas int, num_course_offerings int, total_net_fee double precision, offering_title text) as $$
declare
  curs1 cursor for (select E.name, E.eid from Managers M, Employees E where M.eid = E.eid order by E.name);
  r record;
  n int;
begin
  open curs1;
  loop
    fetch curs1 into r;
    exit when not found;
    n := (with X as (select * from compute_net_registration_fees(r.eid))
          select count(*)
          from Courses C, X
          where (C.course_id = X.course_id)
          and (X.fee = (select MAX(fee) from X)));
    if n = 0 then
      n := 1;
    end if;
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
      total_net_fee := (with X as (select * from compute_net_registration_fees(r.eid))
                        select SUM(X.fee)
                        from X);

      offering_title := (with X as (select * from compute_net_registration_fees(r.eid))
                         select C.title
                         from Courses C, X
                         where (C.course_id = X.course_id)
                         and (X.fee = (select MAX(fee) from X))
                         offset (n - 1)
                         limit 1);
      return next;
      n := n - 1;
    end loop;
  
  end loop;
  close curs1;
end;
$$ language plpgsql;

			      
-- <8>
create or replace function find_rooms (f_session_date date, f_start_time integer, f_duration integer)
returns table(room_id char(20)) as $$
declare
 curs cursor for (select S.rid from Sessions S where S.session_date = f_session_date and S.start_time = f_start_time and S.end_time = (f_start_time + f_duration));
 r record;
begin
 open curs;
 LOOP
  fetch curs into r;
  exit when not found;
  room_id := r.rid;
  return next;
 end loop;

end;
$$ language plpgsql;

			   
-- <9>
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
   EXIT WHEN this_date = end_date + 1;
   with Sessions1 as (select S.sid from Sessions S where S.room_id = r.room_id)
   select sum (end_time - start_time) into period from Sessions S where S.sid = Sessions1.sid and S.session_date = this_date;
   room_id := r.room_id;
   seating_capacity := select seating_capacity from Rooms Rm where Rm.room_id = r.room_id;
   rday := this_date;
   hours[cast(this_date) as integer] := 7 - period;
   this_date := this_date + 1;
  END LOOP
  RETURN NEXT;
 END LOOP;
 CLOSE curs;
end;
$$ language plpgsql;

	       
-- trigger for registration deadline
CREATE TRIGGER registration_deadline_trigger
BEFORE INSERT ON Offerings
FOR EACH ROW EXECUTE FUNCTION registration_deadline_func();

create or replace function registration_deadline_func() RETURNS TRIGGER AS $$
begin
 select
 IF (NEW.start_date - NEW.registration_deadline < 10) THEN
  NEW.registration_deadline := NEW.start_date - 10;
 END IF;
 RETURN NEW;
end;
$$ language plpgsql;

	       
-- <10> // find valid instructor
create trigger target_number_registrations_trigger
before insert on Offerings
for each row execute function target_number_registrations_func();

create or replace function target_number_registrations_func() returns trigger as $$
begin
 IF (NEW.target_number_registrations > NEW.seating_capacity) THEN
  NEW.targer_number_registrations := NEW.seating_capacity;
 END IF;
 RETURN NEW;
end;
$$ language plpgsql;

	       
create or replace function add_course_offering
(course_id char(20), fees double precision, launch_date date, registration_deadline date, target_number_registrations integer, eid char(10), session_date date, start_time int, room_id char(20)) as $$
declare
 num_available_instructors integer;
 this_course_id char(20);
 num_registration integer;
 start_date date;
 end_date date;
begin
 with Specialized_instructors as (select S.eid from Specializes S where S.name = (select area_name from Courses C where C.course_id = course_id))
 select count(*) into num_available_instructors from Specialized_instructors;

 IF (num_available_instructors >= 1) THEN
  select seating_capacity into num_registration from Rooms R where R.room_id = room_id;
  select min (session_date) into start_date from Sessions S where S.launch_date = launch_date and S.course_id = course_id;
  select max (session_date) into end_date from Sessions S where S.launch_date = launch_date and S.course_id = course_id;
  insert into Offerings
  values (launch_date, course_id, fees, target_number_registrations, registration_deadline, num_registration, start_date, end_date, eid);
  ELSE raise exception 'This instructor is not specialized in this course area.';
 END IF
end;

$$ language plpgsql;

										  
-- <11>
create or replace procedure add_course_package
(pname text, num integer, start_date date, end_date date, price double precision) as $$
declare
 pre_pid char(20);
 pid char(20);
begin
 select max(course_packages.package_id) into pre_pid from course_packages;
 if pre_pid is null then pid := 'P00001';
 ELSE pid := concat('P', right(concat('00000', cast( ( cast(right(pre_pid, 5)as integer) + 1) as text )), 5));
 end if;
 insert into Course_packages values (pid, price, num, pname, start_date, end_date);
end;
$$ language plpgsql;

			       
-- <12>
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
  pname := r.name;
  num_free_registrations := r.num_free_registrations;
  end_date := r.sale_end_date;
  price := r.price;
  RETURN NEXT;
 END LOOP;
 CLOSE curs;

end;
$$ language plpgsql;

			       
-- <13>
create or replace function buy_course_package (cust_id, package_id) as $$
declare
 start_date date;
 end_date date;
 number text;
begin
 select sale_start_date into start_date from Course_packages C where C.package_id = package_id;
 select sale_end_date into end_date from Course_packages C where C.package_id = package_id;
 select Cr.number into number from Credit_cards Cr where Cr.cust_id = cust_id;
 IF (CURRENT_DATE >= start_date and CURRENT_DATE <= end_date) THEN
  insert into Buys
  values (CURRENT_DATE, cust_id, number, package_id, 1);
 END IF

end;
$$ language plpgsql;

			       
-- <14>
create or replace function get_my_course_package (cust_id)
returns row_to_json(table (pname, pdate, price, num_free_sessions, num_of_sessions, course_name, session_date, session_start_hour)) as $$
declare
 curs CURSOR FOR (select * from Course_packages CP
 where CP.package_id = (select package_id from Buys B where B.cust_id = cust_id));
 r RECORD;
 cid char (20);
begin
 OPEN curs;
 LOOP
  FETCH curs INTO r;
  EXIT WHEN NOT FOUND;
  pname := r.name;
  select B.buy_date into pdate from Buys B where B.package_id = r.package_id and B.cust_id = cust_id;
  price := r.price;
  num_free_sessions := r.num_free_registrations;
  select B.num_remaining_redemptions into num_of_sessions from Buys B where B.package_id = r.package_id and B.cust_id = cust_id;
  select R.course_id into cid from Redeems R where R.cust_id = cust_id and R.package_id = r.package_id;
  select C.title into course_name from Courses C where C.course_id = cid;
  select S.session_date into session_date from Sessions S where S.course_id = cid;
  select S.start_time into session_start_hour from Sessions S where S.course_id = cid;
  return NEXT;
 END LOOP
 CLOSE curs;
end;
$$ language plpgsql;

			
-- <15>
create or replace function get_available_course_offerings ()
returns table (course_title, course_area, start_date, end_date, registration_deadline, course_fees, num_seats) as $$
declare
 curs CURSOR FOR (select * from Offerings order by registration_deadline, title asc);
 r RECORD;
begin
 OPEN curs;
 LOOP
  FETCH curs INTO r;
  EXIT WHEN NOT FOUND;
  select C.title into course_title from Courses C where C.course_id = r.course_id;
  select C.area_name into course_area from Courses C where C.course_id = r.course_id;
  start_date := r.start_date;
  end_date := r.end_date;
  registration_deadline := r.registration_deadline;
  course_fees := r.fees;
  num_seats := r.seating_capacity - (select count(*) from Redeems R where R.course_id = r.course_id);
  RETURN NEXT;
 END LOOP;
 CLOSE curs;

end;
$$ language plpgsql;
 
			
-- <16>
create or replace function get_available_course_sessions(input_launch_date date, input_course_id char(20))
returns table(sid char(20), s_date date, s_start_hour int, instr_name text, num_of_seats_remaining int) as $$

declare
	curs cursor for 	(
		select		Ss.sid, Ss.launch_date, Ss.course_id, Ss.session_date, Ss.start_time, Ss.name, (Ss.seating_capacity - Ss.register_num - Ss.redeem_num + Ss.cancel_num) as num_seats
		from		(	Sessions natural join Employees natural join 
				(	select R.room_id as rid, R.seating_capacity as seating_capacity 
					from Rooms R) as RoomInfor natural join  
				(	select Rg.sid as sid, Rg.launch_date as launch_date, Rg.course_id as course_id, count(Rg.cust_id) as register_num 
					from (Sessions natural left join Registers) Rg 
					group by Rg.sid, Rg.launch_date, Rg.course_id) as NumRegister natural join 
				(	select Rd.sid as sid, Rd.launch_date as launch_date,  Rd.course_id as course_id, count(Rd.cust_id) as redeem_num 
					from (Sessions natural left join Redeems) Rd 
					group by Rd.sid, Rd.launch_date, Rd.course_id ) as NumRedeem natural join 
				(	select C.sid as sid, C.launch_date as launch_date, C.course_id as course_id, count(C.cust_id) as cancel_num 
					from (Sessions natural left join Cancels) C 
					group by C.sid, C.launch_date, C.course_id) as NumCancel) as Ss
		where 	Ss.launch_date = input_launch_date
		and 		Ss.course_id = input_course_id
		and		(Ss.seating_capacity - Ss.register_num - Ss.redeem_num + Ss.cancel_num) > 0
		and		Ss.session_date > current_date
		order by 	(Ss.session_date, Ss.start_time) asc);
	r record;
begin
	open curs;
	loop
		fetch curs into r;
		exit when not found;
		sid := r.sid;
		s_date := r.session_date;
		s_start_hour := r.start_time;
		instr_name := r.name;
		num_of_seats_remaining := r.num_seats;
		return next;
	end loop;
	close curs;		
end;
$$ language plpgsql;


-- <17>
create or replace procedure register_session(input_cust_id char(20), input_launch_date date, input_course_id char(20), input_sid char(20), pay_method text)
as $$

declare
	curs1 cursor for (	with A as (select * from get_available_course_sessions(input_launch_date, input_course_id))
				select sid from A);
	curs2 cursor for (select * from Buys);
	r1 record;
	r2 record;
	card_num text;
	have_free integer;
begin
	open curs1;
	loop
		fetch curs1 into r1;
		exit when not found;

		if (r1.sid = input_sid) then 
			case 	
			when pay_method = 'credit card' then 
				card_num := (select number from Credit_cards where cust_id = input_cust_id);
				insert into Registers values (input_sid, input_course_id, input_launch_date, input_cust_id, card_num, current_date);	
			when pay_method = 'redemption' then 
				have_free := 0;
				open curs2;
				loop
				fetch curs2 into r2;
				exit when not found;
					if ((r2.cust_id = input_cust_id)  and  (r2.num_remaining_redemptions > 0)) then
						have_free := 1;
						update Buys 
						set num_remaining_redemptions = num_remaining_redemptions - 1 
						where buy_date = r2.buy_date and cust_id = r2.cust_id and number = r2.number and package_id = r2.package_id;
						insert into Redeems values (current_date, r2.cust_id, r2.num, r2.package_id, input_sid, input_launch_date, input_course_id);	
					end if;
				end loop;
				close curs2;
				
				if (have_free = 0) then raise exception 'your do not have any active package.'; end if;
			else 
				raise exception 'your payment type is not supported.'; 
			end case;
		else
			raise exception 'there is no available session.';
		end if;
	end loop;
	close curs1;		
end;
$$ language plpgsql;


-- <18> 有无cancels都跟有cancels一样
create or replace function get_my_registrations(input_cust_id char(20))
returns table(course_name text, course_fees double precision, s_date date, s_start_hour int, s_duration int, instr_name text) as $$

declare
	curs cursor for 	(
		select		S.title, S.fees, S.session_date , S.start_time, S.session_duration, S.name
		from		(	((select sid, session_date, start_time, (end_time - start_time) as session_duration, launch_date, course_id, eid
					from Sessions) as SessionInfor natural join 
					(select course_id, title 
					from Courses) as CourseInfor natural join 
					(select launch_date, course_id, fees 
					from Offerings) as OfferingInfor natural join 
					(select eid, name 
					from Employees) as InstructorInfor)
	
					natural right join 
	
					((select sid, launch_date, course_id 
					from Registers
					where cust_id = input_cust_id) union
					(select sid, launch_date, course_id 
					from Redeems
					where cust_id = input_cust_id) union
					(select sid, launch_date, course_id 
					from Cancels
					where cust_id = input_cust_id)) as RegistedSession ) as S
		where 	S.session_date > current_date
		order by 	(S.session_date, S.start_time) asc);
	r record;
begin
	open curs;
	loop
		fetch curs into r;
		exit when not found;
		course_name := r.title;
		course_fees := r.fees;
		s_date := r.session_date;
		s_start_hour := r.start_time;
		s_duration := r.session_duration;
		instr_name := r.name;
		return next;
	end loop;
	close curs;		
end;
$$ language plpgsql;


-- <19>
create or replace procedure update_course_session(input_cust_id char(20), input_launch_date date, input_course_id char(20), new_sid char(20))
as $$
declare
	curs1 cursor for (	with A as (select * from get_available_course_sessions(input_launch_date, input_course_id))
				select sid from A);
	r1 record;
	curs2 cursor for (select * from Registers);
	r2 record;
	curs3 cursor for (select * from Redeems);
	r3 record;
	have_session_flag integer;
	have_available_flag integer;
begin
	have_session_flag := 0;
	have_available_flag := 0;

	open curs1;
	loop
		fetch curs1 into r1;
		exit when not found;		
		if (r1.sid = new_sid) then 
			have_available_flag := 1;
			
			open curs2;
			loop
				fetch curs2 into r2;
				exit when not found;		
				if(r2.cust_id = input_cust_id and r2.launch_date = input_launch_date and r2.course_id = input_course_id) then
					have_session_flag := 1;
					update Registers 
					set sid = new_sid
					where cust_id = input_cust_id and launch_date = input_launch_date and course_id = input_course_id;
				end if;
			end loop;
			close curs2;
			
			open curs3;
			loop
				fetch curs3 into r3;
				exit when not found;		
				if(r3.cust_id = input_cust_id and r3.launch_date = input_launch_date and r3.course_id = input_course_id) then 
					have_session_flag := 1;
					update Redeems 
					set sid = new_sid
					where cust_id = input_cust_id and launch_date = input_launch_date and course_id = input_course_id;
				end if;
			end loop;
			close curs3;
		end if;
		
		if (have_available_flag = 0) then raise exception 'there is no available session.'; end if;
		if (have_available_flag = 1 and have_session_flag = 0) then raise exception 'you do not have any such registered course session.'; end if;

	end loop;
	close curs1;
end;
$$ language plpgsql;


-- <20> refund没有
create or replace procedure cancel_registration(input_cust_id char(20), input_launch_date date, input_course_id char(20))
as $$
declare
	curs1 cursor for (select * from Registers natural left join (Sessions natural join Offerings));
	r1 record;
	curs2 cursor for (select * from Redeems natural left join Sessions);
	r2 record;
	request_flag integer;

begin
	request_flag := 0;
	
	open curs1;
	loop
		fetch curs1 into r1;
		exit when not found;		
		if(r1.cust_id = input_cust_id and r1.launch_date = input_launch_date and r1.course_id = input_course_id) then
		request_flag := 1;
			if (r1.session_date >= (current_date + '7 day'::interval)) then
				insert into Cancels values (r1.sid, r1.course_id, r1.launch_date, r1.cust_id, current_date, 0.9 * (r1.fees), 0);
			else 
				insert into Cancels values (r1.sid, r1.course_id, r1.launch_date, r1.cust_id, current_date, 0, 0);
			end if;
		end if;
	end loop;
	close curs1;
			
	open curs2;
	loop
		fetch curs2 into r2;
		exit when not found;		
		if(r2.cust_id = input_cust_id and r2.launch_date = input_launch_date and r2.course_id = input_course_id) then
		request_flag := 1;		
			if (r2.session_date >= (current_date + '7 day'::interval)) then
				insert into Cancels values (r1.sid, r1.course_id, r1.launch_date, r1.cust_id, current_date, 0, 1);
				update Redeems 
				set num_remaining_redemptions = num_remaining_redemptions +1 
				where cust_id = input_cust_id and launch_date = input_launch_date and course_id = input_course_id;
			else 
				insert into Cancels values (r1.sid, r1.course_id, r1.launch_date, r1.cust_id, current_date, 0, 0);
			end if;
		end if;
	end loop;
	close curs2;

	if (request_flag = 0) then raise exception 'The cancelation request is invalid, you do not have any such session.'; end if;
end;
$$ language plpgsql;


-- <21>
create or replace procedure update_instructor(input_launch_date date, input_course_id char(20), input_sid char(20), new_eid char(20))
as $$
declare
	curs1 cursor for (select * from Sessions);
	r1 record;
	curs2 cursor for (select * from Sessions);
	r2 record;
	busy_flag integer;
	start_date date;
	start_hour integer;
	end_hour integer;
begin
	busy_flag := 1;

	open curs1;
	loop
		fetch curs1 into r1;
		exit when not found;
			if ((r1.sid = input_sid) and (r1.launch_date = input_launch_date) and (r1.course_id = input_course_id)) then
				start_date := r1.session_date;
				start_hour := r1.start_time;
				end_hour := r1.end_time;
			end if;
	end loop;
	close curs1;

	if ((start_date = current_date and start_hour > date_part ('hour', current_timestamp)) or (start_date > current_date)) then
		open curs2;
		loop
			fetch curs2 into r2;
			exit when not found;
			if (r2.eid = new_eid) then
				if (r2.session_date = start_date and (r2.start_time > (end_hour + 1))) then
					busy_flag := 0;
				end if;
				if (r2.session_date = start_date and (r2.end_time < (start_hour - 1))) then
					busy_flag := 0;
				end if;
				if (r2.session_date < start_date) then
					busy_flag := 0;
				end if;
				if (r2.session_date > start_date) then
					busy_flag := 0;
				end if;			
			end if;
		end loop;
		close curs2;
		
		if (busy_flag = 0) then 
			update Sessions set eid = new_eid where sid = input_sid and launch_date = input_launch_date and course_id = input_course_id;
		else 
			raise exception 'The new instructor is busy now.';
		end if;
	else 
		raise exception 'This session has already started.';
	end if; 
end;
$$ language plpgsql;


-- <22>
create or replace procedure update_room(input_launch_date date, input_course_id char(20), input_sid char(20), new_room_id char(20))
as $$
declare
	start_date date;
	start_hour integer;
	end_hour integer;
	capacity integer;
	register_num integer;
	redeem_num integer;
	cancel_num integer;
begin
	start_date := (select session_date from Sessions where sid = input_sid and launch_date = input_launch_date and course_id = input_course_id);
	start_hour := (select start_time from Sessions where sid = input_sid and launch_date = input_launch_date and course_id = input_course_id);
	end_hour := (select end_time from Sessions where sid = input_sid and launch_date = input_launch_date and course_id = input_course_id);
	register_num := (select count(Rg.cust_id) from (Sessions natural left join Registers) Rg);
	redeem_num := (select count(Rd.cust_id) from (Sessions natural left join Redeems) Rd);
	cancel_num := (select count(Cs.cust_id) from (Sessions natural left join Cancels) Cs);
	capacity := (select seating_capacity from Rooms where room_id = new_room_id);


	if ((start_date = current_date and start_hour > date_part ('hour', current_timestamp)) or (start_date > current_date)) then
		if (capacity >= register_num + redeem_num - cancel_num)  then
			update Sessions set rid = new_room_id where sid = input_sid and launch_date = input_launch_date and course_id = input_course_id;
		else
			raise exception 'the new room do not have seat anymore.';
		end if;
	else 
		raise exception 'This session has already started.';
	end if; 
end;
$$ language plpgsql;


--<26>
create or replace function promote_courses() 
returns table(_cust_id char(10), _cust_name text, _area_name text, _course_id char(10), _title text, 
			  _launch_date date, _regist_ddl date, _fee double precision) as $$
	declare
	
		curs cursor for (select * 
						from courses C,offerings O,course_areas CA
						where O.course_id = C.course_id
						and C.area_name = CA.name
						order by O.registration_deadline);
						
		curs1 cursor for (select * from customers);
		curs2 cursor for (select * from registers);
		r2 record;
		r1 record;
		r3 record;
		isActive integer;
		interested_area text;
	begin
		interested_area := null;
		open curs1;
		loop
			fetch curs1 into r1;
			exit when not found;
			isActive := 0;
			open curs2;
			loop
				fetch curs2 into r3;
				exit when not found;
				if current_date - r3.registers_date <= 120 then 
					isActive := 1;
				end if;
			end loop;
			close curs2;
			raise notice 'test1';
			
			if(isActive = 0) then
				_cust_id := r1.cust_id;
				_cust_name := r1.name;
				
				raise notice 'test2';
				
				select name into interested_area
				from registers R, courses C, course_areas CA,offerings O
				where R.cust_id = r1.cust_id
				and R.launch_date = O.launch_date
				and R.course_id = O.course_id
				and O.course_id = C.course_id
				and C.area_name = CA.name
				order by R.registers_date
				limit 1;
		
				if interested_area is not null then 
					_area_name := interested_area;
					open curs;
					loop
						fetch curs into r2;
						exit when not found;
						if r2.area_name = interested_area and current_date < r2.registration_deadline then
							_course_id := r2.course_id;
							_title := r2.title;
							_launch_date = r2.launch_date;
							_regist_ddl = r2.registration_deadline;
							_fee = r2.fees;
							return next;
						end if;
					end loop;
					close curs;
				else
					open curs;
					loop
						fetch curs into r2;
						exit when not found;
						if  current_date < r2.registration_deadline then
							_area_name := r2.area_name;
							_course_id := r2.course_id;
							_title := r2.title;
							_launch_date = r2.launch_date;
							_regist_ddl = r2.registration_deadline;
							_fee = r2.fees;
							return next;
						end if;
					end loop;
				end if;	
			end if;
		end loop;
	end
$$ language plpgsql;



--triggers

create or replace function check_insert_session_function() returns trigger as $$
begin
  --check specializes
  if (select count(*)
      from Courses C, Specializes S
      where (S.eid = NEW.eid)
      and (C.area_name = S.name)
      and (C.course_id = NEW.course_id)) = 0 then
    raise notice 'Can not insert this session!';
    return null;
  end if;
  --check time
  if (select count(*)
      from Sessions S
      where (S.eid = NEW.eid)
      and (S.session_date = NEW.session_date)
      and (((NEW.start_time >= S.start_time) and (NEW.start_time <= S.end_time)) 
        or ((NEW.end_time >= S.start_time) and (NEW.end_time <= S.end_time)))) > 0 then
    raise notice 'Can not insert this session!';
    return null;
  end if;
  --check consecutive
  if (select count(*)
      from Sessions S
      where (S.eid = NEW.eid)
      and (S.session_date = NEW.session_date)
      and ((NEW.start_time = S.end_time + 1) or (New.end_time + 1 = S.start_time))) > 0 then
    raise notice 'Can not insert this session!';
    return null;
  end if;

  return NEW;
end;
$$ language plpgsql;

create trigger check_insert_session_trigger
before insert on Sessions
for each row execute function check_insert_session_function();


CREATE OR REPLACE FUNCTION maximum_workHour_notice() RETURNS TRIGGER AS $$
	declare
		totalHour integer;
	BEGIN
		select sum(end_time) - sum(start_time) into totalHour
				from sessions s
				where s.eid = new.eid
				and  date_part('month',s.date) = date_part('month',new.start_date)
				and s.course_id = new.course_id;
		if(new.end_time - new.start_time + totalHour > 30) then 
			raise notice 'the total work hour for instructor can not exceed 30 hours per month';
			return null ;
		else  return new;
		end if ;
	
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER maximum_workHour
BEFORE insert on sessions
FOR EACH ROW EXECUTE FUNCTION  maximum_workHour_notice();

CREATE OR REPLACE FUNCTION check_remove_employee() RETURNS TRIGGER AS $$
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
		where O.eid = new.eid
		and new.depart_date <= date(O.registration_deadline);
		
		select 1 into index_instructor
		from sessions S
		where S.eid = new.eid
		and new.depart_date<= S.session_date;
		
		select 1 into index_manager
		from course_areas Ca
		where Ca.eid = new.eid;
		
		if index_Administrator = 1 then 
			raise exception 'the administrator has a incoming registration deadline so he/she can not leave.';
		end if;
		
		if index_instructor = 1 then
			raise exception 'the instructor has a incoming teaching class so he/she can not leave. ';
		end if;
		
		if index_manager = 1 then
			raise exception 'the manager has managed course area so he/she can not leave. ';
		end if;
		
		return new;
	end;	
$$ LANGUAGE plpgsql;

CREATE TRIGGER remove_employees
BEFORE update on employees
FOR EACH ROW EXECUTE FUNCTION  check_remove_employee();




