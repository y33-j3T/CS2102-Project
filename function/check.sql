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
    is_same := (SELECT did FROM employees E WHERE E.eid = is_same_department_AS_meeting_room.eid)
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

