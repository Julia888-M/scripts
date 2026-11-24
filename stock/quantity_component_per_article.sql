SELECT 
	ar.sku,
	ar.Name,
	sum(aba.Quantity_ComponentPerOneMainUnit) as quantity_component
FROM DWH_BI.dim.ArticleBomAggregated as aba
left join 
	(select 
		id,
		sku,
		Name 
	from DWH_BI.dim.Article ) as ar on aba.ID_Article_Main  = ar.id
--where ar.sku = 'SKUA000875100'
group by 
	ar.sku,
	ar.Name 