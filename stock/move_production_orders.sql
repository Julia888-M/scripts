select 
	a.Period,
	a.Nomenclature_ID,
	a.OrderCode,
	a.OrderID,
	b.Articul,
	a.Quantity,
	a.Sender,
	a.Recipient
from BI1C.dbo.ERP_MoveProductionOrders a 
left join
	BI1C.dbo.ERP_Nomenclature b on a.Nomenclature_ID = b.ID
where Period = CAST(getdate() as date)