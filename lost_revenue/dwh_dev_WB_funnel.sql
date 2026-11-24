SELECT 
"date"
--, vendorcode as sku
--, token_id
, sum(orderscount) as orderscount 
, sum(orderssumrub) as orderssumrub 
FROM wb.wb_sales_funnel
where 1=1
and "date" between '2025-01-01' and CURRENT_DATE
and orderscount <> 0
and orderssumrub <> 0
group by 
--token_id
-- nmid
--, vendorcode
 "date";