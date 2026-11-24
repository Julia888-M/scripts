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
				o.id, 
				o.company_id, 
				o.ozon_token_id, 
				o.warehouse_name, 
				o.item_code, 
				o.item_name, 
				o.sku, 
				o.promised_amount, 
				o.free_to_sell_amount, 
				o.reserved_amount, 
				o.express, 
				o.discounted, 
				o.stock_date, 
				o.created_at, 
				o.updated_at, 
				o.idc
			from ozon.ozon_api_seller_fbo_warehouse_stocks o
			inner join t on t.maxdate=o.created_at 
					and t.stock_date=o.stock_date 
					and t.item_code=o.item_code 
					and t.warehouse_name=o.warehouse_name 
					and t.ozon_token_id=o.ozon_token_id
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
				t2.id, 
				t2.company_id, 
				t2.ozon_token_id, 
				t2.warehouse_name, 
				t2.item_code, 
				t2.item_name, 
				t2.sku, 
				t2.promised_amount, 
				t2.free_to_sell_amount, 
				t2.reserved_amount, 
				t2.express, 
				t2.discounted, 
				t2.stock_date, 
				t2.created_at, 
				t2.updated_at, 
				t2.idc,
				gbmuae.cab_name,
				cl.cluster_name,
				'ЦБ-ЦБ000357' as partner_code
from t2
inner join t3 on t2."stock_date"=t3.maxdate
left join 
		(select distinct
			token_id,
			cab_name
		from general.bi_md_users_api_excel) gbmuae on gbmuae.token_id=t2.ozon_token_id
left join ozon.ozon_warehouse_clusters cl on cl.warehouse_id::varchar = t2.id
where t2.stock_date>='2025-01-01'