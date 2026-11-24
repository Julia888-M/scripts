select distinct
date_part('year',rr_dt) as year_report,
to_char(rr_dt,'MM-YYYY') as month_year_report,
'IBP Target M-1' as Demand_Scenario,
'Продажи' as Fact_Type,
sa_name as Article_Sku,
'Вайлдберриз' as Partner_planning_name,
brand_name,
substring(b.cab_name,6) as manufacturer_report,
null as Quantity_BUoM_Forecast,
sum(quantity) as Quantity_BUoM_Actual,
null as Net_Value_Forecast,
(case when substring(b.cab_name,6)='Бьюти Инновации' 
or (substring(b.cab_name,6)='Смарт бьюти' and date_part('year',rr_dt)=2024) 
or substring(b.cab_name,6)='Эко Лаборатория'
then trunc(sum(retail_price_withdisc_rub_units))
else trunc(sum(retail_price_withdisc_rub_units)/1.2)
end)  as retail_price_no_nds,
trunc(sum(retail_price_withdisc_rub_units)::Decimal, 2) as retail_price_withdisc_rub_units
from wb.wb_api_report_nm a
left join (select distinct token_id,cab_name from general.bi_md_users_api_excel) as b on a.wb_token_id=b.token_id
where 1=1
and retail_price_withdisc_rub_units<>0
and rr_dt>='01.01.2024'
--and sa_name='skua000638800' --check
group by year_report,
month_year_report,
sa_name,
brand_name,
b.cab_name
order by month_year_report
;