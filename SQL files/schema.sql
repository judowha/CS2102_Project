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
  status            text);
  
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
   );



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


Create table Credit_cards(
  number INTEGER PRIMARY KEY,
  CVV INTEGER,
  expiry_date TEXT 
);

create Table Buys (
  buy_date date,
  cust_id CHAR(20),
  number INTEGER,
  package_id char(20), 
  num_remaining_redemptions INTEGER,
  FOREIGN key (cust_id) REFERENCES Customers on DELETe CASCADE on UPDATE CASCADE,
  FOREIGN key (number) REFERENCES Credit_cards on DELETe CASCADE on UPDATE CASCADE,
  FOREIGN key (package_id) REFERENCES Course_packegeson on DELETe CASCADE on UPDATE CASCADE,
  PRIMARY KEy (buy_date,cust_id, number, package_id)
);

create Table Redeems (
  redeem_date date,
  cust_id CHAR(20),
  number INTEGER,
  package_id char(20), 
  sid CHAR(20),
  FOREIGN key (cust_id) REFERENCES Customers on DELETe CASCADE on UPDATE CASCADE,
  FOREIGN key (number) REFERENCES Credit_cards on DELETe CASCADE on UPDATE CASCADE,
  FOREIGN key (package_id) REFERENCES Course_packegeson on DELETe CASCADE on UPDATE CASCADE,
  FOREIGN key (sid) REFERENCES Sessions on DELETe CASCADE on UPDATE CASCADE,
  PRIMARY KEy (cust_id, number, package_id)
);







