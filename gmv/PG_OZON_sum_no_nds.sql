-- выборка организаций
with t1 as 
(
	select distinct
	    token_id,
	    token_id token_id_text,
	    mp,
	    cab_name,
	    case when cab_name='Яндекс - МИКСИТ + Смарт Бьюти' then 'Миксит'
	    when cab_name='ОЗОН - SammyBeauty' then 'Бьюти Инновации'
	    else
	    initcap(trim(
	    regexp_replace(cab_name, '^((ОЗОН - )|(ВБ - )||(ОЗОН-)|(Яндекс - ))', '', 'gi')
	    )) end AS cab_name_group
	from general.bi_md_users_api_excel
),
-- выделение НДС
t2 as 
(
	select *,
	case when cab_name_group in ('Бьюти Инновации','Эко Лаборатория') then 1 else 1.22 end as NDS
	from t1
),
-- продажи ОЗОН
t3 as 
(
	SELECT
	    t1.operation_date,
	    t1.ozon_token_id,
	    t2.offer_id,
	    SUM(CASE WHEN t1.type = 'returns' THEN abs(t1.sku_count)* -1 ELSE t1.sku_count END) AS quantity,
	    SUM(CASE WHEN t1.type = 'returns' THEN abs(t1.accruals_for_sale)* -1 ELSE t1.accruals_for_sale END) AS sum_with_nds
	FROM ozon.sts_mv_ozon_api_seller_transactions_nm t1
	LEFT JOIN ozon.sts_mv_ozon_api_seller_products t2
	    ON t1.sku = t2.sku
	WHERE t1.operation_date  >= '2026-02-01'
	and t1.operation_date  <= '2026-02-28' 
	AND t1.accruals_for_sale <> 0
	GROUP BY
	    t1.operation_date,
	    t1.ozon_token_id,
	    t2.offer_id
)
-- объединяем продажи с НДС и считаем sum_no_nds
select 
 --t3.operation_date,
 --t3.ozon_token_id,
 --t3.offer_id,
 sum(t3.quantity),
 sum(round(t3.sum_with_nds)) as sum_with_nds,
 --t2.NDS,
 sum(round(t3.sum_with_nds / NDS)) as sum_no_nds
from t3 left join t2 on t2.token_id = t3.ozon_token_id