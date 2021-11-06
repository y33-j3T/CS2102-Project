DROP TABLE IF EXISTS
    Employees, Departments, HealthDeclaration, Sessions, MeetingRooms, Booker, Manager, Joins, Updates
CASCADE;

CREATE TABLE Departments (
    did             INTEGER,
    dname           VARCHAR(50) NOT NULL,
    PRIMARY KEY (did)
);

CREATE TABLE Employees (
    eid             INTEGER,
    ename           VARCHAR(50) NOT NULL,
    email           TEXT UNIQUE NOT NULL,
    home_number     INTEGER NOT NULL,
    mobile_number   INTEGER UNIQUE NOT NULL,
    office_number   INTEGER UNIQUE NOT NULL,
    resigned_date   DATE DEFAULT NULL,
    did             INTEGER NOT NULL,
    PRIMARY KEY (eid),
    FOREIGN KEY (did) REFERENCES Departments (did) ON DELETE NO ACTION
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
-- default date format: yyyy-mm-dd ex. 2021-10-16

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
    PRIMARY KEY (date, time, room, floor),
    FOREIGN KEY (room, floor) REFERENCES MeetingRooms (room, floor),
    FOREIGN KEY (eid_booker) REFERENCES Booker (eid)
        ON DELETE CASCADE,
    FOREIGN KEY (eid_manager) REFERENCES Manager (eid)
        ON DELETE NO ACTION,

    CONSTRAINT valid_stime CHECK (time >= 0 AND time <= 23) -- 24 available sessions a day,
);
-- assumption (from the project description): each booking is made on 1-hr basis


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
    datetime        TIMESTAMP,
    eid             INTEGER,
    new_cap         INTEGER,
    PRIMARY KEY (datetime, room, floor),
    FOREIGN KEY (eid) REFERENCES Manager (eid)
        ON DELETE SET NULL,
    FOREIGN KEY (room, floor) REFERENCES MeetingRooms (room, floor)
);

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
