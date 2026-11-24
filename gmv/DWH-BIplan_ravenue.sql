select
	/*ID
	, nPartYearMonth
	, [Date]
	, sku
	, accgroup
	, Partner_Planning_Code
	, Partner_Planning_Name
	, DistributionChannel_1_Name
	, DistributionChannel_2_Name
	, DistributionChannel_3_Name
	, row_id
	, tabletype
	, Code_CostItem
	, [Наименование Блок PL]
	, [Наименование статьи]
	, Code_dep
	, Name_dep
	, Name_SlicePlMini
	, [Метод аллокации]
	, Value*/
	 t1.nPartYearMonth
	, t1.[Date]
	, t1.sku
	, t1.accgroup
	, t1.Partner_Planning_Code
	, t1.Partner_Planning_Name
	, t1.DistributionChannel_1_Name
	, t1.Value
	, t2.NameGroupExpenses1
from
dwh_bi.bi.PNL_plan t1
left join dwh_bi.bi.vw_OperationExpenses_v3 t2 on t1.Code_CostItem=t2.CodeExpensesPL
where 1=1
and t2.NameGroupExpenses1 in ('Выручка, руб без НДС')
and tabletype = 'sales'