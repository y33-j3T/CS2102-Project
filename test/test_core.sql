SELECT CURRENT_DATE;

-- Another new session at day D-3
CALL book_room (2, 3, '2021-10-26', 10, 14, 33);
CALL join_meeting (2, 3, '2021-10-26', 10, 14, 50);
CALL join_meeting (2, 3, '2021-10-26', 10, 14, 48);
CALL join_meeting (2, 3, '2021-10-26', 10, 14, 47);
CALL join_meeting (2, 3, '2021-10-26', 10, 14, 46);
--CALL join_meeting (2, 3, '2021-10-26', 10, 14, 45);
CALL join_meeting (2, 3, '2021-10-26', 10, 14, 1);
CALL approve_meeting (2, 3, '2021-10-26', 10, 14, 44);

-- New Session
CALL book_room (2, 3, '2021-10-30', 12, 13, 33);
--CALL join_meeting (2, 3, '2021-10-29', 12, 13, 33);
CALL join_meeting (2, 3, '2021-10-30', 12, 13, 1);
CALL join_meeting (2, 3, '2021-10-30', 12, 13, 2);
CALL join_meeting (2, 3, '2021-10-30', 12, 13, 3);
CALL join_meeting (2, 3, '2021-10-30', 12, 13, 4);
CALL join_meeting (2, 3, '2021-10-30', 12, 13, 15);
CALL approve_meeting (2, 3, '2021-10-30', 12, 13, 44);

-- declare_health test
CALL declare_health(1, '2021-10-29', 36.0); -- successful, non-fever
--CALL declare_health(1, '2021-10-29', 36.1); -- unsuccessful, violates key constraints
CALL declare_health(1, '2021-10-30', 38); -- successful, fever
--CALL declare_health(1, '2021-11-03', 47); -- unsuccessful, violates defined constraints
--CALL declare_health(1, '2021-11-03', 30); -- unsuccessful, violates defined constraints
CALL declare_health(2, '2021-10-29', 36.3);
CALL declare_health(2, '2021-10-30', 35.9);
CALL declare_health(3, '2021-10-29', 35.7);
CALL declare_health(4, '2021-10-30', 37.0);


--SELECT * FROM HealthDeclaration WHERE date > '2021-10-31';
--SELECT * FROM Sessions WHERE date = '2021-10-30';
SELECT * FROM Sessions WHERE date > '2021-10-26';
--SELECT * FROM Joins WHERE date = '2021-10-30';
SELECT * FROM Joins WHERE date > '2021-10-26';


SELECT * FROM contact_tracing (1);


-- delete data after test
-- DELETE FROM HealthDeclaration WHERE date = '2021-10-30' AND eid = 1;
DELETE FROM HealthDeclaration WHERE date > '2021-10-26';
call unbook_room (2, 3, '2021-10-26', 10, 14, 49);
call unbook_room (2, 3, '2021-10-30', 12, 13, 33);
-- SELECT * FROM Joins WHERE date = '2021-10-29';
