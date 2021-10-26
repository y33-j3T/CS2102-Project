create or replace function is_manager(eid_to_check integer)
    returns boolean as
$$
declare
    is_in boolean;
begin
    is_in := EXISTS(SELECT 1 FROM Manager M WHERE eid_to_check = M.eid);
    return is_in;
end;
$$ language plpgsql;


create or replace function is_booker(eid_to_check integer)
    returns boolean as
$$
declare
    is_in boolean;
begin
    is_in := EXISTS(SELECT 1 FROM Booker B WHERE eid_to_check = B.eid);
    return is_in;
end;
$$ language plpgsql;


create or replace function is_having_fever(eid_to_check integer)
    returns boolean as
$$
declare
    is_having_fever boolean;
begin
    is_having_fever :=
            (SELECT fever FROM healthdeclaration HD WHERE HD.eid = eid_to_check ORDER BY HD.date DESC LIMIT 1);
    return is_having_fever;
end;
$$ language plpgsql;

create or replace function is_resigned(eid_to_check integer)
    returns boolean as
$$
declare
    is_resigned boolean;
begin
    is_resigned := (SELECT resignedDate FROM employees E WHERE E.eid = eid_to_check) is not null;
    return is_resigned;
end;
$$ language plpgsql;

create or replace function is_same_department(eid1 int, eid2 int)
    returns boolean as
$$
declare
    is_same boolean;
begin
    is_same := (SELECT did FROM employees E WHERE E.eid = eid1) = (SELECT did FROM employees E WHERE E.eid = eid2);
    return is_same;
end;
$$ language plpgsql;

create or replace function is_meeting_approved(floor int, room int, stime int, date date)
    returns boolean as
$$
declare
    is_approved boolean;
begin
    is_approved := (SELECT S.eid_manager
                    FROM sessions S
                    WHERE S.date = is_meeting_approved.date
                      AND S.room = is_meeting_approved.room
                      AND S.floor = is_meeting_approved.floor
                      AND S.time = is_meeting_approved.stime) is not null;
end;
$$ language plpgsql;

--Check if the meeting session is under the max capacity
create or replace function is_under_max_capacity(floor int, room int, stime int, date date)
    returns boolean as
$$
declare
    num_participants int;
    most_recent_capacity int;
    is_under boolean;
begin
    num_participants := (SELECT count(*)
                         FROM Joins J
                         WHERE J.date = is_under_max_capacity.date
                           AND J.room = is_under_max_capacity.room
                           AND J.floor = is_under_max_capacity.floor
                           AND J.time = is_under_max_capacity.stime);
    most_recent_capacity := (SELECT new_cap FROM Updates U
    --Check this !!!! if can compare between date and datetime
                             WHERE U.datetime <= is_under_max_capacity.date
                               AND U.floor = is_under_max_capacity.floor
                               AND U.room = is_under_max_capacity.room
                             ORDER BY U.datetime DESC
                             LIMIT 1);
    is_under := (num_participants < most_recent_capacity);
    return is_under;
end;
$$ language plpgsql;