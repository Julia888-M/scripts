
with t1 as (
			Select
				wwas.created_at as BalancePeriod,
				MAX(wwas.last_change_date) as last_change_date,
				wwas.supplier_article,
				wwas.warehouse_name,
				wwas.sc_code
			from wb.wb_api_stocks wwas
			where wwas.created_at >= '2025-01-01'
			and wwas.sc_code='Tech'
			group by 
				wwas.created_at,
				wwas.supplier_article,
				wwas.warehouse_name,
				wwas.sc_code
				),
	t2 as (
			select *
			from wb.wb_api_stocks wwas
			where wwas.created_at >= '2025-01-01'
		),
	t3 as (
			select 
				wb1.created_at,
				--wb1.last_change_date,
				wb1.id, 
				wb1.company_id, 
				wb1.wb_token_id, 
				wb1.warehouse_name, 
				wb1.supplier_article, 
				wb1.nm_id, 
				wb1.barcode, 
				sum(wb1.quantity) as quantity, 
				sum(wb1.in_way_to_client) as in_way_to_client, 
				sum(wb1.in_way_from_client) as in_way_from_client, 
				sum(wb1.quantity_full) as quantity_full, 
				wb1.category, 
				wb1.subject, 
				wb1.brand, 
				wb1.tech_size, 
				wb1.days_on_site, 
				wb1.price_units, 
				wb1.discount, 
				wb1.is_supply, 
				wb1.is_realization, 
				wb1.sc_code, 
				sum(wb1.quantity_not_in_orders) as quantity_not_in_orders, 
				avg(wb1.price_with_disc_units) as price_with_disc_units
			from wb.wb_api_stocks wb1
			where wb1.sc_code<>'Tech'
			and wb1.created_at >= '2025-01-01'
			group by
				wb1.created_at,
				--wb1.last_change_date,
				wb1.id, 
				wb1.company_id, 
				wb1.wb_token_id, 
				wb1.warehouse_name, 
				wb1.supplier_article, 
				wb1.nm_id, 
				wb1.barcode, 
				wb1.category, 
				wb1.subject, 
				wb1.brand, 
				wb1.tech_size, 
				wb1.days_on_site, 
				wb1.price_units, 
				wb1.discount, 
				wb1.is_supply, 
				wb1.is_realization, 
				wb1.sc_code
			),
	final as (
		select t2.*
		from t2
		inner join t1 on t1.BalancePeriod = t2.created_at
					and t1.supplier_article = t2.supplier_article
					and t1.warehouse_name = t2.warehouse_name
					and t1.last_change_date = t2.last_change_date
		where t2.sc_code = 'Tech'
		union
		select 
			t3.id, 
			t3.company_id, 
			t3.wb_token_id, 
			t3.created_at, 
			t1.last_change_date, 
			t3.warehouse_name, 
			t3.supplier_article, 
			t3.nm_id, barcode, 
			t3.quantity, 
			t3.in_way_to_client, 
			t3.in_way_from_client, 
			t3.quantity_full, 
			t3.category, 
			t3.subject, 
			t3.brand, 
			t3.tech_size, 
			t3.days_on_site, 
			t3.price_units, 
			t3.discount, 
			t3.is_supply, 
			t3.is_realization, 
			t3.sc_code, 
			t3.quantity_not_in_orders, 
			t3.price_with_disc_units
		from t3
		inner join t1 on t1.BalancePeriod = t3.created_at
					and t1.supplier_article = t3.supplier_article
					and t1.warehouse_name = t3.warehouse_name
		where t3.sc_code <> 'Tech')
		select 
			final.id, 
			final.company_id, 
			final.wb_token_id, 
			final.created_at, 
			final.last_change_date, 
			final.warehouse_name, 
			final.supplier_article, 
			final.nm_id, barcode, 
			final.quantity, 
			final.in_way_to_client, 
			final.in_way_from_client, 
			final.quantity_full, 
			final.category, 
			final.subject, 
			final.brand, 
			final.tech_size, 
			coalesce(final.days_on_site,0) as days_on_site, 
			final.price_units, 
			final.discount, 
			final.is_supply, 
			final.is_realization, 
			final.sc_code, 
			final.quantity_not_in_orders, 
			final.price_with_disc_units,
			c.cab_name,
			'ЕР-ЕР003862' as partner_code
		from final
		left join 
			(select distinct
				token_id,
				cab_name
			from general.bi_md_users_api_excel) c on c.token_id=final.wb_token_id
		--where last_change_date isnull
	