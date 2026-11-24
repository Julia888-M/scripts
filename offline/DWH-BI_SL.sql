WITH "Orders" AS (
    SELECT o."ID" as "ID_Order",
    		o."ID_Partner",
           o."OrderNumber",
           o."CustomerOrderNumber",
           p."Name" AS "Plant",
           p."Plant_1_Name" as "Operator",
           dp."Name" AS "DestinationPlant",
           c."Name" AS "CounterPartyName",
    --       adr.Fld7949_АдресДоставки as Address,
           pa."Partner_Planning_Code",
           cpsd."Date" AS "OrderPlannedShipmentDate",
           casd."Date" AS "OrderActualShipmentDate" 
    FROM "dim"."Order" o
    left JOIN "dim"."Plant" p ON p."ID" = o."ID_Plant"
    LEFT JOIN "dim"."OrderDestinationPlant" dp ON dp."ID" = o."ID_OrderDestinationPlant"
    LEFT JOIN "dim"."Calendar" cpsd ON cpsd."ID" = o."ID_Calendar_PlannedShipmentDate"
    LEFT JOIN "dim"."Calendar" casd ON casd."ID" = o."ID_Calendar_ActualShipmentDate"
    LEFT JOIN "dim"."Counterparty" c ON c."ID" = o."ID_Counterparty"
  --  LEFT JOIN erp1c.Document893_ЗаказКлиента adr on adr.ID_Document893_IDRRef_ЗаказКлиента = o.UIDDS
    LEFT JOIN "olap"."Partner" pa ON pa."ID_Partner" = c."ID_Partner"
      WHERE p."ID_Parent" NOT IN (293, 818)
--      AND ((cpsd.[Date] >= '2025-01-01' AND casd.[Date] >= '2025-01-01') 
--           OR o.PlannedShipmentDate IS NULL 
--           OR o.PlannedShipmentDate IS NULL)
      --AND pa.DistributionChannel_1_Name in ('Аптеки', 'Маркетплейсы', 'Оффлайн', 'Прочие')
),
"Measures" AS (
     SELECT
        'ShipmentMeasure' as "MeasureSource",
        sm."ID_Order", 
        sm."ID_Article", 
        --sm."ID_Article" as "ID_Article_Component",
        sm."Ordered_Quantity_BUoM" as "Ordered", 
        sm."Delivered_Quantity_BUoM" as "Delivered", 
        sm."OOS_Quantity_BUoM" as "Canceled",
       -- NULL::numeric as "Ordered_Component_NetValue",
       -- null::numeric as "Shipment_Component_NetValue",
        sm."Ordered_NetValue" as "NetValue_orders",
        sm."Shipment_NetValue" as "Shipment_NetValue",
        fsc."FlagShipmentCorrection", 
        t."AllocationType",
        ss."ShipmentStatus",
        ss."ShipmentSubStatus",
        sd."SalesDocumentNumber",
        sdc."SalesDocumentCorrectionNumber",
        c2."Date" as "ActualShipmentDate",
        c3."Date" as "PlannedShipmentDate",
        c."Date" as "CorrectionDate",
        --co.Counterparty_AddressActual as Address,
        rr."RejectionReason",
        rr."RejectionReasonCategory",
        sm."OrderedMixit_NetValue",												-- Уровень сервиса заказано Mixit вкл. кор. сумма без НДС
        sm."Execution_NetValue",
        sm."Ordered_NetValue"
    FROM "olap"."ShipmentMeasure" sm
    LEFT JOIN "olap"."FlagShipmentCorrection" fsc ON sm."ID_FlagShipmentCorrection" = fsc."ID_FlagShipmentCorrection"
    LEFT JOIN "olap"."SalesDocument" sd ON sm."ID_SalesDocument" = sd."ID_SalesDocument" 
    LEFT JOIN "olap"."SalesDocumentCorrection" sdc ON sdc."ID_SalesDocumentCorrection" = sm."ID_SalesDocumentCorrection"
    LEFT JOIN "olap"."Counterparty" co on sm."ID_Counterparty" = co."ID_Counterparty"
    LEFT JOIN "dim"."Calendar" c ON c."ID" = sdc."ID_Calendar_SalesDocumentCorrectionDate"
    LEFT JOIN "dim"."Calendar" c2 ON c2."ID" = sm."ID_Calendar_ActualShipmentDate"  
    LEFT JOIN "dim"."Calendar" c3 ON c3."ID" = sm."ID_Calendar_PlannedShipmentDate" 
    LEFT JOIN "olap"."AllocationType" t ON t."ID_AllocationType" = sm."ID_AllocationType" 
    LEFT JOIN "olap"."ShipmentStatus" ss ON sm."ID_ShipmentSubStatus" = ss."ID_ShipmentSubStatus"
    LEFT JOIN "olap"."RejectionReason" rr ON sm."ID_RejectionReason" = rr."ID_RejectionReason" 
    WHERE 
    sm."ID_Order" <> -1
    AND 
    fsc."FlagShipmentCorrection" <> 'Отрицательная кор. отгрузки'
    AND sm."ID_FlagSalesReport" = 1
)
SELECT 
       o."ID_Order", 
       o."OrderNumber",
       o."CustomerOrderNumber",
       o."Plant",
       o."ID_Partner",
       o."Operator",
       o."DestinationPlant",
       o."CounterPartyName",
       o."OrderPlannedShipmentDate",
       o."OrderActualShipmentDate",
       o."Partner_Planning_Code",
       m."PlannedShipmentDate" AS "MeasurePlannedShipmentDate",
       CASE WHEN m."FlagShipmentCorrection" = 'Положительная кор. отгрузки' 
            THEN m."CorrectionDate" 
            ELSE m."ActualShipmentDate" 
       END AS "CalculatedActualShipmentDate", -- Уникальное имя для вычисляемого поля
       m."MeasureSource",
       m."ID_Article",
      -- m."ID_Article_Component",
       a."Sku",
       m."Ordered",
       m."Delivered",
       m."Canceled",
       m."NetValue_orders",
      -- m."Ordered_Component_NetValue",
       m."Shipment_NetValue",
      -- m."Shipment_Component_NetValue",
       m."FlagShipmentCorrection",
       m."AllocationType",
       m."ShipmentStatus",
       m."ShipmentSubStatus",
       m."SalesDocumentNumber",
       m."SalesDocumentCorrectionNumber",
       m."CorrectionDate",              -- Оригинальная дата корректировки (без дублирования)
       m."ActualShipmentDate" AS "MeasureActualShipmentDate", -- Оригинальное поле из Measures под уникальным именем
       m."RejectionReason",
       m."RejectionReasonCategory",
       m."OrderedMixit_NetValue",												-- Уровень сервиса заказано Mixit вкл. кор. сумма без НДС
       m."Execution_NetValue",
       m."Ordered_NetValue"
FROM "Orders" o
LEFT JOIN "Measures" m ON o."ID_Order" = m."ID_Order"
LEFT JOIN "olap"."Partner" p ON o."ID_Partner" = p."ID_Partner"
left join "olap"."Article" a on m."ID_Article" = a."ID_Article"
WHERE p."DistributionChannel_1_Name" in ('Аптеки', 'Оффлайн')
--and date_trunc('year',"OrderPlannedShipmentDate") = date_trunc('year',"OrderActualShipmentDate")
--and date_trunc('month',"OrderPlannedShipmentDate") = date_trunc('month',"OrderActualShipmentDate")
and year("OrderPlannedShipmentDate")= year("OrderActualShipmentDate")
and month("OrderPlannedShipmentDate") = month("OrderActualShipmentDate")
and "ShipmentStatus" in ('Отгружено','Доставлено')
and "RejectionReasonCategory" in ('Unknown','Включена в сервис левел MIXIT')
and "OrderPlannedShipmentDate">='2025-01-01'
;
