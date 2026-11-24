SELECT "Date",
	"Date_start",
	sku,
	"Коммерческий тип" as "Статья",
	'Прогноз квартал' as "Сценарий",
	"Partner_Planning_Code",
	DemandScenarioName,
	"Value",
	Value as "Выручка на начало квартала, руб без НДС"
FROM "DWH_BI".bi."vw_Revenue_ForecastMain"


SELECT "Date",
	"Date_start",
	sku,
	'КП, руб без НДС' as "Статья",
	'Прогноз квартал' as "Сценарий",
	"Partner_Planning_Code",
	DemandScenarioName,
	"Value",
	Value as "КП на начало квартала, руб без НДС"
FROM "DWH_BI".bi."vw_Profit_ForecastMain"