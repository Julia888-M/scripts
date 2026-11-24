with t as (
			Select
				max(stocks_updated_at) as maxdate,
				created_at,
				offer_id,
				warehouse_id,
				token_id,
				campaings_id
			from yandex_market.yandex_stocks
			group by
				created_at,
				offer_id,
				warehouse_id,
				token_id,
				campaings_id
			),
			
	t2 as (
			Select
				ymys.created_at,
				ymys.offer_id,
				ymys.token_id,
				ymys.warehouse_id,
				ymys.campaings_id,
				ymys.available_type,
				ymys.defect_type,
				ymys.expired_type,
				ymys.freeze_type,
				ymys.quarantine_type
			from yandex_market.yandex_stocks ymys
			inner join t on t.maxdate=ymys.stocks_updated_at and t.created_at=ymys.created_at and t.offer_id=ymys.offer_id and t.warehouse_id=ymys.warehouse_id and t.token_id=ymys.token_id and t.campaings_id=ymys.campaings_id
			),

	t3 as (
			Select
				max("created_at") maxdate,
				TO_CHAR("created_at", 'MMyyyy') MonthYear
				from t2
				group by 
				TO_CHAR("created_at", 'MMyyyy')
			)

select
	t2.created_at as "BalancePeriod",
	t2.offer_id as "supplier_article",
	ymyw.warehouse_name as "warehouse_name",
	ymyc.domain_name as "cab_name",
	t2.expired_type as "QuantityOnWay",
	t2.available_type as "Quantity",
	t2.freeze_type as "Reserved",
	t2.defect_type as "Defect",
	t2.quarantine_type as "Quarantine",
	'MarketplacesPBalance' as "TypeTable",
	'c479cedc-0d5c-11ee-b827-a0369f2009be' as "SalePoint_ID"
--	,gbmuae.cab_name
from t2
inner join t3 on t2."created_at"=t3.maxdate
left join yandex_market.yandex_warehouses ymyw on ymyw.warehouse_id=t2.warehouse_id
--left join 
--		(select distinct
--			token_id,
--			cab_name
--		from general.bi_md_users_api_excel) gbmuae on gbmuae.token_id=t2.token_id
left join yandex_market.yandex_campaings ymyc on ymyc.campaings_id=t2.campaings_id
where t2.created_at>='2024-11-01'