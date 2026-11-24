with t1 as (select
      DateSale,
      Organization_ID,
      Contractor_ID,
      Nomenclature_ID,
      Operation,
      Quantity,
      SummWithDiscount,
      Sales_type
from dbo.MarketPlacesSales
where DateSale >='2024-04-01'
and DateSale <'2024-10-01'
and Contractor_ID='d492f8fa-126e-11ea-a20f-005056011207'
and JustificationPayment not in
(
'Возмещение издержек по перевозке',
'Логистика',
'Штрафы и доплаты',
'Возмещение издержек по перевозке/по складским операциям с товаром',
'Логистика сторно'
) -- убираю самые крупные статьи по кол-ву строк с нулем продаж или возвратов
)
select
      DateSale Дата,
      Organization_ID,
      Nomenclature_ID,
      Quantity "Кол-во шт",
      SummWithDiscount as "Сумма со скидкой, руб c НДС",
      (case when Organization_ID='054161fc-4427-11ea-a207-005056011106' 
	  or Organization_ID='ba5215e5-3415-11ed-b81c-a0369f2009be'
	  or Organization_ID='a76af604-9183-11ed-8120-04d4c490d013'
	  then SummWithDiscount
	  else SummWithDiscount/1.2
	  end) as "Сумма со скидкой, руб без НДС"
from t1
where Sales_type = 'Ежедневный'
and Contractor_ID='d492f8fa-126e-11ea-a20f-005056011207'
and DateSale in (select
					distinct m1.DateSale
				from dbo.MarketPlacesSales m1
				left join (select distinct DateSale from dbo.MarketPlacesSales where Sales_type = 'Еженедельный' and Contractor_ID='d492f8fa-126e-11ea-a20f-005056011207' and DateSale<'2024-10-01') m2 on m1.DateSale=m2.DateSale
				where m1.Sales_type = 'Ежедневный' 
				and m1.Contractor_ID='d492f8fa-126e-11ea-a20f-005056011207'
				and m1.DateSale>='2024-03-01'
				and m1.DateSale<'2024-11-01' 
				and m2.DateSale is null)