SELECT 
--id
 company_id
, ozon_token_id
, stock_date
--, sku
--, nazvanie_sklada
--, artikul
--, nazvanie_tovara
, sum(ostatok_na_nachalo_perioda) as ostatok_na_nachalo_perioda
--, sum(prihod) as prihod
--, sum(prihod_iz_postavok) as prihod_iz_postavok
--, sum(rashod) as rashod
--, sum(rashod_otgruzhennyy_v_dostavku) as rashod_otgruzhennyy_v_dostavku
, sum(ostatok_na_konets_perioda) as ostatok_na_konets_perioda
, sum(validnyy_stok_na_konets_perioda) as validnyy_stok_na_konets_perioda
, sum(nevalidnyy_stok_na_konets_perioda) as nevalidnyy_stok_na_konets_perioda
FROM ozon.ozon_lk_stocks_history
where 
stock_date = '2026-02-28'
--and ozon_token_id = '160920247'
--and nazvanie_sklada='ХОРУГВИНО_РФЦ'
group by 
--id
 company_id
, ozon_token_id
, stock_date
--, sku
--, nazvanie_sklada
--, artikul
--, nazvanie_tovara
;