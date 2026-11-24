 ----------------организации
 with org as
(select ID, upper(trim(replace(replace(name,'ООО',''),'новый',''))) as Organization from dwh_bi.dim.Organization)
----------------------------------основная выборка для каналов Оффлайн, Аптеки и Прочие. Прочие без услуг доставки 
select year(q.DateValue) * 100 + month(q.DateValue) as nPartYearMonth
       , q.DateValue as [Date] 
       , OrderDate
       , OrderNumber
       , Partner_Code
       , Partner_Name
       , Partner_Planning_Code
       , Partner_Planning_Name
       , DistributionChannel_1_Name
       , DistributionChannel_2_Name
       , DistributionChannel_3_Name
       , sku
       , q.ID   as ID_Order  
       , q.SalesDocumentNumber
       , q.SalesDocumentDate 
       , q.ActualShipmentDate
       , q.SalesDocumentStatus
       , q.SalesDocumentCorrectionNumber
       , q.SalesDocumentCorrectionDate
       , q.FlagSales
       , q.ShipmentSubStatus
       , q.ShipmentStatus  
       , q.Organization 
       , q.OrderStatus
       /*, q.ExpenseOrderNumber
       , q.ExpenseOrderDate
       , q.ExpenseOrderStatus*/
       , coalesce(ManagementRevenue_Quantity_BUoM, 0)                     as ManagementRevenue_Quantity_BUoM
       , coalesce(ManagementRevenue_NetValue, 0)                          as ManagementRevenue_NetValue
       , coalesce(ManagementRevenue_GrossValue, 0)                        as ManagementRevenue_GrossValue
       , coalesce(ManagementRevenue_NotCompleted_Quantity_BUoM, 0)        as ManagementRevenue_NotCompleted_Quantity_BUoM
       , coalesce(ManagementRevenue_NotCompleted_NetValue, 0)             as ManagementRevenue_NotCompleted_NetValue
       , coalesce(ManagementRevenue_NotCompleted_GrossValue, 0)           as ManagementRevenue_NotCompleted_GrossValue
from (
     select c1."Date" as DateValue
        , d.OrderDate
        , d.OrderNumber
        , p.Partner_Code 
        , p.Partner_Name
        , p.Partner_Planning_Code
        , p.Partner_Planning_Name
        , p.DistributionChannel_1_Name
        , p.DistributionChannel_2_Name
        , p.DistributionChannel_3_Name
        , ar.Sku   as sku
        , d.ID
        , sd.SalesDocumentNumber
        , sd.SalesDocumentDate 
        , sd.ActualShipmentDate
        , sds.Name as SalesDocumentStatus
        , sdc.SalesDocumentCorrectionNumber
        , sdc.SalesDocumentCorrectionDate
        , fsr.NameRu as FlagSales
        , sss.Name as ShipmentSubStatus
        , ss."Name" as ShipmentStatus
        , o.Name as Organization
        , os.Name as OrderStatus
        /*, eo.ExpenseOrderNumber
        , eo.ExpenseOrderDate
        , eos.Name as ExpenseOrderStatus*/
        , sum(ManagementRevenue_Quantity_BUoM)                		 as ManagementRevenue_Quantity_BUoM
        , sum(ManagementRevenue_NetValue)                  			 as ManagementRevenue_NetValue
        , sum(ManagementRevenue_GrossValue)               			 as ManagementRevenue_GrossValue
        , sum(ManagementRevenue_NotCompleted_Quantity_BUoM)    		 as ManagementRevenue_NotCompleted_Quantity_BUoM
        , sum(ManagementRevenue_NotCompleted_NetValue)      		 as ManagementRevenue_NotCompleted_NetValue
        , sum(ManagementRevenue_NotCompleted_GrossValue)      		 as ManagementRevenue_NotCompleted_GrossValue
        , row_number() over (partition by c1."Date", d.OrderDate, ar.Sku, p.Partner_Planning_Code order by c1."Date") as rn
     from fact.ManagementRevenue as s
         left join dim.Calendar                   as c1  on s.ID_Calendar_SalesReportDate = c1.ID
         left join dim.[Order]                    as d   on s.ID_Order                    = d.ID
         left join olap.[Partner]                 as p   on s.ID_Partner = p.ID_Partner
         left join dim.Article                    as ar  on s.ID_Article             = ar.ID
         left join dim.SalesDocumentId            as sd  on s.ID_SalesDocument = sd.ID 
         left join dim.SalesDocumentStatus        as sds on sd.ID_SalesDocumentStatus = sds.ID
         left join dim.SalesDocumentCorrection    as sdc on s.ID_SalesDocumentCorrection = sdc.ID
         left join dim.FlagSalesReport            as fsr on s.ID_FlagSalesReport = fsr.ID
         left join dim.ShipmentSubStatus          as sss ON s.ID_ShipmentSubStatus = sss.ID
         left join dim.ShipmentStatus             AS  ss on sss.ID_ShipmentStatus = ss.ID
         left join dim.Organization               as o   on s.ID_Organization = o.ID
         LEFT JOIN dim.OrderStatus                as os  ON d.ID_OrderStatus = os.ID 
         /*left join dim.ExpenseOrder 			  as eo  on d.ID = eo.ID_Order	 
         left join dim.ExpenseOrderStatus         as eos on eo.ID_ExpenseOrderStatus = eos.ID*/
         where 1=1
         and ar.Name <> 'Доставка заказа'
--      and   s.ID_FlagSalesReport = 1
      and c1.ID_Year >= 2025
      and c1.ID_Year <= YEAR(GETDATE())
      and fsr.NameRu = 'Включен'
    group by c1."Date"
         , d.OrderDate
         , d.OrderNumber
         , p.Partner_Code 
         , p.Partner_Name
         , p.Partner_Planning_Name
         , p.Partner_Planning_Code
         , p.DistributionChannel_1_Name
         , p.DistributionChannel_2_Name
         , p.DistributionChannel_3_Name
         , ar.Sku 
         , sd.SalesDocumentNumber
         , sd.SalesDocumentDate 
         , sd.ActualShipmentDate
         , sds.Name
         , sdc.SalesDocumentCorrectionNumber
         , sdc.SalesDocumentCorrectionDate
         , fsr.NameRu
         , sss.Name
         , ss."Name"
         , d.ID
         , o.Name
         , os.Name
        /* , eo.ExpenseOrderNumber
         , eo.ExpenseOrderDate
         , eos.Name*/
    ) as q
 where DistributionChannel_1_Name in ('Оффлайн', 'Аптеки', 'Прочие')
 ------------------добавляем услуги доставки для прочих
 UNION ALL
select
		NULL as nPartYearMonth
       , ex.DateFrom as [Date] 
       , NULL as OrderDate
       , NULL as OrderNumber
       , NULL as Partner_Code
       , NULL as Partner_Name
       , pa.Partner_Planning_Code as Partner_Planning_Code
       , NULL as Partner_Planning_Name
       , 'Прочие' as DistributionChannel_1_Name
       , NULL as DistributionChannel_2_Name
       , NULL as DistributionChannel_3_Name
       , ar.Sku as sku
       , NULL as ID_Order  
       , NULL as SalesDocumentNumber
       , NULL as SalesDocumentDate 
       , NULL as ActualShipmentDate
       , NULL as SalesDocumentStatus
       , NULL as SalesDocumentCorrectionNumber
       , NULL as SalesDocumentCorrectionDate
       , 'Включен' as FlagSales
       , NULL as ShipmentSubStatus
       , NULL as ShipmentStatus  
       , NULL as Organization 
       , NULL as OrderStatus
       /*, NULL as ExpenseOrderNumber
       , NULL as ExpenseOrderDate
       , NULL as ExpenseOrderStatus*/
       , NULL as ManagementRevenue_Quantity_BUoM
       , sum(ex.Value_RUB)                         as ManagementRevenue_NetValue
       , 0                                      as ManagementRevenue_GrossValue
       , 0                                      as ManagementRevenue_NotCompleted_Quantity_BUoM
       , 0                                      as ManagementRevenue_NotCompleted_NetValue
       , 0                                      as ManagementRevenue_NotCompleted_GrossValue
from dwh_bi.bi.vw_OperationExpenses_w_target     ex
left join dwh_bi.dim.OperationExpenses        re on ex.Code_CostItem=re.CodeExpensesPL
left join dwh_bi.dim.Article                 ar on ex.ID_Article=ar.ID
left join dwh_bi.dim.ArticleBrand             br on ar.ID_ArticleBrand=br.ID and br.IsMarkedForDeletion=0
left join dwh_bi.bi.vw_PlanningPartner        pa on ex.ID_Partner=pa.ID_Partner_Planning
left join                                     org on ex.ID_Organization=org.ID
left join dwh_bi.dim.DistributionChannel     dc on pa.ID_DistributionChannel_Partner_Planning=dc.ID
left join dwh_bi.dim.CompanyDepartment        cd on ex.ID_CompanyDepartment=cd.id and cd.IsMarkedForDeletion=0
left join dwh_bi.dim.OperationExpensesType    ot on ex.ID_OperationExpensesType=ot.ID
where 1=1
and ot.Name = 'Факт'
and re.name IN ('Выручка Прочая', 'Выручка от оказания услуг доставки')
group by
ex.DateFrom
, ar.Sku
, pa.Partner_Planning_Code
 