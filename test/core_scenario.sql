-- A meeting is booked at day D+4 by employee 33
-- Employee 1 is to join that meeting
-- Employee 4 is to join that meeting
-- Employee 3 is to join that meeting
-- Employee 2 approve this meeting (Manager)
-- However, employee 1 declare fever at day D
-- Expected result: he will be removed from the meeting at day D+4

CALL book_room (2, 3, '2021-11-20', 10, 12, 33);
CALL join_meeting (2, 3, '2021-11-20', 10, 12, 1);
CALL join_meeting (2, 3, '2021-11-20', 10, 12, 4);
CALL join_meeting (2, 3, '2021-11-20', 10, 12, 3);
CALL approve_meeting (2, 3, '2021-11-20', 10, 12, 2);
-- at this stage, meeting is booked successfully with participants 1, 3, 4, 33
SELECT * FROM Joins WHERE date = '2021-11-20';


CALL declare_health(1, '2021-11-18', 39);

--SELECT * FROM HealthDeclaration WHERE date = '2021-11-07';
--SELECT * FROM Sessions WHERE date = '2021-11-10';
SELECT * FROM Joins WHERE date = '2021-11-20';

DELETE FROM HealthDeclaration WHERE date >= '2021-11-05';
CALL unbook_room (2, 3, '2021-11-20', 10, 12, 33);
