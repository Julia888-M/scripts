CREATE OR ALTER             view [bi].[vw_OlapSalesAggregated_SalesDocs]
as
---------------------------------------------------------------------------------------------даты для ограничения по мп
with comp_dates as
(
select
'ЕР-ЕР003862' as Partner_Planning_Code---------ВБ
, case 
	when day(getdate())>=10 then cast(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0) as date) 
	else cast(DATEADD(MONTH, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)) as date) end as comp_date
union all
select
distinct
pa.Partner_Planning_Code-----------------------ОЗОН и ЯМ
, case 
	when day(getdate())>=12 then cast(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0) as date) 
	else cast(DATEADD(MONTH, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)) as date) end as comp_date
from dwh_bi.dim.PartnerHierarchy pa
inner join dwh_bi.dim.DistributionChannel dc on pa.ID_DistributionChannel_Partner_Parent=dc.ID and dc.DistributionChannel_1_Name='Маркетплейсы'
where pa.Partner_Planning_Code in ('ЦБ-ЦБ000357','ЕР-ЕР004646','ЕР-ЕР000387')
),
---------------------------------------------------------------------------------------------наименования организаций
org as
(select ID, upper(trim(replace(replace(name,'ООО',''),'новый',''))) as Organization from dwh_bi.dim.Organization)
---------------------------------------------------------------------------------------------основной запрос продаж
select
cl.date
, ar.sku
, br.name as accgroup
, pa.Partner_Planning_Code
, pa.Partner_Planning_Name
, org.Organization
, pa.DistributionChannel_1_Name
, pa.DistributionChannel_2_Name
, pa.DistributionChannel_3_Name
, o.OrderNumber
, sd.SalesDocumentNumber
, sdc.SalesDocumentCorrectionNumber
, sum(sl.ManagementRevenue_Quantity_BUoM) as sales_quantity
, sum(sl.ManagementRevenue_NetValue) as sales_rub_wo_nds
, sum(sl.ManagementRevenue_GrossValue) as sales_rub_with_nds
, sum(sl.ManagementRevenue_NotCompleted_Quantity_BUoM) as sales_quantity_not_completed
, sum(sl.ManagementRevenue_NotCompleted_NetValue) as sales_rub_wo_nds_not_completed
, sum(sl.ManagementRevenue_NotCompleted_GrossValue) as sales_rub_with_nds_not_completed
from         dwh_bi.olap.SalesMeasure sl
left join    dwh_bi.dim.Calendar cl            on sl.ID_Calendar_SalesReportDate=cl.id
left join    dwh_bi.dim.FlagSalesReport fl     on sl.ID_FlagSalesReport=fl.ID
left join    dwh_bi.dim.Article ar             on sl.ID_Article=ar.ID
left join    dwh_bi.dim.ArticleBrand br         on ar.ID_ArticleBrand_ReportGroup=br.ID and br.IsMarkedForDeletion=0
left join    dwh_bi.olap.Partner          pa   on sl.ID_Partner=pa.ID_Partner
left join    org                               on sl.ID_Organization=org.ID
left join    comp_dates                        on pa.Partner_Planning_Code=comp_dates.Partner_Planning_Code
left join    dwh_bi.olap.[Order] o               on sl.ID_Order=o.ID_Order
left join    dwh_bi.olap.SalesDocument sd      on sl.ID_SalesDocument=sd.ID_SalesDocument
left join    dwh_bi.olap.SalesDocumentCorrection sdc on sl.ID_SalesDocumentCorrection=sdc.ID_SalesDocumentCorrection
where 1=1
and cl.[Date]>='2025-01-01'
and fl.Name='Included'
and pa.DistributionChannel_1_Name in ('Оффлайн','Маркетплейсы','Аптеки','Прочие')
and ar.name not like '%доставка%'
and cl.date<coalesce(comp_dates.comp_date,getdate()+100)
group by
cl.date
, ar.sku
, br.name
, pa.Partner_Planning_Code
, pa.Partner_Planning_Name
, org.Organization
, pa.DistributionChannel_1_Name
, pa.DistributionChannel_2_Name
, pa.DistributionChannel_3_Name
, o.OrderNumber
, sd.SalesDocumentNumber
, sdc.SalesDocumentCorrectionNumber
having sum(isnull(sl.ManagementRevenue_NetValue,0)+isnull(sl.ManagementRevenue_NotCompleted_NetValue,0))<>0;