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
where date >= current_date - 8
and date < current_date + 1
and ordered_units <>0
and ordered_units is not null
order by date desc