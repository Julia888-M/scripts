SELECT DISTINCT
    p.ID_Partner_Planning,
    p."Partner_Planning_Name",
    p."Partner_Planning_Code",
    p."DistributionChannel_1_Name",
    p."DistributionChannel_2_Name",
    p."DistributionChannel_3_Name",
    p."Partner_Planning_Employee_Manager",
    CASE 
        WHEN p."DistributionChannel_3_Name" = 'Дистрибьюторы СНГ' 
        THEN ch.BusinessRegion 
        ELSE p.Partner_Planning_Client_Format 
    END AS Partner_Planning_Client_Format
    , count ( distinct p.Partner_Planning_Code) as kol
FROM "DWH_BI".olap."Partner_v2" p
LEFT JOIN dim.CounterpartyHierarchy ch 
    ON p.ID_Partner_Planning = ch.ID_Partner_Planning
   AND ch.ID_BusinessRegion <> -1
   AND p."DistributionChannel_3_Name" = 'Дистрибьюторы СНГ'
group BY 
p.ID_Partner_Planning,
    p."Partner_Planning_Name",
    p."Partner_Planning_Code",
    p."DistributionChannel_1_Name",
    p."DistributionChannel_2_Name",
    p."DistributionChannel_3_Name",
    p."Partner_Planning_Employee_Manager",
    ch.BusinessRegion,
    p.Partner_Planning_Client_Format 
    
   ;
