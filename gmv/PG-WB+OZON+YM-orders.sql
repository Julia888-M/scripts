select distinct
a.date "Дата заказа",
a.token_id::int,
'1' as id,
'ЕР-ЕР003862' "Партнер планирования код",
a.vendorcode "Артикул",
case when b.cab_name = 'ВБ - МИКСИТ' then 'Миксит'
else substring(b.cab_name,6) 
end as "Организация",
a.orderscount "Заказы, шт",
a.orderssumrub "Заказы, руб с НДС",
case 
	when substring(b.cab_name,6) in ('Бьюти Инновации','Эко Лаборатория')
	then orderssumrub
	else  orderssumrub/1.2
end as "Заказы, руб без НДС"
from wb.wb_sales_funnel a
left join (select distinct token_id,cab_name from general.bi_md_users_api_excel) as b on a.token_id=b.token_id::text
where date >= '2025-01-01'
and date < current_date + 1
and orderscount <>0
and orderscount is not null

union

/* добавляем озон */
select
a.date "Дата заказа",
a.token_id,
a.id,
'ЦБ-ЦБ000357' "Партнер планирования код",
c.offer_id "Артикул",
case when b.cab_name ='ОЗОН-Лаборатория Здоровья' then 'Лаборатория Здоровья'	
	 when b.cab_name ='ОЗОН - SammyBeauty' then 'Бьюти инновации'
	 else substring(b.cab_name,8)
end as "Организация",
a.ordered_units "Заказы, шт",
a.revenue "Заказы, руб с НДС",
case 
	when substring(b.cab_name,8) in ('Бьюти Инновации','Эко Лаборатория','SammyBeauty')
	then revenue
	else  revenue/1.2
end as "Заказы, руб без НДС"
from ozon.ozon_sales_funnel a
left join (select distinct token_id,cab_name from general.bi_md_users_api_excel) as b on a.token_id=b.token_id
left join ozon.ozon_api_seller_products as c on a.id = c.sku
where date >= '2025-01-01'
and date < current_date + 1
and ordered_units <>0
and ordered_units is not null
and c.offer_id is null

union 

/* добавляем ЯМ */
select distinct
a.date "Дата заказа",
a.token_id::int,
'1' as id,
'ЕР-ЕР004646' "Партнер планирования код",
a.sku "Артикул",
'Миксит' "Организация",
a.ordered_products_count "Заказы, шт",
a.ordered_products_rub "Заказы, руб с НДС",
a.ordered_products_rub/1.2 "Заказы, руб без НДС"
from yandex_market.yandex_sales_funnel a
where date >= '2025-01-01'
and date < current_date + 1
and ordered_products_count <>0
and ordered_products_count is not null



