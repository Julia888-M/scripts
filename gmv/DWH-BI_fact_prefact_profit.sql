-- bi.vw_GMV_fact_profit source

CREATE OR ALTER   VIEW bi.vw_GMV_fact_profit AS
--ОФФЛАЙН+МП: факт по дате появления ком. расходов
SELECT "date",
    Sku,
    "Partner_Planning_Code",
     "Value"
FROM "DWH_BI".bi."PNL_fact_aggr"
where tabletype = 'КП'
and "date" >= '2025-01-01'
--and DistributionChannel_1_Name <> 'Маркетплейсы'
--and NameCost='Выручка от реализации товара'
and date <=
(
  SELECT top 1
  eomonth(max([Date])) as max_date
  from dwh_bi.bi.pnl_fact_v3 t1
  left join dwh_bi.bi.vw_OperationExpenses_v3 t2 on t1.Code_CostItem=t2.CodeExpensesPL
  LEFT JOIN IbpGateLoader.dbo.doc_fact_approved dfa ON DATEADD(month, DATEDIFF(month, 0, [Date]), 0) = dfa.месяц  --условие от 09-06-2026
  where 1=1
  and t2.NameGroupExpenses1 in ('Коммерческие расходы')
  --and DistributionChannel_1_Name <> 'Маркетплейсы'
  and Date<=(select max("месяц") from IbpGateLoader.dbo.doc_fact_approved
  				where факт_подтвержден = 'Да'
  				)  --условие от 09-06-2026
  and t1.Date >= '2026-01-01'
  group by [Date]
  order by [Date] DESC
  )
--ОФФЛАЙН+МП: предфакт , пока не появился какой-либо ком.расход
UNION ALL
  SELECT "date",
    Sku,
    "Partner_Planning_Code",
     "Value"
from dwh_bi.bi.vw_pnl_prefact_daily_aggr
where tabletype = 'КП'
and "date" >= '2025-01-01'
--and DistributionChannel_1_Name <> 'Маркетплейсы'
and date >
(
  SELECT top 1
  eomonth(max([Date])) as max_date
  from dwh_bi.bi.pnl_fact_v3 t1
  left join dwh_bi.bi.vw_OperationExpenses_v3 t2 on t1.Code_CostItem=t2.CodeExpensesPL
  LEFT JOIN IbpGateLoader.dbo.doc_fact_approved dfa ON DATEADD(month, DATEDIFF(month, 0, [Date]), 0) = dfa.месяц  --условие от 09-06-2026
  where 1=1
  and t2.NameGroupExpenses1 in ('Коммерческие расходы')
  --and DistributionChannel_1_Name <> 'Маркетплейсы'
  and Date<=(select max("месяц") from IbpGateLoader.dbo.doc_fact_approved
  				where факт_подтвержден = 'Да'	)  --условие от 09-06-2026
  and t1.Date >= '2026-01-01'
  group by [Date]
  order by [Date] DESC
)


/*
 
--предыдущая версия
--ОФФЛАЙН: факт по дате появления ком. расходов
SELECT "date",
    Sku,
    "Partner_Planning_Code",
     "Value"
FROM "DWH_BI".bi."PNL_fact_aggr"
where tabletype = 'КП'
and "date" >= '2025-01-01'
and DistributionChannel_1_Name <> 'Маркетплейсы'
--and NameCost='Выручка от реализации товара'
and date <=
(
  SELECT top 1
  eomonth(max([Date])) as max_date
  from dwh_bi.bi.pnl_fact_v3 t1
  left join dwh_bi.bi.vw_OperationExpenses_v3 t2 on t1.Code_CostItem=t2.CodeExpensesPL
  where 1=1
  and t2.NameGroupExpenses1 in ('Коммерческие расходы')
  and DistributionChannel_1_Name <> 'Маркетплейсы'
  and t1.Date >= '2026-01-01'
  group by [Date]
  order by [Date] DESC
  )
--ОФФЛАЙН: предфакт , пока не появился какой-либо ком.расход
UNION ALL
  SELECT "date",
    Sku,
    "Partner_Planning_Code",
     "Value"
from dwh_bi.bi.vw_pnl_prefact_daily_aggr
where tabletype = 'КП'
and "date" >= '2025-01-01'
and DistributionChannel_1_Name <> 'Маркетплейсы'
and date >
(
  SELECT top 1
  eomonth(max([Date])) as max_date
  from dwh_bi.bi.pnl_fact_v3 t1
  left join dwh_bi.bi.vw_OperationExpenses_v3 t2 on t1.Code_CostItem=t2.CodeExpensesPL
  where 1=1
  and t2.NameGroupExpenses1 in ('Коммерческие расходы')
  and DistributionChannel_1_Name <> 'Маркетплейсы'
  and t1.Date >= '2026-01-01'
  group by [Date]
  order by [Date] DESC
)
--МП: факт по последний день месяца Т-2 + факт Т-1, если наступает 10 число месяца
union all
 SELECT "date",
    Sku,
    "Partner_Planning_Code",
     "Value"
--FROM "DWH_BI".bi."PNL_fact_aggr"
from dwh_bi.bi.vw_pnl_prefact_daily_aggr    
where tabletype = 'КП'
and "date" >= '2025-01-01'
and DistributionChannel_1_Name = 'Маркетплейсы'
and 
(date <= EOMONTH(GETDATE(), -2)   --T-2
or (date between DATEADD(month, DATEDIFF(month, 0, GETDATE()) - 1, 0) -- StartOfPreviousMonth
    and EOMONTH(GETDATE(), -1) -- EndOfPreviousMonth
    and CAST(GETDATE() AS DATE) >= DATEFROMPARTS(YEAR(DATEADD(month, 0, GETDATE())), MONTH(DATEADD(month, 0, GETDATE())), 10)  -- 10 число текущего месяца текущего года
    ))
--МП предфакт Т-1, если не наступило 10 число месяца + предфакт Т0    
union all
SELECT "date",
    Sku,
    "Partner_Planning_Code",
     "Value"
from dwh_bi.bi.vw_pnl_prefact_daily_aggr
where tabletype = 'КП'
and "date" >= '2025-01-01'
and DistributionChannel_1_Name = 'Маркетплейсы'
and 
 (date between DATEADD(month, DATEDIFF(month, 0, GETDATE()) - 1, 0) -- StartOfPreviousMonth
    and EOMONTH(GETDATE(), -1) -- EndOfPreviousMonth
    and CAST(GETDATE() AS DATE) < DATEFROMPARTS(YEAR(DATEADD(month, 0, GETDATE())), MONTH(DATEADD(month, 0, GETDATE())), 10) -- 10 число текущего месяца текущего года
    or  date > EOMONTH(GETDATE(), -1)) -- EndOfPreviousMonth;
*/