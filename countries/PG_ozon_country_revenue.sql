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
;