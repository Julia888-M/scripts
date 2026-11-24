SELECT "date",
--	"Sku",
--	"Partner_Code",
--	"Organization",
--	"sales_quantity",
	sum("sales_rub_wo_nds") as "sales_rub_wo_nds",
	sum("sales_rub_with_nds") as "sales_rub_with_nds",
	sum("sales_quantity_not_completed") as "sales_quantity_not_completed",
	sum("sales_rub_wo_nds_not_completed") as "sales_rub_wo_nds_not_completed",
	sum("sales_rub_with_nds_not_completed") as "sales_rub_with_nds_not_completed"
FROM "bi"."vw_SalesByRegion_v2"
where "Partner_Code" in ('ЦБ-ЦБ000357')
--and "Sku" = 'SKU0011754000'
and "date" = '2026-04-01'
group by 
"date"
--	"Sku",
--	"Partner_Code",
--	"Organization";


WITH days AS (
    SELECT
        date_trunc('month',t1.posting_created_at)::date as post_dt
        , CASE
            WHEN COALESCE(cluster_to, cluster_from) IN ('Беларусь','Астана','Алматы','Армения','Узбекистан','Азербайджан','Кыргызстан','Грузия') 
            THEN COALESCE(cluster_to, cluster_from) 
            ELSE 'РФ' 
          END as region
        , t1.offer_id as sku
        , SUM(amount_units) as summa
    FROM ozon.ozon_api_seller_posting_items t1
    WHERE 1=1
      AND t1.posting_created_at>='2026-01-01'
      AND t1.status='delivered'
    GROUP BY
         CASE
            WHEN COALESCE(cluster_to, cluster_from) IN ('Беларусь','Астана','Алматы','Армения','Узбекистан','Азербайджан','Кыргызстан','Грузия') 
            THEN COALESCE(cluster_to, cluster_from) 
            ELSE 'РФ' 
          END
        , date_trunc('month',t1.posting_created_at)
        , t1.offer_id
),
rolling AS (
    SELECT
        post_dt
        , sku
        , region
        , summa
        , SUM(summa) OVER (PARTITION BY region, sku, post_dt ORDER BY post_dt ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS sum_7_rolling
    FROM days
)
SELECT
     date_trunc('month',post_dt) as post_dt
     , sku
     , case 
     	when region in ('Астана','Алматы') then 'Казахстан'
     	when region = 'Кыргызстан' then 'Киргизия'
     	when region = 'Россия' then 'РФ'
     	when region = 'Беларусь' then 'Белоруссия'
     	else region
       end as region
     , summa
     , sum_7_rolling
     , sum_7_rolling / SUM(sum_7_rolling) OVER (PARTITION BY post_dt, sku) as perc
FROM rolling
where region = 'Грузия'
and sku = 'SKU0011754000';


with days
as
(
select
t1.posting_created_at::date as post_dt
, case
	when coalesce(cluster_to,cluster_from) in
(
'Беларусь',
'Астана',
'Алматы',
'Армения',
'Узбекистан',
'Азербайджан',
'Кыргызстан',
'Грузия'
) then coalesce(cluster_to,cluster_from) else 'РФ' 
end as region
, sum(amount_units) as summa
from ozon.sts_mv_ozon_api_seller_posting_items t1
where 1=1
and t1.posting_created_at>='2026-01-01'
and t1.status='delivered'
group by
 case
	when coalesce(cluster_to,cluster_from) in
(
'Беларусь',
'Астана',
'Алматы',
'Армения',
'Узбекистан',
'Азербайджан',
'Кыргызстан',
'Грузия'
) then coalesce(cluster_to,cluster_from) else 'РФ' 
end
,t1.posting_created_at::date
),
rolling as
(
select
post_dt
, region
, summa
, SUM(summa) OVER ( PARTITION BY region ORDER BY post_dt ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS sum_7_rolling
FROM days
)
select
*,
sum_7_rolling/sum(sum_7_rolling) over (partition by post_dt) as perc
from rolling