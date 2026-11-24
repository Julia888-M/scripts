-----выборка значений с максимальной датой last_change_date по created_at, nm_id, warehouse_name


t1 as (
			Select
				wwas.created_at as "BalancePeriod",
				MAX(wwas.last_change_date) as last_change_date,
				'c39c3d0d-6d84-11ea-a212-005056011207' as "SalePoint_ID",
				wwas.supplier_article,
				wwas.quantity as "Quantity",
				wwas.in_way_from_client as "Reserved",
				wwas.in_way_to_client as "QuantityOnWay",
				'MarketplacesPBalance' as "TypeTable",
				wwas.warehouse_name,
				wwas.wb_token_id,
				--wwas.id, 
				wwas.company_id, 
				wwas.nm_id, 
				wwas.barcode, 
				wwas.quantity_full, 
				wwas.category, 
				wwas.subject, 
				wwas.brand, 
				wwas.tech_size, 
				wwas.days_on_site, 
				wwas.price_units, 
				wwas.discount, 
				wwas.is_supply, 
				wwas.is_realization, 
				wwas.sc_code, 
				wwas.quantity_not_in_orders, 
				wwas.price_with_disc_units
			from wb.wb_api_stocks wwas
			where wwas.created_at='2025-11-24'
			and wwas.sc_code='Tech'
			group by 
				wwas.created_at,
				wwas.supplier_article,
				wwas.quantity,
				wwas.in_way_from_client,
				wwas.in_way_to_client,
				wwas.warehouse_name,
				wwas.wb_token_id,
				--wwas.id, 
				wwas.company_id, 
				wwas.nm_id, 
				wwas.barcode, 
				wwas.quantity_full, 
				wwas.category, 
				wwas.subject, 
				wwas.brand, 
				wwas.tech_size, 
				wwas.days_on_site, 
				wwas.price_units, 
				wwas.discount, 
				wwas.is_supply, 
				wwas.is_realization, 
				wwas.sc_code, 
				wwas.quantity_not_in_orders 
				--wwas.price_with_disc_units                 
	union 
			Select
				wwas.created_at as "BalancePeriod",
				MAX(wwas.last_change_date) as last_change_date,
				'c39c3d0d-6d84-11ea-a212-005056011207' as "SalePoint_ID",
				wwas.supplier_article,
				wwas.quantity as "Quantity",
				wwas.in_way_from_client as "Reserved",
				wwas.in_way_to_client as "QuantityOnWay",
				'MarketplacesPBalance' as "TypeTable",
				wwas.warehouse_name,
				wwas.wb_token_id,
				wwas.id, 
				wwas.company_id, 
				wwas.nm_id, 
				wwas.barcode, 
				wwas.quantity_full, 
				wwas.category, 
				wwas.subject, 
				wwas.brand, 
				wwas.tech_size, 
				wwas.days_on_site, 
				wwas.price_units, 
				wwas.discount, 
				wwas.is_supply, 
				wwas.is_realization, 
				wwas.sc_code, 
				wwas.quantity_not_in_orders, 
				wwas.price_with_disc_units
			from wb.wb_api_stocks wwas
			where wwas.created_at>='2025-01-01'
			and wwas.sc_code<>'Tech'
			group by 
			wwas.created_at,
			wwas.supplier_article,
			wwas.warehouse_name,
			wwas.wb_token_id,
			wwas.id, 
			wwas.company_id, 
			wwas.nm_id, 
			wwas.barcode, 
			wwas.category, 
			wwas.subject, 
			wwas.brand, 
			wwas.tech_size, 
			wwas.days_on_site, 
			wwas.is_supply, 
			wwas.is_realization, 
			wwas.sc_code	
			
			
			
			
	t2 as (
			Select
				max("BalancePeriod") maxdate,
				TO_CHAR("BalancePeriod", 'MMyyyy') MonthYear
				from t1
				group by 
				TO_CHAR("BalancePeriod", 'MMyyyy')
			)
select 
	t1.*,
	gbmuae.cab_name
from t1	
left join t2 on t1."BalancePeriod"=t2.maxdate		
left join 
		(select distinct
			token_id,
			cab_name
		from general.bi_md_users_api_excel) gbmuae on gbmuae.token_id=t1.wb_token_id
--where t2.supplier_article like '%непродается%'
	