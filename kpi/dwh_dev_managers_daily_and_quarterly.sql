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
sku_src AS (
    -- 3. Исходные данные по SKU с расчетом минимальной даты для Backfill (для Daily)
    SELECT 
        sku, manager_role, manager, valid_from, valid_to,
        MIN(valid_from) OVER (PARTITION BY sku, manager_role) as first_valid_from
    FROM stage_atom.sku_managers
),
channel_src AS (
    -- 4. Исходные данные по Каналам с расчетом минимальной даты для Backfill (для Daily)
    SELECT 
        channel_code, manager_role, manager, valid_from, valid_to,
        MIN(valid_from) OVER (PARTITION BY channel_code, manager_role) as first_valid_from
    FROM stage_atom.channel_managers
),
sku_grid AS (
    -- 5. Сетка по объектам SKU
    SELECT DISTINCT 'unknown'::text as channel_code, sku, manager_role, c."Date", c.quarter_start, c.quarter_end
    FROM sku_src CROSS JOIN target_calendar c
),
channel_grid AS (
    -- 6. Сетка по объектам Каналов
    SELECT DISTINCT channel_code, 'unknown'::text as sku, manager_role, c."Date", c.quarter_start, c.quarter_end
    FROM channel_src CROSS JOIN target_calendar c
),
-- === БЛОК ОБЪЕДИНЕНИЯ СРЕЗОВ ===
combined_managers AS (
   -- --- СРЕЗ 1: DAILY SKU ---
    SELECT 
        'daily'::text as duration,
        g.channel_code, g.sku, g.manager_role, sm.manager,
        COALESCE(sm.valid_from, g.quarter_start) as valid_from,  
        COALESCE(sm.valid_to, g.quarter_end) as valid_to,      
        g."Date"
    FROM sku_grid g
    LEFT JOIN sku_src sm 
        ON g.sku = sm.sku AND g.manager_role = sm.manager_role 
        AND (g."Date" BETWEEN sm.valid_from AND sm.valid_to OR (g."Date" < sm.first_valid_from AND sm.valid_from = sm.first_valid_from))
    UNION ALL
    -- --- СРЕЗ 2: DAILY CHANNELS ---
    SELECT 
        'daily'::text as duration,
        g.channel_code, g.sku, g.manager_role, cm.manager,
        COALESCE(cm.valid_from, g.quarter_start) as valid_from,  
        COALESCE(cm.valid_to, g.quarter_end) as valid_to,      
        g."Date"
    FROM channel_grid g
    LEFT JOIN channel_src cm 
        ON g.channel_code = cm.channel_code AND g.manager_role = cm.manager_role 
        AND (g."Date" BETWEEN cm.valid_from AND cm.valid_to OR (g."Date" < cm.first_valid_from AND cm.valid_from = cm.first_valid_from))
    UNION ALL
    -- --- СРЕЗ 3: QUARTERLY SKU ---
    SELECT 
        'quarterly'::text as duration,
        g.channel_code, g.sku, g.manager_role, sm.manager,
        COALESCE(sm.valid_from, g.quarter_start) as valid_from,  
        COALESCE(sm.valid_to, g.quarter_end) as valid_to,      
        g."Date"
    FROM sku_grid g
    LEFT JOIN stage_atom.sku_managers sm 
        ON g.sku = sm.sku AND g.manager_role = sm.manager_role 
        AND g.quarter_start BETWEEN sm.valid_from AND sm.valid_to
    UNION ALL
    -- --- СРЕЗ 4: QUARTERLY CHANNELS ---
    SELECT 
        'quarterly'::text as duration,
        g.channel_code, g.sku, g.manager_role, cm.manager,
        COALESCE(cm.valid_from, g.quarter_start) as valid_from,  
        COALESCE(cm.valid_to, g.quarter_end) as valid_to,      
        g."Date"
    FROM channel_grid g
    LEFT JOIN stage_atom.channel_managers cm 
        ON g.channel_code = cm.channel_code AND g.manager_role = cm.manager_role 
        AND g.quarter_start BETWEEN cm.valid_from AND cm.valid_to
)
-- === ФИНАЛЬНАЯ ВЫБОРКА С СОРТИРОВКОЙ ===
SELECT 
    duration,
    channel_code,
    sku,
    -- --- БЛОК ЗАМЕНЫ НАЗВАНИЙ РОЛЕЙ ---
        CASE 
            WHEN manager_role = 'ozon_category_manager' THEN 'Категорийный менеджер ОЗОН'
            WHEN manager_role = 'ozon_manager' THEN 'Менеджер ОЗОН'
            WHEN manager_role = 'wb_category_manager' THEN 'Категорийный менеджер ВБ'
            WHEN manager_role = 'wb_manager' THEN 'Менеджер ВБ'
            WHEN manager_role = 'ym_category_manager' THEN 'Категорийный менеджер ЯМ'
            WHEN manager_role = 'ym_manager' THEN 'Менеджер ЯМ'
            ELSE manager_role::text -- Если роль не попала в список, оставляем как есть
        END as manager_role, 
    manager,
    valid_from,
    valid_to,
    "Date"
FROM combined_managers
ORDER BY duration, sku, channel_code, manager_role, "Date";
