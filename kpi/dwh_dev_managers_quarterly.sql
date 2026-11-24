WITH date_bounds AS (
    -- 1. Динамические границы: текущий год + следующий год
    SELECT 
        date_trunc('year', current_date)::date as year_start,
        (date_trunc('year', current_date) + interval '2 years' - interval '1 day')::date as year_end
),
target_calendar AS (
    -- 2. Сетка дней с расчетом начала и конца каждого квартала
    SELECT 
        c."Date",
        date_trunc('quarter', c."Date")::date as quarter_start,
        (date_trunc('quarter', c."Date") + interval '3 months' - interval '1 day')::date as quarter_end
    FROM olap."Calendar" c
    CROSS JOIN date_bounds b
    WHERE c."Date" BETWEEN b.year_start AND b.year_end
),
unique_skus AS (
    -- 3. ВСЕ уникальные SKU и их роли
    SELECT DISTINCT sku, manager_role
    FROM stage_atom.sku_managers
),
unique_channels AS (
    -- 4. ВСЕ уникальные Каналы и их роли
    SELECT DISTINCT channel_code, manager_role
    FROM stage_atom.channel_managers
),
sku_grid AS (
    -- 5. Полная сетка по объектам SKU
    SELECT 'unknown'::text as channel_code, s.sku, s.manager_role, c."Date", c.quarter_start, c.quarter_end
    FROM unique_skus s CROSS JOIN target_calendar c
),
channel_grid AS (
    -- 6. Полная сетка по объектам Каналов
    SELECT ch.channel_code, 'unknown'::text as sku, ch.manager_role, c."Date", c.quarter_start, c.quarter_end
    FROM unique_channels ch CROSS JOIN target_calendar c
)
-- === ВЕРТИКАЛЬНАЯ СКЛЕЙКА (UNION ALL) ===
-- ЧАСТЬ 1: SKU Managers
SELECT 
    'quarterly'::text as duration,
    g.channel_code,
    g.sku,
    g.manager_role,
    sm.manager,
    -- Если менеджер есть — берем его valid_from, если нет — ставим начало квартала
    COALESCE(sm.valid_from, g.quarter_start) as valid_from,  
    -- Если менеджер есть — берем его valid_to, если нет — ставим конец квартала
    COALESCE(sm.valid_to, g.quarter_end) as valid_to,      
    g."Date"
FROM sku_grid g
LEFT JOIN stage_atom.sku_managers sm 
    ON g.sku = sm.sku 
   AND g.manager_role = sm.manager_role 
   AND g.quarter_start BETWEEN sm.valid_from AND sm.valid_to
UNION ALL
-- ЧАСТЬ 2: Channel Managers
SELECT 
    'quarterly'::text as duration,
    g.channel_code,
    g.sku,
    g.manager_role,
    cm.manager,
    -- Если менеджер есть — берем его valid_from, если нет — ставим начало квартала
    COALESCE(cm.valid_from, g.quarter_start) as valid_from,  
    -- Если менеджер есть — берем его valid_to, если нет — ставим конец квартала
    COALESCE(cm.valid_to, g.quarter_end) as valid_to,      
    g."Date"
FROM channel_grid g
LEFT JOIN stage_atom.channel_managers cm 
    ON g.channel_code = cm.channel_code 
   AND g.manager_role = cm.manager_role 
   AND g.quarter_start BETWEEN cm.valid_from AND cm.valid_to
ORDER BY sku, channel_code, manager_role, "Date";
