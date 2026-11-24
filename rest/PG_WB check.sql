select rr_dt, 
LOWER(sa_name),
cab_name,
to_char(rr_dt,'MM-YYYY'),
doc_type_name,
trunc(sum(retail_price_withdisc_rub_units)::Decimal,2)
--sum(quantity) as quantity
from wb.wb_api_report_nm a
left join (select distinct token_id,cab_name from general.bi_md_users_api_excel) as b on a.wb_token_id=b.token_id
where sa_name='sku0014304000'
and rr_dt >='31.03.2025'
--and rr_dt <'02.03.2025'
and cab_name like '%МИКСИТ%'
group by a.rr_dt,
to_char(rr_dt,'MM-YYYY'),
sa_name,
cab_name,
a.doc_type_name
;