with t as (
			Select
				max(created_at) as maxdate,
				stock_date,
				item_code,
				warehouse_name,
				ozon_token_id
			from ozon.ozon_api_seller_fbo_warehouse_stocks
			group by
				stock_date,
				item_code,
				warehouse_name,
				ozon_token_id
			),
			
	t2 as (
			Select
				oasfws.stock_date,
--				oasfws.created_at,
--				oasfws.updated_at,
				oasfws.item_code,
--				oasfws.company_id,
				oasfws.ozon_token_id,
				oasfws.warehouse_name,
				oasfws.promised_amount ,
				oasfws.free_to_sell_amount,
				oasfws.reserved_amount
			from ozon.ozon_api_seller_fbo_warehouse_stocks oasfws
			inner join t on t.maxdate=oasfws.created_at and t.stock_date=oasfws.stock_date and t.item_code=oasfws.item_code and t.warehouse_name=oasfws.warehouse_name and t.ozon_token_id=oasfws.ozon_token_id
			),

	t3 as (
			Select
				max("stock_date") maxdate,
				TO_CHAR("stock_date", 'MMyyyy') MonthYear
				from t2
				group by 
				TO_CHAR("stock_date", 'MMyyyy')
			)

select
	t2.stock_date as "BalancePeriod",
--	t2.created_at,
--	t2.updated_at,
	t2.item_code as "supplier_article",
--	t2.company_id,
--	t2.ozon_token_id,
	t2.warehouse_name as "warehouse_name",
	t2.promised_amount as "QuantityOnWay",
	t2.free_to_sell_amount as "Quantity",
	t2.reserved_amount as "Reserved",
	'MarketplacesPBalance' as "TypeTable",
	'6785ec70-0760-11ea-a20f-005056011207' as "SalePoint_ID",
	gbmuae.cab_name
from t2
inner join t3 on t2."stock_date"=t3.maxdate
left join 
		(select distinct
			token_id,
			cab_name
		from general.bi_md_users_api_excel) gbmuae on gbmuae.token_id=t2.ozon_token_id
where t2.stock_date>='2024-11-01'