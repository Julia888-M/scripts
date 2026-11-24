SELECT
		date_part('year',status_update_date) as "Календарь.Год",
		to_char(status_update_date, 'MM-YYYY') as "Календарь.Месяц-Год",
		'IBP Target M-1' as "Деманд Сценарий",
		'Маркетплейсы' as "Канал продаж",
		'Продажи' as "Тип факта",
		shop_sku as "Артикул",
		'Яндекс Маркет' as "Партнер.Партнер планирования",
		'MIXIT' as "Бренд",
		c.domain_name as "Производитель",
		null as "Прогноз, шт",
		sum(item_count) "Факт продаж, шт",
		null as "Прогноз_CY, руб без НДС",
		sum((COALESCE(marketplace_cost_per_item,0)+COALESCE(cashback_cost_per_item,0)+COALESCE(buyer_cost_per_item,0))*item_count/1.2) "Выручка_CY, руб без НДС"
--		COALESCE(marketplace_cost_per_item,0) marketplace_cost_per_item,
--		COALESCE(cashback_cost_per_item,0) cashback_cost_per_item,
--		COALESCE(buyer_cost_per_item,0) buyer_cost_per_item,
--		'6e819fbb-5563-11e6-80bd-5e9364d59509' "Контракт_ИД",
--		'0729fd5c-9eb9-11eb-b80f-00505601289b' "Канал_продаж_ИД",
		--'Ежедневный' "Sales_type"
		--details,
        --status
from yandex_market.yandex_orders o
left join (
	select distinct 
		campaings_id,
		domain_name
	from yandex_market.yandex_campaings
)  c on o.campaings_id = c.campaings_id
where 1=1
and status in ('DELIVERED','PARTIALLY_DELIVERED','RETURNED')
and date_part('month',status_update_date)>=date_part('month',now())
and date_part('year',status_update_date)>=date_part('year',now())
and details not like '%REJECTED%'
--and o.order_id = '44088271809' 
group by 
"Календарь.Год",
"Календарь.Месяц-Год",
"Деманд Сценарий",
"Канал продаж",
"Тип факта",
"Артикул",
"Партнер.Партнер планирования",
"Бренд",
"Производитель"
--details,
--status

/*
UNION
SELECT
		cast(status_update_date as date) "Дата",
		shop_sku,
		(COALESCE(marketplace_cost_per_item,0)+COALESCE(cashback_cost_per_item,0)+COALESCE(buyer_cost_per_item,0))*item_count "Сумма, руб",
--		COALESCE(marketplace_cost_per_item,0) marketplace_cost_per_item,
--		COALESCE(cashback_cost_per_item,0) cashback_cost_per_item,
--		COALESCE(buyer_cost_per_item,0) buyer_cost_per_item,
		item_count "Кол-во шт",
		'6e819fbb-5563-11e6-80bd-5e9364d59509' "Контракт_ИД",
		'0729fd5c-9eb9-11eb-b80f-00505601289b' "Канал_продаж_ИД",
		'Продажи' "Тип операции",
		'Markeplaces' "Тип таблицы",
		'Ежедневный' "Sales_type"
		,details
        ,status
from yandex_market.yandex_orders
where 1=1
and status in ('PARTIALLY_DELIVERED')
and cast(status_update_date as date)>='2025-01-01'
and details like '%REJECTED%'
*/