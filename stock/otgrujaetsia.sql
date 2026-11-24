with t1 as (
select 
	"Nomer" as order_number
	, cast("ParametrDataDen" as date) as order_date
	, date_part('year',"ParametrDataDen") as order_year
	, "SsylkaGuid" as order_guid
from "ZakazKlienta"
where "PometkaUdaleniya" is false
and "Proveden" is true
and "Status" not in ('Закрыт', 'Отгружен')
),
t2 as (
select 
	"ZakazKlientaGuid" as order_guid
	,cast("ParametrDataDen" as date) as rtu_date
	,date_part('year',"ParametrDataDen") as rtu_year 
from "RealizatsiyaTovarovUslug"
),
t3 as (
select 
	zkv."SsylkaGuid" as order_guid
	,zkv."NomenklaturaGuid" as nomenclatura_guid
	,zkv."Nomenklatura" as nomenclatura_name
	,n."Artikul" as article
	,zkv."SkladGuid" as sklad_guid
	, "VariantObespecheniya"
	, "Kolichestvo" as articles_number
from "ZakazKlientaTovary" zkv
left join "Nomenklatura" n on zkv."NomenklaturaGuid" = n."SsylkaGuid"
where "VariantObespecheniya" = 'Отгрузить'
)
select 
	t1.order_number 
	--,t1.order_date
	,t1.order_guid 
	,t3.nomenclatura_guid
	,t3.article
	,t3.sklad_guid
	,sum(t3.articles_number) as articles_number 
from t1
left join t2 on t1.order_guid = t2.order_guid
--and t1.order_year = t2.rtu_year
left join t3 on t3.order_guid = t1.order_guid 
where t2.order_guid is null
and t3.nomenclatura_guid is not null
and t3.article is not null
and t3.sklad_guid in (
		'67db1893-1fc7-11ed-b81c-a0369f2009be','87efbfa9-1fc8-11ed-b81c-a0369f2009be', 
		'26bea6ec-22be-11ed-b81c-a0369f2009be','2d1e66f5-202d-11f0-b80e-f8f21e93e2a1',
		'5f53fb8d-1fc8-11ed-b81c-a0369f2009be', 'cd413b94-011d-11ee-8125-04d4c490d013',
        '0f32e9b0-c4e3-11ee-b82b-a0369f2009be','f25852c5-a9aa-11f0-9f7e-005056a4d85d',
        '7cfb249d-a9ab-11f0-9f7e-005056a4d85d','0e9498b5-a9ac-11f0-9f7e-005056a4d85d',
        'e7123124-f795-11f0-9f81-005056a4d85d','758e507f-9085-11f0-9f7d-005056a4d85d',
        'c206af7d-9086-11f0-9f7d-005056a4d85d','419dde7e-9087-11f0-9f7d-005056a4d85d',
       'f132a947-d608-11ee-b82b-a0369f2009be'
)
group by 
	t1.order_number
	--,t1.order_date
	,t1.order_guid 
	,t3.nomenclatura_guid
	,t3.article
	,t3.sklad_guid