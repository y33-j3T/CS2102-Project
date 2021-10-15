DROP TABLE IF EXISTS 
    Employees, Departments, HealthDeclaration, Sessions, MeetingRooms, Bookers, Managers, Senior, Junior, Joins, Updates
CASCADE;

CREATE TABLE Departments (
    did             INTEGER,
    dname           VARCHAR(50) UNIQUE NOT NULL,
    PRIMARY KEY (did)
);

CREATE TABLE Employees (
    eid             INTEGER,
    ename           VARCHAR(50) UNIQUE NOT NULL,
    email           TEXT UNIQUE NOT NULL,
    home_number     INTEGER, -- instead of creating seperate table for home_number, mobile_number, office_number
    mobile_number   INTEGER NOT NULL,
    office_number   INTEGER NOT NULL,
    resignedDate    DATE,
    did             INTEGER NOT NULL,
    PRIMARY KEY (eid),
    FOREIGN KEY (did) REFERENCES Departments (did)
);

-- https://www.postgresql.org/docs/9.5/datatype-numeric.html#DATATYPE-FLOAT
CREATE TABLE HealthDeclaration (
    ddate           DATE UNIQUE,
    eid             INTEGER NOT NULL,
    temp            NUMERIC(3,1) NOT NULL,
    fever           BOOLEAN NOT NULL,
    PRIMARY KEY (ddate),
    FOREIGN KEY (eid) REFERENCES Employees (eid)
        ON DELETE CASCADE,
    CONSTRAINT valid_temp CHECK (temp > 34.0 AND temp < 43.0)
);

-- Combine MeetingRooms and LocatedIn
CREATE TABLE MeetingRooms (
    room            INTEGER,
    floor           INTEGER,
    did             INTEGER NOT NULL,
    rname           VARCHAR(50) NOT NULL
    PRIMARY KEY (room, floor),
    FOREIGN KEY (did) REFERENCES Department (did),
);

-- Refer to slides 53 Lecture 4
CREATE TABLE Bookers (
    eid             INTEGER NOT NULL,
    FOREIGN KEY (eid) REFERENCES Employees (eid)
        ON DELETE CASCADE,
);

-- Refer to slides 53 Lecture 4
CREATE TABLE Managers (
    eid             INTEGER NOT NULL,
    FOREIGN KEY (eid) REFERENCES Bookers (eid)
        ON DELETE CASCADE,
);

CREATE TABLE Seniors (
    eid             INTEGER NOT NULL,
    FOREIGN KEY (eid) REFERENCES Bookers (eid)
        ON DELETE CASCADE,
);

CREATE TABLE Juniors (
    eid             INTEGER NOT NULL,
    FOREIGN KEY (eid) REFERENCES Employees (eid)
        ON DELETE CASCADE,
);

CREATE TABLE Sessions (
    sdate           DATE,
    stime           INTEGER,
    room            INTEGER NOT NULL,
    floor           INTEGER NOT NULL,
    eid_booker      INTEGER NOT NULL,
    eid_manager     INTEGER NOT NULL,
    PRIMARY KEY (sdate, stime, room, floor), -- each meeting room can only have 1 session at a time
    FOREIGN KEY (room, floor) REFERENCES MeetingRooms (room, floor),
    FOREIGN KEY (eid_booker) REFERENCES Bookers (eid),
    FOREIGN KEY (eid_manager) REFERENCES Managers (eid),
    
    CONSTRAINT valid_stime CHECK (stime >= 0 AND stime <= 23), -- 24 available sessions a day,
);

CREATE TABLE Joins (
    eid             INTEGER NOT NULL,
    stime           INTEGER NOT NULL,
    sdate           INTEGER NOT NULL,
    room            INTEGER NOT NULL,
    floor           INTEGER NOT NULL,
    PRIMARY KEY (eid, stime, sdate, room, floor)
    FOREIGN KEY (eid) REFERENCES Employees (eid),
    FOREIGN KEY (stime, sdate, room, floor) REFERENCES Sessions (stime, sdate, room, floor)
);

CREATE TABLE Updates(
    eid             INTEGER NOT NULL,
    udate           DATE,
    new_cap         INTEGER,
    room            INTEGER NOT NULL,
    floor           INTEGER NOT NULL,
    PRIMARY KEY (eid, udate, room, floor),
    FOREIGN KEY (eid) REFERENCES Managers (eid),
    FOREIGN KEY (room, floor) REFERENCES MeetingRooms (room, floor),
);

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