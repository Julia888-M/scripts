/*SELECT 
"date"
, articul
, cab_name_group
, mp
, orderscount
, buyoutscount
, orderssumrub_nonds
, buyoutssumrub_nonds
, orderssumrub_nonds_startmonth
, buyoutssumrub_nonds_startmonth
, orderssumrub_nonds_month_20
, buyoutssumrub_nonds_month_20
, orderssumrub_nonds_startquarter
, buyoutssumrub_nonds_startquarter
, dates_from_current
, orderssumrub_nonds_35
, buyoutssumrub_nonds_35
, updated_at
FROM public.percent_of_ransom;
*/
select 
	date_trunc('month',"date") as start_of_month
	,case 
		when mp = 'OZON' then 'ЦБ-ЦБ000357'
		when mp = 'WB' then 'ЕР-ЕР003862'
		else 'ЕР-ЕР004646'
	end as partner_planning_code
	, sum(buyoutscount) / sum(orderscount) as percent_of_ransom
	, sum(buyoutssumrub_nonds) / sum(orderssumrub_nonds) as percent_of_ransom_nonds
	, sum(buyoutssumrub_nonds_startmonth) / sum(orderssumrub_nonds_startmonth) as percent_of_ransom_nonds_startmonth
	, sum(buyoutssumrub_nonds_month_20) / sum(orderssumrub_nonds_month_20) as percent_of_ransom_nonds_20
	, sum(buyoutssumrub_nonds_startquarter) / sum(orderssumrub_nonds_startquarter) as percent_of_ransom_nonds_startquarter
	, sum(buyoutssumrub_nonds_35) / sum(orderssumrub_nonds_35) as percent_of_ransom_nonds_35
from public.percent_of_ransom
group by
	date_trunc('month',"date"),
	mp
order by start_of_month DESC
, partner_planning_code DESC