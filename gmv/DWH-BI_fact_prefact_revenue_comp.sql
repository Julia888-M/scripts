-- bi.vw_GMV_fact source

--CREATE OR ALTER   VIEW bi.vw_GMV_fact_components AS
--ОФФЛАЙН+МП: факт по дате появления ком. расходов
SELECT
   [date]
	, "Sku"
	, "component"
	, "component_name"
	, "tabletype"
	, "Partner_Planning_Code"
	, "version"
	, "DemandScenarioName"
	, value
from DWH_BI.bi.vw_kp_fact_components_all_versions t1
where 1=1
--and DistributionChannel_1_Name <> 'Маркетплейсы'
and "DemandScenarioName" = 'fact'
and t1.Date <=
(
  SELECT top 1
  eomonth(max([Date])) as max_date
  from dwh_bi.bi.pnl_fact_v3 t1
  left join dwh_bi.bi.vw_OperationExpenses_v3 t2 on t1.Code_CostItem=t2.CodeExpensesPL
  where 1=1
  and t2.NameGroupExpenses1 in ('Коммерческие расходы')
  --and DistributionChannel_1_Name <> 'Маркетплейсы'
--and NameCost='Выручка от реализации товара'
  and t1.Date >= '2026-01-01'
  group by [Date]
  order by [Date] DESC
  )
--ОФФЛАЙН+МП: предфакт , пока не появился какой-либо ком.расход
UNION ALL
  SELECT
  [date]
	, "Sku"
	, "component"
	, "component_name"
	, "tabletype"
	, "Partner_Planning_Code"
	, "version"
	, "DemandScenarioName"
	, value
from DWH_BI.bi.vw_kp_fact_components_all_versions t1
where 1=1
--and DistributionChannel_1_Name <> 'Маркетплейсы'
and "DemandScenarioName" = 'prefact'
and t1.Date > 
(
  SELECT top 1
  eomonth(max([Date])) as max_date
  from dwh_bi.bi.pnl_fact_v3 t1
  left join dwh_bi.bi.vw_OperationExpenses_v3 t2 on t1.Code_CostItem=t2.CodeExpensesPL
  where 1=1
  and t2.NameGroupExpenses1 in ('Коммерческие расходы')
--  and DistributionChannel_1_Name <> 'Маркетплейсы'
--and NameCost='Выручка от реализации товара'
  and t1.Date >= '2026-01-01'
  group by [Date]
  order by [Date] DESC
)

/*
--предыдущая версия
--ОФФЛАЙН: факт по дате появления ком. расходов
SELECT
   [date]
	, "Sku"
	, "component"
	, "component_name"
	, "tabletype"
	, "Partner_Planning_Code"
	, "version"
	, "DemandScenarioName"
	, value
from DWH_BI.bi.vw_kp_fact_components_all_versions t1
where 1=1
and DistributionChannel_1_Name <> 'Маркетплейсы'
and "DemandScenarioName" = 'fact'
and t1.Date <=
(
  SELECT top 1
  eomonth(max([Date])) as max_date
  from dwh_bi.bi.pnl_fact_v3 t1
  left join dwh_bi.bi.vw_OperationExpenses_v3 t2 on t1.Code_CostItem=t2.CodeExpensesPL
  where 1=1
  and t2.NameGroupExpenses1 in ('Коммерческие расходы')
  and DistributionChannel_1_Name <> 'Маркетплейсы'
--and NameCost='Выручка от реализации товара'
  and t1.Date >= '2026-01-01'
  group by [Date]
  order by [Date] DESC
  )
--ОФФЛАЙН: предфакт , пока не появился какой-либо ком.расход
UNION ALL
  SELECT
  [date]
	, "Sku"
	, "component"
	, "component_name"
	, "tabletype"
	, "Partner_Planning_Code"
	, "version"
	, "DemandScenarioName"
	, value
from DWH_BI.bi.vw_kp_fact_components_all_versions t1
where 1=1
and DistributionChannel_1_Name <> 'Маркетплейсы'
and "DemandScenarioName" = 'prefact'
and t1.Date > 
(
  SELECT top 1
  eomonth(max([Date])) as max_date
  from dwh_bi.bi.pnl_fact_v3 t1
  left join dwh_bi.bi.vw_OperationExpenses_v3 t2 on t1.Code_CostItem=t2.CodeExpensesPL
  where 1=1
  and t2.NameGroupExpenses1 in ('Коммерческие расходы')
  and DistributionChannel_1_Name <> 'Маркетплейсы'
--and NameCost='Выручка от реализации товара'
  and t1.Date >= '2026-01-01'
  group by [Date]
  order by [Date] DESC
)
--МП: факт по последний день месяца Т-2 + факт Т-1, если наступает 10 число месяца
union all
SELECT
   [date]
	, "Sku"
	, "component"
	, "component_name"
	, "tabletype"
	, "Partner_Planning_Code"
	, "version"
	, "DemandScenarioName"
	, value
from DWH_BI.bi.vw_kp_fact_components_all_versions t1
where 1=1
and DistributionChannel_1_Name = 'Маркетплейсы'
--and "DemandScenarioName" = 'fact'
and "DemandScenarioName" = 'prefact'
and 
(t1.Date <= EOMONTH(GETDATE(), -2)   --T-2
or (t1.Date between DATEADD(month, DATEDIFF(month, 0, GETDATE()) - 1, 0) -- StartOfPreviousMonth
    and EOMONTH(GETDATE(), -1) -- EndOfPreviousMonth
    and CAST(GETDATE() AS DATE) >= DATEFROMPARTS(YEAR(DATEADD(month, 0, GETDATE())), MONTH(DATEADD(month, 0, GETDATE())), 10)  -- 10 число текущего месяца текущего года
    ))
--МП предфакт Т-1, если не наступило 10 число месяца + предфакт Т0    
union all
SELECT
   [date]
	, "Sku"
	, "component"
	, "component_name"
	, "tabletype"
	, "Partner_Planning_Code"
	, "version"
	, "DemandScenarioName"
	, value
from DWH_BI.bi.vw_kp_fact_components_all_versions t1
where 1=1
and DistributionChannel_1_Name = 'Маркетплейсы'
and "DemandScenarioName" = 'prefact'
and 
(t1.Date between DATEADD(month, DATEDIFF(month, 0, GETDATE()) - 1, 0) -- StartOfPreviousMonth
    and EOMONTH(GETDATE(), -1) -- EndOfPreviousMonth
    and CAST(GETDATE() AS DATE) < DATEFROMPARTS(YEAR(DATEADD(month, 0, GETDATE())), MONTH(DATEADD(month, 0, GETDATE())), 10) -- 10 число текущего месяца текущего года
    or  t1.Date > EOMONTH(GETDATE(), -1)) -- EndOfPreviousMonth;
*/