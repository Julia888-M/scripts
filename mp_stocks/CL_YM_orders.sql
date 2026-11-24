SELECT 
 yo.status_update_date::date
, yo.market_sku
, yo.shop_sku
--, sum(yo.item_count) as item_count
, coalesce(sum(case when status = 'DELIVERY' then yo.item_count end),0) as delivery_count
, coalesce(sum(case when status = 'PICKUP' then yo.item_count end),0) as pickup_count
, coalesce(sum(case when status = 'UNKNOWN' then yo.item_count end),0) as unknown_count
, coalesce(sum(case when status = 'PROCESSING' then yo.item_count end),0) as processing_count
, coalesce(sum(case when status = 'UNPAID' then yo.item_count end),0) as unpaid_count
, yo.warehouse_name
, yo.token_id
, nds.organization 
FROM yandex_market.yandex_orders yo
LEFT JOIN (
	select distinct *
	from general.bi_md_users_api_excel ) nds 
	ON yo.token_id = nds.token_id 
where status_update_date::date >= '2025-01-01'
and status in ('DELIVERY','PICKUP','UNKNOWN','PROCESSING','UNPAID')
group by 
yo.status_update_date::date
, yo.shop_sku
, yo.warehouse_name
, yo.token_id
, nds.organization 
, yo.market_sku
;

select distinct status
FROM yandex_market.yandex_orders;

