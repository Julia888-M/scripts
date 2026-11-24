SELECT 
    datum::date AS date
FROM generate_series(
    '2026-01-01'::DATE, -- Начальная дата
    '2027-12-31'::DATE, -- Конечная дата
    '1 day'::INTERVAL
) AS datum;
