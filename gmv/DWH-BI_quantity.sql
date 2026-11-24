SELECT 
	--ID
	 nPartYearMonth
	, [Date]
	, OrderDate
	, Partner_Planning_Code
	, Partner_Planning_Name
	, DistributionChannel_1_Name
	, DistributionChannel_2_Name
	, DistributionChannel_3_Name
	, sku_main 
	, sku_comp
	, ManagementRevenue_Quantity_BUoM
	, LoadDate,
	month([Date]) as Date
	, sum(ManagementRevenue_Quantity_BUoM) as ManagementRevenue_Quantity_BUoM
FROM 
	DWH_BI.bi.article_component_manravenue
where 
	year([Date]) = 2025
	and DistributionChannel_1_Name = 'Маркетплейсы'
group by 
	nPartYearMonth
	, [Date]
	, OrderDate
	, Partner_Planning_Code
	, Partner_Planning_Name
	, DistributionChannel_1_Name
	, DistributionChannel_2_Name
	, DistributionChannel_3_Name
	, sku_main 
	, sku_comp
	, ManagementRevenue_Quantity_BUoM
	, LoadDate,
	month([Date])