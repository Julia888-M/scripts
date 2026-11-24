WITH t1 AS (
-------------Orders (заказы)
SELECT 
o.ID
, o.UIDDS
, o.IsMarkedForDeletion
, o.OrderNumber
, o.CustomerOrderNumber
, o.OrderDate
, o.CustomerOrderDate
, o.ActualShipmentDate
, o.PlannedShipmentDate
, o.ConfirmedShipmentDate
, o.AgreedDate
, o.ID_Calendar_OrderDate
, o.ID_Calendar_CustomerOrderDate
, o.ID_Calendar_ActualShipmentDate
, o.ID_Calendar_PlannedShipmentDate
, o.ID_Calendar_ConfirmedShipmentDate
, o.ID_Calendar_AgreedDate
, o.IsPosted
, o.IsConfirmedShipmentDate
, o.ID_Organization
, o.ID_Partner
, o.ID_Counterparty
, o.ID_SalesChannel
, o.ID_Plant
, o.ID_OrderStatus
, o.ID_Currency
, o.ID_Operation
, o.ID_Contract
, o.ID_CompanyDepartment
, o.ID_Employee_Manager
, o.IsAgreed
, o.ID_CounterpartyAgreement
, o.AdditionalInformation
, o.ID_FlagSalesReport
, o.ID_DeliveryMethod
, o.PromisedDeliveryDate
, o.ID_Calendar_PromisedDeliveryDate
, o.ID_Document1C
, o.ID_SourceDocument
, o.ID_PointOfSales
, o.ID_PointOfDelivery
, o.ID_OrderDestinationPlant
, o.IsVirtualOrder
FROM DWH_BI.dim.[Order] o
),
t2 AS(
----------------------ExpenceOrders (расходные ордера)
SELECT 
eo.ID
, eo.UIDDS
, eo.IsMarkedForDeletion
, eo.ExpenseOrderNumber
, eo.ExpenseOrderDate
, eo.ID_Calendar_ExpenseOrderDate
, eo.ActualShipmentDate
, eo.ActualShipmentDateTime
, eo.ID_Calendar_ActualShipmentDate
, eo.IsPosted
, eo.ID_Order
, eo.ID_Partner_Recipient
, eo.ID_Plant_Recipient
, eo.ID_CompanyDepartment_Recipient
, eo.ID_Plant
, eo.ID_ExpenseOrderStatus
, eo.ID_Priority
, eo.ID_WarehouseOperation
, eo.ID_Employee_Responsible
, eo.Comment
, eo.ID_FlagSalesReport
, eo.ID_Document1C
, eo.ID_SourceDocument
, eo.ID_Document1C_Base
, eo.ID_SourceDocument_Base
FROM DWH_BI.dim.ExpenseOrder eo
LEFT JOIN DWH_BI.dim.WarehouseOperation wo ON eo.ID_WarehouseOperation = wo.ID 
WHERE wo.Name = 'Отгрузка клиенту'
),
t3 AS (
--------------------- SalesDocument (Документы продажи - Реализация товаров и услуг)
SELECT 
sd.ID
, sd.UIDDS
, sd.IsMarkedForDeletion
, sd.SalesDocumentNumber
, sd.SalesDocumentDate
, sd.ActualShipmentDate
, sd.ID_Order
, sd.ID_Calendar_SalesDocumentDate
, sd.ID_Calendar_ActualShipmentDate
, sd.IsPosted
, sd.ID_Organization
, sd.ID_Partner
, sd.ID_Counterparty
, sd.ID_Plant
, sd.ID_SalesDocumentStatus
, sd.ID_Currency
, sd.ID_Operation
, sd.ID_Contract
, sd.ID_CompanyDepartment
, sd.ID_Employee_Manager
, sd.ID_Employee_Author
, sd.IsAgreed
, sd.ID_CounterpartyAgreement
, sd.ID_FlagSalesReport
, sd.ID_Document1C
, sd.ID_SourceDocument
, sd.ID_Document1C_Order
, sd.ID_SourceDocument_Order
, sd.ID_Document1C_CommissionerReportPreliminary
, sd.ID_SourceDocument_CommissionerReportPreliminary
, sd.ID_CommissionerReportPreliminary
FROM DWH_BI.dim.SalesDocument sd
)
SELECT 
t1.ID as ID_Order
, t1.OrderNumber
, t1.OrderDate
, os.Name as 'OrderStatus'
, t2.ExpenseOrderNumber
, t2.ExpenseOrderDate
, t3.SalesDocumentNumber
, t3.SalesDocumentDate
, sds.Name as 'SalesDocumentStatus'
, fsr.NameRu as 'FlagSales'
, eos.Name as 'ExpenseOrderStatus'
, p.DistributionChannel_1_Name 
, p.DistributionChannel_2_Name 
, p.DistributionChannel_3_Name 
, p.Partner_Planning_Code 
, p.Partner_Planning_Name 
, p.Partner_Code 
, p.Partner_Name 
, o.Name as 'Organization'
, t2.ActualShipmentDate
FROM t1 
LEFT JOIN t3 ON t1.ID = t3.ID_Order
LEFT JOIN t2 ON t1.ID = t2.ID_Order
Left JOIN dim.Calendar                            as c1  on t3.ID_Calendar_SalesDocumentDate = c1.ID
left join olap.[Partner]                 as p   on t1.ID_Partner = p.ID_Partner
left join dim.SalesDocumentStatus        as sds on t3.ID_SalesDocumentStatus = sds.ID
--left join dim.SalesDocumentCorrection    as sdc on t1.ID_SalesDocumentCorrection = sdc.ID
left join dim.FlagSalesReport            as fsr on t1.ID_FlagSalesReport = fsr.ID
 --        left join dim.ShipmentSubStatus          as sss ON s.ID_ShipmentSubStatus = sss.ID
 --        left join dim.ShipmentStatus             AS  ss on sss.ID_ShipmentStatus = ss.ID
left join dim.Organization               as o   on t1.ID_Organization = o.ID
LEFT JOIN dim.OrderStatus                as os  ON t1.ID_OrderStatus = os.ID 
LEFT JOIN dim.ExpenseOrderStatus         as eos ON t2.ID_ExpenseOrderStatus = eos.ID 
WHERE t1.OrderDate >= '2026-01-01'
