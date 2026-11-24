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
AND date <= '2025-11-06'
and orderscount <>0
and orderscount is not null
--and a.vendorcode is null
order by date desc 


