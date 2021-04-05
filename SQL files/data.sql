insert into Employees
values (1, 'Wu Haitao', '12345678', 'wuhaitao@email.com', 'someWhere', '2021-1-1', null),
       (2, 'Bob', '11111110', 'Bob@email.com', 'someWhere', '2021-1-2', null),
       (3, 'Lucy', '11111101', 'Lucy@email.com', 'someWhere', '2021-1-3', null),
       (4, 'Fred', '11111011', 'Fred@email.com', 'someWhere', '2021-01-04', null),
       (5, 'Mark', '11110111', 'Mark@email.com', 'someWhere', '2021-4-1', null),
       (6, 'Anna', '11101111', 'Anna@email.com', 'someWhere', '2021-3-1', '2020-4-15'),
       (7, 'Jack', '11011111', 'Jack@email.com', 'someWhere', '2021-2-1', '2020-3-1'),
       (8, 'John', '10111111', 'John@email.com', 'someWhere', '2021-1-1', null);
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

insert into Courses
values ('CG2271', 'Real-Time Operating Systems', 'Nice course', 3, 'Computer Engineering'),
       ('CG2027', 'Transistor-level Digital Circuits', 'Nice course', 3, 'Computer Engineering'),
       ('CS2040', 'Data Structures and Algorithms', 'Nice course', 2, 'Computer Science'),
       ('CS3230', 'Design and Analysis of Algorithms', 'Bad course', 2, 'Computer Science'),
       ('CS2102', 'Database Systems', 'Bad course', 2, 'Data Science'),
       ('MKT1705', 'Principles of Marketing', 'None', 2, 'Business'),
       ('LL4306', 'Chinese Banking Law', 'None', 2, 'Law'),
       ('LL4320', 'International Space Law', 'None', 2, 'Law');

insert into Offerings
values ('2021-3-1', 'CS2102', 3200, 100, '2021-4-1', 120, '2021-4-20', '2021-5-20', 4),
       ('2021-5-1', 'CS2102', 3200, 100, '2021-6-1', 120, '2021-6-20', '2021-7-20', 4),
       ('2021-3-1', 'CG2271', 2000, 80, '2021-4-1', 120, '2021-4-20', '2021-5-20', 4),
       ('2021-5-1', 'CG2027', 3000, 100, '2021-6-1', 120, '2021-6-20', '2021-7-20', 4),
       ('2021-3-1', 'CS2040', 1800, 60, '2021-4-1', 80, '2021-4-20', '2021-5-20', 4),
       ('2021-3-1', 'CS3230', 2800, 120, '2021-4-1', 150, '2021-4-20', '2021-5-20', 4),
       ('2021-5-1', 'CS3230', 2800, 120, '2021-6-1', 150, '2021-6-20', '2021-7-20', 4),
       ('2021-3-1', 'MKT1705', 2400, 80, '2021-4-1', 120, '2021-4-20', '2021-5-20', 8),
       ('2021-5-1', 'LL4306', 5200, 50, '2021-6-1', 60, '2021-6-20', '2021-7-20', 8),
       ('2021-3-1', 'LL4320', 5200, 50, '2021-4-1', 60, '2021-4-20', '2021-5-20', 8);



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


