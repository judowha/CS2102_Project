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
	   
insert into customers
values ('C00001','Chen Jiqing','12345678','jiqing@email.com','pgpr blk 20'),
	('C00002', 'Dony','23456789','dony@email.com', 'someWhere'),
	('C00003', 'Peter', '34567890', 'peter@email.com', 'someWhere'),
	('C00004', 'Tissue', '45678901', 'Tissue@email.com', 'someWhere'),
	('C00005', 'Dasiy', '56789012', 'Dasiy@email.com','someWhere');
		
insert into credit_cards
values 	(1234567890123456,'C00001','2021-01-01','2022-01-01',111),
	(2345678901234567,'C00002','2020-03-06','2023-02-24',101),
	(3456789012345678,'C00003','2020-11-02','2021-07-13',201),
	(4567890123456789,'C00004','2021-03-23','2021-04-12',311),
	(5678901234567890,'C00005','2019-10-03','2022-05-05'.821);
		



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
values	('P00001', 11.1, 11, 'package_one', '2021-01-01', '2021-01-03'),
	('P00002', 22.2, 22, 'package_two', '2021-01-02', '2021-01-04'),
	('P00003', 33.3, 33, 'package_three', '2021-01-03', '2021-01-05'),
	('P00004', 44.4, 44, 'package_four', '2021-01-04', '2021-01-06'),
	('P00005', 55.5, 55, 'package_five', '2021-01-05', '2021-01-07');
	('P00006', 66.6, 66, 'package_six', '2021-01-06', '2021-01-08');
	('P00007', 77.7, 77, 'package_seven', '2021-01-07', '2021-01-09');
	('P00008', 88.8, 88, 'package_eight', '2021-01-08', '2021-01-10');
	('P00009', 99.9, 99, 'package_nine', '2021-01-09', '2021-01-11');
	('P00010', 1010.1, 1010, 'package_ten', '2021-01-10', '2021-01-12');


insert into Registers
values	('S00001', 'K00001', '2021-01-01', 'C00001', 1234567891234567, '2021-01-02'),
	('S00002', 'K00002', '2021-01-02', 'C00002', 2345678912345678, '2021-01-03'),	
	('S00003', 'K00003', '2021-01-03', 'C00003', 3456789123456789, '2021-01-04'),
	('S00004', 'K00004', '2021-01-04', 'C00004', 4567891234567891, '2021-01-05'),
	('S00005', 'K00005', '2021-01-05', 'C00005', 5678912345678912, '2021-01-06'),
	('S00006', 'K00006', '2021-01-06', 'C00006', 5678912345678912, '2021-01-07'),
	('S00007', 'K00007', '2021-01-07', 'C00007', 5678912345678912, '2021-01-08'),
	('S00008', 'K00008', '2021-01-08', 'C00008', 5678912345678912, '2021-01-09'),
	('S00009', 'K00009', '2021-01-09', 'C00009', 5678912345678912, '2021-01-10'),
	('S00010', 'K00010', '2021-01-10', 'C00010', 5678912345678912, '2021-01-11'),


insert into Redeems
values 	('2021-01-01', 'C00001', 1234567890123456, 'P00001', 'S00001', '2021-01-01', 'K00001'),
	('2021-01-03', 'C00002', 2345678901234567, 'P00002', 'S00002', '2021-01-02', 'K00002');

insert into Sessions
values 	('S00001', "2021-02-01", 9, 12, '2021-01-01', 'K00001', 'R001', 'E00001'),
	('S00002', "2021-02-01", 14, 16, '2021-01-02', 'K00002', 'R002', 'E00002');

insert into Rooms
values ('R001', 'UTown', 50),
('R002', 'UTown', 50),
('R003', 'UTown', 30),
('R004', 'FoE', 50),
('R005', 'FoE', 30),
('R006', 'SoC', 100),
('R007', 'Soc', 50);
