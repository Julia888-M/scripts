         SELECT "wb"."wb_api_stocks_wh".stock_date,
            "wb"."wb_api_stocks_wh".created_at,
            "wb"."wb_api_stocks_wh".updated_at,
            "wb"."wb_api_stocks_wh".wb_token_id AS token,
            "wb"."wb_api_stocks_wh".warehouse_name,
            "wb"."wb_api_stocks_wh".supplier_article AS articul_seller,
            "wb"."wb_api_stocks_wh".nm_id AS articul_mp,
            COALESCE("wb"."wb_api_stocks_wh".quantity, 0) AS free_to_sell_amount,
            COALESCE("wb"."wb_api_stocks_wh".in_way_to_client, 0) AS reserved,
            COALESCE("wb"."wb_api_stocks_wh".in_way_from_client, 0) AS in_way_from_client,
            COALESCE("wb"."wb_api_stocks_wh".quantity, 0) + COALESCE("wb"."wb_api_stocks_wh".in_way_to_client, 0) + COALESCE("wb"."wb_api_stocks_wh".in_way_from_client, 0) AS quantity_full,
            0 AS defect_type,
            0 AS expired_type,
            0 AS quarantine_type,
            0 AS utilization_type,
            'ЕР-ЕР003862'::text AS partner_code,
            'WB'::text AS marketplace_source,
            cab_name_group_with_nds.cab_name_group,
            row_number() OVER (PARTITION BY "wb"."wb_api_stocks_wh".stock_date, "wb"."wb_api_stocks_wh".wb_token_id, "wb"."wb_api_stocks_wh".warehouse_name, "wb"."wb_api_stocks_wh".supplier_article ORDER BY "wb"."wb_api_stocks_wh".updated_at DESC) AS rn
           FROM "wb"."wb_api_stocks_wh"
           LEFT JOIN bi.cab_name_group_with_nds ON "wb"."wb_api_stocks_wh".wb_token_id = cab_name_group_with_nds.token_id AND "wb"."wb_api_stocks_wh".stock_date >= cab_name_group_with_nds.nds_start AND "wb"."wb_api_stocks_wh".stock_date <= cab_name_group_with_nds.nds_end
          WHERE "wb"."wb_api_stocks_wh".stock_date > '2026-07-18'::date 
