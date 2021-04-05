insert into Employees
values ('E00001', 'Wu Haitao', '12345678', 'wuhaitao@email.com', 'someWhere', '2021-1-1', null),
       ('E00002', 'Bob', '11111110', 'Bob@email.com', 'someWhere', '2021-1-2', null),
       ('E00003', 'Lucy', '11111101', 'Lucy@email.com', 'someWhere', '2021-1-3', null),
       ('E00004', 'Fred', '11111011', 'Fred@email.com', 'someWhere', '2021-01-04', null),
       ('E00005', 'Mark', '11110111', 'Mark@email.com', 'someWhere', '2021-4-1', null),
       ('E00006', 'Anna', '11101111', 'Anna@email.com', 'someWhere', '2021-3-1', '2020-4-15'),
       ('E00007', 'Jack', '11011111', 'Jack@email.com', 'someWhere', '2021-2-1', '2020-3-1'),
       ('E00008', 'John', '10111111', 'John@email.com', 'someWhere', '2021-1-1', null);


insert into Part_time_Emp
values ('E00001', 30),
       ('E00005', 25);

insert into Full_time_Emp
values ('E00002', 1000),
       ('E00003', 1500),
       ('E00004', 2000),
       ('E00006', 1800),
       ('E00007', 1600),
       ('E00008', 2100);

insert into Instructors
values ('E00001'),
       ('E00002'),
       ('E00005'),
       ('E00006');

insert into Part_time_instructors
values ('E00001'),
       ('E00005');

insert into Full_time_instructors
values ('E00002'),
       ('E00006');

insert into Managers
values ('E00003'),
       ('E00007');

insert into Administrators
values ('E00004'),
       ('E00008');


insert into Course_areas
values ('Computer Engineering', 'E00003'),
       ('Computer Science', 'E00003'),
       ('Data Science', 'E00003'),
       ('Business', 'E00007'),
       ('Law', 'E00007');

insert into Specializes
values ('E00001', 'Computer Engineering'),
       ('E00001', 'Computer Science'),
       ('E00002', 'Computer Engineering'),
       ('E00002', 'Data Science'),
       ('E00005', 'Business'),
       ('E00006', 'Law');

insert into Courses
values ('K00001', 'Real-Time Operating Systems', 'Nice course', 3, 'Computer Engineering'),
       ('K00002', 'Transistor-level Digital Circuits', 'Nice course', 3, 'Computer Engineering'),
       ('K00003', 'Data Structures and Algorithms', 'Nice course', 2, 'Computer Science'),
       ('K00004', 'Design and Analysis of Algorithms', 'Bad course', 2, 'Computer Science'),
       ('K00005', 'Database Systems', 'Bad course', 2, 'Data Science'),
       ('K00006', 'Principles of Marketing', 'None', 2, 'Business'),
       ('K00007', 'Chinese Banking Law', 'None', 2, 'Law'),
       ('K00008', 'International Space Law', 'None', 2, 'Law');

insert into Offerings
values ('2021-3-1', 'K00005', 3200, 100, '2021-4-1', 120, '2021-4-20', '2021-5-20', 4),
       ('2021-5-1', 'K00005', 3200, 100, '2021-6-1', 120, '2021-6-20', '2021-7-20', 4),
       ('2021-3-1', 'K00001', 2000, 80, '2021-4-1', 120, '2021-4-20', '2021-5-20', 4),
       ('2021-5-1', 'K00002', 3000, 100, '2021-6-1', 120, '2021-6-20', '2021-7-20', 4),
       ('2021-3-1', 'K00003', 1800, 60, '2021-4-1', 80, '2021-4-20', '2021-5-20', 4),
       ('2021-3-1', 'K00004', 2800, 120, '2021-4-1', 150, '2021-4-20', '2021-5-20', 4),
       ('2021-5-1', 'K00004', 2800, 120, '2021-6-1', 150, '2021-6-20', '2021-7-20', 4),
       ('2021-3-1', 'K00006', 2400, 80, '2021-4-1', 120, '2021-4-20', '2021-5-20', 8),
       ('2021-5-1', 'K00007', 5200, 50, '2021-6-1', 60, '2021-6-20', '2021-7-20', 8),
       ('2021-3-1', 'K00008', 5200, 50, '2021-4-1', 60, '2021-4-20', '2021-5-20', 8);


--test for add_employees function
insert into course_areas values ('math'),('computer');
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

--test for add_course
call add_course('data base', 'very hard','computer',30);

insert into offerings values ('2021-03-01', 'K00001', 2000, 100, '2021-02-10 12:00:00', 100, '2021-03-10','2021-05-10','E00005');
insert into rooms values ('R00001','somewhere',30);
insert into sessions values ('S00001','2021-04-04',9,10,'2021-03-01', 'K00001','R00001','E00004') ;


insert into Course_packages 
values	(1, 11.1, 11, 'package_one', '2021-01-01', '2021-01-11'),
	(2, 22.2, 22, 'package_two', '2021-02-02', '2021-02-22'),
	(3, 33.3, 33, 'package_one', '2021-03-03', '2021-03-31'),
	(4, 44.4, 44, 'package_four', '2021-04-04', '2021-04-14'),
	(5, 55.5, 55, 'package_five', '2021-05-05', '2021-05-15');

insert into Registers
values	(1, 11, '2021-01-01', 111, 1234567891234567, '2021-01-11'),
	(2, 22, '2021-02-02', 222, 2345678912345678, '2021-02-22'),	
	(3, 33, '2021-03-03', 333, 3456789123456789, '2021-03-31'),
	(4, 44, '2021-04-04', 444, 4567891234567891, '2021-04-14'),
	(5, 55, '2021-05-05', 555, 5678912345678912, '2021-05-15');
