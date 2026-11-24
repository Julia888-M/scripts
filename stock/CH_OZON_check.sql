SELECT 
--report_date
--, client_id
--, seller_name
--, sku
--, offer_id
--, product_name
--, current_price
--, old_price
--, min_price
--, volume_weight
--, warehouse_id
--, warehouse_name
--, warehouse_type
--, cluster_id
--, cluster_name
--, cluster_type
--, macrolocal_cluster_id
--, turnover_grade_ru
--, turnover_grade_cluster_ru
--, item_tags_arr
/*, barcodes_arr
, ads_global
, ads_cluster
, idc_global
, idc_cluster
, days_without_sales_global
, days_without_sales_cluster
, available_stock_count
, excess_stock_count
, expiring_stock_count
, other_stock_count
, requested_stock_count
, return_from_customer_stock_count
, return_to_seller_stock_count*/
 sum(stock_defect_stock_count) as stock_defect_stock_count 
, sum(transit_defect_stock_count) as transit_defect_stock_count
/*, transit_stock_count
, valid_stock_count
, waiting_docs_stock_count
, updated_at_mv*/
FROM ozon.tbl_ozon_stocks_unified
where report_date = '2026-06-30'
and offer_id = 'SKUA000825800';