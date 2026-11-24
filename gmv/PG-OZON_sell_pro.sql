SET statement_timeout TO 7200000;
SELECT
    t1.operation_date,
    t1.ozon_token_id,
    t2.offer_id,
    t1.sku_count,
    t1.type,
    t1.accruals_for_sale
FROM ozon.sts_mv_ozon_api_seller_transactions_nm t1
LEFT JOIN ozon.sts_mv_ozon_api_seller_products t2
    ON t1.sku = t2.sku
WHERE t1.operation_date  >= '2025-10-01'
and t1.operation_date  <= '2025-12-31' 
AND t1.accruals_for_sale <> 0
/*GROUP BY
    t1.operation_date,
    t1.ozon_token_id,
    t2.offer_id*/