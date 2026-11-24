SELECT 
id
, company_id
, wb_token_id
, stock_date
, last_change_date
, warehouse_name
, supplier_article
, nm_id
, barcode
, quantity
, in_way_to_client
, in_way_from_client
, quantity_full
, category
, subject
, brand
, tech_size
, days_on_site
, price_units
, discount
, is_supply
, is_realization
, sc_code
, quantity_not_in_orders
, price_with_disc_units
, created_at
, updated_at
FROM wb.wb_api_stocks
where supplier_article='SKUA000677100'
and stock_date = '2026-05-15'
and warehouse_name like '%Коледино%';

SELECT 
stock_date
, created_at
, updated_at
, "token"
, warehouse_name
, articul_seller
, articul_mp
, free_to_sell_amount
, reserved
, in_way_from_client
, quantity_full
, defect_type
, expired_type
, quarantine_type
, utilization_type
, partner_code
, marketplace_source
, cab_name_group
FROM bi.vw_mp_stocks
where articul_seller ='SKUA000269400'
and stock_date = '2026-05-15'
and warehouse_name like '%Новосемейкино%'
;

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
            cab_name_group_with_nds.cab_name_group
           FROM wb.wb_api_stocks
             LEFT JOIN bi.cab_name_group_with_nds 
             	ON wb_api_stocks.wb_token_id = cab_name_group_with_nds.token_id 
             	AND wb_api_stocks.stock_date between cab_name_group_with_nds.nds_start AND cab_name_group_with_nds.nds_end
           WHERE wb_api_stocks.stock_date >= '2025-01-01'::date AND COALESCE(wb_api_stocks.quantity_full, 0) <> 0
            and supplier_article ='SKUA000269400'
			and stock_date = '2026-05-15'
			and warehouse_name like '%Новосемейкино%';



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
             LEFT JOIN bi.cab_name_group_with_nds cab 
             ON ys.token_id = cab.token_id
             AND ys.stock_date between cab.nds_start AND cab.nds_end
          WHERE ys.stock_date >= '2025-01-01'::date AND (COALESCE(ys.fit_type, 0::bigint) + COALESCE(ys.freeze_type, 0::bigint) + COALESCE(ys.defect_type, 0::bigint) + COALESCE(ys.expired_type, 0::bigint) + COALESCE(ys.quarantine_type, 0::bigint) + COALESCE(ys.utilization_type, 0::bigint)) <> 0