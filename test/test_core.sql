-- SELECT CURRENT_DATE;

-- Another new session at day D-3
CALL book_room (2, 3, '2021-11-04', 10, 14, 33);

-- CALL join_meeting (2, 3, '2021-11-01', 10, 14, 50);
CALL join_meeting (2, 3, '2021-11-04', 10, 14, 48);
CALL join_meeting (2, 3, '2021-11-04', 10, 14, 47);
CALL join_meeting (2, 3, '2021-11-04', 10, 14, 46);
--CALL join_meeting (2, 3, '2021-11-01', 10, 14, 45);
CALL join_meeting (2, 3, '2021-11-04', 10, 14, 1);

CALL approve_meeting (2, 3, '2021-11-04', 10, 14, 2);

-- New Session
-- CALL book_room (2, 3, '2021-10-30', 12, 13, 33);
--CALL join_meeting (2, 3, '2021-10-29', 12, 13, 33);
-- CALL join_meeting (2, 3, '2021-10-30', 12, 13, 1);
-- CALL join_meeting (2, 3, '2021-10-30', 12, 13, 2);
-- CALL join_meeting (2, 3, '2021-10-30', 12, 13, 3);
-- CALL join_meeting (2, 3, '2021-10-30', 12, 13, 4);
-- CALL join_meeting (2, 3, '2021-10-30', 12, 13, 15);
-- CALL approve_meeting (2, 3, '2021-10-30', 12, 13, 44);

-- declare_health test
CALL declare_health(1, '2021-11-03', 36.0); -- successful, non-fever
--CALL declare_health(1, '2021-10-29', 36.1); -- unsuccessful, violates key constraints
CALL declare_health(1, '2021-11-04', 38); -- successful, fever
--CALL declare_health(1, '2021-11-03', 47); -- unsuccessful, violates defined constraints
--CALL declare_health(1, '2021-11-03', 30); -- unsuccessful, violates defined constraints
CALL declare_health(2, '2021-11-03', 36.3);
CALL declare_health(2, '2021-11-04', 35.9);
CALL declare_health(3, '2021-11-03', 35.7);
CALL declare_health(4, '2021-11-03', 37.0);


SELECT * FROM HealthDeclaration WHERE date >= '2021-11-01';
--SELECT * FROM Sessions WHERE date = '2021-10-30';
SELECT * FROM Sessions WHERE date >= CURRENT_DATE;
--SELECT * FROM Joins WHERE date = '2021-10-30';
SELECT * FROM Joins WHERE date >= CURRENT_DATE;


SELECT * FROM contact_tracing (1);


-- delete data after test
DELETE FROM HealthDeclaration WHERE date >= '2021-11-01';
-- DELETE FROM HealthDeclaration WHERE date >= CURRENT_DATE;
CALL unbook_room (2, 3, '2021-11-04', 10, 14, 33);
--CALL unbook_room (2, 3, '2021-10-30', 12, 13, 33);
-- SELECT * FROM Joins WHERE date = '2021-10-29';


---------------------------
-- Test exceed capacity  --
---------------------------
CALL book_room (2, 3, '2021-11-13', 10, 11, 26);
CALL join_meeting (2, 3, '2021-11-13', 10, 11, 1);
CALL join_meeting (2, 3, '2021-11-13', 10, 11, 2);
CALL join_meeting (2, 3, '2021-11-13', 10, 11, 3);
CALL join_meeting (2, 3, '2021-11-13', 10, 11, 4);
CALL join_meeting (2, 3, '2021-11-13', 10, 11, 5);
CALL join_meeting (2, 3, '2021-11-13', 10, 11, 6);
CALL join_meeting (2, 3, '2021-11-13', 10, 11, 7);
CALL join_meeting (2, 3, '2021-11-13', 10, 11, 8);
CALL join_meeting (2, 3, '2021-11-13', 10, 11, 9);
CALL join_meeting (2, 3, '2021-11-13', 10, 11, 10);  -- exceed capacity 10
CALL join_meeting (2, 3, '2021-11-13', 10, 11, 11);  -- exceed capacity 10
CALL join_meeting (2, 3, '2021-11-13', 10, 11, 12);  -- exceed capacity 10

select * from joins where date = '2021-11-13';
-- should have 1 to 9 and 26

-- clean up
CALL unbook_room (2, 3, '2021-11-13', 10, 11, 26);

-- check clean up
select * from joins where date = '2021-11-13';