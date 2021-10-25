

create or replace function is_manager(eid_to_check integer)
    returns boolean as $$
declare
    is_in boolean;
begin
    is_in := EXISTS (SELECT 1 FROM Manager M WHERE eid_to_check = M.eid);
    return is_in;
end;
$$ language plpgsql;


create or replace function is_booker(eid_to_check integer)
    returns boolean as $$
declare
    is_in boolean;
begin
    is_in := EXISTS(SELECT 1 FROM Booker B WHERE eid_to_check = B.eid);
    return is_in;
end;
$$ language plpgsql;