SELECT 
--token_id
 stock_date
--, warehouse_id
--, offer_id
--, stocks_updated_at
--, turnover_summary_turnover
--, turnover_summary_turnover_days
, sum(available_type) as available_type
, sum(defect_type) as defect_type
, sum(expired_type) as expired_type
, sum(fit_type) as fit_type
, sum(freeze_type) as freeze_type
, sum(quarantine_type) as quarantine_type
, sum(utilization_type) as utilization_type 
--, id
--, campaings_id
--, business_id
--, created_at
, updated_at
FROM yandex_market.yandex_stocks
group by stock_date
, updated_at
order by stock_date DEsc
;