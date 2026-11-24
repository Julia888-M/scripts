SELECT
		cast(status_update_date as date) "Дата",
		shop_sku,
		'ЕР-ЕР004397' as "Партнер планирования - код",
        --t1.token_id,
        --t2.cab_name,
		(COALESCE(marketplace_cost_per_item,0)+COALESCE(cashback_cost_per_item,0)+COALESCE(buyer_cost_per_item,0))*item_count "Сумма, руб без НДС",
		item_count "Кол-во шт"
from yandex_market.yandex_orders t1
left join (select distinct token_id,cab_name from general.bi_md_users_api_excel) t2 on cast(t1.token_id as int) = t2.token_id
where 1=1
and status_update_date >= date_trunc('month', current_date)::date
and status in ('DELIVERED','PARTIALLY_DELIVERED','RETURNED')
--and cast(status_update_date as date)>='2025-01-01'
and details not like '%REJECTED%'

select distinct
order_id,
status
from yandex_market.yandex_orders
order by order_id