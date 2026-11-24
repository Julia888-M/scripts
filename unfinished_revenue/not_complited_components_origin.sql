  DECLARE @startyear int = 2025, @endyear int = YEAR(GETDATE());
  
  select year(q.DateValue) * 100 + month(q.DateValue) as nPartYearMonth
       , q.DateValue as [Date] 
       , OrderDate
       , Partner_Planning_Code
       , Partner_Planning_Name
       , DistributionChannel_1_Name
       , DistributionChannel_2_Name
       , DistributionChannel_3_Name
       , sku_main
       , sku_comp
       , iif(rn=1, coalesce(ManagementRevenue_Quantity_BUoM, ManagementRevenue_Component_Quantity_BUoM, 0) / isnull(Quantity_ComponentPerOneMainUnit,1), 0)                                       as ManagementRevenue_Quantity_BUoM
       , coalesce(ManagementRevenue_NetValue, ManagementRevenue_Component_NetValue, 0)                                                                                                            as ManagementRevenue_NetValue
       , coalesce(ManagementRevenue_GrossValue, ManagementRevenue_Component_GrossValue, 0)                                                                                                        as ManagementRevenue_GrossValue
       , iif(rn=1, coalesce(ManagementRevenue_NotCompleted_Quantity_BUoM, ManagementRevenue_NotCompleted_Component_Quantity_BUoM, 0)/ isnull(Quantity_ComponentPerOneMainUnit,1) , 0)             as ManagementRevenue_NotCompleted_Quantity_BUoM
       , coalesce(ManagementRevenue_NotCompleted_NetValue, ManagementRevenue_NotCompleted_Component_NetValue,0)                                                                                   as ManagementRevenue_NotCompleted_NetValue
       , coalesce(ManagementRevenue_NotCompleted_GrossValue, ManagementRevenue_NotCompleted_Component_GrossValue,0)                                                                               as ManagementRevenue_NotCompleted_GrossValue
       , iif(IsComponent = 0, isnull(ManagementRevenue_Quantity_BUoM, 0), isnull(ManagementRevenue_Component_Quantity_BUoM, 0))                                                                   as  ManagementRevenue_Component_Quantity_BUoM
       , iif(IsComponent = 0, isnull(ManagementRevenue_NetValue,0),       isnull(ManagementRevenue_Component_NetValue     , 0))                                                                   as ManagementRevenue_Component_NetValue
       --, iif(IsComponent = 0, ManagementRevenue_NetValue, ManagementRevenue_Component_GrossValue)                                                                                                   as ManagementRevenue_Component_GrossValue
       , iif(IsComponent = 0, isnull(ManagementRevenue_NotCompleted_Quantity_BUoM, 0), isnull(ManagementRevenue_NotCompleted_Component_Quantity_BUoM, 0))                                         as ManagementRevenue_NotCompleted_Component_Quantity_BUoM
       , iif(IsComponent = 0, isnull(ManagementRevenue_NotCompleted_NetValue, 0),      isnull(ManagementRevenue_NotCompleted_Component_NetValue, 0))                                              as ManagementRevenue_NotCompleted_Component_NetValue
       , q.ID                                                                                                                                                                                     as ID_Order
     --  , iif(IsComponent = 0, ManagementRevenue_NotCompleted_NetValue, ManagementRevenue_NotCompleted_Component_GrossValue)                                                                         as ManagementRevenue_NotCompleted_Component_GrossValue
       
  from (
  
   select c1."Date" as DateValue
        , d.OrderDate
        , p.Partner_Planning_Code
        , p.Partner_Planning_Name
        , p.DistributionChannel_1_Name
        , p.DistributionChannel_2_Name
        , p.DistributionChannel_3_Name
        , ar.Sku                                                                                     as sku_main
        , ar_comp.SKU                                                                                as sku_comp
        , iif(IsComponent = 1, sum(ManagementRevenue_Component_Quantity_BUoM), null)                 as ManagementRevenue_Component_Quantity_BUoM
        , iif(IsComponent = 1, sum(ManagementRevenue_Component_NetValue), null)                      as ManagementRevenue_Component_NetValue
        , iif(IsComponent = 1, sum(ManagementRevenue_Component_GrossValue), null)                    as ManagementRevenue_Component_GrossValue
        , iif(IsComponent = 1, sum(ManagementRevenue_NotCompleted_Component_Quantity_BUoM), null)    as ManagementRevenue_NotCompleted_Component_Quantity_BUoM
        , iif(IsComponent = 1, sum(ManagementRevenue_NotCompleted_Component_NetValue), null)         as ManagementRevenue_NotCompleted_Component_NetValue
        , iif(IsComponent = 1, sum(ManagementRevenue_NotCompleted_Component_GrossValue), null)       as ManagementRevenue_NotCompleted_Component_GrossValue
        , iif(IsComponent = 0, sum(ManagementRevenue_Component_Quantity_BUoM), null)                 as ManagementRevenue_Quantity_BUoM
        , iif(IsComponent = 0, sum(ManagementRevenue_Component_NetValue), null)                      as ManagementRevenue_NetValue
        , iif(IsComponent = 0, sum(ManagementRevenue_Component_GrossValue), null)                    as ManagementRevenue_GrossValue
        , iif(IsComponent = 0, sum(ManagementRevenue_NotCompleted_Component_Quantity_BUoM), null)    as ManagementRevenue_NotCompleted_Quantity_BUoM
        , iif(IsComponent = 0, sum(ManagementRevenue_NotCompleted_Component_NetValue), null)         as ManagementRevenue_NotCompleted_NetValue
        , iif(IsComponent = 0, sum(ManagementRevenue_NotCompleted_Component_GrossValue), null)       as ManagementRevenue_NotCompleted_GrossValue
        , IsComponent
        , row_number() over (partition by c1."Date", d.OrderDate, ar.Sku, p.Partner_Planning_Code order by c1."Date") as rn
        , bom.Quantity_ComponentPerOneMainUnit
        , d.ID
    from fact.ManagementRevenueComponent as s
         left join dim.Calendar          as c1  on s.ID_Calendar_SalesReportDate = c1.ID
         left join dim.[Order]           as d   on s.ID_Order                    = d.ID
         left join olap.[Partner]        as p   on s.ID_Partner = p.ID_Partner
         left join dim.Article           as ar_comp  on s.ID_Article_Component   = ar_comp.ID
         left join dim.Article           as ar       on s.ID_Article             = ar.ID
         left join dim.ArticleBom        as bom      on ar.ID = bom.ID_Article_Main
                                                    and ar_comp.ID = bom.ID_Article_Component
    where s.ID_FlagSalesReport = 1
      and c1.ID_Year >= @startyear
      and c1.ID_Year < @endyear 
    group by c1."Date"
         , d.OrderDate 
         , ar_comp.Sku     
         , p.Partner_Planning_Name
         , p.Partner_Planning_Code
         , p.DistributionChannel_1_Name
         , p.DistributionChannel_2_Name
         , p.DistributionChannel_3_Name
         , ar.Sku 
         , IsComponent
         , bom.Quantity_ComponentPerOneMainUnit
         , d.ID
  
  ) as q;