with t1 as (
	select 
		"Nomer" as order_number
		,"OkonchanieSborkiRazborki" as order_date
		,"SsylkaGuid" as order_guid
		,"NomenklaturaGuid" as nomenclatura_guid
		,"SkladGuid" as sklad_guid
	from "ZakazNaSborku" 
	where "Status" in ('К выполнению')
	and "PometkaUdaleniya" is false
	and "KHozyaystvennayaOperatsiya" in ('Сборка из комплектующих')
		),
t2 as (
	select 
		znst."SsylkaGuid" as order_guid
		,znst."NomenklaturaGuid" as nomenclatura_guid
		,znst."Nomenklatura" as nomenclatura_name
		,n."Artikul" as article
		, "Kolichestvo" as articles_number
	from "ZakazNaSborkuTovary" znst
	left join "Nomenklatura" n on znst."NomenklaturaGuid" = n."SsylkaGuid"
	where "VariantObespecheniya" = 'Отгрузить'
	),
t3 as (
select 
	"Status" as status
	,"Nomer" as nomer_sborki
	,"ZakazNaSborkuGuid" as order_guid
from "SborkaTovarov"
where "Status" not in ('Собрано (разобрано)')
)
select
	t1.order_number
	--,t1.order_date 
	,t1.order_guid
	,t1.nomenclatura_guid
	,t2.article
	,t1.sklad_guid
	,sum(t2.articles_number) as articles_number
from t1 
left join t2 on t1.order_guid = t2.order_guid 
left join t3 on t1.order_guid = t3.order_guid 
where t2.nomenclatura_guid is not null
and t2.article is not null
and t1.sklad_guid in (
		'67db1893-1fc7-11ed-b81c-a0369f2009be','87efbfa9-1fc8-11ed-b81c-a0369f2009be', 
		'26bea6ec-22be-11ed-b81c-a0369f2009be','2d1e66f5-202d-11f0-b80e-f8f21e93e2a1',
		'5f53fb8d-1fc8-11ed-b81c-a0369f2009be', 'cd413b94-011d-11ee-8125-04d4c490d013',
        '0f32e9b0-c4e3-11ee-b82b-a0369f2009be','f25852c5-a9aa-11f0-9f7e-005056a4d85d',
        '7cfb249d-a9ab-11f0-9f7e-005056a4d85d','0e9498b5-a9ac-11f0-9f7e-005056a4d85d',
        'e7123124-f795-11f0-9f81-005056a4d85d','758e507f-9085-11f0-9f7d-005056a4d85d',
        'c206af7d-9086-11f0-9f7d-005056a4d85d','419dde7e-9087-11f0-9f7d-005056a4d85d',
       'f132a947-d608-11ee-b82b-a0369f2009be'
        )
and t3.order_guid is not null
group by 
	t1.order_number
	--,t1.order_date 
	,t1.order_guid
	,t1.nomenclatura_guid
	,t1.sklad_guid
	,t2.article