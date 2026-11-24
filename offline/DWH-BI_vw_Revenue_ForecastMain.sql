IF OBJECT_ID('[bi].[vw_Revenue_ForecastMain]', 'V') IS NOT NULL
    DROP VIEW [bi].[vw_Revenue_ForecastMain]
GO

CREATE VIEW [bi].[vw_Revenue_ForecastMain] AS
WITH LastLoadedPeriod AS (
    -- Шаг 1: Находим последний квартал, где Date и Date_start совпадают и Month(Date_start) корректен
    SELECT 
        MAX(YEAR("Date")) as LastYear,
        MAX(DATEPART(quarter, "Date")) as LastQuarter
    FROM "DWH_BI".bi."PNLIBP_v8"
    INNER JOIN "DWH_BI".bi."vw_OperationExpenses_v3"
        ON Code_CostItem = CodeExpensesPL
    INNER JOIN "DWH_BI".bi."vw_demand_scenarios"
        ON DemandScenarioName = Name
    WHERE NameGroupExpenses1 = 'Выручка, руб без НДС'
      AND "Value" <> 0
      AND YEAR("Date") = YEAR("Date_start")
      AND DATEPART(quarter, "Date") = DATEPART(quarter, "Date_start")
      AND MONTH("Date_start") IN (1, 4, 7, 10)
),
PreparedData AS (
    -- Шаг 2: Собираем данные и подтягиваем вычисленные границы
    SELECT 
        "Date",
        "Date_start",
        sku,
        'Выручка, руб без НДС' as "Коммерческий тип",
        "Partner_Planning_Code",
        "Code_CostItem",
        DemandScenarioName,
        "Value",
        YEAR("Date") as TargetYear,
        DATEPART(quarter, "Date") as TargetQuarter,     
        (SELECT LastYear FROM LastLoadedPeriod) as LimitYear,
        (SELECT LastQuarter FROM LastLoadedPeriod) as LimitQuarter
    FROM "DWH_BI".bi."PNLIBP_v8"
    INNER JOIN "DWH_BI".bi."vw_OperationExpenses_v3"
        ON Code_CostItem = CodeExpensesPL
    INNER JOIN "DWH_BI".bi."vw_demand_scenarios"
        ON DemandScenarioName = Name
    WHERE NameGroupExpenses1 = 'Выручка, руб без НДС'
      AND "Value" <> 0
--      AND "Partner_Planning_Code" NOT IN ('ЕР-ЕР000387','ЕР-ЕР003862','ЕР-ЕР004646','ЦБ-ЦБ000357')
)
-- Шаг 3: Фильтруем прошлое и будущее с жестким контролем Date_start
SELECT 
    "Date",
    "Date_start",
    sku,
    "Коммерческий тип",
    "Partner_Planning_Code",
--    "Code_CostItem",
    DemandScenarioName,
    "Value"
FROM PreparedData
WHERE 
    -- 1. ДЛЯ ИСТОРИИ (Включая последний закрытый квартал):
    -- Год и квартал Date должны строго совпадать с годом и кварталом Date_start
    (
        (TargetYear < LimitYear OR (TargetYear = LimitYear AND TargetQuarter <= LimitQuarter))
        AND YEAR("Date") = YEAR("Date_start")
        AND DATEPART(quarter, "Date") = DATEPART(quarter, "Date_start")
        AND MONTH("Date_start") IN (1, 4, 7, 10)
    )
    OR 
    -- 2. ДЛЯ БУДУЩИХ ПЕРИОДОВ (Строго после последнего закрытого квартала):
    -- Date уходит в будущее, но Date_start жестко фиксируется на последнем доступном квартале планирования
    (
        (TargetYear > LimitYear OR (TargetYear = LimitYear AND TargetQuarter > LimitQuarter))
        AND YEAR("Date_start") = LimitYear
        AND DATEPART(quarter, "Date_start") = LimitQuarter
        AND MONTH("Date_start") IN (1, 4, 7, 10)
    )


