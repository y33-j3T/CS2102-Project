CALL declare_health(1, '2021-11-01', 38); -- successful, fever
DELETE FROM HealthDeclaration WHERE date >= '2021-11-01';
