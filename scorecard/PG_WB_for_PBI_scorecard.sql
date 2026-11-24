select
--rr_dt,
date_part('year',rr_dt) as "Календарь.Год",
to_char(rr_dt,'MM-YYYY') as "Календарь.Месяц-Год",
'IBP Target M-1' as "Деманд Сценарий",
'Маркетплейсы' as "Канал продаж",
a.doc_type_name as "Тип факта",
lower(sa_name) as "Артикул",
'Вайлдберриз' as "Партнер.Партнер планирования",
brand_name as "Бренд",
brand_name as "Группа отчетности",
substring(b.cab_name,6) as "Производитель",
null as "Прогноз, шт",
sum(quantity) as "Факт продаж, шт",
null as "Прогноз_CY, руб без НДС",
(case when substring(b.cab_name,6)='Бьюти Инновации' 
or (substring(b.cab_name,6)='Смарт бьюти' and date_part('year',rr_dt)=2024)
or substring(b.cab_name,6)='Эко Лаборатория'
then trunc(sum(
				(case when LOWER(doc_type_name)='возврат' 
				then -retail_price_withdisc_rub_units 
				else retail_price_withdisc_rub_units
				end)))
else trunc(sum(
				(case when LOWER(doc_type_name)='возврат' 
				then -retail_price_withdisc_rub_units/1.2 
				else retail_price_withdisc_rub_units/1.2
				end)))
end)  as retail_price_no_nds,
trunc(sum(
				(case when LOWER(doc_type_name)='возврат' 
				then -retail_price_withdisc_rub_units 
				else retail_price_withdisc_rub_units
				end))::Decimal, 2) as retail_price_withdisc_rub_units
from wb.wb_api_report_nm a
left join (select distinct token_id,cab_name from general.bi_md_users_api_excel) as b on a.wb_token_id=b.token_id
where 1=1
and retail_price_withdisc_rub_units<>0
and rr_dt>='01.03.2024'
--and LOWER(doc_type_name)='возврат'
--and sa_name='sku0014304000' --check
group by "Календарь.Год",
"Календарь.Месяц-Год",
"Артикул",
brand_name,
b.cab_name,
doc_type_name
