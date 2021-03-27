create table Courses (
  course_id     char(20) primary key,
  title         text unique,
  description   text,
  duration      integer);

create table Offerings (
  launch_date                   date primary key,
  fees                          double precision,
  target_number_registrations   integer,
  registration_deadline         timestamp,
  seating_capacity              integer,
  start_date                    date,
  end_date                      date,
  eid                           char(20) not null,
  foreign key(eid) references Administrators);
  
create table Course_packages (
  package_id                char(20) primary key,
  price                     double precision,
  num_free_registrations    integer,
  name                      text,
  sale_start_date           date,
  sale_end_date             date);
  
create table Customers (
  cust_id   char(20) primary key,
  name      char(30),
  phone     text,
  email     text,
  address   text);

create table Credit_cards (
  number        text primary key,
  expiry_date   date,
  CVV           integer);
  
create table Employees (
  eid           char(20) primary key,
  name          char(30),
  phone         text,
  email         text,
  address       text,
  join_date     date,
  depart_date   date);

create table Part_time_Emp (
  eid char(20) primary key,
  hourly_rate numeric,
  foreign key (eid) references Employees on delete cascade);

create table Full_time_Emp (
  eid char(20) primary key,
  monthly_salary numeric,
  foreign key (eid) references Employees on delete cascade);

create table Instructors (
  eid char(20) primary key,
  foreign key (eid) references Employees on delete cascade);

create table Part_time_instructors (
  eid char(20) primary key,
  foreign key (eid) references Instructors on delete cascade);

create table Full_time_instructors (
  eid char(20) primary key,
  foreign key (eid) references Instructors on delete cascade);

create table Administrators (
  eid char(20) primary key,
  foreign key (eid) references Full_time_Emp on delete cascade);

create table Managers (
  eid char(20) primary key,
  foreign key (eid) references Full_time_Emp on delete cascade);

create table Pay_slips (
  payment_date      date,
  eid               char(20),
  amount            integer,
  num_work_hours    numeric,
  num_work_days     numeric,
  foreign key (eid) references Employees on delete cascade,
  primary key(payment_date, eid));

create table Rooms (
  room_id		         char(20) primary key,
  location 		       text,
  seating_capacity   integer);

create table Sessions (

  session_id	char(20),
  date 		    text,
  start_time 	text,
  end_time	    text,
  launch_date   date,
  course_id     char(20),
  foreign key (launch_date) references Offerings on delete cascade,
  foreign key (course_id)   references Courses   on delete cascade,
  primary key (session_id, launch_date, course_id));

create table Course_areas (

  name      char(20) primary key
);

              
create table Buys (
  buy_date   		              date,
  cust_id    		              char(20),
  number     		              integer,
  package_id  		            char(20), 
  num_remaining_redemptions   integer,
  foreign key (cust_id)    references Customers       on delete cascade on update cascade,
  foreign key (number)     references Credit_cards    on delete cascade on update cascade,
  foreign key (package_id) references Course_packeges on delete cascade on update cascade,
  primary key (buy_date,cust_id, number, package_id));

create table Redeems (
  redeem_date   date,
  cust_id       char(20),
  number        integer,
  package_id    char(20), 
  sid           char(20),
  foreign key (cust_id)    references Customers       on delete cascade on update cascade,
  foreign key (number)     references Credit_cards    on delete cascade on update cascade,
  foreign key (package_id) references Course_packeges on delete cascade on update cascade,
  foreign key (sid)        references Sessions        on delete cascade on update cascade,
  primary key (cust_id, number, package_id));


create table Conducts (
  room_id       char(20),
  session_id    char(20),
  primary key(room_id, session_id),
  foreign key (room_id)    references Rooms    on delete cascade,
  foreign key (session_id) references Sessions on delete cascade);

create table Specializes (
  eid     char(20),
  name    char(20),
  primary key(eid, name),
  foreign key (name) references Course_areas on delete cascade,
  foreign key (eid)  references Employees    on delete cascade);

create table Cours_in (
  name          char(20),
  course_id     char(20),
  primary key(course_id, name),
  foreign key (name) references Course_areas on delete cascade,
  foreign key (course_id) references Courses on delete cascade
);

create table Registers(
  sid char(20),
  course_id char(20),
  launch_date date,
  cust_id char(20),
  number text,
  registers_date date,
  FOREIGN key (sid,launch_date,course_id) REFERENCES Sessions on delete CASCADE on UPDATE CASCADE,
  FOREIGN key (number)REFERENCES Credit_cards on delete CASCADE on UPDATE CASCADE,
  FOREIGN key (cust_id)REFERENCES Customers on delete CASCADE on UPDATE CASCADE,
  PRIMARY key (sid, course_id, launch_date,cust_id,number,registers_date)

);

create table Owns(
  number text,
  cust_id char(20) not null,
  from_date date,
  FOREIGN key (number)REFERENCES Credit_cards on delete CASCADE on UPDATE CASCADE,
  FOREIGN key (cust_id)REFERENCES Customers on delete CASCADE on UPDATE CASCADE,
  PRIMARY key (number)
);

create table Cancels(
  sid char(20),
  course_id char(20),
  launch_date date,
  cust_id char(20),
  cancels_date date,
  FOREIGN key (sid, course_id,launch_date) REFERENCES Sessions on DELETE CASCADE on UPDATE CASCADE,
  FOREIGN key (cust_id) REFERENCES Customers on DELETE CASCADE on UPDATE CASCADE,
  PRIMARY key (sid, course_id, launch_date, cust_id, cancels_date)
);

