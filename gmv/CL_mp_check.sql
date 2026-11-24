SET statement_timeout TO 7200000;
SELECT
    date_trunc('day',cast(operation_date as date)) as date,
    t1.ozon_token_id,
--    t2.offer_id,
    SUM(CASE WHEN t1.type = 'returns' THEN abs(t1.sku_count)* -1 ELSE t1.sku_count END) AS quantity,
    SUM(CASE WHEN t1.type = 'returns' THEN abs(t1.accruals_for_sale)* -1 ELSE t1.accruals_for_sale END) AS sum_with_nds
FROM ozon.ozon_api_seller_transactions_nm t1
--FROM ozon.sts_mv_ozon_api_seller_transactions_nm t1
LEFT JOIN ozon.sts_mv_ozon_api_seller_products t2
    ON t1.sku = t2.sku
WHERE 1=1
--and date_trunc('month',cast(operation_date as date))  >= current_date - 61
--and date_trunc('month',cast(operation_date as date))  < current_date +1 
and date_trunc('day',cast(operation_date as date))  >= current_date-61
and date_trunc('day',cast(operation_date as date))  <= current_date+1 
AND t1.accruals_for_sale <> 0
and t1.ozon_token_id = '160920247'
GROUP BY
   date_trunc('day',cast(t1.operation_date as date))
    ,t1.ozon_token_id
--    t2.offer_id
order by date_trunc('day',cast(operation_date as date)) desc
;

SELECT
		date_trunc('day',cast(status_update_date as date)) "Дата",
		status,
		details,
		--initial_items,
		shop_sku,
    --            token_id,
		sum((COALESCE(marketplace_cost_per_item,0)+COALESCE(cashback_cost_per_item,0)+COALESCE(buyer_cost_per_item,0))*item_count) "Сумма, руб"
		--item_count "Кол-во шт"
from yandex_market.v_yandex_orders_not_rejected
where 1=1
--and status in ('DELIVERED','PARTIALLY_DELIVERED','RETURNED')
and cast(status_update_date as date) >= current_date-61
and cast(status_update_date as date) <= current_date+1
--and details not like '%REJECTED%'
group by date_trunc('day',cast(status_update_date as date))
, status
, details
--, initial_items
, shop_sku
order by "Дата" desc
;

SELECT
		date_trunc('month',cast(status_update_date as date)) "Дата",
	--	shop_sku,
    --            token_id,
		sum((COALESCE(marketplace_cost_per_item,0)+COALESCE(cashback_cost_per_item,0)+COALESCE(buyer_cost_per_item,0))*item_count) "Сумма, руб"
	--	item_count "Кол-во шт"
from yandex_market.v_yandex_orders_not_rejected
where 1=1
and status in ('DELIVERED','PARTIALLY_DELIVERED','RETURNED')
and cast(status_update_date as date) >= current_date-61
and cast(status_update_date as date) < current_date+1
group by date_trunc('month',cast(status_update_date as date))
order by "Дата"
--and details not like '%REJECTED%'
;

 SELECT o.status_update_date::date,
       --     o.shop_sku,
       --     o.token_id,
          --  o.marketplace_cost_per_item,
          --  o.buyer_cost_per_item,
          --  o.cashback_cost_per_item,
        --    o.campaings_id,
        --    o.item_count,
            status,
            details,
            sum((COALESCE(marketplace_cost_per_item, 0::double precision) + COALESCE(cashback_cost_per_item, 0::double precision) + COALESCE(buyer_cost_per_item, 0::double precision)) * (o.item_count - COALESCE((regexp_match(replace(replace(replace(replace(o.details, ''''::text, '"'::text), 'False'::text, 'false'::text), 'True'::text, 'true'::text), 'None'::text, 'null'::text), '"itemCount":\s*(\d+)'::text))[1]::integer, 0))) AS sales_rub_with_nds
            FROM yandex_market.yandex_orders o
          WHERE 1 = 1 AND o.status::text = 'PARTIALLY_DELIVERED'::text AND o.details ~~ '%REJECTED%'::text AND o.status_update_date >= (CURRENT_DATE - 61) AND o.status_update_date <= (CURRENT_DATE + 1)
          group by o.status_update_date::date,
          status,
          details
          order by status_update_date DESC
          
select
date_trunc('day',cast(rr_dt as date)) as date,
--rr_dt,
--sa_name,
--wb_token_id as token_id,
sum(case when doc_type_name='Возврат' then quantity*-1 else quantity end) as quantity,
sum(case when doc_type_name='Возврат' then retail_price_withdisc_rub_units*-1 else retail_price_withdisc_rub_units end) as retail_price_withdisc_rub_units
from wb.sts_mv_wb_api_report_nm
--from wb.wb_api_report_nm
where 1=1
--and sa_name = 'SKUA001112700'
and retail_price_withdisc_rub_units<>0
and date_trunc('day',cast(rr_dt as date))  >= current_date-61
and date_trunc('day',cast(rr_dt as date))  < current_date+1
--and rr_dt  >= current_date-61
--and rr_dt  < current_date+1
--and wb_token_id = '160920241' --Миксит
--and wb_token_id = '160920242' --Бьюти Инновации
--and wb_token_id = '160920243' --Эксперт криэйшн
--and wb_token_id = '160920244' --Смарт Бьюти
-- and wb_token_id = '160920245' --Эко Лаборатория
--and wb_token_id = '160920246' --Лаборатория здоровья
group by
date_trunc('day',cast(rr_dt as date))
--rr_dt
--sa_name,
--, token_id
order by date_trunc('day',cast(rr_dt as date))  desc

select
date_sale
--, vendorcode
, token_id 
, sum(sales_quantity) as  sales_quantity
, sum(sales_rub_with_nds) as sales_rub_with_nds
from
bi.wb_buyouts_funnel
group by 
date_sale
--, vendorcode
, token_id 