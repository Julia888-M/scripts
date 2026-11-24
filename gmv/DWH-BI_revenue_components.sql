SELECT distinct
[date]
, Sku
, component
, component_name
, tabletype
, Partner_Planning_Code
, version
, DemandScenarioName
, value
FROM DWH_BI.bi.vw_kp_fact_components_all_versions
where  tabletype in ('Выручка, штуки','Выручка, руб без НДС','КП','Выручка, единички','заказано единичек','заказано руб без ндс','заказано штук');


SELECT distinct
--[date]
--, Sku
--, component
--, component_name
--, Partner_Planning_Code
 tabletype
-- version
-- DemandScenarioName
--, value
FROM DWH_BI.bi.vw_kp_fact_components_all_versions;