SELECT
		date_trunc('day',status_update_date) "Дата",
		--shop_sku,
         --       token_id,
		sum((COALESCE(marketplace_cost_per_item,0)+COALESCE(cashback_cost_per_item,0)+COALESCE(buyer_cost_per_item,0))*item_count) as "Сумма, руб",
		sum(item_count) as "Кол-во шт"
from yandex_market.v_yandex_orders_not_rejected
where 1=1
and status in ('DELIVERED','PARTIALLY_DELIVERED','RETURNED')
and cast(status_update_date as date) >= current_date-61
and cast(status_update_date as date) < current_date+1
--AND (details IS NULL OR details NOT LIKE '%REJECTED%')
group by date_trunc('day',status_update_date)
order by date_trunc('day',status_update_date) DESC