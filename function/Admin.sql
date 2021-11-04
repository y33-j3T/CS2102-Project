-- 1. non_compliance: This routine is used to find all employees that do not comply with the daily health declaration (i.e., to snitch). 
-- The inputs to the routine should minimally include:
    -- Start date
    -- End date
-- The routine returns a table containing all employee ID that do not declare their temperature at least once from the start date (inclusive) to the end date (inclusive). 
-- In other words, [start date, end date].
-- The table returned should minimally include the following columns:
    -- Employee ID
    -- Number of days
-- Number of days is the number of days the employee did not declare their temperature within the given period. The table should be sorted in descending order of number of days.
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




-- 2. view_booking_report: This routine is to be used by employee to find all meeting rooms that are booked by the employee. 
-- The inputs to the routine should minimally include:
    -- Start date
    -- Employee ID
-- The routine returns a table containing all meeting rooms that are booked by the given employee as well as its approval status from the given start date onwards.
-- The table returned should minimally include the following columns:
    -- Floor number 
    -- Room number 
    -- Date
    -- Start hour
    -- Is approved
-- The table should be sorted in ascending order of date and start hour.
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




-- 3. view_future_meeting: This routine is to be used by employee to find all future meetings this employee is going to
-- have that are already approved. The inputs to the routine should minimally include:
    -- Start date
    -- Employee ID
-- The routine returns a table containing all meetings that are already approved for which this employee is joining from the given start date onwards. 
-- Note that the employee need not be the one booking this meeting room. The table returned should minimally include the following columns:
    -- Floor number 
    -- Room number 
    -- Date
    -- Start hour
-- The table should be sorted in ascending order of date and start hour.
CREATE OR REPLACE FUNCTION view_future_meeting (IN start_date DATE, IN eid INT)
RETURNS TABLE(floor INT, room INT, date DATE, start_hr TEXT) AS $$
DECLARE
    curs CURSOR FOR (SELECT * FROM Joins J WHERE J.eid = view_future_meeting.eid ORDER BY date, time);
    r1 RECORD;
    today DATE;
BEGIN
    today = CURRENT_DATE;
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





-- 4. view_manager_report: This routine is to be used by manager to find all meeting rooms that require approval. The
-- inputs to the routine should minimally include: 
    -- Start date
    -- Employee ID
-- If the employee ID does not belong to a manager, the routine returns an empty table. 
-- Otherwise, the routine returns a table containing all meeting that are booked but not yet approved from the given start date onwards. 
-- Note that the routine should only return all meeting in the room with the same department as the manager. The table returned should minimally include the following columns:
    -- Floor number 
    -- Room number 
    -- Date
    -- Start hour 
    -- Employee ID
-- The table should be sorted in ascending order of date and start hour.
CREATE OR REPLACE FUNCTION get_employee_department (IN eid INT)
RETURNS INTEGER AS $$
BEGIN
    RETURN (SELECT did FROM Employees E WHERE E.eid = get_employee_department.eid); 
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_resigned (IN in_eid INT)
RETURNS TABLE(eid INT, resigned_date DATE) AS $$
BEGIN
    RETURN QUERY
        SELECT E.eid, E.resigned_date FROM Employees E
        WHERE E.eid = get_resigned.in_eid;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_room_department(IN room INT, IN floor INT)
RETURNS INTEGER AS $$
BEGIN
    RETURN (SELECT did FROM MeetingRooms M WHERE M.room = get_room_department.room AND M.floor = get_room_department.floor);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION view_manager_report (IN start_date DATE, IN in_eid INT)
RETURNS TABLE(floor INT, room INT, date DATE, start_hr INT, eid INT) AS $$
DECLARE
    curs CURSOR FOR (SELECT * FROM Sessions S
                     WHERE S.eid_manager IS NULL
                     AND get_room_department(S.room, S.floor) = get_employee_department(view_manager_report.in_eid)
                     AND (SELECT T.resigned_date FROM get_resigned(eid_booker) T) IS NULL
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