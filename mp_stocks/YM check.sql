select *,
wr.warehouse_name 
from yandex_market.yandex_stocks t2
left join yandex_market.yandex_warehouses wr on wr.warehouse_id = t2.warehouse_id
where 
created_at = '2025-11-26'
and offer_id = 'SKU0011448000'
