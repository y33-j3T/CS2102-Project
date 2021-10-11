CREATE TABLE Departments (
    did             INTEGER,
    dname           VARCHAR(50) NOT NULL,
    PRIMARY KEY (did)
);

CREATE TABLE HealthDeclaration (
    eid             INTEGER,
    date            DATE UNIQUE,
    temp            NUMERIC(3, 1),
    fever           BOOLEAN,
    PRIMARY KEY (eid, date),
    FOREIGN KEY (eid) REFERENCES Employees (eid)
        ON DELETE CASCADE
);

CREATE TABLE Employees (
    eid             INTEGER,
    ename           VARCHAR(50) NOT NULL,
    email           TEXT UNIQUE NOT NULL,
    phone_home      INTEGER NOT NULL,
    phone_mobile    INTEGER NOT NULL,
    phone_office    INTEGER NOT NULL,
    resigned_date   DATE NOT NULL,
    did             INTEGER NOT NULL,
    PRIMARY KEY (eid),
    FOREIGN KEY (did) REFERENCES Departments (did)
);

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
    room            INTEGER,
    floor           INTEGER,
    date            DATE,
    time            DATETIME,
    eid_booker      INTEGER NOT NULL,
    eid_manager     INTEGER,
    PRIMARY KEY (room, floor, date, time),
    FOREIGN KEY (room, floor) REFERENCES MeetingRooms (room, floor),
    FOREIGN KEY (eid_booker) REFERENCES Booker (eid),
    FOREIGN KEY (eid_manager) REFERENCES Manager (eid),

    CONSTRAINT same_department CHECK (
        (SELECT did FROM Employees e WHERE e.eid = eid_manager) = 
        (SELECT did FROM MeetingRooms m WHERE m.room = room AND m.floor = floor)
    )

    CONSTRAINT is_future CHECK (
        date >= (SELECT CURRENT_DATE) AND
        time > (SELECT CURRENT_TIME)
    )

    CONSTRAINT not_resigned_booker CHECK (
        (SELECT resigned_date FROM Employees e WHERE e.eid = eid_booker) IS NULL
    )

    CONSTRAINT not_resigned_manager CHECK (
        (SELECT resigned_date FROM Employees e WHERE e.eid = eid_manager) IS NULL
    )
);

CREATE TABLE Joins (
    eid             INTEGER,
    room            INTEGER,
    floor           INTEGER,
    date            DATE,
    time            DATETIME,
    new_cap         INTEGER,
    PRIMARY KEY (eid, room, floor, date, time),
    FOREIGN KEY (eid) REFERENCES Employees (eid),
    FOREIGN KEY (room, floor, date, time) REFERENCES Sessions (room, floor, date, time)

    CONSTRAINT future_meeting CHECK (
        date >= (SELECT CURRENT_DATE)
        time > (SELECT CURRENT_TIME)
    )
);

CREATE TABLE MeetingRooms (
    room            INTEGER,
    floor           INTEGER,
    rname           VARCHAR(50) NOT NULL,
    did             INTEGER NOT NULL,
    PRIMARY KEY (room, floor),
    FOREIGN KEY (did) REFERENCES Departments (did)
);

CREATE TABLE Updates (
    eid             INTEGER,
    room            INTEGER,
    floor           INTEGER,
    date            DATE,
    new_cap         INTEGER,
    PRIMARY KEY (eid, room, floor, date),
    FOREIGN KEY (eid) REFERENCES Manager (eid),
    FOREIGN KEY (room, floor) REFERENCES MeetingRooms (room, floor),

    CONSTRAINT same_department CHECK (
        (SELECT did FROM Employees e WHERE e.eid = eid) = 
        (SELECT did FROM MeetingRooms m WHERE m.room = room AND m.floor = floor)
    )
);

-- Constraints to be implemented in functions

-- 16, 19
-- check for fever, then only allow join / book

-- 18
-- set booking employee to join immediately

-- 22
-- check if eid_manager null, then only allow approve

-- 23
-- check if eid_manager null, then only allow changes

-- 27
-- check approval date in future before udpate

-- 28
-- check every day if HealthDeclaration has all eid

-- 31, 34
-- check temperature, then update