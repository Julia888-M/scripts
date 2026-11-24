SELECT
t1.Date
, t1.sku
, t1.accgroup
, t1.Partner_Planning_Code
, t1.Partner_Planning_Name
, t1.DistributionChannel_1_Name
, t1.DistributionChannel_2_Name
, t1.DistributionChannel_3_Name
, t1.tabletype
, t1.Code_CostItem
, t1.Code_dep
, t1.Name_dep
, t2.NameGroupExpenses1
, t2.BlockPL
, t2.NameCost
, case
    when t2.NameGroupExpenses1 <>'Выручка, руб без НДС' then Value*-1 else Value
    end as Value
from
dwh_bi.bi.pnl_fact_v3 t1
left join dwh_bi.bi.vw_OperationExpenses_v3 t2 on t1.Code_CostItem=t2.CodeExpensesPL
where 1=1
and t2.NameGroupExpenses1 in ('Выручка, руб без НДС','Себестоимость','Коммерческие расходы')