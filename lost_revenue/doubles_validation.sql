WITH final_result AS (
  WITH ranked_sku_managers AS (
    SELECT 
        "sku",
        "name",
        "manager_role",
        "manager",
        "valid_to",
        -- Нумеруем строки для каждого SKU в порядке убывания даты valid_to
        ROW_NUMBER() OVER(PARTITION BY "sku" ORDER BY "valid_to" DESC) as rn
    FROM "stage_atom"."sku_managers"
)
SELECT 
    "sku",
    "name",
    "valid_to",
    -- Разворачиваем роли в столбцы (замените названия ролей на реальные из вашей базы)
    MAX(CASE WHEN "manager_role" = 'ym_manager' THEN "manager" END) AS "ym_manager",
    MAX(CASE WHEN "manager_role" = 'ozon_manager' THEN "manager" END) AS "ozon_manager",
    MAX(CASE WHEN "manager_role" = 'wb_category_manager' THEN "manager" END) AS "wb_category_manager",
    MAX(CASE WHEN "manager_role" = 'ozon_category_manager' THEN "manager" END) AS "ozon_category_manager",
    MAX(CASE WHEN "manager_role" = 'wb_manager' THEN "manager" END) AS "wb_manager",
    MAX(CASE WHEN "manager_role" = 'ym_category_manager' THEN "manager" END) AS "ym_category_manager"
FROM ranked_sku_managers
WHERE rn = 1 -- Оставляем только строки с максимальной датой valid_to
GROUP BY 
    "sku", 
    "name", 
    "valid_to"
)
SELECT COUNT(*), COUNT(DISTINCT final_result)
FROM final_result;

