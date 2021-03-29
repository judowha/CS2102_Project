insert into Employees
values (1, 'Wu Haitao', '12345678', 'wuhaitao@email.com', 'someWhere', 2020-1-1, null),
       (2, 'Bob', '11111110', 'Bob@email.com', 'someWhere', 2020-1-2, null),
       (3, 'Lucy', '11111101', 'Lucy@email.com', 'someWhere', 2020-1-3, null),
       (4, 'Fred', '11111011', 'Fred@email.com', 'someWhere', '2020-01-04', null);
//先别删，测试用

call add_employees ('Wu Haitao', '12345678', 'wuhaitao@email.com', 'someWhere', 
		'monthly: 4000','2020-1-1','instructor', array['math']);
		
call add_employees('Bob', '11111110', 'Bob@email.com', 'someWhere',
		'hourly: 40', '2020-1-2','instructor', array['math','computer']);
		
call add_employees('Lucy', '11111101', 'Lucy@email.com', 'someWhere', 
		'monthly: 3500','2020-1-3','manager', array['math']);
		
call add_employees('Fred', '11111011', 'Fred@email.com', 'someWhere', 
		'monthly: 3500','2020-1-3','administrator', null);

insert into Part_time_Emp
values (1, 30);

insert into Full_time_Emp
values (2, 1000),
       (3, 1500),
       (4, 2000);

insert into Instructors
values (1),
       (2);

insert into Part_time_instructors
values (1);

insert into Full_time_instructors
values (2);

insert into Managers
values (3);

insert into Administrators
values (4);