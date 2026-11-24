WITH date_bounds AS (
    SELECT 
        date_trunc('year', current_date)::date as year_start,
        least( (date_trunc('year', current_date) + interval '2 years' - interval '1 day')::date, '2026-08-31'::date ) as year_end
),
target_calendar AS (
    SELECT 
        q.q_start as quarter_start,
        (q.q_start + interval '3 months' - interval '1 day')::date as quarter_end
    FROM date_bounds b,
    LATERAL generate_series(date_trunc('quarter', b.year_start), date_trunc('quarter', b.year_end), interval '3 month') as q(q_start)
),
-- Находим минимальный valid_from для сущностей
prepared_sku AS (
    SELECT 
        sku, manager_role, manager, valid_from, least(valid_to, '2026-08-31'::date) as valid_to,
        MIN(valid_from) OVER(PARTITION BY sku, manager_role) as min_valid_from
    FROM stage_atom.sku_managers
    WHERE valid_from < '2026-09-01'
),
prepared_channel AS (
    SELECT 
        channel_code, manager_role, manager, valid_from, least(valid_to, '2026-08-31'::date) as valid_to,
        MIN(valid_from) OVER(PARTITION BY channel_code, manager_role) as min_valid_from
    FROM stage_atom.channel_managers
    WHERE valid_from < '2026-09-01'
),
all_managers_intervals AS (
    -- 1. Daily SKU: Самый первый интервал расширяем до начала его квартала
    SELECT 
        'daily'::text as duration, 'unknown'::text as channel_code, sku, manager_role, manager, valid_from, valid_to,
        CASE 
            WHEN valid_from = min_valid_from THEN date_trunc('quarter', valid_from)::date 
            ELSE valid_from 
        END as range_start,
        valid_to as range_end
    FROM prepared_sku    
    UNION ALL   
    -- 2. Daily Channel: Самый первый интервал расширяем до начала его квартала
    SELECT 
        'daily'::text as duration, channel_code, 'unknown'::text as sku, manager_role, manager, valid_from, valid_to,
        CASE 
            WHEN valid_from = min_valid_from THEN date_trunc('quarter', valid_from)::date 
            ELSE valid_from 
        END as range_start,
        valid_to as range_end
    FROM prepared_channel      
    UNION ALL   
    -- 3. Quarterly SKU: Нарезка по кварталам (ограничиваем плечо range_end, чтобы избежать дублирования строк)
    SELECT 
        'quarterly'::text as duration, 'unknown'::text as channel_code, sm.sku, sm.manager_role, sm.manager, sm.valid_from, sm.valid_to,
        GREATEST(sm.valid_from, tc.quarter_start) as range_start,
        LEAST(sm.valid_to, tc.quarter_end) as range_end
    FROM target_calendar tc
    JOIN prepared_sku sm ON sm.valid_from <= tc.quarter_end AND sm.valid_to >= tc.quarter_start  
    UNION ALL  
    -- 4. Quarterly Channel: Нарезка по кварталам (исправлены префиксы cm -> ch)
    SELECT 
        'quarterly'::text as duration, ch.channel_code, 'unknown'::text as sku, ch.manager_role, ch.manager, ch.valid_from, ch.valid_to,
        GREATEST(ch.valid_from, tc.quarter_start) as range_start,
        LEAST(ch.valid_to, tc.quarter_end) as range_end
    FROM target_calendar tc
    JOIN prepared_channel ch ON ch.valid_from <= tc.quarter_end AND ch.valid_to >= tc.quarter_start
)
SELECT 
    m.duration,
    m.channel_code,
    m.sku,
    COALESCE(roles.role_ru, m.manager_role) as manager_role,
    m.manager,
    m.valid_from,
    m.valid_to,
    d.day::date as "Date"
FROM all_managers_intervals m
LEFT JOIN (VALUES 
    ('ozon_category_manager', 'Категорийный менеджер ОЗОН'),
    ('ozon_manager',          'Менеджер ОЗОН'),
    ('wb_category_manager',   'Категорийный менеджер ВБ'),
    ('wb_manager',            'Менеджер ВБ'),
    ('ym_category_manager',   'Категорийный менеджер ЯМ'),
    ('ym_manager',            'Менеджер ЯМ')
) as roles(role_en, role_ru) ON m.manager_role = roles.role_en
-- Безопасная генерация серий без декартова перемножения
CROSS JOIN LATERAL generate_series(m.range_start, m.range_end, interval '1 day') as d(day);
