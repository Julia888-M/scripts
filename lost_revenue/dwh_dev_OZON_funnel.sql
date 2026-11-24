SELECT 
 osf."date"
, oasp.offer_id AS sku
, osf.token_id 
, sum(osf.ordered_units) as orderscount 
, sum(osf.revenue) as orderssumrub 
FROM ozon.ozon_sales_funnel osf
JOIN ozon.ozon_api_seller_products oasp
ON osf.id = oasp.sku
where 1=1
and osf."date" between '2025-01-01' and current_date
and osf.revenue <> 0
and osf.ordered_units <> 0
group by 
osf."date"
, osf.id
, oasp.offer_id
, osf.token_id 
;