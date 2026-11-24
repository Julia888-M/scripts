select
t1.operation_date as "Дата",
t2.offer_id as "Номенклатура - артикул",
'0729fd5c-9eb9-11eb-b80f-00505601289b' as "Канал_продаж_ИД",
(case when t3.cab_name='ОЗОН - SammyBeauty'
then replace(t3.cab_name,'ОЗОН - SammyBeauty','Семми бьюти ООО')
else 
(case when t3.cab_name='ОЗОН - Смарт Бьюти'
then replace(t3.cab_name,'ОЗОН - Смарт Бьюти','СМАРТ БЬЮТИ')
else
(case when t3.cab_name='ОЗОН - Эко Лаборатория'
then replace(t3.cab_name,'ОЗОН - Эко Лаборатория','Эко лаборатория')
else 
(case when t3.cab_name='ОЗОН - Миксит'
then replace(t3.cab_name,'ОЗОН - Миксит','Миксит новый')
else
(case when t3.cab_name='ОЗОН - Эксперт Криэйшн'
then replace(t3.cab_name,'ОЗОН - Эксперт Криэйшн','Эксперт Криэйшн ООО')
else 
(case when t3.cab_name='ОЗОН-Лаборатория Здоровья'
then replace(t3.cab_name,'ОЗОН-Лаборатория Здоровья','Лаборатория здоровья')
end
)end)end)end)end)end) as "Наименование организации",
(case when t1.type='returns' then replace(t1.type,'returns','возврат') else
(case when t1.type='orders' then replace(t1.type,'orders','продажа')
end)end) as "Тип операции",
'Еженедельный' "Sales_type",
'Markeplaces' as "Тип таблицы",
'214c74fa-2a63-11e7-80da-5e9364d59509' as "Контракт_ИД",
(CASE WHEN t1.type = 'returns' THEN t1.sku_count * -1 ELSE t1.sku_count END) AS "Кол-во шт",
t1.accruals_for_sale AS "Сумма, руб"
FROM ozon.ozon_api_seller_transactions_nm t1
LEFT JOIN ozon.ozon_api_seller_products t2 ON t1.sku::text = t2.sku::text
left join (select distinct token_id,cab_name from general.bi_md_users_api_excel) t3 on cast(t2.token_id as int) = t3.token_id
WHERE t1.operation_date::date >= date_trunc('month', current_date)::date
AND t1.accruals_for_sale <> 0