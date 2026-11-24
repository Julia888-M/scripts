TRUNCATE TABLE bi.mp_stocks
;

INSERT INTO bi.mp_stocks
SELECT * FROM bi.vw_mp_stocks