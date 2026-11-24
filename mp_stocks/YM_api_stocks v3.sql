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
			select
				ymys.token_id, 
				ymys.created_at, 
				ymys.warehouse_id, 
				ymys.offer_id, 
				ymys.stocks_updated_at, 
				ymys.turnover_summary_turnover, 
				ymys.turnover_summary_turnover_days, 
				ymys.available_type, 
				ymys.defect_type, 
				ymys.expired_type, 
				ymys.fit_type, 
				ymys.freeze_type, 
				ymys.quarantine_type, 
				ymys.utilization_type, 
				ymys.id, 
				ymys.campaings_id, 
				ymys.business_id
			from yandex_market.yandex_stocks ymys
			inner join t on t.maxdate=ymys.stocks_updated_at and t.created_at=ymys.created_at and t.offer_id=ymys.offer_id and t.warehouse_id=ymys.warehouse_id and t.token_id=ymys.token_id and t.campaings_id=ymys.campaings_id
			)
/*	t3 as (
			Select
				max("created_at") maxdate,
				TO_CHAR("created_at", 'MMyyyy') MonthYear
				from t2
				group by 
				TO_CHAR("created_at", 'MMyyyy')
			)*/
select distinct
	t2.token_id, 
	t2.created_at, 
	t2.warehouse_id, 
	t2.offer_id, 
	t2.stocks_updated_at, 
	t2.turnover_summary_turnover, 
	t2.turnover_summary_turnover_days, 
	t2.available_type, 
	t2.defect_type, 
	t2.expired_type, 
	t2.fit_type, 
	t2.freeze_type, 
	t2.quarantine_type, 
	t2.utilization_type, 
	t2.id, 
	t2.campaings_id, 
	t2.business_id,
	ymyc.domain_name,
	--yc.barcodes,
	'ЕР-ЕР004646' as partner_code,
	wr.warehouse_name
	--ymyc.*,
	--yc.*,
	--wr.*
	--gbmuae.cab_name
from t2
--inner join t3 on t2."created_at"=t3.maxdate
left join yandex_market.yandex_warehouses ymyw on ymyw.warehouse_id=t2.warehouse_id
/*left join 
		(select distinct
			token_id,
			cab_name
		from general.bi_md_users_api_excel) gbmuae on gbmuae.token_id=t2.token_id*/
left join yandex_market.yandex_campaings ymyc on ymyc.campaings_id=t2.campaings_id
left join yandex_market.yandex_warehouses wr on wr.warehouse_id = t2.warehouse_id
where t2.created_at>='2025-01-01'