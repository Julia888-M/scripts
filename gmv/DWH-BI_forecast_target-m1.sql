with cl as
       (
        select 
        distinct cal.ID_YearHalfYearQuarterMonth
        ,cal.[Date]
        from dwh_bi.dim.Calendar as cal
        where day(cal.[Date])=1
        )
select
cl.[Date]
, ar.sku
, pa.Partner_Planning_Code
, pa.DistributionChannel_1_Name
,'Выручка, руб без НДС' as NameGroupExpenses1
--,sum(ibp.Quantity_BUoM) as Quantity_BUoM
,sum(ibp.NetValue) as Value
from 
DWH_BI.olap.DemandForecastMeasure ibp
left join    cl                                 on ibp.ID_YearHalfYearQuarterMonth=cl.ID_YearHalfYearQuarterMonth
left join    dwh_bi.dim.FactType ft             on ibp.ID_FactType=ft.ID
left join    dwh_bi.dim.DemandScenario sc       on ibp.ID_DemandScenario=sc.ID
left join    dwh_bi.dim.Article ar              on ibp.ID_Article=ar.ID
left join    dwh_bi.dim.ArticleBrand br         on ar.ID_ArticleBrand_ReportGroup=br.ID and br.IsMarkedForDeletion=0
left join    dwh_bi.olap.Partner pa             on ibp.ID_Partner=pa.ID_Partner
where 1=1
and ft.Name='Sales'
and sc.name=N'IBP Таргет М-1'
and cl.[Date]>='2025-01-01'
and cl.[Date]<='2025-12-31'
group by
cl.[Date]
, ar.sku
, br.name
, pa.Partner_Planning_Code
, pa.Partner_Planning_Name
, pa.DistributionChannel_1_Name
, pa.DistributionChannel_2_Name
, pa.DistributionChannel_3_Name
, sc.Name
union all
select
cl.[Date]
, ar.sku
, pa.Partner_Planning_Code
, pa.DistributionChannel_1_Name
,'Выручка, шт' as NameGroupExpenses1
,sum(ibp.Quantity_BUoM) as Value
--,sum(ibp.NetValue) as Value
from 
DWH_BI.olap.DemandForecastMeasure ibp
left join    cl                                 on ibp.ID_YearHalfYearQuarterMonth=cl.ID_YearHalfYearQuarterMonth
left join    dwh_bi.dim.FactType ft             on ibp.ID_FactType=ft.ID
left join    dwh_bi.dim.DemandScenario sc       on ibp.ID_DemandScenario=sc.ID
left join    dwh_bi.dim.Article ar              on ibp.ID_Article=ar.ID
left join    dwh_bi.dim.ArticleBrand br         on ar.ID_ArticleBrand_ReportGroup=br.ID and br.IsMarkedForDeletion=0
left join    dwh_bi.olap.Partner pa             on ibp.ID_Partner=pa.ID_Partner
where 1=1
and ft.Name='Sales'
and sc.name=N'IBP Таргет М-1'
and cl.[Date]>='2025-01-01'
and cl.[Date]<='2025-12-31'
group by
cl.[Date]
, ar.sku
, br.name
, pa.Partner_Planning_Code
, pa.Partner_Planning_Name
, pa.DistributionChannel_1_Name
, pa.DistributionChannel_2_Name
, pa.DistributionChannel_3_Name
, sc.Name
;