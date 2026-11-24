select
	b.Description as Ячейка,
	c.Description as Зона,
	d.Description as Номенклатура,
	d.Articul as Артикул,
	a.BatchName as "Партия Номенклатуры",
	a.DateBestBefore as "Партия Номенклатуры. СГ",
	a.StorageDays as "Номенклатура, срок хран. в днях",
	a.Balance as "Кол-во упаковок",
	a.StorageBalanceDays as "Остаток срока годности, дней"
from BI1C.dbo.WMS_BalanceWithStorage a left join
	BI1C.dbo.WMS_Cells b on a.CellID = b.ID left join
	BI1C.dbo.WMS_Zones c on a.ZoneID = c.ID left join
	BI1C.dbo.ERP_Nomenclature d on a.NomenclatureID = d.ID
where a.Period = CAST(getdate() as date)
and a.ZoneID in (
'c65f6bd-1fc9-11ed-abce-000c29109bc5',
'cf65f6b6-1fc9-11ed-abce-000c29109bc5',
'1ffc4c11-2bb6-11ee-abfa-000c29109bc5',
'cba83bd4-1fc7-11ed-abce-000c29109bc5',
'8a3b50b5-8302-11ee-ac00-000c29109bc5',
'98db3233-2e83-11ed-abce-000c29109bc5',
'1806710f-2e83-11ed-abce-000c29109bc5',
'00c405d7-2c47-11ee-abfa-000c29109bc5',
'9de87811-1fc8-11ed-abce-000c29109bc5',
'3718b09f-1fc9-11ed-abce-000c29109bc5',
'4458b5c3-1fc9-11ed-abce-000c29109bc5',
'b7c9d2dd-1fc9-11ed-abce-000c29109bc5',
'b3ff7fa8-d93b-11ed-abe7-000c29109bc5',
'20ad3498-c8a8-11ed-abe7-000c29109bc5',
'991193b6-05d3-11ee-abf4-000c29109bc5',
'b37efd08-044e-11ee-abf4-000c29109bc5',
'faa7479f-2420-11f0-ac09-0050560147cd',
'cf65f6bd-1fc9-11ed-abce-000c29109bc5'
)
--and d.Articul='SKUA000498100'