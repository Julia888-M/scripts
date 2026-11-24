-- === ЧАСТЬ 1: SKU MANAGERS ===
-- Обычные данные из таблицы за существующий период
SELECT 
null as channel_code
, sku
, manager_role
, manager
, valid_from
, valid_to
, "Date"
FROM stage_atom.sku_managers sm
inner join olap."Calendar" c ON "Date" BETWEEN valid_from AND valid_to
where "Date" between 
	(SELECT MIN(valid_from) FROM stage_atom.sku_managers)  
	and (date_trunc('month', current_date) + interval '2 month' - interval '1 day')::date
UNION ALL
-- Искусственное дублирование строк от 21.08.2026 назад до 01.01.2026
SELECT 
    null as channel_code
    , sm.sku
    , sm.manager_role
    , sm.manager
    , sm.valid_from
    , sm.valid_to
    , c."Date"
FROM stage_atom.sku_managers sm
-- Привязываем к этим строкам ВСЕ дни календаря из диапазона с 01.01.2026 до 20.08.2026 включительно
INNER JOIN olap."Calendar" c ON c."Date" BETWEEN '2026-01-01'::date AND (SELECT MIN(valid_from) FROM stage_atom.sku_managers) - INTERVAL '1 day'
-- Находим строки, у которых valid_from равен самой ранней дате в таблице (2026-08-21)
WHERE sm.valid_from = (SELECT MIN(valid_from) FROM stage_atom.sku_managers)
UNION ALL
-- === ЧАСТЬ 2: CHANNEL MANAGERS ===
-- Обычные данные из таблицы за существующий период
SELECT 
    cm.channel_code
    , null as sku
    , cm.manager_role
    , cm.manager
    , cm.valid_from
    , cm.valid_to
    , c."Date"
FROM stage_atom.channel_managers cm
INNER JOIN olap."Calendar" c ON c."Date" BETWEEN cm.valid_from AND cm.valid_to
WHERE c."Date" <= (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '2 month' - INTERVAL '1 day')::date
UNION ALL
-- Искусственное дублирование строк для каналов назад до 01.01.2026
SELECT 
    cm.channel_code
    , null as sku
    , cm.manager_role
    , cm.manager
    , cm.valid_from
    , cm.valid_to
    , c."Date"
FROM stage_atom.channel_managers cm
INNER JOIN olap."Calendar" c ON c."Date" BETWEEN '2026-01-01'::date AND (SELECT MIN(valid_from) FROM stage_atom.channel_managers) - INTERVAL '1 day'
WHERE cm.valid_from = (SELECT MIN(valid_from) FROM stage_atom.channel_managers)