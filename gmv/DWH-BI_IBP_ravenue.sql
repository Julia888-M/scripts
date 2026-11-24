SELECT "Date",
    sku,
    accgroup,
    "Partner_Planning_Code",
    "Partner_Planning_Name",
    "DistributionChannel_1_Name",
    "Code_CostItem",
    DemandScenarioName,
    "Value"
FROM "DWH_BI".bi."PNLIBP_v8"
INNER JOIN "DWH_BI".bi."vw_OperationExpenses_v3"
ON Code_CostItem = CodeExpensesPL
INNER JOIN "DWH_BI".bi."vw_demand_scenarios"
ON DemandScenarioName = Name
WHERE NameGroupExpenses1 = 'Выручка, руб без НДС'
and NameCost='Выручка от реализации товара'
AND month("Date_start") = 1
AND Year("Date")= Year("Date_start")
AND Month("Date") IN (01,02,03);