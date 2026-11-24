SELECT 
 date(posting_created_at) as posting_created_at  
, ozon_token_id
, sku
, case when status = 'awaiting_deliver' then quantity else 0 end as awaiting_deliver_quantity
, case when status = 'awaiting_packaging' then quantity else 0 end as awaiting_packaging_quantity
, case when status = 'delivering' then quantity else 0 end as delivering_quantity
, offer_id
, delivery_schema
, "warehouse"
, status
, nds.organization 
FROM ozon.ozon_api_seller_posting_items pi
LEFT JOIN (
	select distinct *
	from general.bi_md_users_api_excel ) nds
ON pi.ozon_token_id = nds.token_id 
where status in ('awaiting_deliver', 'awaiting_packaging', 'delivering')
and posting_created_at >= '2025-01-01';