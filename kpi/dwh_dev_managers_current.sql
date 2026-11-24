WITH date_bounds AS (
    SELECT 
        '2026-09-01'::date as period_start,
        (date_trunc('year', current_date) + interval '2 years' - interval '1 day')::date as period_end
),
-- Справочник ролей
roles(role_en, role_ru) AS (
    VALUES 
        ('ozon_category_manager', 'Категорийный менеджер ОЗОН'),
        ('ozon_manager',          'Менеджер ОЗОН'),
        ('wb_category_manager',   'Категорийный менеджер ВБ'),
        ('wb_manager',            'Менеджер ВБ'),
        ('ym_category_manager',   'Категорийный менеджер ЯМ'),
        ('ym_manager',            'Менеджер ЯМ')
),
-- Генерируем один календарь для быстрой склейки (оптимизация)
calendar AS (
    SELECT d.day::date as "Date",
           date_trunc('quarter', d.day)::date as quarter_start
    FROM date_bounds b
    CROSS JOIN generate_series(b.period_start::timestamp, b.period_end::timestamp, interval '1 day') as d(day)
),
-- Подготовка SKU
prepared_sku AS (
    SELECT 
        'unknown'::text as channel_code, sm.sku, sm.manager_role, sm.manager, 
        sm.valid_from, sm.valid_to,
        GREATEST(sm.valid_from, b.period_start) as range_start,
        LEAST(sm.valid_to, b.period_end) as range_end
    FROM stage_atom.sku_managers sm
    CROSS JOIN date_bounds b
    WHERE sm.valid_from <= b.period_end AND sm.valid_to >= b.period_start
),
-- Подготовка каналов
prepared_channel AS (
    SELECT 
        cm.channel_code, 'unknown'::text as sku, cm.manager_role, cm.manager, 
        cm.valid_from, cm.valid_to,
        GREATEST(cm.valid_from, b.period_start) as range_start,
        LEAST(cm.valid_to, b.period_end) as range_end
    FROM stage_atom.channel_managers cm
    CROSS JOIN date_bounds b
    WHERE cm.valid_from <= b.period_end AND cm.valid_to >= b.period_start
),
-- Объединяем менеджмент
base_intervals AS (
    SELECT * FROM prepared_sku   
    UNION ALL   
    SELECT * FROM prepared_channel
),
-- Связываем интервалы с днями (БЕЗ размножения на daily/quarterly)
expanded_days AS (
    SELECT 
        i.channel_code, i.sku, i.manager_role, i.manager, i.valid_from, i.valid_to,
        c."Date", c.quarter_start
    FROM base_intervals i
    JOIN calendar c ON c."Date" BETWEEN i.range_start AND i.range_end
),
-- Вычисляем квартального менеджера (последнего в каждом квартале для сущности)
quarterly_managers AS (
    SELECT DISTINCT ON (channel_code, sku, manager_role, quarter_start)
        channel_code, 
        sku, 
        manager_role, 
        quarter_start,
        manager as quarterly_manager,
        valid_from as q_valid_from,
        valid_to as q_valid_to
    FROM expanded_days
    ORDER BY channel_code, sku, manager_role, quarter_start, "Date" DESC
)
-- Финальная сборка с разделением логики daily и quarterly
SELECT 
    'daily'::text as duration, 
    t.channel_code, t.sku,
    COALESCE(r.role_ru, t.manager_role) as manager_role,
    t.manager, t.valid_from, t.valid_to, t."Date"
FROM expanded_days t
LEFT JOIN roles r ON t.manager_role = r.role_en
UNION ALL
SELECT 
    'quarterly'::text as duration, 
    t.channel_code, t.sku,
    COALESCE(r.role_ru, t.manager_role) as manager_role,
    qm.quarterly_manager as manager, 
    qm.q_valid_from as valid_from, 
    qm.q_valid_to as valid_to, 
    t."Date"
FROM expanded_days t
JOIN quarterly_managers qm 
    ON t.channel_code = qm.channel_code 
   AND t.sku = qm.sku 
   AND t.manager_role = qm.manager_role 
   AND t.quarter_start = qm.quarter_start
LEFT JOIN roles r ON t.manager_role = r.role_en;
