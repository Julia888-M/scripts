	select 
		 Period
		, Nomenclature_ID 
		, Price
	from (
		select 
			Period
			, Nomenclature_ID
			, Price 
			, ROW_NUMBER() OVER (PARTITION BY Nomenclature_ID order by Period DESC) as rn
		from ERP_Price
		where PriceType_ID='7acc8512-7b4c-11e6-80ca-5e9364d59509'
		and Period>='01.01.2024') as t3  -- признак себестоимости с НДС из таблицы ERP_PriceTypes ) 
	where t3.rn = 1		
		
