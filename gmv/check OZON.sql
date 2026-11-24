select
date_trunc('month',posting_created_at)::date as "date",
offer_id articul,
--c.mp,
sum(amount_units) orderssumrub_nonds,
sum(case when status='delivered' then amount_units else 0 end) buyoutssumrub_nonds
from ozon.sts_mv_ozon_api_seller_posting_items t1
--left join c on t1.ozon_token_id=c.token_id
where 1=1
and posting_created_at between '2025-01-01' and current_date+1
--and quantity<>0
--and quantity is not null
group by
"date",
articul
--c.mp
order by "date" ASC