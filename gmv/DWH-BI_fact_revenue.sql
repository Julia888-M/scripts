WITH t1 as 
(      
  SELECT top 1
  eomonth(max([Date])) as max_date
  from dwh_bi.bi.pnl_fact_v3 t1
  left join dwh_bi.bi.vw_OperationExpenses_v3 t2 on t1.Code_CostItem=t2.CodeExpensesPL
  where 1=1
  and t2.NameGroupExpenses1 in ('Коммерческие расходы')
--and NameCost='Выручка от реализации товара'
  and t1.Date >= '2026-01-01'
  group by [Date]
  order by [Date] DESC
		),
t2 as 
(
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
and t2.NameGroupExpenses1 in ('Выручка, руб без НДС','Себестоимость','Коммерческие расходы')
--and NameCost='Выручка от реализации товара'
and t1.Date >= '2025-01-01'
)
select 
	t2.Date
	,sku
	,Partner_Planning_Code
	,NameGroupExpenses1
	,NameCost
	,Value	
from t1 left join t2 on t2.date>t1.max_date
;


