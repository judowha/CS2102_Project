create table Courses (
  cid         char(20) primary key,
  title       text unique,
  description text,
  area        text
  duration    integer);

create table Offerings (
  fee               float，
  target_num        integer,
  launch_date       date,
  register_deadline timestamp,
  capacity          integer,
  start_date        date,
  end_date          date,
  status            text
  eid               char(20) not null,
  foreign key(eid) references Administrators);
  
create table CoursePakages (
  pid         char(20) primary key,
  price       float,
  number      integer,
  name        text,
  start_date  date,
  end_date    date
  status      text);
  
create table Customers (
  cid         char(20) primary key,
  name        char(30),
  phone       text,
  email       text,
  home        text,
  card_info   ?);



create table Employees (
  eid         char(20) primary key,
  name        char(30),
  phone       text,
  email       text,
  home        text,
  join_date   date,
  depart_date date);

create table Part_time_Emp (
  eid char(20) primary key references Employees
      on delete cascade,
  hourly_rate numeric);

create table Full_time_Emp (
  eid char(20) primary key references Employees
      on delete cascade,
  monthly_salary numeric);

create table Instructors (
  eid char(20) primary key references Employees
      on delete cascade);

create table Part_time_instructors (
  eid char(20) primary key references Part_time_Emp
      references Instructors
      on delete cascade);

create table Full_time_instructors (
  eid char(20) primary key references Full_time_Emp
      references Instructors
      on delete cascade);

create table Administrators (
  eid char(20) primary key references Full_time_Emp
      on delete cascade);

create table Managers (
  eid char(20) primary key references Full_time_Emp
      on delete cascade);

create table Pay_slips (
  payment_date date,
  eid char(20) references Employees
      on delete cascade,
  amount integer,
  num_work_hours numeric,
  num_work_days numeric,
  primary key(payment_date, eid));