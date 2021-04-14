create table Rooms (
  room_id		         char(20) primary key,
  location 		       text,
  seating_capacity   integer);

create table Specializes (
  eid     char(10) not NULL,
  name    char(20),
  primary key(eid, name),
  foreign key (name) references Course_areas on delete cascade,
  foreign key (eid)  references instructors  on delete cascade);

