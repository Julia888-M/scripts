select
replace(upper(sa_name),' ','') articul,
sum(case when doc_type_name='Возврат' then -abs(retail_price_withdisc_rub_units/t2.nds) else retail_price_withdisc_rub_units/t2.nds end)/
sum(case when doc_type_name='Возврат' then -abs(quantity) else quantity end) as avg_price_3_monts
from wb.sts_mv_wb_api_report_nm t1
left join bi.cab_name_group_with_nds t2 on t1.wb_token_id=t2.token_id and t1.rr_dt between t2.nds_start and t2.nds_end
where 1=1
and retail_price_withdisc_rub_units<>0
and quantity<>0
    and rr_dt >= date_trunc('month', CURRENT_DATE) - INTERVAL '4 months'
    and rr_dt < date_trunc('month', CURRENT_DATE) - INTERVAL '1 month'
group by
articul
having sum(case when doc_type_name='Возврат' then -abs(quantity) else quantity end)<>0