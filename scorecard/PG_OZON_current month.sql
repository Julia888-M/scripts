SELECT
    t1.operation_date::date,
    'ЦБ-ЦБ000357' as "Партнер планирования - Код",
    t2.offer_id,
    t1.type,
    (CASE WHEN t1.type = 'returns' THEN t1.sku_count * -1 ELSE t1.sku_count END) AS quantity,
    (CASE WHEN t1.type = 'returns' THEN t1.accruals_for_sale * -1 ELSE t1.accruals_for_sale END) AS sum_with_nds,
    (case when substring(t3.cab_name,8)='Бьюти Инновации' 
	or substring(t3.cab_name,8)='Эко Лаборатория'
	then (CASE WHEN t1.type = 'returns' THEN t1.accruals_for_sale * -1 ELSE t1.accruals_for_sale END)
	else (CASE WHEN t1.type = 'returns' THEN t1.accruals_for_sale * -1 ELSE t1.accruals_for_sale END)/1.2
	end) as sum_no_nds 
FROM ozon.ozon_api_seller_transactions_nm t1
LEFT JOIN ozon.ozon_api_seller_products t2 ON t1.sku::text = t2.sku::text
left join (select distinct token_id,cab_name from general.bi_md_users_api_excel) t3 on cast(t2.token_id as int) = t3.token_id    
WHERE t1.operation_date::date >= date_trunc('month', current_date)::date
AND t1.accruals_for_sale <> 0
and t1.type = 'returns'