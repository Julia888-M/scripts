select
rr_dt as date,
case 
	when site_country = 'Россия' then 'РФ'
	when site_country = 'Беларусь' then 'Белоруссия'
	else site_country
 end as site_country,
sa_name,
case 
when wb_token_id = '160920241' then 'Миксит'
when wb_token_id = '160920242' then 'Бьюти Инновации'
when wb_token_id = '160920243' then 'Эксперт криэйшн'
when wb_token_id = '160920244' then 'Смарт Бьюти'
when wb_token_id = '160920245' then 'Эко Лаборатория'
when wb_token_id = '160920246' then 'Лаборатория здоровья'
end as "Организация",
case 
when wb_token_id = '160920241' then 1.22
when wb_token_id = '160920242' then 1
when wb_token_id = '160920243' then 1.22
when wb_token_id = '160920244' then 1.22
when wb_token_id = '160920245' then 1
when wb_token_id = '160920246' then 1.22
end as "НДС",
sum(case when doc_type_name='Возврат' then quantity*-1 else quantity end) as quantity,
sum(case when doc_type_name='Возврат' then retail_price_withdisc_rub_units*-1 else retail_price_withdisc_rub_units end) as retail_price_withdisc_rub_units
from wb.wb_api_report_nm
where 1=1
and retail_price_withdisc_rub_units<>0
and cast(rr_dt as date)  >= '2026-01-01'
group by
cast(rr_dt as date),
site_country,
sa_name,
wb_token_id
order by cast(rr_dt as date) DESC