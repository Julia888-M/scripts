select
	t1.Period,
	t2.Articul,
	t1.Nomenclature_ID,
	t1.OrderCode,
	t1.OrderID,
	t1.sender,
	t1.Recipient,
	t1.Summ,
	t1.Quantity
from BI1C.dbo.ERP_MoveProductionOrders t1 
left join
	BI1C.dbo.ERP_Nomenclature t2 on t1.Nomenclature_ID = t2.ID
inner join (
	select Nomenclature_ID, MAX(Period) as last_date
	from BI1C.dbo.ERP_MoveProductionOrders
	group by Nomenclature_ID
) t3 on t1.Nomenclature_ID = t3.Nomenclature_ID
	and t1.Period = t3.last_date
where Summ > 0