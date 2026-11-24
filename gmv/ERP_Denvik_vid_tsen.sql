with t1 as (
   select distinct
    p."mix_ПартнерПланирования"
    , "Kontragent"
	, "Partner"
	, "VidTSen"
	--, "VidTSenGuid"
	--, "KontragentGuid"
	--, "PartnerGuid"
	--, p."mix_ПартнерПланированияГуид"
	from public."Partnery" as p 
	left join public."SoglasheniyaSKlientami" as sk on sk."PartnerGuid" = p."СсылкаГуид"
	left join public."UstanovkaTSenNomenklaturyTovary" utn on utn."VidTSenyGuid" = sk."VidTSenGuid" 
	where "VidTSen" is not null 
	and "VidTSen" <> ''
	and p."mix_ПартнерПланирования" is not null
	and p."mix_ПартнерПланирования" <> ''
	AND "Kontragent" <> ''
    AND "Kontragent" IS NOT null
    and utn."ParametrDataDen" >= '2026-01-01'
   ),
t2 as (    
	SELECT distinct
	 n."Artikul" 
	, "Nomenklatura"
	, "VidTSeny"
	, "TSena"
	, cast("ParametrDataDen" as date) as start_of_price
	, coalesce(LEAD("ParametrDataDen") OVER (PARTITION BY n."Artikul","VidTSeny" ORDER BY "ParametrDataDen")::date, '2099-01-01'::date) AS next_date
	, coalesce((LEAD("ParametrDataDen") OVER (PARTITION BY n."Artikul","VidTSeny" ORDER BY "ParametrDataDen")- INTERVAL '1 day')::date, '2099-01-01'::date ) AS end_of_price
	FROM public."UstanovkaTSenNomenklaturyTovary" utn
	left join public."Nomenklatura" n on utn."NomenklaturaGuid" = n."SsylkaGuid"
	where "Nomenklatura" is not null
	and "Nomenklatura" <> ''
   ),
t3 as (
	SELECT 
     datum::date AS calendar_date
	FROM generate_series(
    '2026-01-01'::DATE, -- Начальная дата
    '2027-12-31'::DATE, -- Конечная дата
    '1 day'::INTERVAL
) AS datum
)
select 
t3.calendar_date
, t1."mix_ПартнерПланирования"
, t2."Artikul"
, t2."TSena"
from t3
left join t2 on calendar_date >= start_of_price and calendar_date <= end_of_price
left join t1 on t2."VidTSeny" = t1."VidTSen"
where "VidTSen" is not null 
	and "VidTSen" <> ''
	and "mix_ПартнерПланирования" is not null
	and "mix_ПартнерПланирования" <> ''
	AND "Kontragent" <> ''
	AND "Kontragent" IS NOT null
	and end_of_price >='2026-01-01'
;
	


