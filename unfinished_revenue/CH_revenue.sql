WITH org AS (
    SELECT 
        ID, 
        upper(trimBoth(replaceAll(replaceAll(name, 'ООО', ''), 'новый', ''))) AS Organization 
    FROM dim.Organization
)
-- Основная выборка для каналов Оффлайн, Аптеки и Прочие (без услуг доставки)
SELECT 
    toYYYYMM(q.DateValue) AS nPartYearMonth,
    q.DateValue AS Date,
    q.OrderDate AS OrderDate,
    q.OrderNumber AS OrderNumber,
    q.Partner_Code AS Partner_Code,
    q.Partner_Name AS Partner_Name,
    q.Partner_Planning_Code AS Partner_Planning_Code,
    q.Partner_Planning_Name AS Partner_Planning_Name,
    q.DistributionChannel_1_Name AS DistributionChannel_1_Name,
    q.DistributionChannel_2_Name AS DistributionChannel_2_Name,
    q.DistributionChannel_3_Name AS DistributionChannel_3_Name,
    q.sku AS sku,
    q.ID_Order AS ID_Order,
    q.SalesDocumentNumber AS SalesDocumentNumber,
    q.SalesDocumentDate AS SalesDocumentDate,
    q.ActualShipmentDate AS ActualShipmentDate,
    q.SalesDocumentStatus AS SalesDocumentStatus,
    q.SalesDocumentCorrectionNumber AS SalesDocumentCorrectionNumber,
    q.SalesDocumentCorrectionDate AS SalesDocumentCorrectionDate,
    q.FlagSales AS FlagSales,
    q.ShipmentSubStatus AS ShipmentSubStatus,
    q.ShipmentStatus AS ShipmentStatus,
    q.Organization AS Organization,
    q.OrderStatus AS OrderStatus,
    coalesce(q.ManagementRevenue_Quantity_BUoM, 0) AS ManagementRevenue_Quantity_BUoM,
    coalesce(q.ManagementRevenue_NetValue, 0) AS ManagementRevenue_NetValue,
    coalesce(q.ManagementRevenue_GrossValue, 0) AS ManagementRevenue_GrossValue,
    coalesce(q.ManagementRevenue_NotCompleted_Quantity_BUoM, 0) AS ManagementRevenue_NotCompleted_Quantity_BUoM,
    coalesce(q.ManagementRevenue_NotCompleted_NetValue, 0) AS ManagementRevenue_NotCompleted_NetValue,
    coalesce(q.ManagementRevenue_NotCompleted_GrossValue, 0) AS ManagementRevenue_NotCompleted_GrossValue
FROM (
    SELECT 
        c1.Date AS DateValue,
        d.OrderDate AS OrderDate,
        d.OrderNumber AS OrderNumber,
        p.Partner_Code AS Partner_Code,
        p.Partner_Name AS Partner_Name,
        p.Partner_Planning_Code AS Partner_Planning_Code,
        p.Partner_Planning_Name AS Partner_Planning_Name,
        p.DistributionChannel_1_Name AS DistributionChannel_1_Name,
        p.DistributionChannel_2_Name AS DistributionChannel_2_Name,
        p.DistributionChannel_3_Name AS DistributionChannel_3_Name,
        ar.Sku AS sku,
        d.ID AS ID_Order,
        sd.SalesDocumentNumber AS SalesDocumentNumber,
        sd.SalesDocumentDate AS SalesDocumentDate,
        sd.ActualShipmentDate AS ActualShipmentDate,
        sds.Name AS SalesDocumentStatus,
        sdc.SalesDocumentCorrectionNumber AS SalesDocumentCorrectionNumber,
        sdc.SalesDocumentCorrectionDate AS SalesDocumentCorrectionDate,
        fsr.NameRu AS FlagSales,
        sss.Name AS ShipmentSubStatus,
        ss.Name AS ShipmentStatus,
        o.Name AS Organization,
        os.Name AS OrderStatus,
        sum(ManagementRevenue_Quantity_BUoM) AS ManagementRevenue_Quantity_BUoM,
        sum(ManagementRevenue_NetValue) AS ManagementRevenue_NetValue,
        sum(ManagementRevenue_GrossValue) AS ManagementRevenue_GrossValue,
        sum(ManagementRevenue_NotCompleted_Quantity_BUoM) AS ManagementRevenue_NotCompleted_Quantity_BUoM,
        sum(ManagementRevenue_NotCompleted_NetValue) AS ManagementRevenue_NotCompleted_NetValue,
        sum(ManagementRevenue_NotCompleted_GrossValue) AS ManagementRevenue_NotCompleted_GrossValue,
        row_number() OVER (PARTITION BY c1.Date, d.OrderDate, ar.Sku, p.Partner_Planning_Code ORDER BY c1.Date) AS rn
    FROM fact.ManagementRevenue AS s
    LEFT JOIN dim.Calendar                AS c1  ON s.ID_Calendar_SalesReportDate = c1.ID
    LEFT JOIN dim.Order                   AS d   ON s.ID_Order = d.ID
    LEFT JOIN olap.Partner                AS p   ON s.ID_Partner = p.ID_Partner
    LEFT JOIN dim.Article                 AS ar  ON s.ID_Article = ar.ID
    LEFT JOIN dim.SalesDocumentId         AS sd  ON s.ID_SalesDocument = sd.ID 
    LEFT JOIN dim.SalesDocumentStatus     AS sds ON sd.ID_SalesDocumentStatus = sds.ID
    LEFT JOIN dim.SalesDocumentCorrection AS sdc ON s.ID_SalesDocumentCorrection = sdc.ID
    LEFT JOIN dim.FlagSalesReport         AS fsr ON s.ID_FlagSalesReport = fsr.ID
    LEFT JOIN dim.ShipmentSubStatus       AS sss ON s.ID_ShipmentSubStatus = sss.ID
    LEFT JOIN dim.ShipmentStatus          AS ss  ON sss.ID_ShipmentStatus = ss.ID
    LEFT JOIN dim.Organization            AS o   ON s.ID_Organization = o.ID
    LEFT JOIN dim.OrderStatus             AS os  ON d.ID_OrderStatus = os.ID 
    WHERE ar.Name != 'Доставка заказа'
      AND c1.ID_Year >= 2025
      AND c1.ID_Year <= toYear(today())
      AND fsr.NameRu = 'Включен'
    GROUP BY 
        c1.Date,
        d.OrderDate,
        d.OrderNumber,
        p.Partner_Code,
        p.Partner_Name,
        p.Partner_Planning_Name,
        p.Partner_Planning_Code,
        p.DistributionChannel_1_Name,
        p.DistributionChannel_2_Name,
        p.DistributionChannel_3_Name,
        ar.Sku,
        sd.SalesDocumentNumber,
        sd.SalesDocumentDate,
        sd.ActualShipmentDate,
        sds.Name,
        sdc.SalesDocumentCorrectionNumber,
        sdc.SalesDocumentCorrectionDate,
        fsr.NameRu,
        sss.Name,
        ss.Name,
        d.ID,
        o.Name,
        os.Name
) AS q
WHERE q.DistributionChannel_1_Name IN ('Оффлайн', 'Аптеки', 'Прочие')
UNION ALL
-- Добавляем услуги доставки для прочих
SELECT
    NULL AS nPartYearMonth,
    ex.DateFrom AS Date,
    NULL AS OrderDate,
    NULL AS OrderNumber,
    NULL AS Partner_Code,
    NULL AS Partner_Name,
    pa.Partner_Planning_Code AS Partner_Planning_Code,
    NULL AS Partner_Planning_Name,
    'Прочие' AS DistributionChannel_1_Name,
    NULL AS DistributionChannel_2_Name,
    NULL AS DistributionChannel_3_Name,
    ar.Sku AS sku,
    NULL AS ID_Order,
    NULL AS SalesDocumentNumber,
    NULL AS SalesDocumentDate,
    NULL AS ActualShipmentDate,
    NULL AS SalesDocumentStatus,
    NULL AS SalesDocumentCorrectionNumber,
    NULL AS SalesDocumentCorrectionDate,
    'Включен' AS FlagSales,
    NULL AS ShipmentSubStatus,
    NULL AS ShipmentStatus,
    NULL AS Organization,
    NULL AS OrderStatus,
    NULL AS ManagementRevenue_Quantity_BUoM,
    sum(ex.Value_RUB) AS ManagementRevenue_NetValue,
    0 AS ManagementRevenue_GrossValue,
    0 AS ManagementRevenue_NotCompleted_Quantity_BUoM,
    0 AS ManagementRevenue_NotCompleted_NetValue,
    0 AS ManagementRevenue_NotCompleted_GrossValue
FROM bi.vw_OperationExpenses_w_target     AS ex
LEFT JOIN dim.OperationExpenses           AS re ON ex.Code_CostItem = re.CodeExpensesPL
LEFT JOIN dim.Article                     AS ar ON ex.ID_Article = ar.ID
LEFT JOIN dim.ArticleBrand                AS br ON ar.ID_ArticleBrand = br.ID AND br.IsMarkedForDeletion = 0
LEFT JOIN bi.vw_PlanningPartner           AS pa ON ex.ID_Partner = pa.ID_Partner_Planning
LEFT JOIN dim.Organization                as org ON ex.ID_Organization = org.ID
LEFT JOIN dim.DistributionChannel         AS dc ON pa.ID_DistributionChannel_Partner_Planning = dc.ID
LEFT JOIN dim.CompanyDepartment           AS cd ON ex.ID_CompanyDepartment = cd.ID AND cd.IsMarkedForDeletion = 0
LEFT JOIN dim.OperationExpensesType       AS ot ON ex.ID_OperationExpensesType = ot.ID
WHERE ot.Name = 'Факт'
  AND re.Name IN ('Выручка Прочая', 'Выручка от оказания услуг доставки')
GROUP BY
    ex.DateFrom,
    ar.Sku,
    pa.Partner_Planning_Code;
