SELECT 
	--id
	--, company_id
	--, wb_token_id
	 --date_trunc('month',created_at) as created_at 
	 date_trunc('month',last_change_date) as last_change_date
	--, warehouse_name
	--, supplier_article
	--, nm_id
	--, barcode
	, sum(quantity) as quantity 
	, sum(in_way_to_client) as in_way_to_client
	, sum(in_way_from_client) as  in_way_from_client
	, sum(quantity_full) as quantity_full
	--, category
	--, subject
	--, brand
	--, tech_size
	--, days_on_site
	, sum(price_units) as price_units
	--, discount
	--, is_supply
	--, is_realization
	--, sc_code
	, sum(quantity_not_in_orders) as quantity_not_in_orders
	, sum(price_with_disc_units) as price_with_disc_units
FROM wb.wb_api_stocks
group by 
	date_trunc('month',last_change_date)
order by 
	last_change_date DESC
;