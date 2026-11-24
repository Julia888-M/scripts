SELECT 
"date"
, sku
, token_id
, sum(ordered_products_count) as orderscount 
, sum(ordered_products_rub) as orderssumrub
FROM yandex_market.yandex_sales_funnel
where 1=1
and "date" between '2025-01-01' and current_date
and ordered_products_count<>0
and ordered_products_rub <> 0
group by 
"date"
, sku
, token_id
;