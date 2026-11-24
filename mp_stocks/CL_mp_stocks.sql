-- bi.vw_mp_stocks source

CREATE OR REPLACE VIEW bi.vw_mp_stocks
AS WITH t1_raw AS (
         SELECT wb_api_stocks.stock_date,
            wb_api_stocks.created_at,
            wb_api_stocks.updated_at,
            wb_api_stocks.wb_token_id AS token,
            wb_api_stocks.warehouse_name,
            wb_api_stocks.supplier_article AS articul_seller,
            wb_api_stocks.nm_id AS articul_mp,
            COALESCE(wb_api_stocks.quantity, 0) AS free_to_sell_amount,
            COALESCE(wb_api_stocks.in_way_to_client, 0) AS reserved,
            COALESCE(wb_api_stocks.in_way_from_client, 0) AS in_way_from_client,
            COALESCE(wb_api_stocks.quantity_full, 0) AS quantity_full,
            0 AS defect_type,
            0 AS expired_type,
            0 AS quarantine_type,
            0 AS utilization_type,
            'ЕР-ЕР003862'::text AS partner_code,
            'WB'::text AS marketplace_source,
            cab_name_group_with_nds.cab_name_group,
            row_number() OVER (PARTITION BY wb_api_stocks.stock_date, wb_api_stocks.wb_token_id, wb_api_stocks.warehouse_name, wb_api_stocks.supplier_article ORDER BY wb_api_stocks.updated_at DESC) AS rn
           FROM wb.wb_api_stocks
             LEFT JOIN bi.cab_name_group_with_nds ON wb_api_stocks.wb_token_id = cab_name_group_with_nds.token_id AND wb_api_stocks.stock_date >= cab_name_group_with_nds.nds_start AND wb_api_stocks.stock_date <= cab_name_group_with_nds.nds_end
          WHERE wb_api_stocks.stock_date >= '2025-01-01'::date AND COALESCE(wb_api_stocks.quantity_full, 0) <> 0
        ), t2_raw AS (
         SELECT ozon_api_seller_fbo_warehouse_stocks.stock_date,
            ozon_api_seller_fbo_warehouse_stocks.created_at,
            ozon_api_seller_fbo_warehouse_stocks.updated_at,
            ozon_api_seller_fbo_warehouse_stocks.ozon_token_id AS token,
            ozon_api_seller_fbo_warehouse_stocks.warehouse_name,
            ozon_api_seller_fbo_warehouse_stocks.item_code AS articul_seller,
            ozon_api_seller_fbo_warehouse_stocks.sku AS articul_mp,
            COALESCE(ozon_api_seller_fbo_warehouse_stocks.free_to_sell_amount::bigint, 0::bigint) AS free_to_sell_amount,
            COALESCE(ozon_api_seller_fbo_warehouse_stocks.reserved_amount::bigint, 0::bigint) AS reserved,
            0 AS in_way_from_client,
            COALESCE(ozon_api_seller_fbo_warehouse_stocks.free_to_sell_amount::bigint, 0::bigint) + COALESCE(ozon_api_seller_fbo_warehouse_stocks.reserved_amount::bigint, 0::bigint) AS quantity_full,
            0 AS defect_type,
            0 AS expired_type,
            0 AS quarantine_type,
            0 AS utilization_type,
            'ЦБ-ЦБ000357'::text AS partner_code,
            'OZON'::text AS marketplace_source,
            cab_name_group_with_nds.cab_name_group,
            row_number() OVER (PARTITION BY ozon_api_seller_fbo_warehouse_stocks.stock_date, ozon_api_seller_fbo_warehouse_stocks.ozon_token_id, ozon_api_seller_fbo_warehouse_stocks.warehouse_name, ozon_api_seller_fbo_warehouse_stocks.item_code ORDER BY ozon_api_seller_fbo_warehouse_stocks.updated_at DESC) AS rn
           FROM ozon.ozon_api_seller_fbo_warehouse_stocks
             LEFT JOIN bi.cab_name_group_with_nds ON ozon_api_seller_fbo_warehouse_stocks.ozon_token_id = cab_name_group_with_nds.token_id AND ozon_api_seller_fbo_warehouse_stocks.stock_date >= cab_name_group_with_nds.nds_start AND ozon_api_seller_fbo_warehouse_stocks.stock_date <= cab_name_group_with_nds.nds_end
          WHERE ozon_api_seller_fbo_warehouse_stocks.stock_date >= '2025-01-01'::date AND (COALESCE(ozon_api_seller_fbo_warehouse_stocks.free_to_sell_amount::bigint, 0::bigint) + COALESCE(ozon_api_seller_fbo_warehouse_stocks.reserved_amount::bigint, 0::bigint)) <> 0
        ), t3_raw AS (
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
            cab.cab_name_group,
            row_number() OVER (PARTITION BY ys.stock_date, ys.token_id, yw.warehouse_name, ys.offer_id ORDER BY ys.updated_at DESC) AS rn
           FROM yandex_market.yandex_stocks ys
             LEFT JOIN yandex_market.yandex_warehouses yw ON ys.warehouse_id = yw.warehouse_id
             LEFT JOIN bi.cab_name_group_with_nds cab ON ys.token_id = cab.token_id AND ys.stock_date >= cab.nds_start AND ys.stock_date <= cab.nds_end
          WHERE ys.stock_date >= '2025-01-01'::date AND (COALESCE(ys.fit_type, 0::bigint) + COALESCE(ys.freeze_type, 0::bigint) + COALESCE(ys.defect_type, 0::bigint) + COALESCE(ys.expired_type, 0::bigint) + COALESCE(ys.quarantine_type, 0::bigint) + COALESCE(ys.utilization_type, 0::bigint)) <> 0
        )
 SELECT t1_raw.stock_date,
    t1_raw.created_at,
    t1_raw.updated_at,
    t1_raw.token,
    t1_raw.warehouse_name,
    t1_raw.articul_seller,
    t1_raw.articul_mp,
    t1_raw.free_to_sell_amount,
    t1_raw.reserved,
    t1_raw.in_way_from_client,
    t1_raw.quantity_full,
    t1_raw.defect_type,
    t1_raw.expired_type,
    t1_raw.quarantine_type,
    t1_raw.utilization_type,
    t1_raw.partner_code,
    t1_raw.marketplace_source,
    t1_raw.cab_name_group
   FROM t1_raw
  WHERE t1_raw.rn = 1
UNION ALL
 SELECT t2_raw.stock_date,
    t2_raw.created_at,
    t2_raw.updated_at,
    t2_raw.token,
    t2_raw.warehouse_name,
    t2_raw.articul_seller,
    t2_raw.articul_mp,
    t2_raw.free_to_sell_amount,
    t2_raw.reserved,
    t2_raw.in_way_from_client,
    t2_raw.quantity_full,
    t2_raw.defect_type,
    t2_raw.expired_type,
    t2_raw.quarantine_type,
    t2_raw.utilization_type,
    t2_raw.partner_code,
    t2_raw.marketplace_source,
    t2_raw.cab_name_group
   FROM t2_raw
  WHERE t2_raw.rn = 1
UNION ALL
 SELECT t3_raw.stock_date,
    t3_raw.created_at,
    t3_raw.updated_at,
    t3_raw.token,
    t3_raw.warehouse_name,
    t3_raw.articul_seller,
    t3_raw.articul_mp,
    t3_raw.free_to_sell_amount,
    t3_raw.reserved,
    t3_raw.in_way_from_client,
    t3_raw.quantity_full,
    t3_raw.defect_type,
    t3_raw.expired_type,
    t3_raw.quarantine_type,
    t3_raw.utilization_type,
    t3_raw.partner_code,
    t3_raw.marketplace_source,
    t3_raw.cab_name_group
   FROM t3_raw
  WHERE t3_raw.rn = 1;

-- Permissions
/*
ALTER TABLE bi.vw_mp_stocks OWNER TO bi_user;
GRANT ALL ON TABLE bi.vw_mp_stocks TO bi_user;
GRANT SELECT ON TABLE bi.vw_mp_stocks TO dwh_admin;
*/