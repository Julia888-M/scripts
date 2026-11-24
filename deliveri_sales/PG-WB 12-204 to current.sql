select
rr_dt as "Дата",
sale_dt as "DateSale",
upper(sa_name) as "Номенклатура - артикул",
(case when substring(t2.cab_name,6)='Бьюти Инновации'
then replace(t2.cab_name,'ВБ - Бьюти Инновации','Бьюти Инновации ООО')
else 
(case when substring(t2.cab_name,6)='Смарт бьюти'
then replace(t2.cab_name,'ВБ - Смарт бьюти','СМАРТ БЬЮТИ')
else
(case when substring(t2.cab_name,6)='Эко Лаборатория'
then replace(t2.cab_name,'ВБ - Эко Лаборатория','Эко лаборатория')
else 
(case when substring(t2.cab_name,6)='МИКСИТ'
then replace(t2.cab_name,'ВБ - МИКСИТ','Миксит новый')
else
(case when substring(t2.cab_name,6)='Эксперт Криэйшн'
then replace(t2.cab_name,'ВБ - Эксперт Криэйшн','Эксперт Криэйшн ООО')
else 
(case when substring(t2.cab_name,6)='Лаборатория Здоровья'
then replace(t2.cab_name,'ВБ - Лаборатория Здоровья','Лаборатория здоровья')
end
)end)end)end)end)end) as "Наименование организации",
'd492f8fa-126e-11ea-a20f-005056011207' as "Контракт_ИД",
lower(doc_type_name) as "Тип операции",
(case when LOWER(doc_type_name)='возврат' 
			then -(quantity)
			else (quantity)
			end
 ) as "Кол-во шт",
(case when LOWER(doc_type_name)='возврат' 
			then -(retail_price_units)
			else (retail_price_units)
			end
 ) as "Сумма без скидки, руб",
(case when LOWER(doc_type_name)='возврат' 
			then -(retail_price_withdisc_rub_units)
			else (retail_price_withdisc_rub_units)
			end
 ) as "Сумма, руб",
(case when LOWER(doc_type_name)='возврат' 
			then -(retail_price_withdisc_rub_units)
			else (retail_price_withdisc_rub_units)
			end
 ) as "Сумма со скидкой, руб",
 'Ежедневный' "Sales_type"
from wb.wb_api_report_nm t1
left join (select distinct token_id,cab_name from general.bi_md_users_api_excel) t2 on t1.wb_token_id=t2.token_id
where retail_price_withdisc_rub_units<>0
and rr_dt>= '2025-02-01'
and rr_dt< '2025-03-01'
order by rr_dt desc

