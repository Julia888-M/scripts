SELECT 
--order_id
 --creation_date as creation_date
   date_trunc('month',status_update_date) as status_update_date
--date_trunc('day',status_update_date) as status_update_date
--, partner_order_id
--, payment_type
--, fake
--, buyer_type
--, initial_items
--, region_id
--, region_name
--, status
--, offer_name
--, market_sku
--, shop_sku*/
, sum(item_count) as item_count 
/*, details
, cis_list
, warehouse_id
, warehouse_name
, cofinance_threshold
, bid_fee*/
/*	,sum(cofinance_value) +
	 sum(marketplace_cost_per_item) +
	 sum(marketplace_total) +
	 sum(buyer_cost_per_item) +
	 sum(buyer_total) +
	 sum(cashback_cost_per_item)  +
	 sum(cashback_total) as summa_total */
, sum(cofinance_value) as cofinance_value 
, sum(marketplace_cost_per_item) as marketplace_cost_per_item
, sum(marketplace_total) as marketplace_total
, sum(buyer_cost_per_item) as buyer_cost_per_item
, sum(buyer_total) as buyer_total
, sum(cashback_cost_per_item) as cashback_cost_per_item
, sum(cashback_total) as cashback_total
--, sum(spasibo_cost_per_item) as spasibo_cost_per_item
--, sum(spasibo_total) as spasibo_total
--, date_trunc('month',created_at) as created_at
--, token_id
--, id
--, business_id
--, campaings_id
FROM yandex_market.yandex_orders
where details not like '%REJECTED%'
--status_update_date >= '2026-03-07'
--and marketplace_total is null*/
group by 
date_trunc('month',status_update_date)
--, status
--, creation_date
--, date_trunc('month',created_at)
order by status_update_date DESC;