WITH t1 AS (
         SELECT wb_api_stocks.stock_date,
            wb_api_stocks.created_at,
            wb_api_stocks.updated_at,
            wb_api_stocks.wb_token_id AS token,
            wb_api_stocks.warehouse_name,
            wb_api_stocks.supplier_article AS articul_seller,
            wb_api_stocks.nm_id AS articul_mp,
            wb_api_stocks.quantity AS free_to_sell_amount,
            wb_api_stocks.in_way_to_client AS reserved,
            wb_api_stocks.in_way_from_client,
            wb_api_stocks.quantity_full,
            0 AS defect_type,
            0 AS expired_type,
            0 AS quarantine_type,
            0 AS utilization_type,
            'ЕР-ЕР003862'::text AS partner_code,
            'WB'::text AS marketplace_source,
            cab_name_group_with_nds.cab_name_group
           FROM wb.wb_api_stocks
             LEFT JOIN bi.cab_name_group_with_nds ON wb_api_stocks.wb_token_id = cab_name_group_with_nds.token_id
          WHERE wb_api_stocks.stock_date >= '2025-01-01'::date AND (wb_api_stocks.quantity + wb_api_stocks.in_way_to_client + wb_api_stocks.in_way_from_client) <> 0
        ), t2 AS (
         SELECT ozon_api_seller_fbo_warehouse_stocks.stock_date,
            ozon_api_seller_fbo_warehouse_stocks.created_at,
            ozon_api_seller_fbo_warehouse_stocks.updated_at,
            ozon_api_seller_fbo_warehouse_stocks.ozon_token_id AS token,
            ozon_api_seller_fbo_warehouse_stocks.warehouse_name,
            ozon_api_seller_fbo_warehouse_stocks.item_code AS articul_seller,
            ozon_api_seller_fbo_warehouse_stocks.sku AS articul_mp,
            ozon_api_seller_fbo_warehouse_stocks.free_to_sell_amount,
            ozon_api_seller_fbo_warehouse_stocks.reserved_amount AS reserved,
            0 AS in_way_from_client,
            ozon_api_seller_fbo_warehouse_stocks.free_to_sell_amount + ozon_api_seller_fbo_warehouse_stocks.reserved_amount AS quantity_full,
            0 AS defect_type,
            0 AS expired_type,
            0 AS quarantine_type,
            0 AS utilization_type,
            'ЦБ-ЦБ000357'::text AS partner_code,
            'OZON'::text AS marketplace_source,
            cab_name_group_with_nds.cab_name_group
           FROM ozon.ozon_api_seller_fbo_warehouse_stocks
             LEFT JOIN bi.cab_name_group_with_nds ON ozon_api_seller_fbo_warehouse_stocks.ozon_token_id = cab_name_group_with_nds.token_id
          WHERE ozon_api_seller_fbo_warehouse_stocks.stock_date >= '2025-01-01'::date AND (ozon_api_seller_fbo_warehouse_stocks.free_to_sell_amount + ozon_api_seller_fbo_warehouse_stocks.reserved_amount) <> 0
        ), t3 AS (
         SELECT ys.stock_date,
            ys.created_at,
            ys.updated_at,
            ys.token_id AS token,
            yw.warehouse_name,
            ys.offer_id AS articul_seller,
            'none'::text AS articul_mp,
            COALESCE(ys.fit_type, 0::bigint) AS free_to_sell_amount,
            COALESCE(ys.freeze_type, 0::bigint) AS reserved,
            0 AS in_way_from_client,
            COALESCE(ys.fit_type, 0::bigint) + COALESCE(ys.freeze_type, 0::bigint) + COALESCE(ys.defect_type, 0::bigint) + COALESCE(ys.quarantine_type, 0::bigint) AS quantity_full,
            COALESCE(ys.defect_type, 0::bigint) AS defect_type,
            COALESCE(ys.expired_type, 0::bigint) AS expired_type,
            COALESCE(ys.quarantine_type, 0::bigint) AS quarantine_type,
            COALESCE(ys.utilization_type, 0::bigint) AS utilization_type,
            'ЕР-ЕР004646'::text AS partner_code,
            'YM'::text AS marketplace_source,
            cab.cab_name_group
           FROM yandex_market.yandex_stocks ys
             LEFT JOIN yandex_market.yandex_warehouses yw ON ys.warehouse_id = yw.warehouse_id
             LEFT JOIN bi.cab_name_group_with_nds cab ON ys.token_id = cab.token_id
          WHERE ys.stock_date >= '2025-01-01'::date AND (ys.fit_type + ys.freeze_type + ys.defect_type + ys.expired_type + ys.quarantine_type + ys.utilization_type) <> 0
        ),
 result as (       
 SELECT t1.stock_date,
    t1.created_at,
    t1.updated_at,
    t1.token,
    t1.warehouse_name,
    t1.articul_seller,
    t1.articul_mp,
    t1.free_to_sell_amount,
    t1.reserved,
    t1.in_way_from_client,
    t1.quantity_full,
    t1.defect_type,
    t1.expired_type,
    t1.quarantine_type,
    t1.utilization_type,
    t1.partner_code,
    t1.marketplace_source,
    t1.cab_name_group
   FROM t1
UNION ALL
 SELECT t2.stock_date,
    t2.created_at,
    t2.updated_at,
    t2.token,
    t2.warehouse_name,
    t2.articul_seller,
    t2.articul_mp,
    t2.free_to_sell_amount,
    t2.reserved,
    t2.in_way_from_client,
    t2.quantity_full,
    t2.defect_type,
    t2.expired_type,
    t2.quarantine_type,
    t2.utilization_type,
    t2.partner_code,
    t2.marketplace_source,
    t2.cab_name_group
   FROM t2
UNION ALL
 SELECT t3.stock_date,
    t3.created_at,
    t3.updated_at,
    t3.token,
    t3.warehouse_name,
    t3.articul_seller,
    t3.articul_mp,
    t3.free_to_sell_amount,
    t3.reserved,
    t3.in_way_from_client,
    t3.quantity_full,
    t3.defect_type,
    t3.expired_type,
    t3.quarantine_type,
    t3.utilization_type,
    t3.partner_code,
    t3.marketplace_source,
    t3.cab_name_group
   FROM t3
   )
   select 
    sum(free_to_sell_amount)
   , sum(reserved)
   , sum(in_way_from_client)
   , sum(quantity_full)
   , sum(utilization_type)
   , sum(defect_type)
   , sum(expired_type)
   , sum(quarantine_type)
   from result
   ;