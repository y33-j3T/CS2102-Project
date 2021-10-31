CREATE OR REPLACE PROCEDURE declare_health (
    eid INTEGER, date DATE, temp NUMERIC(3,1)
) AS $$
DECLARE
    fever BOOLEAN;
BEGIN
    IF temp > 37.5 THEN
        fever := TRUE;
    ELSE
        fever := FALSE;
    END IF;

    -- RAISE NOTICE '% % % %', eid, date, temp, fever;
    INSERT INTO HealthDeclaration VALUES(eid, date, temp, fever);
END;
$$ LANGUAGE plpgsql;


-- Assuming once meeting approved, it will occur with all participants attending
-- Get all employees in the same approved meeting room from day D-3 to day D
CREATE OR REPLACE FUNCTION contact_tracing (fever_eid INTEGER) 
    RETURNS TABLE (close_contact_eid INTEGER) AS $$
BEGIN
    -- meetings that fever employee was in from day D-3 to day D
    RETURN QUERY
    WITH CloseContactSessions AS (
        SELECT s.date, s.time, s.room, s.floor
        FROM Joins j, Sessions s
        WHERE s.eid_manager IS NOT NULL
        -- AND s.date >= CAST('2021-07-10' AS DATE) - 30
        -- AND s.date <= CAST('2021-07-10' AS DATE)
        AND s.date >= CURRENT_DATE - 3
        AND s.date <= CURRENT_DATE
        AND s.time = j.time
        AND s.room = j.room
        AND s.floor = j.floor
        AND j.eid = fever_eid
    )
    SELECT DISTINCT(j.eid)
    FROM Joins j
    WHERE EXISTS (
        SELECT 1
        FROM CloseContactSessions c
        WHERE c.date = j.date
        AND c.time = j.time
        AND c.room = j.room
        AND c.floor = j.floor
    );
END;
$$ LANGUAGE plpgsql;

-- CREATE OR REPLACE FUNCTION test1 () 
--     RETURNS TABLE (eid2 INTEGER) AS $$
-- BEGIN
--     RETURN QUERY
--     SELECT DISTINCT(j.eid)
--     FROM Joins j
--     WHERE j.eid < 5;
-- END;
-- $$ LANGUAGE plpgsql;


-- CREATE OR REPLACE FUNCTION test2 (OUT eid2 INT) 
--     RETURNS INTEGER AS $$
-- BEGIN
--     -- SELECT DISTINCT(j.eid) into eid2
--     SELECT DISTINCT(j.eid)
--     FROM Joins j
--     WHERE j.eid = 5;
-- END;
-- $$ LANGUAGE plpgsql;


-- Fever SOP:
-- If employee is booker, delete Sessions where he booked, approved or not.
-- Else remove the employee from all future Joins, approved or not.
-- Get close contacts and do the same but for day D to day D+7 only
CREATE OR REPLACE FUNCTION fever_sop() RETURNS TRIGGER AS $$
DECLARE
    fever_eid INTEGER;
BEGIN
    fever_eid := NEW.eid;

    -- for fever employee
    IF is_booker(fever_eid) THEN
        -- employee is booker, delete Sessions where he booked
        DELETE FROM Sessions
        WHERE eid_booker = fever_eid
        AND date > CURRENT_DATE;
    ELSE
        -- remove employee from all future Joins
        DELETE FROM Joins j
        WHERE j.eid = fever_eid
        AND date > CURRENT_DATE;
    END IF;

    -- for close contacts
    WITH CloseContacts AS (SELECT close_contact_eid FROM contact_tracing(fever_eid))
    -- close contact is booker, delete Session he booked in day D to day D+7
    DELETE FROM Sessions s
    WHERE EXISTS (
        SELECT 1
        FROM CloseContacts c
        WHERE s.eid_booker = c.close_contact_eid
        AND s.date >= CURRENT_DATE
        AND s.date <= CURRENT_DATE + 7
    )
    -- remove close contacts from Joins in day D to day D+7
    DELETE FROM Joins j
    WHERE EXISTS (
        SELECT 1
        FROM CloseContacts c
        WHERE j.eid = c.close_contact_eid
        AND j.date >= CURRENT_DATE
        AND j.date <= CURRENT_DATE + 7
    );


    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


-- If an employee is declares fever at day D, activate fever SOP
DROP TRIGGER IF EXISTS fever_detected ON HealthDeclaration;
CREATE TRIGGER fever_detected
AFTER INSERT ON HealthDeclaration
FOR EACH ROW WHEN (NEW.fever = TRUE)
EXECUTE FUNCTION fever_sop();