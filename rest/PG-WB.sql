select distinct
--rr_dt,
--brand_name _name,
date_part('month',rr_dt) as month_report,
date_part('year',rr_dt) as year_report,
to_char(rr_dt,'MM-YYYY') as month_year_report,
substring(b.cab_name,6) as manufacturer_report,
--wb_token_id,
--doc_type_name,
--sum(quantity) as quantity,
sa_name,
(case when substring(b.cab_name,6)='Бьюти Инновации' 
or substring(b.cab_name,6)='Смарт бьюти' 
or substring(b.cab_name,6)='Эко Лаборатория'
then trunc(sum(retail_price_withdisc_rub_units))
else trunc(sum(retail_price_withdisc_rub_units)/1.2)
end)  as retail_price_no_nds,
(trunc(sum(retail_price_withdisc_rub_units))) as retail_price_withdisc_rub_units
from wb.wb_api_report_nm a
left join general.bi_md_users_api_excel b on a.wb_token_id=b.token_id
where 1=1
and retail_price_withdisc_rub_units<>0
and rr_dt>='01.01.2024'
and sa_name='skua000638800' --check
group by
--rr_dt,
--brand_name,
b.cab_name,
sa_name,
month_report,
year_report,
month_year_report,
wb_token_id
--doc_type_name
order by year_report,
month_report