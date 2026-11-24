SELECT
		cast(status_update_date as date) "Дата",
		shop_sku,
                token_id,
		(COALESCE(marketplace_cost_per_item,0)+COALESCE(cashback_cost_per_item,0)+COALESCE(buyer_cost_per_item,0))*item_count "Сумма, руб",
		item_count "Кол-во шт"
		,details
        ,status
from yandex_market.yandex_orders
where 1=1
and status in ('PARTIALLY_DELIVERED')
and cast(status_update_date as date) >= current_date-61
and cast(status_update_date as date) < current_date +1 
and details like '%REJECTED%'