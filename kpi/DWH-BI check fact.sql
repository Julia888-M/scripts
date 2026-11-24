SELECT 
   t1.[Date] 
--  , t1.sku
--  , t1.Partner_Planning_Code
  , t2.NameGroupExpenses1
  , NameCost
  /*, case
      when t2.NameGroupExpenses1 <>'Выручка, руб без НДС' then Value*-1 else Value
      end as Value*/
  , sum(Value)
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
  LEFT JOIN IbpGateLoader.dbo.doc_fact_approved dfa ON DATEADD(month, DATEDIFF(month, 0, [Date]), 0) = dfa.месяц  --условие от 09-06-2026
  where 1=1
  and t2.NameGroupExpenses1 in ('Коммерческие расходы')
 -- and DistributionChannel_1_Name <> 'Маркетплейсы'
--and NameCost='Выручка от реализации товара'
  and t1.Date >= '2026-01-01'
  and Date<=(select max("месяц") from IbpGateLoader.dbo.doc_fact_approved
  				where факт_подтвержден = 'Да'
  				)  --условие от 09-06-2026
  group by [Date]
  order by [Date] DESC
  )
  group by t1.[Date]
  , t2.NameGroupExpenses1
  , NameCost
  order by t1.[Date] desc