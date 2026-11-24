-- bi.newview source

--CREATE OR REPLACE VIEW bi.vw_mp_stocks
--AS 
with t1 as (
SELECT 
 stock_date as stock_date
, created_at as created_at
, updated_at as updated_at
, wb_token_id as token
, warehouse_name as warehouse_name
, supplier_article as articul_seller
, nm_id as articul_mp
, quantity as free_to_sell_amount
, in_way_to_client as reserved
, in_way_from_client as in_way_from_client
, quantity_full as quantity_full 
, 0 as defect_type
, 0 as expired_type
, 0 as quarantine_type
, 0 as utilization_type
, 'ЕР-ЕР003862' as partner_code
, 'WB' as marketplace_source
, cab_name_group
FROM wb.wb_api_stocks
left join bi.cab_name_group_with_nds on wb_token_id = token_id
where stock_date >= '2025-01-01'
and quantity + in_way_to_client + in_way_from_client <> 0
),
t2 as (
SELECT 
 stock_date as stock_date
, created_at as created_at
, updated_at as updated_at
, ozon_token_id as token
, warehouse_name as warehouse_name
, item_code as articul_seller
, sku as articul_mp
, free_to_sell_amount as free_to_sell_amount
, reserved_amount as reserved
, 0 as in_way_from_client
, free_to_sell_amount +  reserved_amount as quantity_full
, 0 as defect_type
, 0 as expired_type
, 0 as quarantine_type
, 0 as utilization_type
, 'ЦБ-ЦБ000357' as partner_code
, 'OZON' as marketplace_source
, cab_name_group
FROM ozon.ozon_api_seller_fbo_warehouse_stocks
left join bi.cab_name_group_with_nds on ozon_token_id  = token_id
where stock_date >= '2025-01-01'
and free_to_sell_amount + reserved_amount <> 0
),
t3 as (
SELECT 
 ys.stock_date as stock_date
, ys.created_at as created_at
, ys.updated_at as updated_at
, ys.token_id as token
, yw.warehouse_name as warehouse_name
, ys.offer_id as articul_seller
, 'none' as articul_mp
, coalesce(fit_type,0) as free_to_sell_amount
, coalesce(freeze_type,0) as reserved
, 0 as in_way_from_client
, coalesce(fit_type,0) + coalesce(freeze_type,0) + coalesce(defect_type,0) + coalesce(quarantine_type,0) as  quantity_full
, coalesce(defect_type,0) as defect_type
, coalesce(expired_type,0) as expired_type
, coalesce(quarantine_type,0) as quarantine_type
, coalesce(utilization_type,0) as utilization_type
, 'ЕР-ЕР004646' as partner_code
, 'YM' as marketplace_source
, cab_name_group
FROM yandex_market.yandex_stocks ys
left join yandex_market.yandex_warehouses yw on ys.warehouse_id = yw.warehouse_id
left join bi.cab_name_group_with_nds cab on ys.token_id  = cab.token_id
where stock_date >= '2025-01-01'
and fit_type + freeze_type + defect_type + expired_type + quarantine_type + utilization_type <> 0
)
select *
from t1
union all 
select *
from t2
union all 
select * from t3

