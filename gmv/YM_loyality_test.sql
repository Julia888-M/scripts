SELECT 
--business_id
--, model_raboty
--, magazin_id
--, magazin_name
--, inn
--, nomer_dogovor_razmeshenie
--, nomer_dogovor_prodvizhenie
--, nomer_zakaza
--,sku
--, nazvanie_tovara
date_trunc('month',data_vremya_okazaniya_usligi) as data_vremya_okazaniya_usligi
, sum(vasha_tsena_ed_rub) as vasha_tsena_ed_rub
, sum(polzovatel_zaplatil_rub) as polzovatel_zaplatil_rub
, sum(kolichestvo) as kolichestvo
--, usluga
--, otzyv_id
--, tarif_ed
--, edinitsa_izmereniya
--, data_formirovaniya_akta
, sum(stoimost_uslugi_rub) as stoimost_uslugi_rub
--, token_id
--, created_at
--, id
FROM yandex_market.yandex_services_loyalty
group by date_trunc('month',data_vremya_okazaniya_usligi)
order by date_trunc('month',data_vremya_okazaniya_usligi) DESC
;