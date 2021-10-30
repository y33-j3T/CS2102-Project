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
SELECT search_room(5, current_date, 2, 7);


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
    IF sessions_not_available = 0 AND end_time < 24 THEN
        while curr_time < end_time
            loop
                INSERT INTO sessions(date, time, room, floor, eid_booker)
                VALUES (book_date, curr_time, book_room, book_floor, eid_booker);
                INSERT INTO joins(eid, date, time, room, floor)
                VALUES (eid_booker, book_date, curr_time, book_room, book_floor);
                curr_time := curr_time + 1;
            end loop;
    END IF;
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
begin
    curr_time := start_time;
    sessions_existed := (SELECT count(*)
                         FROM sessions S
                         WHERE S.date = join_meeting.date
                           AND S.room = join_meeting.room
                           AND S.floor = join_meeting.floor
                           AND (S.time >= start_time AND S.time < end_time));
    if sessions_existed = end_time - start_time then
        while curr_time < end_time
            loop
                INSERT INTO joins(eid, date, time, room, floor)
                VALUES (join_meeting.eid, join_meeting.date, curr_time, join_meeting.room, join_meeting.floor);
                curr_time := curr_time + 1;
            end loop;
    end if;
end;
$$ LANGUAGE plpgsql;

-- remove employee from all meeting session ( allow not continuous)
CREATE OR REPLACE PROCEDURE leave_meeting(floor INT, room INT, date DATE, start_time INT, end_time INT, eid INT)
AS
$$
declare
    curr_time int;
begin
    curr_time := start_time;
    while curr_time < end_time
        loop
            delete
            from joins J
            where J.floor = leave_meeting.floor
              and J.room = leave_meeting.room
              and J.date = leave_meeting.date
              and J.eid = leave_meeting.eid
              and J.time = curr_time;
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
end;
$$ language plpgsql;
