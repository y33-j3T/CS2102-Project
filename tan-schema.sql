DROP TABLE IF EXISTS


CREATE TABLE Departments (
    did             INTEGER PRIMARY KEY,
    name           VARCHAR(50) NOT NULL,
);

CREATE TABLE Employees (
    eid             INTEGER PRIMARY KEY,
    name            VARCHAR(50) NOT NULL,
    email           TEXT UNIQUE NOT NULL,
    phone_home      INTEGER ,
    phone_mobile    INTEGER ,
    phone_office    INTEGER ,
    resigned_date   DATE DEFAULT NULL, -- NULL MEANS NOT RESIGNED
    did             INTEGER NOT NULL,
    FOREIGN KEY (did) REFERENCES Departments (did)
);

CREATE TABLE Bookers (
  eid INTEGER PRIMARY KEY,
  FOREIGN KEY (eid) REFERENCES Employees (eid) ON DELETE CASCADE
);

CREATE TABLE Managers (
  id INTEGER PRIMARY KEY,
  FOREIGN KEY (eid) REFERENCES Bookers (eid) ON DELETE CASCADE
);

CREATE TABLE HealthDeclaration (
    eid             INTEGER,
    date            DATE,
    temp            NUMERIC NOT NULL,
    fever           BOOLEAN,
    PRIMARY KEY (eid, date),
    FOREIGN KEY (eid) REFERENCES Employees (eid) ON DELETE CASCADE,
    CONSTRAINT normal_temp CHECK (temp >= 34 AND temp <= 43)
    CONSTRAINT fever_check CHECK
    ((fever AND temp > 37.5) OR (NOT fever AND temp <= 37.5))
);

CREATE TABLE MeetingRooms (
  room INTEGER,
  floor INTEGER,
  rname VARCHAR(50) NOT NULL,
  did INTEGER NOT NULL,
  PRIMARY KEY (room,floor),
  FOREIGN KEY (did) REFERENCES Departments (did)
);

CREATE TABLE Updates (
  date DATE,
  new_cap INTEGER NOT NULL,
  room INTEGER,
  floor INTEGER,
  PRIMARY KEY (date,room,floor),
  FOREIGN KEY(room,floor) REFERENCES Meetings (room,floor) ON DELETE CASCADE
);

CREATE TABLE Sessions (
  time TIME,
  date DATE,
  room INTEGER,
  floor INTEGER,
  eid_booked INTEGER NOT NULL,
  eid_approved INTEGER DEFAULT NULL , -- NULL MEAN NOT APPROVED
  PRIMARY KEY (time,date,room,floor),
  FOREIGN KEY (eid_booked) REFERENCES Bookers(eid),
  FOREIGN KEY (eid_approved) REFERENCES Managers(eid)
  FOREIGN KEY(room,floor) REFERENCES Meetings (room,floor) ON DELETE CASCADE
)

CREATE TABLE Joins (
  eid INTEGER,
  time TIME,
  date DATE,
  room INTEGER,
  floor INTEGER,
  FOREIGN KEY (time,date,room,floor) REFERENCES Sessions (time,date,room,floor)
  ON DELETE CASCADE,
  FOREIGN KEY (eid) REFERENCES Employees(eid) ON DELETE CASCADE,
  PRIMARY KEY (eid,time,date,room,floor)
)

-- 12. Each employee must be one and only one of the three kinds of employees: junior, senior or
-- manager.
-- 16. If an employee is having a fever, they cannot book a room.
-- 18. The employee booking the room immediately joins the booked meeting.
-- 19. If an employee is having a fever, they cannot join a booked meeting.
-- 21. A manager can only approve a booked meeting in the same department as the manager (i.e., the
-- manager and the meeting room is in the same department).
-- 23. Once approved, there should be no more changes in the participants and the participants will
-- denitely come to the meeting on the stipulated day.
-- 25. A booking can only be made for future meetings.
-- 26. An employee can only join future meetings.
-- 27. An approval can only be made on future meetings.
-- 31. If the declared temperature is higher than 37.5 Celsius, the employee is having a fever.
-- 34. When an employee resign, they are no longer allowed to book or approve any meetings.
-- 35. Contact tracing constraints are omitted from this list.
