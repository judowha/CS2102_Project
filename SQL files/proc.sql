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