WITH date_bounds AS (
    -- 1. Динамические границы: текущий год + следующий год
    SELECT 
        date_trunc('year', current_date)::date as year_start,
        (date_trunc('year', current_date) + interval '2 years' - interval '1 day')::date as year_end
),
target_calendar AS (
    -- 2. Сетка дней с расчетом начала и конца квартала для каждого дня
    SELECT 
        c."Date",
        date_trunc('quarter', c."Date")::date as quarter_start,
        (date_trunc('quarter', c."Date") + interval '3 months' - interval '1 day')::date as quarter_end
    FROM olap."Calendar" c
    CROSS JOIN date_bounds b
    WHERE c."Date" BETWEEN b.year_start AND b.year_end
),
sku_src AS (
    -- 3. Исходные данные по SKU с расчетом минимальной даты для Backfill
    SELECT 
        sku, manager_role, manager, valid_from, valid_to,
        MIN(valid_from) OVER (PARTITION BY sku, manager_role) as first_valid_from
    FROM stage_atom.sku_managers
),
channel_src AS (
    -- 4. Исходные данные по Каналам с расчетом минимальной даты для Backfill
    SELECT 
        channel_code, manager_role, manager, valid_from, valid_to,
        MIN(valid_from) OVER (PARTITION BY channel_code, manager_role) as first_valid_from
    FROM stage_atom.channel_managers
),
sku_grid AS (
    -- 5. Полная сетка по объектам SKU
    SELECT DISTINCT 'unknown'::text as channel_code, sku, manager_role, c."Date", c.quarter_start, c.quarter_end
    FROM sku_src CROSS JOIN target_calendar c
),
channel_grid AS (
    -- 6. Полная сетка по объектам Каналов
    SELECT DISTINCT channel_code, 'unknown'::text as sku, manager_role, c."Date", c.quarter_start, c.quarter_end
    FROM channel_src CROSS JOIN target_calendar c
)
-- === ВЕРТИКАЛЬНАЯ СКЛЕЙКА (UNION ALL) ===
-- ЧАСТЬ 1: SKU Managers (Daily)
SELECT 
    'daily'::text as duration,
    g.channel_code,
    g.sku,
    g.manager_role,
    sm.manager,
    -- Если менеджер отсутствует, проставляем начало текущего квартала
    COALESCE(sm.valid_from, g.quarter_start) as valid_from,  
    -- Если менеджер отсутствует, проставляем конец текущего квартала
    COALESCE(sm.valid_to, g.quarter_end) as valid_to,      
    g."Date"
FROM sku_grid g
LEFT JOIN sku_src sm 
    ON g.sku = sm.sku 
   AND g.manager_role = sm.manager_role 
   AND (
        -- Условие А: день попадает в его законный период
        g."Date" BETWEEN sm.valid_from AND sm.valid_to
        OR 
        -- Условие Б (Backfill): день раньше самой первой записи — берем первого менеджера
        (g."Date" < sm.first_valid_from AND sm.valid_from = sm.first_valid_from)
   )
UNION ALL
-- ЧАСТЬ 2: Channel Managers (Daily)
SELECT 
    'daily'::text as duration,
    g.channel_code,
    g.sku,
    g.manager_role,
    cm.manager,
    -- Если менеджер отсутствует, проставляем начало текущего квартала
    COALESCE(cm.valid_from, g.quarter_start) as valid_from,  
    -- Если менеджер отсутствует, проставляем конец текущего квартала
    COALESCE(cm.valid_to, g.quarter_end) as valid_to,      
    g."Date"
FROM channel_grid g
LEFT JOIN channel_src cm 
    ON g.channel_code = cm.channel_code 
   AND g.manager_role = cm.manager_role 
   AND (
        -- Условие А: день внутри периода
        g."Date" BETWEEN cm.valid_from AND cm.valid_to
        OR 
        -- Условие Б (Backfill): день раньше самой первой записи
        (g."Date" < cm.first_valid_from AND cm.valid_from = cm.first_valid_from)
   )
ORDER BY sku, channel_code, manager_role, "Date";
