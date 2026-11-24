with t as (select distinct OrderID from dbo.ERP_ClientOrders)

select
      dco.MoveType "Вид движения",
--   dco.Period "Период",
      dco.OrderCode "Номер заказа",
      dco.OrderDate "Дата заказа",
      dco.OrderID "Заказа_ИД",
      dco.Contractor_ID "Контракт_ИД",
      dco.Nomenclature_ID "Номенклатура_ИД",
      dco.Quantity "Кол-во",
      dco.Summ "Сумма, руб",
      dco.CancelReason "Причина отмены",
      dco.SalesChannel_ID "Канал_продаж_ИД",
      dco.RecorderKey,
	  dco.NumberSite,
--    dco.LineNum,
--    dco.Wirehouse_ID,
dco.Actions,
      case 
          when rtu.datedoc is not null then rtu.datedoc
          when dco.ShipmentDate='01.01.1753' then dco.ShipOneDate
          else dco.ShipmentDate end as "Желаемая дата отгрузки",
      dco.ShipOneDate "Отгружать одной датой - дата",
      case 
         when dco.ShipOneDate is null then dco.ShipmentDate
         else dco.ShipOneDate end as "Дата отгрузки",
      case 
         when dco.ShipOneDate is not null then 1 
         else 0 end as "Отгружать одной датой",
      case
         when dco.AgreedShipmentDate is not null then AgreedShipmentDate
         when dco.ShipOneDate is not null then dco.ShipOneDate
         else dco.ShipmentDate end as "Дата согласованная с клиентом",
      dco.RTUCode,
      dwsc.Status "Статус",
      dwsc.Period "Дата фактической отгрузки"
from dbo.clientorders dco
left join t on dco.OrderID=t.OrderID
left join dbo.RTU on dco.OrderID=rtu.OrderID and dco.RTUCode=RTU.NumberDoc and rtu.isdeleted=0 and rtu.conducted=1
left join (select          
                           --distinct
			   YEAR(Period) "YearShipmentCheck",
                           sts.KIS_number,
                           --NomenclatureID,
                           max(Period) Period,
                           sts.Status,
                           ContractorID
           from dbo.WMS_ShipmentCheck shp left join dbo.WMS_ShipmentOrderStatuses sts on shp.OrderID=sts.OrderID
           group by sts.KIS_number, sts.Status, ContractorID, YEAR(Period) --, NomenclatureID
                                      ) dwsc on dwsc.KIS_number=dco.RTUCode and dco.Contractor_ID=dwsc.ContractorID and YEAR(dco.ShipmentDate)=dwsc.YearShipmentCheck
                                       --and dwsc.NomenclatureID=dco.Nomenclature_ID
where (dco.ShipmentDate>='01.01.2024' or rtu.datedoc>='01.01.2024' or dco.ShipOneDate>='01.01.2024')
and dco.MoveType=1
and dco.Wirehouse_ID not in
(
'f132a947-d608-11ee-b82b-a0369f2009be',
'ad770733-cef7-11ee-b82b-a0369f2009be',
'74f5c0aa-d70a-11ee-b82b-a0369f2009be',
'484690f7-d804-11ee-b82b-a0369f2009be',
'0f32e9b0-c4e3-11ee-b82b-a0369f2009be',
'0a982803-d48c-11ee-b82b-a0369f2009be'
)
and t.OrderID is null
and dco.OrderDate>'30.11.2024'

union all

select
      dco.MoveType "Вид движения",
--    dco.Period "Период",
      dco.OrderCode "Номер заказа",
      dco.OrderDate "Дата заказа",
      dco.OrderID "Заказа_ИД",
      dco.Contractor_ID "Контракт_ИД",
      dco.Nomenclature_ID "Номенклатура_ИД",
      dco.Quantity "Кол-во",
      dco.Summ "Сумма, руб",
      dco.CancelReason "Причина отмены",
      dco.SalesChannel_ID "Канал_продаж_ИД",
      dco.RecorderKey,
	  dco.NumberSite,
--    dco.LineNum,
dco.Actions,
      case 
          when rtu.datedoc is not null then rtu.datedoc
          when dco.ShipmentDate='01.01.1753' then dco.ShipOneDate
          else dco.ShipmentDate end as "Желаемая дата отгрузки",
      dco.ShipOneDate "Отгружать одной датой - дата",
      case 
         when dco.ShipOneDate is null then dco.ShipmentDate
         else dco.ShipOneDate end as "Дата отгрузки",
      case 
         when dco.ShipOneDate is not null then 1 
         else 0 end as "Отгружать одной датой",
      case
         when dco.AgreedShipmentDate is not null then AgreedShipmentDate
         when dco.ShipOneDate is not null then dco.ShipOneDate
         else dco.ShipmentDate end as "Дата согласованная с клиентом",
      dco.RTUCode,
      case
        when rtu.DateDoc is not null and dco.Actions='Отгрузить' and rtu.isdeleted=0 then 'Отгружен'
        else null end as "Статус",
      rtu.DateDoc "Дата фактической отгрузки"
from dbo.clientorders dco
left join t on dco.OrderID=t.OrderID
left join dbo.RTU on dco.OrderID=rtu.OrderID and dco.RTUCode=RTU.NumberDoc and rtu.isdeleted=0 and rtu.conducted=1
where (dco.ShipmentDate>='01.01.2024' or rtu.datedoc>='01.01.2024' or dco.ShipOneDate>='01.01.2024')
and dco.MoveType=1
and dco.Wirehouse_ID in
(
'f132a947-d608-11ee-b82b-a0369f2009be',
'ad770733-cef7-11ee-b82b-a0369f2009be',
'74f5c0aa-d70a-11ee-b82b-a0369f2009be',
'484690f7-d804-11ee-b82b-a0369f2009be',
'0f32e9b0-c4e3-11ee-b82b-a0369f2009be',
'0a982803-d48c-11ee-b82b-a0369f2009be'
)
and t.OrderID is null
and dco.OrderDate>'30.11.2024'

union all


select
      dco.MoveType "Вид движения",
--   dco.Period "Период",
      dco.OrderCode "Номер заказа",
      dco.OrderDate "Дата заказа",
      dco.OrderID "Заказа_ИД",
      dco.Contractor_ID "Контракт_ИД",
      dco.Nomenclature_ID "Номенклатура_ИД",
      dco.Quantity "Кол-во",
      dco.Summ "Сумма, руб",
      dco.CancelReason "Причина отмены",
      dco.SalesChannel_ID "Канал_продаж_ИД",
      dco.RecorderKey,
	  dco.NumberSite,
--    dco.LineNum,
--    dco.Wirehouse_ID,
dco.Actions,
      case 
          when erp_rtu.datedoc is not null then erp_rtu.datedoc
          when dco.ShipmentDate is not null then dco.ShipmentDate
          else dco.ShipOneDate end as "Желаемая дата отгрузки",
      dco.ShipOneDate "Отгружать одной датой - дата",
      case 
         when dco.ShipOneDate is null then dco.ShipmentDate
         else dco.ShipOneDate end as "Дата отгрузки",
      case 
         when dco.ShipOneDate is not null then 1 
         else 0 end as "Отгружать одной датой",
      case
         when dco.AgreedShipmentDate is not null then AgreedShipmentDate
         when dco.ShipOneDate is not null then dco.ShipOneDate
         else dco.ShipmentDate end as "Дата согласованная с клиентом",
      dco.RTUCode,
      dwsc.Status "Статус",
      dwsc.Period "Дата фактической отгрузки"
from dbo.erp_clientorders dco
left join dbo.erp_RTU on dco.OrderID=erp_rtu.OrderID and dco.RTUCode=erp_RTU.NumberDoc and erp_rtu.isdeleted=0 and erp_rtu.conducted=1
left join (select          
                           --distinct
			   YEAR(Period) "YearShipmentCheck",
                           sts.KIS_number,
                           --NomenclatureID,
                           max(Period) Period,
                           sts.Status,
                           ContractorID
           from dbo.WMS_ShipmentCheck shp left join dbo.WMS_ShipmentOrderStatuses sts on shp.OrderID=sts.OrderID
           group by sts.KIS_number, sts.Status, ContractorID, YEAR(Period) --, NomenclatureID
                                      ) dwsc on dwsc.KIS_number=dco.RTUCode and dco.Contractor_ID=dwsc.ContractorID 
                                       --and YEAR(dco.ShipmentDate)=dwsc.YearShipmentCheck
                                       --and dwsc.NomenclatureID=dco.Nomenclature_ID
where (dco.ShipmentDate>='01.01.2024' or erp_rtu.datedoc>='01.01.2024' or dco.ShipOneDate>='01.01.2024')
and dco.MoveType=1
and dco.Wirehouse_ID not in
(
'f132a947-d608-11ee-b82b-a0369f2009be',
'ad770733-cef7-11ee-b82b-a0369f2009be',
'74f5c0aa-d70a-11ee-b82b-a0369f2009be',
'484690f7-d804-11ee-b82b-a0369f2009be',
'0f32e9b0-c4e3-11ee-b82b-a0369f2009be',
'0a982803-d48c-11ee-b82b-a0369f2009be'
)
and dco.OrderDate>'30.11.2024'

union all

select
      dco.MoveType "Вид движения",
--    dco.Period "Период",
      dco.OrderCode "Номер заказа",
      dco.OrderDate "Дата заказа",
      dco.OrderID "Заказа_ИД",
      dco.Contractor_ID "Контракт_ИД",
      dco.Nomenclature_ID "Номенклатура_ИД",
      dco.Quantity "Кол-во",
      dco.Summ "Сумма, руб",
      dco.CancelReason "Причина отмены",
      dco.SalesChannel_ID "Канал_продаж_ИД",
      dco.RecorderKey,
	  dco.NumberSite,
--    dco.LineNum,
dco.Actions,
      case 
          when erp_rtu.datedoc is not null then erp_rtu.datedoc
          when dco.ShipmentDate is not null then dco.ShipmentDate
          else dco.ShipOneDate end as "Желаемая дата отгрузки",
      dco.ShipOneDate "Отгружать одной датой - дата",
      case 
         when dco.ShipOneDate is null then dco.ShipmentDate
         else dco.ShipOneDate end as "Дата отгрузки",
      case 
         when dco.ShipOneDate is not null then 1 
         else 0 end as "Отгружать одной датой",
      case
         when dco.AgreedShipmentDate is not null then AgreedShipmentDate
         when dco.ShipOneDate is not null then dco.ShipOneDate
         else dco.ShipmentDate end as "Дата согласованная с клиентом",
      dco.RTUCode,
      case
        when erp_rtu.DateDoc is not null and dco.Actions='Отгрузить' and erp_rtu.isdeleted=0 then 'Отгружен'
        else null end as "Статус",
      erp_rtu.DateDoc "Дата фактической отгрузки"
from dbo.erp_clientorders dco
left join dbo.erp_RTU on dco.OrderID=erp_rtu.OrderID and dco.RTUCode=erp_RTU.NumberDoc and erp_rtu.isdeleted=0 and erp_rtu.conducted=1
where (dco.ShipmentDate>='01.01.2024' or erp_rtu.datedoc>='01.01.2024' or dco.ShipOneDate>='01.01.2024')
and dco.MoveType=1
and dco.Wirehouse_ID in
(
'f132a947-d608-11ee-b82b-a0369f2009be',
'ad770733-cef7-11ee-b82b-a0369f2009be',
'74f5c0aa-d70a-11ee-b82b-a0369f2009be',
'484690f7-d804-11ee-b82b-a0369f2009be',
'0f32e9b0-c4e3-11ee-b82b-a0369f2009be',
'0a982803-d48c-11ee-b82b-a0369f2009be'
)
and dco.OrderDate>'30.11.2024'