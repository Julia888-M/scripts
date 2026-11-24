with wb as (
	SELECT 
	"date"
	, vendorcode as sku
	, 'WB' as marketplace
	, token_id 
	, sum(orderscount) as orderscount 
	, sum(orderssumrub) as orderssumrub 
	FROM wb.wb_sales_funnel
	where 1=1
	and "date" between '2025-01-01' and CURRENT_DATE
	and orderscount <> 0
	and orderssumrub <> 0
	group by 
	1, 2, 4
),
ozon as (
	SELECT 
	 osf."date"
	, oasp.offer_id AS sku
	, 'OZON' as marketplace
	, osf.token_id 
	, sum(osf.ordered_units) as orderscount 
	, sum(osf.revenue) as orderssumrub 
	FROM ozon.ozon_sales_funnel osf
	JOIN ozon.ozon_api_seller_products oasp
	ON osf.id = oasp.sku
	where 1=1
	and osf."date" between '2025-01-01' and current_date
	and osf.revenue <> 0
	and osf.ordered_units <> 0
	group by 
	1, 2, 4
),
ym as (
	SELECT 
	"date"
	, sku
	, 'YM' as marketplace
	, token_id 
	, sum(ordered_products_count) as orderscount 
	, sum(ordered_products_rub) as orderssumrub
	FROM yandex_market.yandex_sales_funnel
	where 1=1
	and "date" between '2025-01-01' and current_date
	and ordered_products_count<>0
	and ordered_products_rub <> 0
	group by 
	1, 2, 4
),
nds as (
	SELECT 
	token_id
	, token_id_text
	, mp
	, cab_name
	, cab_name_group
	, nds_start
	, nds_end
	, nds
	FROM bi.cab_name_group_with_nds
),
combined_mp as (
	SELECT "date", sku, marketplace, token_id, orderscount, orderssumrub FROM wb 
	UNION ALL
	SELECT "date", sku, marketplace, token_id, orderscount, orderssumrub FROM ozon
	UNION ALL
	SELECT "date", sku, marketplace, token_id, orderscount, orderssumrub FROM ym
) 
SELECT 
 -- MD5(CONCAT(cm."date"::text, '_', UPPER(cm.sku), '_', UPPER(cm.marketplace), '_', cm.token_id)) AS unique_key
 cm."date"
--, cm.sku
, cm.marketplace
--, cm.token_id
--, nds.nds
, sum(cm.orderscount) as orderscount
, sum(cm.orderssumrub) as orderssumrub 
/*, cm.orderssumrub / nds.nds as orderssumrub_no_nds
, cm.orderssumrub/cm.orderscount as potential_price
, (cm.orderssumrub/cm.orderscount)/nds.nds as potential_price_no_nds
, ROUND(
  AVG(cm.orderscount) OVER (
    PARTITION BY cm.sku, cm.marketplace
    ORDER BY cm."date" 
    RANGE BETWEEN INTERVAL '30 days' PRECEDING AND CURRENT ROW
   )::numeric, 2
  ) AS avg_orderscount_last_30d
, ROUND(
  AVG(cm.orderssumrub) OVER (
    PARTITION BY cm.sku, cm.marketplace
    ORDER BY cm."date" 
    RANGE BETWEEN INTERVAL '30 days' PRECEDING AND CURRENT ROW
   )::numeric, 2
  ) AS avg_orderssumrub_last_30d
, ROUND(
  AVG(cm.orderscount) OVER (
    PARTITION BY cm.sku, cm.marketplace
    ORDER BY cm."date" 
    RANGE BETWEEN INTERVAL '30 days' PRECEDING AND CURRENT ROW
   )::numeric, 2
  ) * 5 AS orderscount_target_balance
, ROUND(
  AVG(cm.orderssumrub) OVER (
    PARTITION BY cm.sku, cm.marketplace
    ORDER BY cm."date" 
    RANGE BETWEEN INTERVAL '30 days' PRECEDING AND CURRENT ROW
   )::numeric, 2
  ) * 5 AS orderssumrub_target_balance*/
FROM combined_mp cm
left join nds on cm.token_id = nds.token_id and cm."date" between nds_start and nds.nds_end 
group by 
cm."date"
--, cm.sku
, cm.marketplace
--, cm.token_id
--, nds.nds
;

