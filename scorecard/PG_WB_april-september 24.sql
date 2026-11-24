select
      DateSale Дата,
      'ЕР-ЕР003862' as "Партнер планирования - Код",
      --Organization_ID Орг_ИД,
      --Contractor_ID Контракт_ИД,
      --Nomenclature_ID НК_ИД,
      t2.Articul,
     -- Operation "Тип операции",
      Quantity "Кол-во шт",
      SummWithDiscount "Выручка, руб с НДС",
      (case when Organization_ID='054161fc-4427-11ea-a207-005056011106' 
	  or Organization_ID='ba5215e5-3415-11ed-b81c-a0369f2009be'
	  or Organization_ID='a76af604-9183-11ed-8120-04d4c490d013'
	  then SummWithDiscount
	  else SummWithDiscount/1.2
	  end) as "Выручка, руб без НДС"
    --  Sales_type
from dbo.MarketPlacesSales t1
left join BI1C.dbo.ERP_Nomenclature t2 on t1.Nomenclature_ID = t2.ID
where Sales_type = 'Ежедневный'
and DateSale >= '2024-04-01'
and DateSale < '2024-10-01'
and Contractor_ID='d492f8fa-126e-11ea-a20f-005056011207'
and SummWithDiscount <> 0
