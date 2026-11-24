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
and ordered_products_count <>0
and ordered_products_count is not null
order by date desc