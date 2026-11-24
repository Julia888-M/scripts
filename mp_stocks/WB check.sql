SELECT created_at,
--last_change_date,
wb_token_id,
supplier_article,
sc_code,
warehouse_name,
count (last_change_date) as last_change_date_count
FROM wb.wb_api_stocks
where created_at = '2025-11-26'
--and supplier_article = 'SKUA000464100'
and warehouse_name = 'Электросталь'
group by 
created_at,
--last_change_date,
wb_token_id,
supplier_article,
sc_code,
warehouse_name
having count (last_change_date)>1
order by supplier_article;

SELECT *
FROM wb.wb_api_stocks
where created_at = '2025-11-26'
and supplier_article = 'SKU0011897000'
and warehouse_name = 'Электросталь'
