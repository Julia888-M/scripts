IF OBJECT_ID('[bi].[vw_Profit_ForecastMain]', 'V') IS NOT NULL
    DROP VIEW [bi].[vw_Profit_ForecastMain]
GO

CREATE VIEW [bi].[vw_Profit_ForecastMain] AS
WITH LastLoadedPeriod AS (
    -- Шаг 1: Находим последний квартал, где date и Date_start совпадают, тип 'КП' и Month(Date_start) корректен
    SELECT 
        MAX(YEAR("date")) as LastYear,
        MAX(DATEPART(quarter, "date")) as LastQuarter
    FROM [bi].[PNLIBP_aggr]
    INNER JOIN [bi].[vw_demand_scenarios] 
        ON DemandScenarioName = Name
    WHERE tabletype = 'КП'
      AND "Value" <> 0
      AND YEAR("date") = YEAR("Date_start")
      AND DATEPART(quarter, "date") = DATEPART(quarter, "Date_start")
      AND MONTH("Date_start") IN (1, 4, 7, 10)
),
PreparedData AS (
    -- Шаг 2: Собираем данные из агрегированной таблицы и подтягиваем вычисленные границы
    SELECT 
        "date",
        "Date_start",
        sku,
        "Partner_Planning_Code",
        DemandScenarioName,
        "Value",
        YEAR("date") as TargetYear,
        DATEPART(quarter, "date") as TargetQuarter,    
        (SELECT LastYear FROM LastLoadedPeriod) as LimitYear,
        (SELECT LastQuarter FROM LastLoadedPeriod) as LimitQuarter
    FROM [bi].[PNLIBP_aggr]
    INNER JOIN [bi].[vw_demand_scenarios] 
        ON DemandScenarioName = Name
    WHERE tabletype = 'КП'
      AND "Value" <> 0
)
-- Шаг 3: Фильтруем прошлое и будущее с контролем версий Date_start
SELECT 
    "date",
    "Date_start",
    sku,
    "Partner_Planning_Code",
    DemandScenarioName,
    "Value"
FROM PreparedData
WHERE 
    -- 1. ДЛЯ ИСТОРИИ (Включая последний закрытый квартал):
    (
        (TargetYear < LimitYear OR (TargetYear = LimitYear AND TargetQuarter <= LimitQuarter))
        AND YEAR("date") = YEAR("Date_start")
        AND DATEPART(quarter, "date") = DATEPART(quarter, "Date_start")
        AND MONTH("Date_start") IN (1, 4, 7, 10)
    )
    OR 
    -- 2. ДЛЯ БУДУЩИХ ПРОГНОЗОВ (Строго после последнего закрытого квартала):
    (
        (TargetYear > LimitYear OR (TargetYear = LimitYear AND TargetQuarter > LimitQuarter))
        AND YEAR("Date_start") = LimitYear
        AND DATEPART(quarter, "Date_start") = LimitQuarter
        AND MONTH("Date_start") IN (1, 4, 7, 10)
    );