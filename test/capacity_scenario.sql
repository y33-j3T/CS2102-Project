-- create a booking in the future (2 time slots)
-- add 4 employees to that meeting 
-- approve that meeting
-- update capacity of the meeting room to be 3
-- Expected result: that meeting should be removed

CALL add_employee ('Hung', 71829, 12893, 12093, 'junior', 1);
SELECT * FROM Employees WHERE ename = 'Hung';


CALL book_room (2, 3, '2021-11-13', 10, 12, 26);
CALL join_meeting (2, 3, '2021-11-13', 10, 12, 1);
CALL join_meeting (2, 3, '2021-11-13', 10, 12, 2);
CALL join_meeting (2, 3, '2021-11-13', 10, 12, 3);
CALL join_meeting (2, 3, '2021-11-13', 10, 12, 4);
CALL join_meeting (2, 3, '2021-11-13', 10, 12, 12);
--CALL join_meeting (2, 3, '2021-11-14', 10, 12, 12);

SELECT * FROM Joins WHERE date = '2021-11-13';

CALL leave_meeting (2, 3, '2021-11-13', 10, 12, 26);
--CALL join_meeting (2, 3, '2021-11-13', 10, 12, 51);
CALL approve_meeting (2, 3, '2021-11-13', 10, 12, 2); 

SELECT * FROM Sessions WHERE date = '2021-11-13';
SELECT * FROM Joins WHERE date = '2021-11-13';

-- change capacity at floor 2, room 3 to 5, by eid = 2
--CALL change_capacity (2, 3, 4, 2);

SELECT * FROM Sessions WHERE date = '2021-11-13';
SELECT * FROM Joins WHERE date = '2021-11-13';

-- CALL remove_employee (2);

-- -- booking is booked, but cannot approve
-- CALL book_room (2, 3, '2021-11-14', 10, 12, 26);
-- CALL join_meeting (2, 3, '2021-11-14', 10, 12, 1);
-- CALL join_meeting (2, 3, '2021-11-14', 10, 12, 3);
-- CALL join_meeting (2, 3, '2021-11-14', 10, 12, 4);
-- CALL join_meeting (2, 3, '2021-11-14', 10, 12, 12);
-- CALL approve_meeting (2, 3, '2021-11-14', 10, 12, 2);

-- SELECT * FROM Sessions WHERE date >= '2021-11-14';
-- SELECT * FROM Joins WHERE date >= '2021-11-14';

-- test cleanup
CALL change_capacity (2, 3, 10, 2);
DELETE FROM Employees WHERE ename = 'Hung';
-- UPDATE Employees SET resigned_date = NULL WHERE eid = 2;
CALL unbook_room (2, 3, '2021-11-13', 10, 12, 26);
-- CALL unbook_room (2, 3, '2021-11-14', 10, 12, 26);
