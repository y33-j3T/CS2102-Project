--\i 'D:/CS2102/code/cs2102_proj/function.sql'  

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

-- CALL add_department(1, 'test');

CREATE OR REPLACE PROCEDURE remove_department(department_id INTEGER)
AS
$$
BEGIN
    DELETE
    FROM Departments
    WHERE did = department_id;
END;
$$ LANGUAGE 'plpgsql';

-- CALL remove_department(2);

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


--CALL add_room(1, 1, 'test', 10, 1);


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

-- CALL change_capacity(1,1, 15, 0);


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


-- CALL add_employee('Hieu', '123', '456', '789', 'junior', 1);
-- CALL add_employee('YeeJet', '1011', '1112', '1213', 'senior', 3);
-- CALL add_employee('Hung', '1314', '1415', '1516', 'manager', 2);


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

-- CALL remove_employee(2, '2021-10-20');
-- We should keep the eid in booker and manager to keep track?
-- not allow input date > current date

