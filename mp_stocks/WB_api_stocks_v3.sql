-----выборка значений с максимальной датой last_change_date по created_at, nm_id, warehouse_name
with t as (
			Select
				max(last_change_date) as maxdate,
				wb1.id, 
				wb1.company_id, 
				wb1.wb_token_id, 
				wb1.created_at, 
				wb1.warehouse_name, 
				wb1.supplier_article, 
				wb1.nm_id, 
				wb1.barcode, 
				wb1.quantity, 
				wb1.in_way_to_client, 
				wb1.in_way_from_client, 
				wb1.quantity_full, 
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
				wb1.quantity_not_in_orders, 
				wb1.price_with_disc_units
			from wb.wb_api_stocks wb1
			group by
				wb1.id, 
				wb1.company_id, 
				wb1.wb_token_id, 
				wb1.created_at, 
				wb1.warehouse_name, 
				wb1.supplier_article, 
				wb1.nm_id, 
				wb1.barcode, 
				wb1.quantity, 
				wb1.in_way_to_client, 
				wb1.in_way_from_client, 
				wb1.quantity_full, 
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
				wb1.quantity_not_in_orders, 
				wb1.price_with_disc_units
			),
		t2 as (
			Select
				wwas.created_at as "BalancePeriod",
				--last_change_date,
				'c39c3d0d-6d84-11ea-a212-005056011207' as "SalePoint_ID",
			--	'' as "Organization_ID",
			--	'' as "Wirehouse_ID",
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
			inner join t on t.maxdate=wwas.last_change_date and t.created_at=wwas.created_at and t.nm_id=wwas.nm_id and t.warehouse_name=wwas.warehouse_name
			where wwas.created_at>='2025-01-01'
			UNION
			Select
				wwas.created_at as "BalancePeriod",
			--	last_change_date,
				'c39c3d0d-6d84-11ea-a212-005056011207' as "SalePoint_ID",
			--	'' as "Organization_ID",
			--	'' as "Wirehouse_ID",
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
			where wwas.created_at>='2025-01-01' and wwas.sc_code<>'Tech'
			),	
	t3 as (
			Select
				max("BalancePeriod") maxdate,
				TO_CHAR("BalancePeriod", 'MMyyyy') MonthYear
				from t2
				group by 
				TO_CHAR("BalancePeriod", 'MMyyyy')
			)
select 
	t2.*,
	gbmuae.cab_name
from t2	
left join t3 on t2."BalancePeriod"=t3.maxdate		
left join 
		(select distinct
			token_id,
			cab_name
		from general.bi_md_users_api_excel) gbmuae on gbmuae.token_id=t2.wb_token_id
--where t2.supplier_article like '%непродается%'
	