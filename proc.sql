-- proc.sql

-- check.sql
CREATE OR REPLACE FUNCTION is_manager(eid_to_check INTEGER)
    RETURNS BOOLEAN AS
$$
DECLARE
    is_in BOOLEAN;
BEGIN
    is_in := EXISTS(SELECT 1 FROM Manager M WHERE eid_to_check = M.eid);
    RETURN is_in;
end;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION is_booker(eid_to_check INTEGER)
    RETURNS BOOLEAN AS
$$
DECLARE
    is_in BOOLEAN;
BEGIN
    is_in := EXISTS(SELECT 1 FROM Booker B WHERE eid_to_check = B.eid);
    RETURN is_in;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION is_having_fever(eid_to_check INTEGER)
    RETURNS BOOLEAN AS
$$
DECLARE
    is_having_fever BOOLEAN;
BEGIN
    is_having_fever :=
            (SELECT fever FROM healthdeclaration HD WHERE HD.eid = eid_to_check ORDER BY HD.date DESC LIMIT 1);
    RETURN is_having_fever;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION is_resigned(eid_to_check INTEGER)
    RETURNS BOOLEAN AS
$$
DECLARE
    is_resigned BOOLEAN;
BEGIN
    is_resigned := (SELECT resigned_date FROM employees E WHERE E.eid = eid_to_check) IS NOT NULL;
    RETURN is_resigned;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION is_same_department(eid1 INT, eid2 INT)
    RETURNS BOOLEAN AS
$$
DECLARE
    is_same BOOLEAN;
BEGIN
    is_same := (SELECT did FROM employees E WHERE E.eid = eid1)
        = (SELECT did FROM employees E WHERE E.eid = eid2);
    RETURN is_same;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION is_same_department_as_meeting_room(eid INT, floor INT, room INT)
    RETURNS BOOLEAN AS
$$
DECLARE
    is_same BOOLEAN;
BEGIN
    is_same := (SELECT did FROM employees E WHERE E.eid = is_same_department_as_meeting_room.eid)
        = (SELECT did
           FROM meetingrooms M
           WHERE M.floor = is_same_department_as_meeting_room.floor
             AND M.room = is_same_department_as_meeting_room.room);
    RETURN is_same;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION is_meeting_approved(floor INT, room INT, stime INT, date DATE)
    RETURNS BOOLEAN AS
$$
DECLARE
    is_approved BOOLEAN;
BEGIN
    is_approved := (SELECT S.eid_manager
                    FROM sessions S
                    WHERE S.date = is_meeting_approved.date
                      AND S.room = is_meeting_approved.room
                      AND S.floor = is_meeting_approved.floor
                      AND S.time = is_meeting_approved.stime) IS NOT NULL;
    RETURN is_approved;
end;
$$ LANGUAGE plpgsql;

--Check if the meeting session is under the max capacity
CREATE OR REPLACE FUNCTION is_under_max_capacity(floor INT, room INT, stime INT, date DATE)
    RETURNS BOOLEAN AS
$$
DECLARE
    num_participants     INTEGER;
    most_recent_capacity INTEGER;
    is_under             BOOLEAN;
BEGIN
    num_participants := (SELECT count(*)
                         FROM Joins J
                         WHERE J.date = is_under_max_capacity.date
                           AND J.room = is_under_max_capacity.room
                           AND J.floor = is_under_max_capacity.floor
                           AND J.time = is_under_max_capacity.stime);
    most_recent_capacity := (SELECT new_cap
                             FROM Updates U
                             WHERE date(U.datetime) <= is_under_max_capacity.date
                               AND U.floor = is_under_max_capacity.floor
                               AND U.room = is_under_max_capacity.room
                             ORDER BY U.datetime DESC
                             LIMIT 1);
    is_under := (num_participants < most_recent_capacity);
    RETURN is_under;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION is_meeting_exist(floor INT, room INT, stime INT, date DATE)
    RETURNS BOOLEAN AS
$$
DECLARE
    is_there BOOLEAN;
BEGIN
    is_there := EXISTS(SELECT 1
                    FROM sessions S
                    WHERE S.date = is_meeting_exist.date
                      AND S.room = is_meeting_exist.room
                      AND S.floor = is_meeting_exist.floor
                      AND S.time = is_meeting_exist.stime);
    RETURN is_there;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION is_future_meeting (date DATE)
    RETURNS BOOLEAN AS
$$
DECLARE
    is_future BOOLEAN;
BEGIN
    is_future := date > CURRENT_DATE;
    RETURN is_future;
end;
$$ LANGUAGE plpgsql;


--*************************************************************************
-- basic.sql
-- DROP PROCEDURE IF EXISTS add_department, remove_department,
--                           add_room, change_capacity,
--                           add_employee, remove_employee
-- CASCADE;

CREATE OR REPLACE PROCEDURE add_department(department_id INTEGER, department_name VARCHAR(50))
AS
$$
BEGIN
    INSERT INTO Departments(did, dname)
    VALUES (department_id, department_name);
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE PROCEDURE remove_department(department_id INTEGER)
AS
$$
BEGIN
    DELETE
    FROM Departments
    WHERE did = department_id;
END;
$$ LANGUAGE 'plpgsql';
CREATE OR REPLACE PROCEDURE add_room(floor_number INTEGER,
                                     room_number INTEGER,
                                     room_name VARCHAR(50),
                                     room_capacity INTEGER,
                                     department_id INTEGER)
AS
$$
BEGIN
    INSERT INTO MeetingRooms(room, floor, did, rname)
    VALUES (room_number, floor_number, department_id, room_name);
    INSERT INTO Updates(room, floor, datetime, eid, new_cap)
    VALUES (room_number, floor_number, current_timestamp, null, room_capacity);
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE PROCEDURE change_capacity(floor_number    INTEGER, 
                                        room_number     INTEGER,
                                        room_capacity   INTEGER,
                                        eid             INTEGER,
                                        datetime_input  TIMESTAMP DEFAULT current_timestamp)
  AS $$
    DECLARE
        can_approve BOOLEAN;
    BEGIN
    can_approve := is_manager(eid)
        AND (not is_resigned(eid))
        AND is_same_department_as_meeting_room(eid, floor_number, room_number);

    IF datetime_input < current_timestamp THEN 
        RAISE EXCEPTION 'changing capacity in the past is nonsense';
    END IF;

    IF NOT can_approve THEN RAISE EXCEPTION 'This employee cannot change capacity of this room';
    END IF;

    INSERT INTO Updates(room, floor, datetime, eid, new_cap)
    VALUES(room_number, floor_number, datetime_input, eid, room_capacity);
    END;
  $$ LANGUAGE 'plpgsql';

  CREATE OR REPLACE PROCEDURE add_employee(ename VARCHAR(50),
                                         home_number INTEGER,
                                         mobile_number INTEGER,
                                         office_number INTEGER,
                                         role VARCHAR(50),
                                         department_id INTEGER)
AS
$$
DECLARE
    eid           INTEGER;
    email         TEXT;
    random_number INTEGER;
BEGIN
    IF (SELECT MAX(employees.eid) + 1 from employees) IS NULL THEN
        eid := 1;
    ELSE
        eid := (SELECT MAX(employees.eid) + 1 from employees);
    END IF;
    random_number := (floor(1000 + random() * 8999));
    email := CONCAT(ename, random_number, '@gmail.com');

    INSERT INTO Employees(eid, ename, email, home_number, mobile_number, office_number, resigned_date, did)
    VALUES (eid, ename, email, home_number, mobile_number, office_number, null, department_id);
    IF role = 'senior' THEN
        INSERT INTO Booker(eid)
        VALUES (eid);
    ELSIF role = 'manager' THEN
        INSERT INTO Booker(eid)
        VALUES (eid);
        INSERT INTO Manager(eid)
        VALUES (eid);
    END IF;

END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE PROCEDURE remove_employee(employee_id INTEGER,
                                            date DATE DEFAULT current_date)
AS
$$
BEGIN
    IF date > current_date THEN
        RAISE EXCEPTION 'input date > current date';
    END IF;

    UPDATE Employees
    SET resigned_date = date
    WHERE employee_id = eid;
END;
$$ LANGUAGE 'plpgsql';


--*************************************************************************
-- core.sql
-- hours larger than 1 hour and must be available
-- ascending order of capacity
CREATE OR REPLACE FUNCTION search_room(search_capacity INT, search_date DATE, start_time INT, end_time INT)
    RETURNS TABLE
            (
                floor    INT,
                room     INT,
                did      INT,
                capacity INT
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT M.floor, M.room, M.did, U.new_cap
        FROM Updates U
                 JOIN MeetingRooms M
                      ON U.room = M.room AND U.floor = M.floor
             -- capacity check for the most recent update before that date
        WHERE search_capacity <= (SELECT U2.new_cap
                                  FROM Updates U2
                                  WHERE date(U2.datetime) <= search_date
                                    AND U2.floor = M.floor
                                    AND U2.room = M.room
                                  ORDER BY U2.datetime DESC
                                  LIMIT 1)
          AND U.datetime = (SELECT U3.datetime
                            FROM Updates U3
                            WHERE date(U3.datetime) <= search_date
                              AND U3.floor = M.floor
                              AND U3.room = M.room
                            ORDER BY U3.datetime DESC
                            LIMIT 1)
          -- Not any slot in the period is taken
          AND NOT EXISTS(SELECT 1
                         FROM sessions S
                         where S.floor = M.floor
                           and S.room = M.room
                           and S.date = search_date
                           and S.time >= start_time
                           and S.time < end_time)
        ORDER BY U.new_cap, M.floor, M.room;
END;
$$ LANGUAGE plpgsql;


-- eid of the employee booking the room
-- assume that can book multiple 1 hour slot
-- to consider : allow booking at odd time like 10:30
CREATE OR REPLACE PROCEDURE book_room(book_floor INT, book_room INT, book_date DATE, start_time INT, end_time INT,
                                      eid_booker INT)
AS
$$
declare
    sessions_not_available int;
    curr_time              int;
BEGIN
    sessions_not_available := (SELECT count(*)
                               FROM sessions S
                               WHERE S.date = book_date
                                 AND S.room = book_room
                                 AND S.floor = book_floor
                                 AND (S.time >= start_time AND S.time < end_time));

    curr_time = start_time;
    if sessions_not_available = 0 and end_time < 24
        and is_booker(eid_booker)
        and not is_resigned(eid_booker)
        and not is_having_fever(eid_booker)
        and is_future_meeting(book_date) then
        while curr_time < end_time
            loop
                INSERT INTO sessions(date, time, room, floor, eid_booker)
                VALUES (book_date, curr_time, book_room, book_floor, eid_booker);
                INSERT INTO joins(eid, date, time, room, floor)
                VALUES (eid_booker, book_date, curr_time, book_room, book_floor);
                curr_time := curr_time + 1;
            end loop;
    else
        RAISE NOTICE 'This booking cannot be completed';
    end if;
END;
$$ language plpgsql;


-- un-book all session in the period with the correct booker eid (allow not continuous)
CREATE OR REPLACE PROCEDURE unbook_room(floor INT, room INT, date DATE, start_time INT, end_time INT,
                                        eid_booker INT)
AS
$$
declare
    curr_time int;
begin
    -- check if end_time is correct
    if (is_future_meeting(unbook_room.date)) then
        curr_time := start_time;
        while curr_time < end_time
            loop
                delete
                from sessions S
                where S.eid_booker = unbook_room.eid_booker
                  and S.time = curr_time
                  and S.date = unbook_room.date
                  and S.floor = unbook_room.floor
                  and S.room = unbook_room.room;
                curr_time := curr_time + 1;
            end loop;
    end if;
end;
$$ language plpgsql;

-- allow join all session in the meeting room during the period ( not allow if cannot join all ,i.e not continuous)
-- if approved cannot join and abort
CREATE OR REPLACE PROCEDURE join_meeting(floor INT, room INT, date DATE, start_time INT, end_time INT, eid INT)
AS
$$
declare
    curr_time        int;
    sessions_existed int;
    can_join_meeting boolean;
    join_date        date := join_meeting.date;
    join_eid         int  := join_meeting.eid;
    join_floor       int  := join_meeting.floor;
    join_room        int  := join_meeting.room;
begin
    curr_time := start_time;
    sessions_existed := (SELECT count(*)
                         FROM sessions S
                         WHERE S.date = join_date
                           AND S.room = join_room
                           AND S.floor = join_floor
                           AND (S.time >= start_time AND S.time < end_time));
    if sessions_existed = end_time - start_time
        and not is_having_fever(join_eid)
        and not is_resigned(join_eid) then
        while curr_time < end_time
            loop
                can_join_meeting := is_meeting_exist(join_floor, join_room, curr_time, join_date)
                    and not is_meeting_approved(join_floor, join_room, curr_time, join_date)
                    and is_under_max_capacity(join_floor, join_room, curr_time, join_date)
                    and is_future_meeting(join_date);
                if can_join_meeting then
                    INSERT INTO joins(eid, date, time, room, floor)
                    VALUES (join_eid, join_date, curr_time, join_room, join_floor);
                else
                    RAISE NOTICE 'This employee cannot join session % to %', curr_time, curr_time + 1;
                end if;
                curr_time := curr_time + 1;
            end loop;
    else
        RAISE NOTICE 'This employee cannot join this session';
    end if;
end;
$$ LANGUAGE plpgsql;

-- remove employee from all meeting session ( allow not continuous)
CREATE OR REPLACE PROCEDURE leave_meeting(floor INT, room INT, date DATE, start_time INT, end_time INT, eid INT)
AS
$$
declare
    curr_time         int;
    can_leave_meeting boolean;
begin
    curr_time := start_time;
    while curr_time < end_time
        loop
            can_leave_meeting :=
                        not is_meeting_approved(leave_meeting.floor, leave_meeting.room, curr_time,
                                                 leave_meeting.date)
                        and is_future_meeting(leave_meeting.date)
                        -- if booker, not allow to leave
                        and not leave_meeting.eid = (SELECT eid_booker FROM sessions S WHERE S.floor = leave_meeting.floor
                            and S.room = leave_meeting.room and S.date = leave_meeting.date and S.time = curr_time);
            if can_leave_meeting then
                delete
                from joins J
                where J.floor = leave_meeting.floor
                  and J.room = leave_meeting.room
                  and J.date = leave_meeting.date
                  and J.eid = leave_meeting.eid
                  and J.time = curr_time;
            else
                RAISE NOTICE 'This employee cannot leave this session';
            end if;

            curr_time := curr_time + 1;
        end loop;
end;
$$ language plpgsql;

-- approve all meeting sessions within the same department (ignore all that is not from same department)
-- allow not continuous approval
CREATE OR REPLACE PROCEDURE approve_meeting(floor INT, room INT, date DATE, start_time INT, end_time INT, eid INT)
AS
$$
declare
    curr_time int;
begin
    curr_time := start_time;
    if is_manager(eid)
        and (not is_resigned(eid))
        and is_same_department_as_meeting_room(eid, floor, room)
        and is_future_meeting(date) then
        while curr_time < end_time
            loop
                update sessions S
                set eid_manager = eid
                where S.floor = approve_meeting.floor
                  AND S.room = approve_meeting.room
                  AND S.date = approve_meeting.date
                  AND S.time = curr_time;
                curr_time := curr_time + 1;
            end loop;
    else
        RAISE NOTICE 'The approval for this booking session cannot be completed';
    end if;
end;
$$ language plpgsql;


--*************************************************************************
-- health.sql
CREATE OR REPLACE PROCEDURE declare_health (
    eid INTEGER, date DATE, temp NUMERIC(3,1)
) AS $$
DECLARE
    fever BOOLEAN;
BEGIN
    IF temp > 37.5 THEN
        fever := TRUE;
    ELSE
        fever := FALSE;
    END IF;

    -- RAISE NOTICE '% % % %', eid, date, temp, fever;
    INSERT INTO HealthDeclaration VALUES(eid, date, temp, fever);
END;
$$ LANGUAGE plpgsql;


-- Assuming once meeting approved, it will occur with all participants attending
-- Get all employees in the same approved meeting room from day D-3 to day D
CREATE OR REPLACE FUNCTION contact_tracing (fever_eid INTEGER, fever_date DATE) 
    RETURNS TABLE (close_contact_eid INTEGER) AS $$
BEGIN
    -- meetings that fever employee was in from day D-3 to day D
    RETURN QUERY
        WITH CloseContactSessions AS (
            SELECT s.date, s.time, s.room, s.floor
            FROM Joins j, Sessions s
            WHERE s.eid_manager IS NOT NULL
            AND s.date >= fever_date - 3
            AND s.date <= fever_date
            AND s.time = j.time
            AND s.room = j.room
            AND s.floor = j.floor
            AND j.eid = fever_eid
        )
        SELECT DISTINCT(j.eid)
        FROM Joins j
        WHERE EXISTS (
            SELECT 1
            FROM CloseContactSessions c
            WHERE c.date = j.date
            AND c.time = j.time
            AND c.room = j.room
            AND c.floor = j.floor
        );
END;
$$ LANGUAGE plpgsql;


--*************************************************************************
-- admin.sql
-- non_compliance: find all employees that do not comply with the daily health declaration (i.e., to snitch). 
CREATE OR REPLACE FUNCTION get_num_declared (IN start_date DATE, IN end_date DATE)
RETURNS TABLE(eid INT, num_date INT) AS $$
BEGIN
    RETURN QUERY
        SELECT E.eid AS eid, COALESCE(S.num_date, 0)::INT AS num_date 
        FROM Employees E LEFT JOIN (SELECT H.eid AS eid, COUNT(DISTINCT date) AS num_date FROM HealthDeclaration H
                               WHERE date BETWEEN start_date AND end_date
                               GROUP BY H.eid ORDER BY num_date) S
        ON E.eid = S.eid
        ORDER BY num_date;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION non_compliance (IN start_date DATE, IN end_date DATE)
RETURNS TABLE(eid INT, num_date INT) AS $$
DECLARE
    curs CURSOR FOR (SELECT * FROM get_num_declared (start_date, end_date));
    r RECORD;
BEGIN
    IF start_date > end_date THEN
        RAISE NOTICE 'End date must be after start date';
    ELSE
        OPEN curs;
        LOOP
            FETCH curs into r;
            EXIT WHEN NOT FOUND;
            eid := r.eid;
            num_date := (end_date - start_date)::INT - r.num_date + 1;
            RETURN NEXT;
        END LOOP;
        CLOSE curs;
    END IF;
END;
$$ LANGUAGE plpgsql;


-- view_booking_report: used by employee to find all meeting rooms that are booked by the employee. 
CREATE OR REPLACE FUNCTION view_booking_report (IN start_date DATE, IN eid INT)
RETURNS TABLE(floor INT, room INT, date DATE, start_hr TEXT, is_approved BOOLEAN) AS $$
DECLARE
    curs CURSOR FOR (SELECT * FROM Sessions S
                     WHERE S.eid_booker = view_booking_report.eid
                     AND S.date >= view_booking_report.start_date
                     ORDER BY date, time);
    r1 RECORD;
BEGIN
    OPEN curs;
    LOOP
        FETCH curs INTO r1;
        EXIT WHEN NOT FOUND;
        floor := r1.floor;
        room := r1.room;
        date := r1.date;
        start_hr := CONCAT(r1.time::text, ':00');
        IF r1.eid_manager IS NULL THEN
            is_approved := FALSE;
        ELSE
            is_approved := TRUE;
        END IF;
        RETURN NEXT;
    END LOOP;
    CLOSE curs;
END;
$$ LANGUAGE plpgsql;


-- view_future_meeting: used by employee to find all future meetings this employee is going to
-- have that are already approved.
CREATE OR REPLACE FUNCTION view_future_meeting (IN start_date DATE, IN eid INT)
RETURNS TABLE(floor INT, room INT, date DATE, start_hr TEXT) AS $$
DECLARE
    curs CURSOR FOR (SELECT * FROM Joins J WHERE J.eid = view_future_meeting.eid ORDER BY date, time);
    r1 RECORD;
BEGIN
    OPEN curs;
    LOOP
        FETCH curs INTO r1;
        EXIT WHEN NOT FOUND;
        IF r1.date > start_date THEN
            floor := r1.floor;
            room := r1.room;
            date := r1.date;
            start_hr := CONCAT(r1.time::TEXT, ':00');
            RETURN NEXT;
        END IF;
    END LOOP;
    CLOSE curs;
END;
$$ LANGUAGE plpgsql;


-- view_manager_report: used by manager to find all meeting rooms that require approval.
CREATE OR REPLACE FUNCTION view_manager_report (IN start_date DATE, IN in_eid INT)
RETURNS TABLE(floor INT, room INT, date DATE, start_hr INT, eid INT) AS $$
DECLARE
    curs CURSOR FOR (SELECT * FROM Sessions S
                     WHERE not is_meeting_approved(S.floor, S.room, S.time, S.date)
                     AND is_same_department_as_meeting_room (view_manager_report.in_eid, S.floor, S.room)
                     AND not is_resigned(S.eid_booker)
                     ORDER BY date, time);
    r1 RECORD;
BEGIN
    OPEN curs;
    LOOP
        FETCH curs INTO r1;
        EXIT WHEN NOT FOUND;
        floor := r1.floor;
        room := r1.room;
        date := r1.date;
        start_hr := r1.time;
        eid := r1.eid_booker;
        RETURN NEXT;
    END LOOP;
    CLOSE curs;
END;
$$ LANGUAGE plpgsql;


--*************************************************************************
-- trigger.sql
CREATE OR REPLACE FUNCTION remove_bookings_over_capacity()
    RETURNS TRIGGER AS
$$
declare
    --Get the nearest update after this
    next_update_date date := (SELECT date(U.datetime)
                              FROM updates U
                              WHERE U.datetime > NEW.datetime AND U.room = NEW.room AND U.floor = NEW.floor
                              ORDER BY U.datetime
                              LIMIT 1);
    capacity         int  := NEW.new_cap;
    curs CURSOR FOR (SELECT S.time, S.date, S.floor, S.room, COUNT(J.eid)
                     FROM sessions S
                              JOIN Joins J
                                   ON S.time = J.time AND S.date = J.date AND S.floor = J.floor AND S.room = J.room
                     WHERE S.floor = NEW.floor AND S.room = NEW.room
                       AND S.date >= CURRENT_DATE         -- Future Sessions
                       AND (S.date >= date(NEW.datetime)) -- After the update date
                     GROUP BY S.time, S.date, S.floor, S.room
                     HAVING COUNT(J.eid) > capacity);
    r                RECORD;
begin
    open curs;
    loop
        -- EXIT WHEN NO MORE ROWS
        fetch curs into r;
        exit when not FOUND;
        DELETE
        FROM sessions S
        WHERE S.time = r.time
          AND S.date = r.date
          AND S.floor = r.floor
          AND S.room = r.room
          AND (((next_update_date is not null) and S.date < next_update_date)
            OR next_update_date is null);
    end loop;
    close curs;
    return null;
end;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS remove_bookings_over_capacity ON Updates;
CREATE TRIGGER remove_bookings_over_capacity
    AFTER INSERT
    ON Updates
    FOR EACH ROW
EXECUTE FUNCTION remove_bookings_over_capacity();


-- Fever SOP:
-- If employee is booker, delete Sessions where he booked, approved or not.
-- Else remove the employee from all future Joins, approved or not.
-- Get close contacts and do the same but for day D to day D+7 only
CREATE OR REPLACE FUNCTION fever_sop() RETURNS TRIGGER AS
$$
DECLARE
    fever_eid INTEGER;
    fever_date DATE;
BEGIN
    fever_eid := NEW.eid;
    fever_date := NEW.date;

    -- for fever employee
    -- remove employee from all future Joins
    DELETE
    FROM Joins j
    WHERE j.eid = fever_eid
      AND date > fever_date;

    -- employee is booker, delete Sessions where he booked
    DELETE
    FROM Sessions
    WHERE eid_booker = fever_eid
      AND date > fever_date;

    -- for close contacts
    -- remove close contacts from Joins in day D to day D+7
    WITH CloseContacts AS (SELECT close_contact_eid FROM contact_tracing(fever_eid, fever_date))
    DELETE
    FROM Joins j
    WHERE EXISTS(
                  SELECT 1
                  FROM CloseContacts c
                  WHERE j.eid = c.close_contact_eid
                    AND j.date >= fever_date
                    AND j.date <= fever_date + 7
              );

    WITH CloseContacts AS (SELECT close_contact_eid FROM contact_tracing(fever_eid, fever_date))
         -- close contact is booker, delete Session he booked in day D to day D+7
    DELETE
    FROM Sessions s
    WHERE EXISTS(
                  SELECT 1
                  FROM CloseContacts c
                  WHERE s.eid_booker = c.close_contact_eid
                    AND s.date >= fever_date
                    AND s.date <= fever_date + 7
              );


    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


-- If an employee is declares fever at day D, activate fever SOP
DROP TRIGGER IF EXISTS fever_detected ON HealthDeclaration;
CREATE TRIGGER fever_detected
    AFTER INSERT
    ON HealthDeclaration
    FOR EACH ROW
    WHEN (NEW.fever = TRUE)
EXECUTE FUNCTION fever_sop();


CREATE OR REPLACE FUNCTION remove_employee_from_future_record()
    RETURNS TRIGGER AS
$$
BEGIN
    -- Update session to non-approved if resigned employee is a approval
    -- DELETE FROM Sessions WHERE eid_manager = NEW.eid AND Sessions.date > NEW.resigned_date;
    UPDATE Sessions
    SET eid_manager = null
    WHERE eid_manager = NEW.eid AND Sessions.date > NEW.resigned_date;

    -- remove session if resigned employee is a booker
    DELETE FROM Sessions WHERE eid_booker = NEW.eid AND Sessions.date > NEW.resigned_date;

    -- remove employee from future meeting
    DELETE FROM Joins WHERE eid = NEW.eid AND Joins.date > NEW.resigned_date;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS resignation_sop ON Employees;
CREATE TRIGGER resignation_sop
    AFTER UPDATE OF resigned_date
    ON Employees
    FOR EACH ROW
EXECUTE FUNCTION remove_employee_from_future_record();

