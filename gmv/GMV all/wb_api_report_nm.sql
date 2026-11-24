select
rr_dt,
sa_name,
wb_token_id as token_id,
sum(case when doc_type_name='Возврат' then quantity*-1 else quantity end) as quantity,
sum(case when doc_type_name='Возврат' then retail_price_withdisc_rub_units*-1 else retail_price_withdisc_rub_units end) as retail_price_withdisc_rub_units
from wb.sts_mv_wb_api_report_nm
where 1=1
and retail_price_withdisc_rub_units<>0
and rr_dt >= current_date-61
and rr_dt < current_date+1
group by
rr_dt,
sa_name,
token_id