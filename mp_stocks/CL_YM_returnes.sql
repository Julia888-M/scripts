SELECT 
yr.token_id
, update_date::date
, market_sku
, shop_sku
, logistic_pickup_point_name
,  nds.organization 
, coalesce(sum(case when return_type='RETURN' and shipment_status='CREATED' then item_count end),0) as return_created_count
, coalesce(sum(case when return_type='RETURN' and shipment_status='IN_TRANSIT' then item_count end),0) as return_in_transit_count
, coalesce(sum(case when return_type='RETURN' and shipment_status='RECEIVED' then item_count end),0) as return_received_count
, coalesce(sum(case when return_type='RETURN' and shipment_status='EXPIRED' then item_count end),0) as return_expired_count
, coalesce(sum(case when return_type='RETURN' and shipment_status='CANCELLED' then item_count end),0) as return_cancelled_count
, coalesce(sum(case when return_type='RETURN' and shipment_status='FULFILMENT_RECEIVED' then item_count end),0) as return_fulfilment_received_count
, coalesce(sum(case when return_type='UNREDEEMED' and shipment_status='CREATED' then item_count end),0) as unredeemed_created_count
, coalesce(sum(case when return_type='UNREDEEMED' and shipment_status='LOST' then item_count end),0) as unredeemed_lost_count
, coalesce(sum(case when return_type='UNREDEEMED' and shipment_status='RECEIVED' then item_count end),0) as unredeemed_received_count
, coalesce(sum(case when return_type='UNREDEEMED' and shipment_status='IN_TRANSIT' then item_count end),0) as unredeemed_in_transit_count
, coalesce(sum(case when return_type='UNREDEEMED' and shipment_status='FULFILMENT_RECEIVED' then item_count end),0) as unredeemed_fulfilment_received_count
FROM yandex_market.yandex_returns yr
LEFT JOIN (
	select distinct *
	from general.bi_md_users_api_excel ) nds
ON yr.token_id = nds.token_id 
where update_date::date>='2025-01-01'
and yr.logistic_pickup_point_type = 'WAREHOUSE'
group by 
yr.token_id
, market_sku
, shop_sku
, logistic_pickup_point_name
, update_date::date
, nds.organization 
order by update_date desc
;

select distinct return_type, shipment_status
FROM yandex_market.yandex_returns;

select distinct logistic_pickup_point_type 
FROM yandex_market.yandex_returns;
