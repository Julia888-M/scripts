select
cast(DateDoc as Date) as "Дата",
t3.Articul as "Артикул",
'ЦБ-ЦБ000357' as "Партнер планирования - код",
t2.Quantity "Штуки упр",
t2.SummWithNDS "Выручка, руб с НДС",
(case when OrganizationID='054161fc-4427-11ea-a207-005056011106' 
	  or OrganizationID='ba5215e5-3415-11ed-b81c-a0369f2009be'
	  or OrganizationID='a76af604-9183-11ed-8120-04d4c490d013'
	  then SummWithNDS
	  else SummWithNDS/1.2
	  end) as "Выручка, руб без НДС"
from dbo.ERP_ReportCommissionaire t1
left join ERP_ReportCommissionaireProducts t2 on t1.ID=t2.HeaderID
left join BI1C.dbo.ERP_Nomenclature t3 on t2.NomenclatureID = t3.ID
where 1=1
and SummWithNDS <> 0
and t1.IsDeleted=0
and Conducted=1
and ContractorID='214c74fa-2a63-11e7-80da-5e9364d59509'
and DateDoc between '2024-04-01' and '2024-09-30'