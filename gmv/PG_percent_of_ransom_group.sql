------------------------------------------------------------------------------------------------------------------------------- организации и ндс
with
t as 
(
SELECT DISTINCT bi_md_users_api_excel.token_id,
            bi_md_users_api_excel.token_id AS token_id_text,
            bi_md_users_api_excel.mp,
            bi_md_users_api_excel.cab_name,
                CASE
                    WHEN bi_md_users_api_excel.cab_name::text = 'Яндекс - МИКСИТ + Смарт Бьюти'::text THEN 'Миксит'::text
                    WHEN bi_md_users_api_excel.cab_name::text = 'ОЗОН - SammyBeauty'::text THEN 'Бьюти Инновации'::text
                    WHEN bi_md_users_api_excel.cab_name::text = 'ОЗОН - Смарт Бьюти'::text THEN 'Смарт Бьюти'::text
                    WHEN bi_md_users_api_excel.cab_name::text = 'ОЗОН - Эко Лаборатория'::text THEN 'Эко Лаборатория'::text
                    WHEN bi_md_users_api_excel.cab_name::text = 'ОЗОН-Лаборатория Здоровья'::text THEN 'Лаборатория Здоровья'::text
                    ELSE initcap(TRIM(BOTH FROM regexp_replace(bi_md_users_api_excel.cab_name::text, '^((ОЗОН - )|(ВБ - )||(ОЗОН-)|(Яндекс - ))'::text, ''::text, 'gi'::text)))
                END AS cab_name_group
           FROM general.bi_md_users_api_excel
),
c as 
(
select *,
case when cab_name_group in ('Бьюти Инновации','Эко Лаборатория') then 1 else 1.2 end as NDS
from t
),
------------------------------------------------------------------------------------------------------------------------------- факт по датам
uni as
(
select 
"date",
coalesce(t2.vendorcode,t1.vendorcode) articul,
c.cab_name_group,
c.mp,
sum(orderscount) orderscount,
sum(buyoutscount) buyoutscount,
sum(orderssumrub/c.nds)  orderssumrub_nonds,
sum(buyoutssumrub/c.nds) buyoutssumrub_nonds
from wb.sts_mv_wb_sales_funnel t1 
left join c on t1.token_id=c.token_id_text
left join wb.sts_mv_wb_api_products t2 on t1.nmid=t2.nmid
where 1=1
and "date"between '2025-01-01' and current_date+1
and orderscount <>0
and orderscount is not null
group by
"date",
articul,
c.cab_name_group,
c.mp
union all
select
posting_created_at::date "date",
offer_id articul,
c.cab_name_group,
c.mp,
sum(quantity) orderscount,
sum(case when status='delivered' then quantity else 0 end) buyoutscount,
sum(amount_units/c.nds) orderssumrub_nonds,
sum(case when status='delivered' then amount_units/c.nds else 0 end) buyoutssumrub_nonds
from ozon.sts_mv_ozon_api_seller_posting_items t1
left join c on t1.ozon_token_id=c.token_id
where 1=1
and posting_created_at between '2025-01-01' and current_date+1
and quantity<>0
and quantity is not null
group by
"date",
articul,
c.cab_name_group,
c.mp
union all
select
"date",
sku articul,
'Миксит' cab_name_group,
'Yandex' mp,
sum(ordered_products_count) orderscount,
sum(delivered_from_orders_count) buyoutscount,
sum(ordered_products_rub/1.2) orderssumrub_nonds,
sum(delivered_from_orders_rub/1.2) buyoutssumrub_nonds
from yandex_market.sts_mv_yandex_sales_funnel t1
where 1=1
and ordered_products_rub<>0
and ordered_products_rub is not null
and "date" between '2025-01-01' and current_date+1
group by
"date",
articul
),
------------------------------------------------------------------------------------------------------------------------------- факт по месяцам
uni_m as 
(
select 
date_trunc('month',"date")::date as "date",
coalesce(t2.vendorcode,t1.vendorcode) articul,
c.mp,
sum(orderssumrub/c.nds)  orderssumrub_nonds,
sum(buyoutssumrub/c.nds) buyoutssumrub_nonds
from wb.sts_mv_wb_sales_funnel t1 
left join c on t1.token_id=c.token_id_text
left join wb.wb_api_products t2 on t1.nmid=t2.nmid
where 1=1
and "date" between '2025-01-01' and current_date+1
and orderscount <>0
and orderscount is not null
group by
"date",
articul,
c.mp
union all
select
date_trunc('month',posting_created_at)::date as "date",
offer_id articul,
c.mp,
sum(amount_units/c.nds) orderssumrub_nonds,
sum(case when status='delivered' then amount_units/c.nds else 0 end) buyoutssumrub_nonds
from ozon.sts_mv_ozon_api_seller_posting_items t1
left join c on t1.ozon_token_id=c.token_id
where 1=1
and posting_created_at between '2025-01-01' and current_date+1
and quantity<>0
and quantity is not null
group by
"date",
articul,
c.mp
union all
select
date_trunc('month',"date")::date as "date",
sku articul,
'Yandex' mp,
sum(ordered_products_rub/1.2) orderssumrub_nonds,
sum(delivered_from_orders_rub/1.2) buyoutssumrub_nonds
from yandex_market.sts_mv_yandex_sales_funnel t1
where 1=1
and ordered_products_rub<>0
and ordered_products_rub is not null
and "date" between '2025-01-01' and current_date+1
group by
"date",
articul
),
------------------------------------------------------------------------------------------------------------------------------- факт по кварталам
uni_q as
(
select 
date_trunc('quarter',"date")::date as "date",
coalesce(t2.vendorcode,t1.vendorcode) articul,
c.mp,
sum(orderssumrub/c.nds)  orderssumrub_nonds,
sum(buyoutssumrub/c.nds) buyoutssumrub_nonds
from wb.sts_mv_wb_sales_funnel t1 
left join c on t1.token_id=c.token_id_text
left join wb.wb_api_products t2 on t1.nmid=t2.nmid
where 1=1
and "date"between '2025-01-01' and current_date+1
and orderscount <>0
and orderscount is not null
group by
"date",
articul,
c.mp
union all
select
date_trunc('quarter',posting_created_at)::date as "date",
offer_id articul,
c.mp,
sum(amount_units/c.nds) orderssumrub_nonds,
sum(case when status='delivered' then amount_units/c.nds else 0 end) buyoutssumrub_nonds
from ozon.sts_mv_ozon_api_seller_posting_items t1
left join c on t1.ozon_token_id=c.token_id
where 1=1
and posting_created_at between '2025-01-01' and current_date+1
and quantity<>0
and quantity is not null
group by
"date",
articul,
c.mp
union all
select
date_trunc('quarter',"date")::date as "date",
sku articul,
'Yandex' mp,
sum(ordered_products_rub/1.2) orderssumrub_nonds,
sum(delivered_from_orders_rub/1.2) buyoutssumrub_nonds
from yandex_market.sts_mv_yandex_sales_funnel t1
where 1=1
and ordered_products_rub<>0
and ordered_products_rub is not null
and "date" between '2025-01-01' and current_date+1
group by
"date",
articul
),
-------------------------------------------------------------------------------------------------------------------------------кпэ месяц 1 вариант
uni2 as
(
select 
t1."date",
t1.articul,
t1.cab_name_group,
t1.mp,
t1.orderscount,
t1.buyoutscount,
t1.orderssumrub_nonds,
t1.buyoutssumrub_nonds,
sum(t2.orderssumrub_nonds) as orderssumrub_nonds_startmonth,
sum(t2.buyoutssumrub_nonds) as buyoutssumrub_nonds_startmonth
from uni t1 
left join
uni_m t2 on t1.articul=t2.articul and t1.mp=t2.mp 
and (date_trunc('MONTH', t1."date")::DATE-interval '1' month)::date>t2."date"
and (date_trunc('MONTH', t1."date")::DATE-interval '4' month)::date<=t2."date"
group by
t1."date",
t1.articul,
t1.cab_name_group,
t1.mp,
t1.orderscount,
t1.buyoutscount,
t1.orderssumrub_nonds,
t1.buyoutssumrub_nonds
),
-------------------------------------------------------------------------------------------------------------------------------кпэ месяц 2 вариант
uni3 as
(
select 
t1."date",
t1.articul,
t1.cab_name_group,
t1.mp,
t1.orderscount,
t1.buyoutscount,
t1.orderssumrub_nonds,
t1.buyoutssumrub_nonds,
t1.orderssumrub_nonds_startmonth,
t1.buyoutssumrub_nonds_startmonth,
sum(t3.orderssumrub_nonds) as orderssumrub_nonds_month_20,
sum(t3.buyoutssumrub_nonds) as buyoutssumrub_nonds_month_20
from uni2 t1 
left join
uni_m t3 on t1.articul=t3.articul and t1.mp=t3.mp
and (date_trunc('MONTH', t1."date")::DATE-interval '0' month)::date>t3."date"
and (date_trunc('MONTH', t1."date")::DATE-interval '3' month)::date<=t3."date"
group by
t1."date",
t1.articul,
t1.cab_name_group,
t1.mp,
t1.orderscount,
t1.buyoutscount,
t1.orderssumrub_nonds,
t1.buyoutssumrub_nonds,
t1.orderssumrub_nonds_startmonth,
t1.buyoutssumrub_nonds_startmonth
),
-------------------------------------------------------------------------------------------------------------------------------кпэ квартал 1 вариант
uni4 as
(
select 
t1."date",
t1.articul,
t1.cab_name_group,
t1.mp,
t1.orderscount,
t1.buyoutscount,
t1.orderssumrub_nonds,
t1.buyoutssumrub_nonds,
t1.orderssumrub_nonds_startmonth,
t1.buyoutssumrub_nonds_startmonth,
t1.orderssumrub_nonds_month_20,
t1.buyoutssumrub_nonds_month_20,
sum(t3.orderssumrub_nonds) as orderssumrub_nonds_startquarter,
sum(t3.buyoutssumrub_nonds) as buyoutssumrub_nonds_startquarter
from uni3 t1 
left join
uni_q t3 on t1.articul=t3.articul and t1.mp=t3.mp
and (date_trunc('quarter', t1."date")::date-interval '3' month)::date>t3."date"
and (date_trunc('quarter', t1."date")::date-interval '6' month)::date<=t3."date"
group by
t1."date",
t1.articul,
t1.cab_name_group,
t1.mp,
t1.orderscount,
t1.buyoutscount,
t1.orderssumrub_nonds,
t1.buyoutssumrub_nonds,
t1.orderssumrub_nonds_startmonth,
t1.buyoutssumrub_nonds_startmonth,
t1.orderssumrub_nonds_month_20,
t1.buyoutssumrub_nonds_month_20
)
-------------------------------------------------------------------------------------------------------------------------------кпэ квартал 2 вариант
select 
	date_trunc('month',t1."date") as start_of_month
	,case 
		when t1.mp = 'OZON' then 'ЦБ-ЦБ000357'
		when t1.mp = 'WB' then 'ЕР-ЕР003862'
		else 'ЕР-ЕР004646'
	end as partner_planning_code
	, sum(buyoutscount) / sum(orderscount) as percent_of_ransom
	, sum(t1.buyoutssumrub_nonds) / sum(t1.orderssumrub_nonds) as percent_of_ransom_nonds
	, sum(t1.buyoutssumrub_nonds_startmonth) / sum(t1.orderssumrub_nonds_startmonth) as percent_of_ransom_nonds_startmonth
	, sum(t1.buyoutssumrub_nonds_month_20) / sum(t1.orderssumrub_nonds_month_20) as percent_of_ransom_nonds_20
	, sum(t1.buyoutssumrub_nonds_startquarter) / sum(t1.orderssumrub_nonds_startquarter) as percent_of_ransom_nonds_startquarter
	, sum(t3.buyoutssumrub_nonds) / sum(t3.orderssumrub_nonds) as percent_of_ransom_nonds_35
from uni4 t1 
left join
	uni_q t3 on t1.articul=t3.articul and t1.mp=t3.mp
	and (date_trunc('quarter', t1."date")::date-interval '0' month)::date>t3."date"
	and (date_trunc('quarter', t1."date")::date-interval '3' month)::date<=t3."date"
group by
	date_trunc('month',t1."date"),
	t1.mp
order by start_of_month DESC
, partner_planning_code DESC