-- Test 1
CALL declare_health(1, '2021-11-01', 38); -- successful, fever
DELETE FROM HealthDeclaration WHERE date >= '2021-11-01';


-- Test 2
CALL book_room (2, 3, '2021-11-13', 10, 11, 26);
CALL join_meeting (2, 3, '2021-11-13', 10, 11, 1);
CALL join_meeting (2, 3, '2021-11-13', 10, 11, 2);
CALL approve_meeting (2, 3, '2021-11-13', 10, 11, 2);
-- meeting booked with eid 26, 1, 2 on day D - 4

CALL book_room (2, 3, '2021-11-14', 10, 11, 26);
CALL join_meeting (2, 3, '2021-11-14', 10, 11, 1);
CALL join_meeting (2, 3, '2021-11-14', 10, 11, 3);
CALL approve_meeting (2, 3, '2021-11-14', 10, 11, 2);
-- meeting booked with eid 26, 1, 3 on day D - 3

CALL book_room (2, 3, '2021-11-17', 10, 11, 26);
CALL join_meeting (2, 3, '2021-11-17', 10, 11, 1);
CALL join_meeting (2, 3, '2021-11-17', 10, 11, 4);
CALL join_meeting (2, 3, '2021-11-17', 10, 11, 6);
CALL approve_meeting (2, 3, '2021-11-17', 10, 11, 2);
-- meeting booked with eid 26, 1, 4, 6 on day D

CALL book_room (2, 3, '2021-11-24', 10, 11, 33);
CALL join_meeting (2, 3, '2021-11-24', 10, 11, 1);
CALL join_meeting (2, 3, '2021-11-24', 10, 11, 2);
CALL join_meeting (2, 3, '2021-11-24', 10, 11, 3);
CALL join_meeting (2, 3, '2021-11-24', 10, 11, 4);
CALL join_meeting (2, 3, '2021-11-24', 10, 11, 5);
CALL join_meeting (2, 3, '2021-11-24', 10, 11, 6);
CALL approve_meeting (2, 3, '2021-11-24', 10, 11, 2);
-- meeting booked with eid 33, 1, 2, 3, 4, 5, 6 on day D + 7

CALL book_room (2, 3, '2021-11-25', 10, 11, 33);
CALL join_meeting (2, 3, '2021-11-25', 10, 11, 1);
CALL join_meeting (2, 3, '2021-11-25', 10, 11, 2);
CALL join_meeting (2, 3, '2021-11-25', 10, 11, 3);
CALL join_meeting (2, 3, '2021-11-25', 10, 11, 4);
CALL join_meeting (2, 3, '2021-11-25', 10, 11, 5);
CALL approve_meeting (2, 3, '2021-11-25', 10, 11, 2);
-- meeting booked with eid 33, 1, 2, 3, 4, 5 on day D + 8

SELECT * FROM Sessions WHERE date >= '2021-11-13';
SELECT * FROM Joins WHERE date >= '2021-11-13';
-- should have all meetings inserted above

SELECT * FROM contact_tracing(1, '2021-11-17');
-- close contacts should be 26, 1, 3, 4, 6

CALL declare_health(1, '2021-11-17', 39); -- day D
SELECT * FROM Joins WHERE date >= '2021-11-13';
-- day D - 4 remain unchanged
-- day D - 3 remain unchanged
-- day D all removed
-- day D + 7 left w/ 33, 2, 5
-- day D + 8 left w/ 33, 2, 3, 4, 5

-- clean up
CALL unbook_room (2, 3, '2021-11-13', 10, 11, 26);
CALL unbook_room (2, 3, '2021-11-14', 10, 11, 26);
CALL unbook_room (2, 3, '2021-11-17', 10, 11, 26);
CALL unbook_room (2, 3, '2021-11-24', 10, 11, 33);
CALL unbook_room (2, 3, '2021-11-25', 10, 11, 33);
DELETE FROM HealthDeclaration WHERE date = '2021-11-17';

-- check clean up
SELECT * FROM HealthDeclaration WHERE date >= '2021-11-13';
SELECT * FROM Sessions WHERE date >= '2021-11-13';
SELECT * FROM Joins WHERE date >= '2021-11-13';