select
t2."Artikul"
, t2."NaimenovaniePolnoe"
, t1."Znachenie" 
, 'Группа товаров на МП' as "Svoistvo"
from erp.public."NomenklaturaDopolnitelnyeRekvizity"  t1
left join erp.public."Nomenklatura" t2 on t1."SsylkaGuid"=t2."SsylkaGuid"
where t1."Svoystvo" like '%Группа товаров на МП%'