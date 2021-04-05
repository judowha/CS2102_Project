insert into Employees
values (1, 'Wu Haitao', '12345678', 'wuhaitao@email.com', 'someWhere', '2020-1-1', null),
       (2, 'Bob', '11111110', 'Bob@email.com', 'someWhere', '2020-1-2', null),
       (3, 'Lucy', '11111101', 'Lucy@email.com', 'someWhere', '2020-1-3', null),
       (4, 'Fred', '11111011', 'Fred@email.com', 'someWhere', '2020-01-04', null),
       (5, 'Mark', '11110111', 'Mark@email.com', 'someWhere', '2020-4-1', null),
       (6, 'Anna', '11101111', 'Anna@email.com', 'someWhere', '2020-3-1', '2020-4-15'),
       (7, 'Jack', '11011111', 'Jack@email.com', 'someWhere', '2020-2-1', '2020-3-1'),
       (8, 'John', '10111111', 'John@email.com', 'someWhere', '2020-1-1', null);
//先别删，测试用


--test for add_employees function
call add_employees ('Wu Haitao', '12345678', 'wuhaitao@email.com', 'someWhere', 
		'monthly: 4000','2020-1-1','instructor', array['math']);
		
call add_employees('Bob', '11111110', 'Bob@email.com', 'someWhere',
		'hourly: 40', '2020-1-2','instructor', array['math','computer']);
		
call add_employees('Lucy', '11111101', 'Lucy@email.com', 'someWhere', 
		'monthly: 3500','2020-1-3','manager', array['math']);
		
call add_employees('Fred', '11111011', 'Fred@email.com', 'someWhere', 
		'monthly: 3500','2020-1-3','administrator', null);

--truncate employees cascade;
-- test end

insert into Part_time_Emp
values (1, 30),
       (5, 25);

insert into Full_time_Emp
values (2, 1000),
       (3, 1500),
       (4, 2000),
       (6, 1800),
       (7, 1600),
       (8, 2100);

insert into Instructors
values (1),
       (2),
       (5),
       (6);

insert into Part_time_instructors
values (1),
       (5);

insert into Full_time_instructors
values (2),
       (6);

insert into Managers
values (3),
       (7);

insert into Administrators
values (4),
       (8);


insert into Course_areas
values ('Computer Engineering', 3),
       ('Computer Science', 3),
       ('Data Science', 3),
       ('Business', 7),
       ('Law', 7);

insert into Specializes
values (1, 'Computer Engineering'),
       (1, 'Computer Science'),
       (2, 'Computer Engineering'),
       (2, 'Data Science'),
       (5, 'Business'),
       (6, 'Law');

--test for remove_employees function
insert into course_id
values ('cs2101', 'data base', 'none',1);

insert into offerings
values ('2020-03-30', 'cs2101', 1200,100,'2020-04-02 12:00:00',100,'2020-04-20','2020-05-20','00001');
insert into sessions
values ('00001','2020-04-20','15:00:00','16:00:00','2020-03-30','cs2102');

--if the administrator leaves before the registration ddl
call add_employees('Fred', '11111011', 'Fred@email.com', 'someWhere', 
		'monthly: 3500','2020-1-3','administrator', null);
call remove_employees('00001','2020-04-01');

--if the instructors leaves before the start date of the session
insert into course_areas values ('math'),('computer');
call add_employees('Bob', '11111110', 'Bob@email.com', 'someWhere',
		'hourly: 40', '2020-1-2','instructor', array['math','computer']);
insert into rooms values ('A0002','.',20);
insert into conducts values ('A0002','00002','00001','2020-03-20','cs2101');

call remove_employees('00002','2020-04-18');

--test for add_customers function
call add_customers ('Bob','123456','test@test.com','somewhere',
				   '123456','2025-01-01','111');
--test for update_credit_card function
call update_credit_card('C00001','234567','2022-10-01','101');


