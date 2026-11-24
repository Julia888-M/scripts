SELECT 
-- stock_date
report_date 
 --, cab_name_group
--, created_at
--, updated_at
--, token
--, warehouse_name
--, articul_seller
--, articul_mp
--, barcode
/*, sum(free_to_sell_amount) as free_to_sell_amount
, sum(reserved)  as reserved
, sum(in_way_from_client) as in_way_from_client
, sum(quantity_full) as quantity_full 
, sum(defect_type) as defect_type
, sum(expired_type) as expired_type
, sum(quarantine_type) as quarantine_type
, sum(utilization_type) as utilization_type*/
--, partner_code
--, marketplace_source
--, organization_name
--, organization_id
/*, sum(available_stock_count) as available_stock_count
, sum(excess_stock_count) as excess_stock_count 
, sum(expiring_stock_count) as expiring_stock_count
, sum(other_stock_count) as other_stock_count
, sum(requested_stock_count) as requested_stock_count
, sum(return_from_customer_stock_count) as return_from_customer_stock_count
, sum(return_to_seller_stock_count) as return_to_seller_stock_count
, sum(stock_defect_stock_count) as stock_defect_stock_count 
, sum(transit_defect_stock_count) as transit_defect_stock_count
, sum(transit_stock_count) as transit_stock_count
, sum(valid_stock_count) as valid_stock_count
, sum(waiting_docs_stock_count) as waiting_docs_stock_count*/
, sum(
    plus(available_stock_count,
    plus(excess_stock_count,
    plus(expiring_stock_count,
    plus(other_stock_count,
    plus(requested_stock_count,
    plus(return_from_customer_stock_count,
    plus(return_to_seller_stock_count,
    plus(stock_defect_stock_count,
    plus(transit_defect_stock_count,
    plus(transit_stock_count,
    plus(valid_stock_count, waiting_docs_stock_count)
    ))))))))))
) as total_stock_count
--FROM `general`.tbl_mp_stocks
from ozon.vw_agg_ozon_fbo_stocks_daily
--where marketplace_source = 'OZON'
group by 
--stock_date
report_date 
--, cab_name_group
order by report_date desc
;