WITH t1 AS (
    -- Orders (заказы)
    SELECT 
        o.ID,
        o.OrderNumber,
        o.OrderDate,
        o.ID_Organization,
        o.ID_Partner,
        o.ID_OrderStatus,
        o.ID_FlagSalesReport
    FROM dim.Order AS o
    WHERE o.IsPosted = 1 
      AND o.IsMarkedForDeletion = 0
      AND o.OrderDate >= '2026-01-01'
),
t2 AS (
    -- ExpenseOrders (расходные ордера)
    SELECT 
        eo.ID_Order,
        eo.ExpenseOrderNumber,
        eo.ExpenseOrderDate,
        eo.ActualShipmentDate,
        eo.ID_ExpenseOrderStatus
    FROM dim.ExpenseOrder AS eo
    INNER JOIN dim.WarehouseOperation AS wo 
        ON eo.ID_WarehouseOperation = wo.ID 
    WHERE wo.Name = 'Отгрузка клиенту'
      AND eo.IsPosted = 1 
      AND eo.IsMarkedForDeletion = 0
),
t3 AS (
    -- SalesDocument (Документы продажи - Реализация товаров и услуг)
    SELECT 
        sd.ID_Order,
        sd.SalesDocumentNumber,
        sd.SalesDocumentDate,
        sd.ID_Calendar_SalesDocumentDate,
        sd.ID_SalesDocumentStatus
    FROM dim.SalesDocument AS sd
    WHERE sd.IsPosted = 1 
      AND sd.IsMarkedForDeletion = 0
      AND sd.SalesDocumentNumber IS NOT NULL
)
SELECT 
    t1.ID AS ID_Order,
    t1.OrderNumber,
    t1.OrderDate,
    os.Name AS OrderStatus,
    t2.ExpenseOrderNumber,
    t2.ExpenseOrderDate,
    t3.SalesDocumentNumber,
    t3.SalesDocumentDate,
    sds.Name AS SalesDocumentStatus,
    fsr.NameRu AS FlagSales,
    eos.Name AS ExpenseOrderStatus,
    p.DistributionChannel_1_Name,
    p.DistributionChannel_2_Name,
    p.DistributionChannel_3_Name,
    p.Partner_Planning_Code,
    p.Partner_Planning_Name,
    p.Partner_Code,
    p.Partner_Name,
    o.Name AS Organization,
    t2.ActualShipmentDate
FROM t1 
INNER JOIN t3 ON t1.ID = t3.ID_Order
LEFT JOIN t2 ON t1.ID = t2.ID_Order
LEFT JOIN dim.Calendar AS c1 ON t3.ID_Calendar_SalesDocumentDate = c1.ID
LEFT JOIN olap.Partner AS p ON t1.ID_Partner = p.ID_Partner
LEFT JOIN dim.SalesDocumentStatus AS sds ON t3.ID_SalesDocumentStatus = sds.ID
LEFT JOIN dim.FlagSalesReport AS fsr ON t1.ID_FlagSalesReport = fsr.ID
LEFT JOIN dim.Organization AS o ON t1.ID_Organization = o.ID
LEFT JOIN dim.OrderStatus AS os ON t1.ID_OrderStatus = os.ID 
LEFT JOIN dim.ExpenseOrderStatus AS eos ON t2.ID_ExpenseOrderStatus = eos.ID;
