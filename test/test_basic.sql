-- add_department, all successful
CALL add_department (51, 'HEaT');
CALL add_department (52, 'Security');
CALL add_department (53, 'Database');

SELECT * FROM Departments WHERE did >= 50;

-- add_room
CALL add_room (20, 40, 'A', 20, 51);
CALL add_room (30, 60, 'B', 10, 52);
CALL add_room (40, 80, 'C', 10, 53);

SELECT * FROM MeetingRooms WHERE did >= 51;


-- add_employee
CALL add_employee ('Hung', 981, 126, 450, 'junior', 51);
CALL add_employee ('Hieu', 981, 456, 789, 'senior', 52);
CALL add_employee ('YJ', 981, 654, 321, 'manager', 53);
CALL add_employee ('Adi', 567, 889, 654, 'manager', 52);
CALL add_employee ('Chris', 732, 123, 132, 'manager', 51);

SELECT * FROM Employees WHERE did >= 51;

-- change_capacity
-- the manager who changes the capacity of the room must be in the same department of the room
CALL change_capacity (20, 40, 15, 55); -- must not be successful
CALL change_capacity (30, 60, 5, 54); -- must not be successful
CALL change_capacity (40, 80, 999, 53); -- should be successful

SELECT * FROM Updates WHERE datetime >= '2021-10-30';


--DELETE FROM Employees WHERE did >= 50;

-- remove_department
-- current solution for employee in department to-be-deleted: update eid's did manually
-- current solution for room in department to-be-deleted: update room did manually
CALL remove_employee(51);
CALL remove_employee(52);
CALL remove_employee(50);
CALL remove_employee(53);
CALL remove_employee(54);

DELETE FROM Employees WHERE did >= 51;
DELETE FROM Updates WHERE room >= 20;
DELETE FROM MeetingRooms WHERE did >= 51;


CALL remove_department (51);
CALL remove_department (52);
CALL remove_department (53);


CALL add_employee ('Hieu', 981, 456, 789, 'senior', 1);
CALL remove_employee(51);
SELECT * FROM Employees WHERE ename = 'Hieu';
DELETE FROM Employees WHERE ename = 'Hieu';

