SELECT 
	ID
	, nPartYearMonth
	, [Date]
--	, OrderDate
	, Partner_Planning_Code
	, Partner_Planning_Name
	, DistributionChannel_1_Name
	, DistributionChannel_2_Name
	, DistributionChannel_3_Name
	, sku_main, sku_comp
	, ManagementRevenue_Quantity_BUoM
	, ManagementRevenue_NetValue
	, ManagementRevenue_GrossValue
	--, ManagementRevenue_NotCompleted_Quantity_BUoM
	--, ManagementRevenue_NotCompleted_NetValue
	--, ManagementRevenue_NotCompleted_GrossValue
	--, ManagementRevenue_Component_Quantity_BUoM
	--, ManagementRevenue_Component_NetValue
	--, ManagementRevenue_NotCompleted_Component_Quantity_BUoM
	--, ManagementRevenue_NotCompleted_Component_NetValue
	--, LoadDate
	/*year([Date]) as Date
	, sum(ManagementRevenue_Component_Quantity_BUoM) as ManagementRevenue_Component_Quantity_BUoM
	, sum(ManagementRevenue_Quantity_BUoM) as ManagementRevenue_Quantity_BUoM
	, sum(ManagementRevenue_Component_NetValue) as ManagementRevenue_Component_NetValue
	, sum(ManagementRevenue_NetValue) as ManagementRevenue_NetValue
	, sum(ManagementRevenue_GrossValue) as ManagementRevenue_GrossValue
	, sum(ManagementRevenue_NotCompleted_Quantity_BUoM) as ManagementRevenue_NotCompleted_Quantity_BUoM
	, sum(ManagementRevenue_NotCompleted_NetValue) as ManagementRevenue_NotCompleted_NetValue
	, sum(ManagementRevenue_NotCompleted_GrossValue) as ManagementRevenue_NotCompleted_GrossValue
	, sum(ManagementRevenue_NotCompleted_Quantity_BUoM) as ManagementRevenue_NotCompleted_Component_Quantity_BUoM
	, sum(ManagementRevenue_NotCompleted_Component_NetValue) as ManagementRevenue_NotCompleted_Component_NetValue*/
FROM 
	DWH_BI.bi.article_component_manravenue
where 
	month([Date]) = 12 and year([Date])=2025
--	DistributionChannel_1_Name <> 'Маркетплейсы'
/*group by 
	year([Date])*/
order by [Date];