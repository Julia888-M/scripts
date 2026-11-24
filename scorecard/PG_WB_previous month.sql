select
rr_dt,
'ЕР-ЕР003862' as "Партнер планирования - Код",
lower(a.doc_type_name) as "Тип факта",
lower(sa_name) as "Номенклатура - Артикул",
--substring(b.cab_name,6) as "Производитель",
sum(quantity) as "Факт продаж, шт",
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
and rr_dt>= date_trunc('month', current_date - interval '1' month)
  and rr_dt < date_trunc('month', current_date)
--'01.03.2024' and rr_dt <'01.01.2025'
--and sa_name='sku0014304000' --check
group by 
rr_dt,
"Партнер планирования - Код",
"Номенклатура - Артикул",
b.cab_name,
doc_type_name
