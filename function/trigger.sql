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

-- Check if the employee can book

CREATE OR REPLACE FUNCTION can_book()
    RETURNS TRIGGER AS
$$
declare
    can_book boolean;
begin
    can_book := is_booker(new.eid_booker)
        and not is_resigned(new.eid_booker)
        and not is_having_fever(new.eid_booker)
        and not is_meeting_exist(new.floor, new.room, new.time, new.date);
    if can_book then
        return new;
    end if;
    return null;
end;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS can_book ON Sessions;
CREATE TRIGGER can_book
    BEFORE INSERT
    ON Sessions
    FOR EACH ROW
EXECUTE FUNCTION can_book();
-- Check if the employee can approve booking
-- If fail check then delete ? ( currently not)

CREATE OR REPLACE FUNCTION can_approve()
    RETURNS TRIGGER AS
$$
declare
    can_approve boolean;
begin
    can_approve := is_manager(new.eid_manager)
        and (not is_resigned(new.eid_manager))
        and is_same_department_as_meeting_room(new.eid_manager, old.floor, old.room)
        and is_meeting_exist(old.floor, old.room, old.time, old.date);
    if can_approve then
        return new;
    end if;
    return old;
end;
$$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS can_approve ON Sessions;
CREATE TRIGGER can_approve
    BEFORE UPDATE OF eid_manager
    ON Sessions
    FOR EACH ROW
EXECUTE FUNCTION can_approve();

-- Check if the meeting about to join is approved

CREATE OR REPLACE FUNCTION can_join_meeting()
    RETURNS TRIGGER AS
$$
declare
    can_join_meeting boolean;
begin
    can_join_meeting := is_meeting_exist(new.floor, new.room, new.time, new.date)
        and not is_meeting_approved(new.floor, new.room, new.time, new.date)
        and (not is_having_fever(new.eid))
        and (not is_resigned(new.eid))
        and is_under_max_capacity(new.floor, new.room, new.time, new.date)
        and is_future_meeting(new.date);
    if can_join_meeting then
        return new;
    end if;
    return null;
end;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS can_join_meeting ON Joins;
CREATE TRIGGER can_join_meeting
    BEFORE INSERT
    ON Joins
    FOR EACH ROW
EXECUTE FUNCTION can_join_meeting();
-- Check if the meeting about to leave is approved

CREATE OR REPLACE FUNCTION can_leave_meeting()
    RETURNS TRIGGER AS
$$
declare
    can_leave_meeting boolean;
begin
    can_leave_meeting := (not is_meeting_approved(old.floor, old.room, old.time, old.date))
        and is_future_meeting(new.date);

    if can_leave_meeting or not is_meeting_exist(old.floor, old.room, old.time, old.date) then
        return old;
    end if;
    return null;
end;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS can_leave_meeting ON Joins;
CREATE TRIGGER can_leave_meeting
    BEFORE DELETE
    ON Joins
    FOR EACH ROW
EXECUTE FUNCTION can_leave_meeting();

