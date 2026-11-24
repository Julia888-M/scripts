SELECT
		cast(status_update_date as date) "Дата",
		shop_sku,
                token_id,
		(COALESCE(marketplace_cost_per_item,0)+COALESCE(cashback_cost_per_item,0)+COALESCE(buyer_cost_per_item,0))*item_count "Сумма, руб",
		item_count "Кол-во шт"
from yandex_market.v_yandex_orders_not_rejected
where 1=1
and status in ('DELIVERED','PARTIALLY_DELIVERED','RETURNED')
and cast(status_update_date as date) >= current_date-61
and cast(status_update_date as date) < current_date+1
--and details not like '%REJECTED%'