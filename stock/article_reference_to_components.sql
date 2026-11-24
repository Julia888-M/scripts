SELECT 
	ar.sku as article,
	ar.Name as article_name,
	--aba.ID_Article_Component,
	case
		when t1.sku is null 
		then ar.sku 
		else t1.sku
	end	as component_article,
	case
		when t1.name is null
		then ar.Name
		else t1.name
	end as component_name,
	case 
		when aba.Quantity_ComponentPerOneMainUnit is null
		then 1
		else aba.Quantity_ComponentPerOneMainUnit
	end as quantity_component_per_main_unit,
	case 
		when t1.sku is null 
		then 0 
		else 1
	end is_set	
FROM DWH_BI.dim.Article as ar
left JOIN 
	( select 
		ID_Article
	  from DWH_BI.olap.Article
	  where ArticleLevel_1_Name = 'Готовая продукция') aln on ar.ID = aln.ID_Article 
left join 
	(select 
		ID_Article_Main,
		ID_Article_Component,
		Quantity_ComponentPerOneMainUnit 
	from DWH_BI.dim.ArticleBomAggregated) aba on aba.ID_Article_Main  = ar.id
left join 
	(select 
		ID,
		sku,
		Name
	from DWH_BI.dim.Article) t1 on t1.ID = aba.ID_Article_Component
where ar.Sku <> 'Unknown' 
	and ar.Sku is not null
	

	