Select
a.BalancePeriod,
a.Wirehouse_ID,
b.Description,
a.Nomenclature_ID,
c.Articul,
a.Quantity
From BI1C.dbo.ERP_OrganizationsBalance a
Left Join BI1C.dbo.ERP_Warehouses b on a.Wirehouse_ID = b.ID
Left Join BI1C.dbo.ERP_Nomenclature c on a.Nomenclature_ID = c.ID
WHERE a.BalancePeriod >= DATEADD(MONTH, 0, GETDATE())