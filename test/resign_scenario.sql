-- a meeting is booked at a day in the future
-- employee 50 joins the meeting with other employees
-- the meeting is approve
-- employee 50 resigned
-- Expected result: employee 50 no longer in the meeting - correct
-- Possible scenarios to consider: 
--      employee 2 is a manager approve that meeting - the meeting is completely deleted
--      employee 26 is a booker of that meeting - the meeting is completely deleted


-- SCENARIO 1: the employee is only the participant of the booking
-- Expected result: the employee is removed from the booking

CALL book_room (2, 3, '2021-11-13', 10, 12, 26);
CALL join_meeting (2, 3, '2021-11-13', 10, 12, 1);
CALL join_meeting (2, 3, '2021-11-13', 10, 12, 2);
CALL join_meeting (2, 3, '2021-11-13', 10, 12, 50);
CALL approve_meeting (2, 3, '2021-11-13', 10, 12, 2);

CALL book_room (2, 3, '2021-11-14', 10, 12, 26);
CALL join_meeting (2, 3, '2021-11-14', 10, 12, 1);
CALL join_meeting (2, 3, '2021-11-14', 10, 12, 2);
CALL join_meeting (2, 3, '2021-11-14', 10, 12, 50);
CALL approve_meeting (2, 3, '2021-11-14', 10, 12, 2);

SELECT * FROM Sessions WHERE date >= '2021-11-13';
SELECT * FROM Joins WHERE date >= '2021-11-13';

CALL remove_employee (50);

SELECT * FROM Employees WHERE eid = 50;
SELECT * FROM Sessions WHERE date >= '2021-11-13';
SELECT * FROM Joins WHERE date >= '2021-11-13';


UPDATE Employees SET resigned_date = NULL WHERE eid = 50;
CALL unbook_room (2, 3, '2021-11-13', 10, 12, 26);
CALL unbook_room (2, 3, '2021-11-14', 10, 12, 26);


-- SCENARIO 2: 26 is the booker resigned
-- Expected result: the booking is removed

-- CALL book_room (2, 3, '2021-11-13', 10, 12, 26);
-- CALL join_meeting (2, 3, '2021-11-13', 10, 12, 1);
-- CALL join_meeting (2, 3, '2021-11-13', 10, 12, 2);
-- CALL join_meeting (2, 3, '2021-11-13', 10, 12, 50);
-- CALL approve_meeting (2, 3, '2021-11-13', 10, 12, 2);

-- SELECT * FROM Sessions WHERE date = '2021-11-13';
-- SELECT * FROM Joins WHERE date = '2021-11-13';

-- CALL remove_employee (26);

-- SELECT * FROM Employees WHERE eid = 26;
-- SELECT * FROM Sessions WHERE date = '2021-11-13';
-- SELECT * FROM Joins WHERE date = '2021-11-13';


-- UPDATE Employees SET resigned_date = NULL WHERE eid = 26;
-- CALL unbook_room (2, 3, '2021-11-13', 10, 12, 26);

-- SCENARIO 3: 2 is the manager resigned
-- Expected result: the booking is removed
-- IF THE MANAGER APPROVING A FUTURE BOOKING RESIGNS, THAT MEETING IS LEFT UNAPPROVED

-- CALL book_room (2, 3, '2021-11-13', 10, 12, 26);
-- CALL join_meeting (2, 3, '2021-11-13', 10, 12, 1);
-- CALL join_meeting (2, 3, '2021-11-13', 10, 12, 2);
-- CALL join_meeting (2, 3, '2021-11-13', 10, 12, 50);
-- CALL approve_meeting (2, 3, '2021-11-13', 10, 12, 2);

-- SELECT * FROM Sessions WHERE date = '2021-11-13';
-- SELECT * FROM Joins WHERE date = '2021-11-13';

-- CALL remove_employee (2);

-- SELECT * FROM Employees WHERE eid = 2;
-- SELECT * FROM Sessions WHERE date = '2021-11-13';
-- SELECT * FROM Joins WHERE date = '2021-11-13';


-- UPDATE Employees SET resigned_date = NULL WHERE eid = 2;
-- CALL unbook_room (2, 3, '2021-11-13', 10, 12, 26);

