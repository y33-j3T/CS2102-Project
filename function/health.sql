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
