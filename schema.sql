DROP TABLE IF EXISTS
    Employees, Departments, HealthDeclaration, Sessions, MeetingRooms, Booker, Manager, Senior, Junior, Joins, Updates
CASCADE;

CREATE TABLE Departments (
    did             INTEGER,
    dname           VARCHAR(50) NOT NULL,
    PRIMARY KEY (did)
);

CREATE TABLE Employees (
    eid             INTEGER,
    ename           VARCHAR(50) UNIQUE NOT NULL,
    email           TEXT UNIQUE NOT NULL,
    home_number     INTEGER NOT NULL,
    mobile_number   INTEGER NOT NULL,
    office_number   INTEGER NOT NULL,
    resignedDate    DATE DEFAULT NULL,
    did             INTEGER NOT NULL,
    PRIMARY KEY (eid),
    FOREIGN KEY (did) REFERENCES Departments (did) ON DELETE CASCADE
);

-- https://www.postgresql.org/docs/9.5/datatype-numeric.html#DATATYPE-FLOAT
CREATE TABLE HealthDeclaration (
    eid             INTEGER,
    date            DATE,
    temp            NUMERIC(3,1) NOT NULL,
    fever           BOOLEAN NOT NULL,
    PRIMARY KEY (eid, date),
    FOREIGN KEY (eid) REFERENCES Employees (eid)
        ON DELETE CASCADE,
    CONSTRAINT valid_temp CHECK (temp > 34.0 AND temp < 43.0),
    CONSTRAINT fever_check CHECK
        ((fever AND temp > 37.5) OR (NOT fever AND temp <= 37.5))
);
-- declare daily? -> do in function/triggers
-- fever? -> functions
-- default date format: yyyy-mm-dd ex. 2021-10-16
-- insert into t values(TO_DATE('10/12/2015', 'DD/MM/YYYY'));

-- Combine MeetingRooms and LocatedIn
CREATE TABLE MeetingRooms (
    room            INTEGER,
    floor           INTEGER,
    did             INTEGER NOT NULL,
    rname           VARCHAR(50) NOT NULL,
    PRIMARY KEY (room, floor),
    FOREIGN KEY (did) REFERENCES Departments (did) ON DELETE NO ACTION
);
-- update the dapartment of the meeting rooms manually

CREATE TABLE Booker (
    eid             INTEGER PRIMARY KEY,
    FOREIGN KEY (eid) REFERENCES Employees (eid)
        ON DELETE CASCADE
);


CREATE TABLE Manager (
    eid             INTEGER PRIMARY KEY,
    FOREIGN KEY (eid) REFERENCES Booker (eid)
        ON DELETE CASCADE
);


CREATE TABLE Sessions (
    date            DATE,
    time            INTEGER,
    room            INTEGER,
    floor           INTEGER,
    eid_booker      INTEGER NOT NULL,
    eid_manager     INTEGER DEFAULT NULL,
    PRIMARY KEY (date, time, room, floor), -- each meeting room can only have 1 session at a time
    FOREIGN KEY (room, floor) REFERENCES MeetingRooms (room, floor),
    FOREIGN KEY (eid_booker) REFERENCES Booker (eid)
        ON DELETE CASCADE,
    FOREIGN KEY (eid_manager) REFERENCES Manager (eid)
        ON DELETE NO ACTION,

    CONSTRAINT valid_stime CHECK (time >= 0 AND time <= 23) -- 24 available sessions a day,
);
-- assumption (from the project description): each booking is made on 1-hr basis
-- what if booker and manager is deleted?
-- Same department manager - in function
-- is future meeting - in function/trigger
-- what if the booker resigned? - remove/continue meeting
-- what if the approved manager resigned?

CREATE TABLE Joins (
    eid             INTEGER,
    date            DATE,
    time            INTEGER,
    room            INTEGER,
    floor           INTEGER,
    PRIMARY KEY (eid, time, date, room, floor),
    FOREIGN KEY (eid) REFERENCES Employees (eid)
        ON DELETE CASCADE,
    FOREIGN KEY (date, time, room, floor)
    REFERENCES Sessions (date, time, room, floor) ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE Updates(
    room            INTEGER,
    floor           INTEGER,
    -- datetime        DATETIME,
    date            DATE,
    time            TIME,
    eid             INTEGER,
    new_cap         INTEGER,
    PRIMARY KEY (date,time, room, floor),
    FOREIGN KEY (eid) REFERENCES Manager (eid)
        ON DELETE SET NULL,
    FOREIGN KEY (room, floor) REFERENCES MeetingRooms (room, floor)
);

-- datetime: what is the new capacity, if multiple updates in a day?
-- what if a manager change a room capacity, then resign??

-- uncaptured
-- 16. If an employee is having a fever, they cannot book a room.
-- 18. The employee booking the room immediately joins the booked meeting.
-- 19. If an employee is having a fever, they cannot join a booked meeting.
-- 21. A manager can only approve a booked meeting in the same department as the manager
-- 23. Once approved, there should be no more changes in the participants and the participants will definitely come to the meeting on the stipulated day.
-- 24. A manager from the same department as the meeting room may change the meeting room capacity.
-- 25. A booking can only be made for future meetings.
-- 26. An employee can only join future meetings.
-- 27. An approval can only be made on future meetings.
-- 28. Every employee must do a daily health declaration.
-- 31. If the declared temperature is higher than 37.5 Celsius, the employee is having a fever.
-- 34. When an employee resign, they are no longer allowed to book or approve any meetings.
-- 35. Contact tracing constraints

-- CREATE TABLE Seniors (
--     eid             INTEGER NOT NULL,
--     FOREIGN KEY (eid) REFERENCES Booker (eid)
--         ON DELETE CASCADE,
-- );

-- CREATE TABLE Juniors (
--     eid             INTEGER NOT NULL,
--     FOREIGN KEY (eid) REFERENCES Employees (eid)
--         ON DELETE CASCADE,
-- );
