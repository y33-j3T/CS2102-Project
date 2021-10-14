DROP TABLE IF EXISTS Employees, Departments, MeetingRooms HealthDeclaration, 
                    Junior, Booker, Senior, Manager, 
                    Updates, Joins, Books, Aprroves, Sessions CASCADE;


CREATE TABLE Employees (
    eid             INTEGER         PRIMARY KEY,
    ename           VARCHAR(50)     NOT NULL,
    email           TEXT            UNIQUE NOT NULL,
    department_id   INTEGER         NOT NULL,
    resigned_date   DATE,
    home_phone      INTEGER,
    mobile_phone    INTEGER,
    office_phone    INTEGER

    FOREIGN KEY (department_id) REFERENCES Departments (did) 
                                ON UPDATE CASCADE
                                ON DELETE NO ACTION
);

CREATE TABLE Departments (
    did              INTEGER        PRIMARY KEY,
    dname            VARCHAR(50)    NOT NULL,
);

CREATE TABLE HealthDeclaration (
    eid     INTEGER,
    date    DATE,
    temp     NUMERIC NOT NULL
    -- fever ?

    PRIMARY KEY (eid, date),
    FOREIGN KEY (eid) REFERENCES Employees (eid)
                                ON DELETE CASCADE
);

CREATE TABLE Junior (
    eid INTEGER PRIMARY KEY;
    FOREIGN KEY (eid) REFERENCES Employees (eid) ON DELETE CASCADE
);

CREATE TABLE Booker (
    eid INTEGER PRIMARY KEY;
    FOREIGN KEY (eid) REFERENCES Employees (eid) ON DELETE CASCADE
);

CREATE TABLE Senior (
    eid INTEGER PRIMARY KEY;
    FOREIGN KEY (eid) REFERENCES Booker (eid) ON DELETE CASCADE
);

CREATE TABLE Manager (
    eid INTEGER PRIMARY KEY;
    FOREIGN KEY (eid) REFERENCES Booker (eid) ON DELETE CASCADE
);

CREATE TABLE MeetingRooms (
    room        INTEGER,
    floor       INTEGER,
    rname       VARCHAR(50)     NOT NULL,
    did         INTEGER,

    PRIMARY KEY (room, floor)
    FOREIGN KEY (did) REFERENCES Departments (did) ON DELETE CASCADE
    UNIQUE (floor, room)
);

CREATE TABLE Updates (
    eid     INTEGER,
    date    DATE,
    new_cap INTEGER     NOT NULL,
    room    INTEGER,
    floor   INTEGER

    PRIMARY KEY (eid, date, room, floor)

    FOREIGN KEY (eid) REFERENCES Manager (eid) ON DELETE CASCADE
    FOREIGN KEY (room, floor) REFERENCES MeetingRooms (room, floor) ON DELETE CASCADE
);

CREATE TABLE Joins (
    eid     INTEGER,
    time    INTEGER, --check the type
    date    DATE,
    room    INTEGER ,
    floor   INTEGER 

    PRIMARY KEY (eid, time, date, room, floor)

    FOREIGN KEY (eid) REFERENCES Employees (eid) ON DELETE CASCADE
    FOREIGN KEY (time, date, room, floor) REFERENCES Sessions (time, date, room, floor) 
                                                ON DELETE CASCADE
);

CREATE TABLE Books (
    eid     INTEGER,
    time    INTEGER, --check the type
    date    DATE,
    room    INTEGER ,
    floor   INTEGER 

    PRIMARY KEY (eid, time, date, room, floor)

    FOREIGN KEY (eid) REFERENCES Booker (eid) ON DELETE CASCADE
    FOREIGN KEY (time, date, room, floor) REFERENCES Sessions (time, date, room, floor) 
                                                ON DELETE CASCADE
);

CREATE TABLE Approves (
    eid     INTEGER,
    time    INTEGER, --check the type
    date    DATE,
    room    INTEGER,
    floor   INTEGER 

    PRIMARY KEY (eid, time, date, room, floor)

    FOREIGN KEY (eid) REFERENCES Manager (eid) ON DELETE CASCADE
    FOREIGN KEY (time, date, room, floor) REFERENCES Sessions (time, date, room, floor) 
                                                ON DELETE CASCADE);

CREATE TABLE Sessions (
    time    INTEGER, --check the type
    date    DATE,
    room    INTEGER ,
    floor   INTEGER

    PRIMARY KEY (time, date, room, floor)
    FOREIGN KEY (room, floor) REFERENCES MeetingRooms (room, floor)
                                ON DELETE CASCADE
);
