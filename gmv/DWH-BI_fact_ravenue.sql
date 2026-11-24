SELECT
t1.Date
, t1.sku
, t1.Partner_Planning_Code
, t1.Partner_Planning_Name
, t1.DistributionChannel_1_Name
, case
    when t2.NameGroupExpenses1 <>'Выручка, руб без НДС' then Value*-1 else Value
    end as Value
from dwh_bi.bi.pnl_fact_v3 t1
left join dwh_bi.bi.vw_OperationExpenses_v3 t2 on t1.Code_CostItem=t2.CodeExpensesPL
where 1=1
and t2.NameGroupExpenses1 in ('Выручка, руб без НДС')
and NameCost='Выручка от реализации товара'