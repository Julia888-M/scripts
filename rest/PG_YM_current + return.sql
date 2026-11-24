SELECT
		date_part('year',status_update_date) as "Календарь.Год",
		to_char(status_update_date, 'MM-YYYY') as "Календарь.Месяц-Год",
		'IBP Target M-1' as "Деманд Сценарий",
		'Маркетплейсы' as "Канал продаж",
		'продажа' as "Тип факта",
		shop_sku as "Артикул",
		'Яндекс Маркет' as "Партнер.Партнер планирования",
		'MIXIT' as "Бренд",
		'MIXIT' as "Группа отчетности",
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
union 
(with r as (
select distinct
--update_date,
date_part('year',update_date) as "Календарь.Год",
to_char(update_date,'MM-YYYY') as "Календарь.Месяц-Год",
return_type,
shop_sku,
order_id,
--domain_name as "Производитель",
item_count,
campaings_id
from yandex_market.yandex_returns
where 1=1
and return_type = 'RETURN'
and shipment_status in ('FULFILMENT_RECEIVED', 'RECEIVED_FOR_EXPROPRIATION', 'READY_FOR_EXPROPRIATION', 'UTILIZED', 'PREPARED_FOR_UTILIZATION')
and date_part('month',update_date)>=date_part('month',now())
and date_part('year',update_date)>=date_part('year',now())
)
select 
	--r.update_date,
	r."Календарь.Год",
	r."Календарь.Месяц-Год",
	'IBP Target M-1' as "Деманд Сценарий",
	'Маркетплейсы' as "Канал продаж",
	'возврат'  as "Тип факта",
	r.shop_sku as "Артикул",
	'Яндекс Маркет' as "Партнер.Партнер планирования",
	'MIXIT' as "Бренд",
	'MIXIT' as "Группа отчетности",
	c.domain_name as "Производитель",
	null as "Прогноз, шт",
	sum(r.item_count) "Факт продаж, шт",
	null as "Прогноз_CY, руб без НДС",
	sum(-retail_price_withdisc_rub_units/1.2) as "Выручка_CY, руб без НДС"
	--r.order_id
from r
left join (
		select distinct
			date_part('year',status_update_date) as "Календарь.Год",
			to_char(status_update_date, 'MM-YYYY') as "Календарь.Месяц-Год",
			shop_sku,
			order_id,
			sum((COALESCE(marketplace_cost_per_item,0)+COALESCE(cashback_cost_per_item,0)+COALESCE(buyer_cost_per_item,0))*item_count) "retail_price_withdisc_rub_units"
		from yandex_market.yandex_orders
		where 1=1
		and status in ('DELIVERED','PARTIALLY_DELIVERED','RETURNED')
		--and date_part('month',status_update_date)>=date_part('month',now())
		--and date_part('year',status_update_date)>=date_part('year',now())
		and details not like '%REJECTED%'
		--and order_id='44088271809'
		group by 
		"Календарь.Год",
		"Календарь.Месяц-Год",
		shop_sku,
		order_id
) o on (cast(r.order_id as varchar) = o.order_id and r.shop_sku = o.shop_sku)
left join (
	select distinct 
		campaings_id,
		domain_name
	from yandex_market.yandex_campaings
)  c on r.campaings_id = c.campaings_id
where 1=1
--and r.shop_sku = 'SKU0012555000'
--and r.order_id='44088271809'
group by
	--r.update_date,
	r."Календарь.Год",
	r."Календарь.Месяц-Год",
	"Деманд Сценарий",
	"Канал продаж",
	"Тип факта",
	"Артикул",
	"Партнер.Партнер планирования",
	"Бренд",
	"Производитель",
	r.order_id
	)


