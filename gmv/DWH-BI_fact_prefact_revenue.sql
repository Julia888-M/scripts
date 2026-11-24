-- bi.vw_GMV_fact source

--CREATE OR ALTER   VIEW bi.vw_GMV_fact_revenue AS
SELECT
   t1.[Date]
  , t1.sku
  , t1.Partner_Planning_Code
  , t2.NameGroupExpenses1
  , NameCost
  /*, case
      when t2.NameGroupExpenses1 <>'Выручка, руб без НДС' then Value*-1 else Value
      end as Value*/
  , Value
from dwh_bi.bi.pnl_fact_v3 t1
left join dwh_bi.bi.vw_OperationExpenses_v3 t2 on t1.Code_CostItem=t2.CodeExpensesPL
where 1=1
and t2.NameGroupExpenses1 in ('Выручка, руб без НДС','Выручка, шт','Себестоимость','Коммерческие расходы')
--and DistributionChannel_1_Name <> 'Маркетплейсы'
--and NameCost='Выручка от реализации товара'
and t1.[Date] <=
(
  SELECT top 1
  eomonth(max([Date])) as max_date
  from dwh_bi.bi.pnl_fact_v3 t1
  left join dwh_bi.bi.vw_OperationExpenses_v3 t2 on t1.Code_CostItem=t2.CodeExpensesPL
  where 1=1
  and t2.NameGroupExpenses1 in ('Коммерческие расходы')
 -- and DistributionChannel_1_Name <> 'Маркетплейсы'
--and NameCost='Выручка от реализации товара'
  and t1.Date >= '2026-01-01'
  group by [Date]
  order by [Date] DESC
  )
--ОФФЛАЙН+МП: предфакт , пока не появился какой-либо ком.расход
UNION ALL
  SELECT
   Date
  , sku
  , Partner_Planning_Code
  , NameGroupExpenses1
  , NameCost
  /*, case
      when t2.NameGroupExpenses1 <>'Выручка, руб без НДС' then Value*-1 else Value
      end as Value*/
  , Value
from dwh_bi.bi.pnl_prefact_daily t1
left join dwh_bi.bi.vw_OperationExpenses_v3 t2 on t1.Code_CostItem=t2.CodeExpensesPL
where 1=1
and t2.NameGroupExpenses1 in ('Выручка, руб без НДС','Выручка, шт','Себестоимость','Коммерческие расходы')
--and DistributionChannel_1_Name <> 'Маркетплейсы'
--and NameCost='Выручка от реализации товара'
and t1.Date > 
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
;
/*
--предыдущий вариант
--ОФФЛАЙН: факт по дате появления ком. расходов
SELECT
   t1.[Date]
  , t1.sku
  , t1.Partner_Planning_Code
  , t2.NameGroupExpenses1
  , NameCost
  /*, case
      when t2.NameGroupExpenses1 <>'Выручка, руб без НДС' then Value*-1 else Value
      end as Value*/
  , Value
from dwh_bi.bi.pnl_fact_v3 t1
left join dwh_bi.bi.vw_OperationExpenses_v3 t2 on t1.Code_CostItem=t2.CodeExpensesPL
where 1=1
and t2.NameGroupExpenses1 in ('Выручка, руб без НДС','Выручка, шт','Себестоимость','Коммерческие расходы')
and DistributionChannel_1_Name <> 'Маркетплейсы'
--and NameCost='Выручка от реализации товара'
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
   Date
  , sku
  , Partner_Planning_Code
  , NameGroupExpenses1
  , NameCost
  /*, case
      when t2.NameGroupExpenses1 <>'Выручка, руб без НДС' then Value*-1 else Value
      end as Value*/
  , Value
from dwh_bi.bi.pnl_prefact_daily t1
left join dwh_bi.bi.vw_OperationExpenses_v3 t2 on t1.Code_CostItem=t2.CodeExpensesPL
where 1=1
and t2.NameGroupExpenses1 in ('Выручка, руб без НДС','Выручка, шт','Себестоимость','Коммерческие расходы')
and DistributionChannel_1_Name <> 'Маркетплейсы'
--and NameCost='Выручка от реализации товара'
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
   t1.[Date]
  , t1.sku
  , t1.Partner_Planning_Code
  , t2.NameGroupExpenses1
  , NameCost
  /*, case
      when t2.NameGroupExpenses1 <>'Выручка, руб без НДС' then Value*-1 else Value
      end as Value*/
  , Value
--from dwh_bi.bi.pnl_fact_v3 t1
from dwh_bi.bi.pnl_prefact_daily t1  
left join dwh_bi.bi.vw_OperationExpenses_v3 t2 on t1.Code_CostItem=t2.CodeExpensesPL
where 1=1
and t2.NameGroupExpenses1 in ('Выручка, руб без НДС','Выручка, шт','Себестоимость','Коммерческие расходы')
and DistributionChannel_1_Name = 'Маркетплейсы'
--and NameCost='Выручка от реализации товара'
and 
(t1.Date <= EOMONTH(GETDATE(), -2)   --T-2
or (t1.Date between DATEADD(month, DATEDIFF(month, 0, GETDATE()) - 1, 0) -- StartOfPreviousMonth
    and EOMONTH(GETDATE(), -1) -- EndOfPreviousMonth
    and CAST(GETDATE() AS DATE) >= DATEFROMPARTS(YEAR(DATEADD(month, 0, GETDATE())), MONTH(DATEADD(month, 0, GETDATE())), 10)  -- 10 число текущего месяца текущего года
    ))
--МП предфакт Т-1, если не наступило 10 число месяца + предфакт Т0    
union all
SELECT
   Date
  , sku
  , Partner_Planning_Code
  , NameGroupExpenses1
  , NameCost
  /*, case
      when t2.NameGroupExpenses1 <>'Выручка, руб без НДС' then Value*-1 else Value
      end as Value*/
  , Value
from dwh_bi.bi.pnl_prefact_daily t1
left join dwh_bi.bi.vw_OperationExpenses_v3 t2 on t1.Code_CostItem=t2.CodeExpensesPL
where 1=1
and t2.NameGroupExpenses1 in ('Выручка, руб без НДС','Выручка, шт','Себестоимость','Коммерческие расходы')
and DistributionChannel_1_Name = 'Маркетплейсы'
and 
(t1.Date between DATEADD(month, DATEDIFF(month, 0, GETDATE()) - 1, 0) -- StartOfPreviousMonth
    and EOMONTH(GETDATE(), -1) -- EndOfPreviousMonth
    and CAST(GETDATE() AS DATE) < DATEFROMPARTS(YEAR(DATEADD(month, 0, GETDATE())), MONTH(DATEADD(month, 0, GETDATE())), 10) -- 10 число текущего месяца текущего года
    or  t1.Date > EOMONTH(GETDATE(), -1)) -- EndOfPreviousMonth;
*/