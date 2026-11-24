SELECT 
 year([Date]) as year
, month([Date]) as month
--, sku
--, Partner_Planning_Code
--, NameGroupExpenses1
--, NameCost
, sum(Value) as Value
FROM DWH_BI.bi.vw_GMV_fact_revenue
where NameGroupExpenses1 like '%выручка%'
and NameGroupExpenses1 <> 'Выручка, шт'
group by 
year([Date])
,month([Date])
order by year, month
;

SELECT 
year([Date]) as year
, month([Date]) as month
--, sku
--, accgroup
--, Partner_Planning_Code
, Partner_Planning_Name
--, Organization
, DistributionChannel_1_Name
--, DistributionChannel_2_Name
---, DistributionChannel_3_Name
--, sales_quantity
, sum(sales_rub_wo_nds) as sales_rub_wo_nds
--, sales_rub_with_nds
--, sales_quantity_not_completed
--, sales_rub_wo_nds_not_completed
--, sales_rub_with_nds_not_completed
FROM DWH_BI.bi.vw_OlapSalesAggregated
--FROM DWH_BI.bi.salesaggregated
group by 
year([Date])
,month([Date])
,DistributionChannel_1_Name
, Partner_Planning_Name
order by year, month
;

