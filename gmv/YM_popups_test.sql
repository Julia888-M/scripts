SELECT 
 data_okazaniya_uslugi
--business_id
--, model_raboty
--, magazin_id
--, magazin_name
--, inn
--, nomer_dogovor_razmeshenie
--, nomer_dogovor_prodvizhenie
--, reklamodatel_id
--, nomer_campanii
--, nazvanie_kampanii
--, usluga
, sum(pokazy) as pokazy 
--, budget_type
--, budget
--, data_okazaniya_uslugi
--, date_trunc('month',data_okazaniya_uslugi) as data_okazaniya_uslugi
--, data_formirovaniya_akta
, sum(stoimost_uslugi_rub) as stoimost_uslugi_rub
--, token_id
--, created_at
--, id
FROM yandex_market.yandex_services_popups
where data_okazaniya_uslugi >= '2026-03-01'
group by 
--usluga
 data_okazaniya_uslugi
--, date_trunc('month',data_okazaniya_uslugi)
order by data_okazaniya_uslugi DESC
;