-- non_compliance
SELECT * from non_compliance ('2021-01-01', '2021-01-01') ORDER BY num_date DESC, eid;
select eid,  count(*) from healthdeclaration where date >= '2021-01-01' and date <= '2021-01-01' group by eid order by count, eid;

-- view_booking_report
-- 2nd test case shows that one of the date return is BEFORE given start date
SELECT * from view_booking_report ('2021-01-01', 1);
select floor, room, date, time, eid_manager from sessions where eid_booker = 1 and date >= '2021-01-01' order by date, time;

SELECT * from view_booking_report ('2021-01-01', 33);
select floor, room, date, time, eid_manager from sessions where eid_booker = 33 and date >= '2021-01-01' order by date, time;

-- view_future_meeting
SELECT * from view_future_meeting ('2021-01-01', 1);
select s.floor, s.room, s.date, s.time from sessions s, joins j where s.date >= '2021-01-01' and s.eid_manager is not NULL and s.date = j.date and s.time = j.time and s. room = j.room and s.floor = j.floor and j.eid = 1 order by date, time;


-- view_manager_report
-- `view_manager_report` different from check
SELECT * FROM view_manager_report ('2021-01-01', 4);  -- not manager, should return empty table
SELECT * FROM view_manager_report ('2021-01-01', 34);  -- return session w/ same department as manager, booked but not approved
select s.floor, s.room, s.date, s.time, s.eid_booker
from sessions s, meetingrooms mr
where s.floor = mr.floor
and s.room = mr.room
and s.date >= '2021-01-01'
and s.eid_manager is null
and mr.did = (select did from employees e where e.eid = 34)
order by s.date, s.time;



-- Test data
-- Add Sessions
-- INSERT INTO Sessions VALUES ('2021-01-05', 19, 2, 3, 33, 44);
-- INSERT INTO Sessions VALUES ('2021-01-05', 20, 2, 3, 33, 44);

-- INSERT INTO Sessions VALUES ('2021-01-05', 22, 2, 3, 33, 44);
-- INSERT INTO Sessions VALUES ('2021-01-05', 23, 2, 3, 33, 44);

-- Add Joins
-- INSERT INTO Joins VALUES (33, '2021-01-05', 19, 2, 3);
-- INSERT INTO Joins VALUES (1, '2021-01-05', 19, 2, 3);
-- INSERT INTO Joins VALUES (3, '2021-01-05', 19, 2, 3);
-- INSERT INTO Joins VALUES (36, '2021-01-05', 19, 2, 3);
-- INSERT INTO Joins VALUES (8, '2021-01-05', 19, 2, 3);
-- INSERT INTO Joins VALUES (47, '2021-01-05', 19, 2, 3);
-- INSERT INTO Joins VALUES (17, '2021-01-05', 19, 2, 3);
-- INSERT INTO Joins VALUES (19, '2021-01-05', 19, 2, 3);
-- INSERT INTO Joins VALUES (20, '2021-01-05', 19, 2, 3);
-- INSERT INTO Joins VALUES (29, '2021-01-05', 19, 2, 3);

-- INSERT INTO Joins VALUES (33, '2021-01-05', 20, 2, 3);
-- INSERT INTO Joins VALUES (1, '2021-01-05', 20, 2, 3);
-- INSERT INTO Joins VALUES (3, '2021-01-05', 20, 2, 3);
-- INSERT INTO Joins VALUES (36, '2021-01-05', 20, 2, 3);
-- INSERT INTO Joins VALUES (8, '2021-01-05', 20, 2, 3);
-- INSERT INTO Joins VALUES (47, '2021-01-05', 20, 2, 3);
-- INSERT INTO Joins VALUES (17, '2021-01-05', 20, 2, 3);
-- INSERT INTO Joins VALUES (19, '2021-01-05', 20, 2, 3);
-- INSERT INTO Joins VALUES (20, '2021-01-05', 20, 2, 3);
-- INSERT INTO Joins VALUES (29, '2021-01-05', 20, 2, 3);

-- INSERT INTO Joins VALUES (33, '2021-01-05', 22, 2, 3);
-- INSERT INTO Joins VALUES (1, '2021-01-05', 22, 2, 3);
-- INSERT INTO Joins VALUES (3, '2021-01-05', 22, 2, 3);
-- INSERT INTO Joins VALUES (36, '2021-01-05', 22, 2, 3);
-- INSERT INTO Joins VALUES (8, '2021-01-05', 22, 2, 3);
-- INSERT INTO Joins VALUES (47, '2021-01-05', 22, 2, 3);
-- INSERT INTO Joins VALUES (17, '2021-01-05', 22, 2, 3);
-- INSERT INTO Joins VALUES (19, '2021-01-05', 22, 2, 3);
-- INSERT INTO Joins VALUES (20, '2021-01-05', 22, 2, 3);
-- INSERT INTO Joins VALUES (29, '2021-01-05', 22, 2, 3);

-- INSERT INTO Joins VALUES (33, '2021-01-05', 23, 2, 3);
-- INSERT INTO Joins VALUES (1, '2021-01-05', 23, 2, 3);
-- INSERT INTO Joins VALUES (3, '2021-01-05', 23, 2, 3);
-- INSERT INTO Joins VALUES (36, '2021-01-05', 23, 2, 3);
-- INSERT INTO Joins VALUES (8, '2021-01-05', 23, 2, 3);
-- INSERT INTO Joins VALUES (47, '2021-01-05', 23, 2, 3);
-- INSERT INTO Joins VALUES (17, '2021-01-05', 23, 2, 3);
-- INSERT INTO Joins VALUES (19, '2021-01-05', 23, 2, 3);
-- INSERT INTO Joins VALUES (20, '2021-01-05', 23, 2, 3);
-- INSERT INTO Joins VALUES (29, '2021-01-05', 23, 2, 3);

-- CALL unbook_room (2, 3, '2021-01-05', 19, 23, 33);

