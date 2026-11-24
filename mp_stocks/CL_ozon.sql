SELECT 
 ozon_api_seller_fbo_warehouse_stocks.updated_at,
 ozon_api_seller_fbo_warehouse_stocks.stock_date,
 ozon_api_seller_fbo_warehouse_stocks.warehouse_name,
 item_code,
 sum(COALESCE(ozon_api_seller_fbo_warehouse_stocks.free_to_sell_amount::bigint, 0::bigint)) AS free_to_sell_amount,
 sum(COALESCE(ozon_api_seller_fbo_warehouse_stocks.reserved_amount::bigint, 0::bigint)) AS reserved,
 sum(COALESCE(ozon_api_seller_fbo_warehouse_stocks.free_to_sell_amount::bigint, 0::bigint) + COALESCE(ozon_api_seller_fbo_warehouse_stocks.reserved_amount::bigint, 0::bigint)) AS quantity_full,
 cab_name_group_with_nds.cab_name_group
FROM ozon.ozon_api_seller_fbo_warehouse_stocks
LEFT JOIN bi.cab_name_group_with_nds ON ozon_api_seller_fbo_warehouse_stocks.ozon_token_id = cab_name_group_with_nds.token_id AND ozon_api_seller_fbo_warehouse_stocks.stock_date >= cab_name_group_with_nds.nds_start AND ozon_api_seller_fbo_warehouse_stocks.stock_date <= cab_name_group_with_nds.nds_end
WHERE ozon_api_seller_fbo_warehouse_stocks.stock_date = '2026-05-28'::date
--and item_code like '%SKUA000275700%'
group by ozon_api_seller_fbo_warehouse_stocks.updated_at,
 cab_name_group_with_nds.cab_name_group,
 ozon_api_seller_fbo_warehouse_stocks.stock_date,
 ozon_api_seller_fbo_warehouse_stocks.warehouse_name,
 item_code
 order by cab_name_group, warehouse_name, item_code 

        