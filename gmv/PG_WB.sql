select
date_trunc('month',rr_dt) as date,
--rr_dt,
--sa_name,
--wb_token_id as token_id,
sum(case when doc_type_name='Возврат' then quantity*-1 else quantity end) as quantity,
sum(case when doc_type_name='Возврат' then retail_price_withdisc_rub_units*-1 else retail_price_withdisc_rub_units end) as retail_price_withdisc_rub_units
from wb.sts_mv_wb_api_report_nm
where 1=1
and retail_price_withdisc_rub_units<>0
--and rr_dt >= '2026-03-30'
--and rr_dt < '2026-04-01'
and wb_token_id not in ('160920241','160920244','160920246')
group by
--date,
date_trunc('month',rr_dt)
--sa_name,
-- , wb_token_id
order by date ASC