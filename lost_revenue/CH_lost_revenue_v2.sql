with
            base as (
                select
                    stock_date as date,
                    articul_seller as sku_raw,
                    case
                        when token in (160920240, 160920241, 160920247) then 'ООО Миксит'
                        when token in (160920242, 160920249) then 'ООО Бьюти Инновации'
                        when token in (160920243, 170920242) then 'ООО Эксперт Криэйшн'
                        when token in (160920244, 160920248) then 'ООО Смарт бьюти'
                        when token in (160920245, 170920241) then 'ООО Эко Лаборатория'
                        when token in (160920246, 220420251) then 'ООО Лаборатория Здоровья'
                        else 'Не определено'
                    end as entity,
                    marketplace_source as marketplace,
                    toInt64(sum(coalesce(free_to_sell_amount, available_stock_count, 0))) as stock,
                    toInt64(0) as orders,
                    toFloat64(0) as orders_rub
                from
                    general.tbl_mp_stocks
                where
                    articul_seller <> ''
                    and articul_seller is not null
                    and (placement_type <> 'LAAS'
                    or placement_type is null)
                group by
                    1, 2, 3, 4
                union all
                select
                    report_date as date,
                    vendor_code as sku_raw,
                    case
                        when inn = '7733333130' then 'ООО Миксит'
                        when inn = '7733350288' then 'ООО Бьюти Инновации'
                        when inn = '9724132209' then 'ООО Лаборатория Здоровья'
                        when inn = '9703102267' then 'ООО Эко Лаборатория'
                        when inn = '9703102309' then 'ООО Смарт бьюти'
                        else 'Не определено'
                    end as entity,
                    'WB' as marketplace,
                    toInt64(0) as stock,
                    toInt64(sum(orders_count)) as orders,
                    toFloat64(sum(orders_sum_rub)) as orders_rub
                from
                    wb.vw_agg_wb_funnel_history
                group by
                    1, 2, 3
                union all
                select
                    s.date as date,
                    s.offer_id as sku_raw,
                    case
                        when s.client_id = '1435319' then 'ООО Лаборатория Здоровья'
                        when s.client_id = '24708' then 'ООО Миксит'
                        when s.client_id = '604766' then 'ООО Смарт бьюти'
                        when s.client_id = '98898' then 'ООО Бьюти Инновации'
                        else 'Не определено'
                    end as entity,
                    'OZON' as marketplace,
                    toInt64(0) as stock,
                    toInt64(sum(s.ordered_units)) as orders,
                    toFloat64(sum(s.revenue)) as orders_rub
                from
                    ozon.vw_agg_ozon_sales_funnel_daily s
                group by
                    1, 2, 3
                union all
                select
                    report_date as date,
                    offer_id as sku_raw,
                    'ООО Миксит' as entity,
                    'YM' as marketplace,
                    toInt64(0) as stock,
                    toInt64(sum(order_items)) as orders,
                    toFloat64(sum(order_items_total_amount)) as orders_rub
                from
                    yandex_market.vw_agg_yandex_shows_sales_daily
                group by
                    1, 2
            ),
            cleaned as (
                select
                    date,
                    extract(upper(trimBoth(sku_raw)), '^((?:SKU[0-9]{10}|SKUA[0-9]{9})(?:-[A-Z0-9]+)?)') as sku,
                    extract(upper(trimBoth(sku_raw)), '^(SKU[0-9]{10}|SKUA[0-9]{9})') as sku_base,
                    marketplace,
                    entity,
                    stock,
                    orders,
                    orders_rub
                from
                    base
            ),
            agg as (
                select
                    date,
                    sku,
                    sku_base,
                    marketplace,
                    entity,
                    sum(orders) as orders,
                    sum(orders_rub) as orders_rub,
                    sum(stock) as stock
                from
                    cleaned
                where
                    sku_base != ''
                group by
                    date,
                    sku,
                    sku_base,
                    marketplace,
                    entity
            ),
            -- дни распродаж
            flagged as (
                select
                    *,
                    (marketplace = 'WB' and date >= toDate('2026-07-24') and date <= toDate('2026-07-26')) as is_anomaly
                from
                    agg
            ),
            avg30 as (
                select
                    *,
                    avg(nullIf(if(is_anomaly, 0, orders), 0)) over (partition by sku, marketplace, entity order by toUInt32(date) range between 30 preceding and 1 preceding) as avg_sales_30,
                    countIf(not is_anomaly and orders > 0) over (partition by sku, marketplace, entity order by toUInt32(date) range between 30 preceding and 1 preceding) as days_in_avg_30
                from
                    flagged
            ),
            norm as (
                select
                    *,
                    round(ifNull(avg_sales_30, 0) * 5, 2) as stock_norm,
                    if(avg_sales_30 is not null and stock > avg_sales_30 * 5 and not is_anomaly, 1, 0) as is_healthy_day,
                    (sum(if(stock > 0 or orders > 0, 1, 0)) over (partition by sku, marketplace, entity order by toUInt32(date) range between 3 preceding and 1 preceding) = 0) as no_activity_3d,
                    (sum(if(stock > 0 or orders > 0, 1, 0)) over (partition by sku, marketplace, entity order by toUInt32(date) range between 5 preceding and 1 preceding) = 0) as no_activity_5d,
                    (sum(if(stock > 0 or orders > 0, 1, 0)) over (partition by sku, marketplace, entity order by toUInt32(date) range between 7 preceding and 1 preceding) = 0) as no_activity_7d
                from
                    avg30
            ),
            healthy as (
                select
                    sku, marketplace, entity, date,
                    orders as ord,
                    orders_rub as rev,
                    row_number() over (partition by sku, marketplace, entity order by date) as hd_idx
                from
                    norm
                where
                    is_healthy_day = 1
            ),
            healthy_rolling AS (
        SELECT
            sku,
            marketplace,
            entity,
            date,
            sum(ord) OVER w_excl / nullIf(count() OVER w_excl, 0) AS pot_self,
            sum(rev) OVER w_excl / nullIf(sum(ord) OVER w_excl, 0) AS price_self,
            count() OVER w_excl AS days_self,
            max(date) OVER w_excl AS base_self,
            sum(ord) OVER w_incl / nullIf(count() OVER w_incl, 0) AS pot_next,
            sum(rev) OVER w_incl / nullIf(sum(ord) OVER w_incl, 0) AS price_next,
            count() OVER w_incl AS days_next,
            max(date) OVER w_incl AS base_next
        FROM healthy
        WINDOW
            w_excl AS (
                PARTITION BY sku,
                marketplace,
                entity ORDER BY hd_idx ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
            ),
            w_incl AS (
                PARTITION BY sku,
                marketplace,
                entity ORDER BY hd_idx ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
            )
    ),
           joined AS (
        SELECT
            n.*,
            hr.pot_self AS pot_self,
            hr.price_self AS price_self,
            hr.days_self AS days_self,
            hr.base_self AS base_self,
            hr.pot_next AS pot_next,
            hr.price_next AS price_next,
            hr.days_next AS days_next,
            hr.base_next AS base_next
        FROM norm n
        LEFT JOIN healthy_rolling hr
            ON hr.sku = n.sku
            AND hr.marketplace = n.marketplace
            AND hr.entity = n.entity
            AND hr.date = n.date
    ),
           grp AS (
        SELECT
            *,
            count(pot_next) OVER (
                PARTITION BY sku,
                marketplace,
                entity ORDER BY toUInt32(date) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS ffill_grp
        FROM joined
    ),
            filled AS (
        SELECT
            *,
            max(pot_next) OVER wg AS pot_next_f,
            max(price_next) OVER wg AS price_next_f,
            max(days_next) OVER wg AS days_next_f,
            max(base_next) OVER wg AS base_next_f
        FROM grp
        WINDOW
            wg AS (PARTITION BY sku, marketplace, entity, ffill_grp)
    ),
    result AS (
        SELECT
            *,
            if(is_healthy_day = 1, pot_self, pot_next_f) AS pot_final,
            if(is_healthy_day = 1, price_self, price_next_f) AS price_final,
            if(is_healthy_day = 1, days_self, days_next_f) AS days_final,
            if(is_healthy_day = 1, base_self, base_next_f) AS base_final
        FROM filled
    )
        select
                date as Date,
                sku as SKU,
                sku_base as SKU_Base,
                marketplace as Marketplace,
                case 
                	when entity='ООО Миксит' then 'Миксит новый'
                	when entity='ООО Бьюти Инновации' then 'Бьюти Инновации ООО'
                	when entity='ООО Эксперт Криэйшн' then 'Эксперт Криэйшн ООО'
                	when entity='ООО Смарт бьюти' then 'СМАРТ БЬЮТИ'
                	when entity='ООО Эко Лаборатория' then 'Эко лаборатория'
                	when entity='ООО Лаборатория Здоровья' then 'Лаборатория здоровья'
                end as organization_name,                
                entity as Entity, 
                orders as Ordered, --Количество заказов
                orders_rub as Revenue, --Сумма заказов, руб 
                orders_rub/NDS as Revenue_no_nds, --Сумма заказов, руб без НДС
                stock as Stock,--Доступный к продаже остаток, шт
                round(ifNull(avg_sales_30, 0), 4) as AvgSales30, --Заказано шт в среднем за последние 30 дней
                days_in_avg_30 as DaysInAvg30, --Дней в интервале 30d
                stock_norm as StockNorm, --Целевое количество запасов, шт
                round(ifNull(pot_final, 0), 4) AS PotentialSalesV2, --Потенциал продаж, шт/день
                round(ifNull(price_final, 0), 2) AS PotentialPriceV2, --Потенциальная цена (эталон), руб
                ifNull(days_final, 0) AS HealthyDaysUsed, --Количество здоровых дней в расчете
                base_final AS PotentialBaseDate, --Базовая дата для расчета потенциальных продаж
                dateDiff('day', base_final, date) AS PotentialAgeDays, --Количество потенциальных дней
                is_anomaly as IsAnomaly, --Дни распродаж
                no_activity_3d as NoActivity3d, --Период без движения 3d
                no_activity_5d as NoActivity5d, --Период без движения 5d
                no_activity_7d as NoActivity7d, --Период без движения 7d
                case 
	                when stock <= stock_norm and orders < round(ifNull(pot_self, 0), 4) then 1 
                	else 0 
                end as IsDeficitDay,
                 case 
	                when stock <= stock_norm and orders < round(ifNull(pot_self, 0), 4)
	                then round(ifNull(pot_self, 0), 4) - orders	
	                else 0
                end as "Упущенные заказы, шт",
                case 
	                when stock <= stock_norm and orders < round(ifNull(pot_self, 0), 4)
	                then (round(ifNull(pot_self, 0), 4) - orders) * round(ifNull(price_self, 0), 2)	
	                else 0
                end as "Упущенная выручка, руб",
                case 
	                when stock <= stock_norm and orders < round(ifNull(pot_self, 0), 4)
	                then ((round(ifNull(pot_self, 0), 4) - orders) * round(ifNull(price_self, 0), 2))/NDS	
	                else 0
                end as "Упущенная выручка, руб без НДС", 
                case 
	                when stock <= stock_norm and orders < round(ifNull(pot_self, 0), 4)  and no_activity_5d=0
	                then round(ifNull(pot_self, 0), 4) - orders	
	                else 0
                end as "Упущенные заказы вне периодов без движения 5d, шт",
                case 
	                when stock <= stock_norm and orders < round(ifNull(pot_self, 0), 4) and no_activity_5d=0
	                then (round(ifNull(pot_self, 0), 4) - orders) * round(ifNull(price_self, 0), 2)	
	                else 0
                end as "Упущенная выручка вне периодов без движения 5d, руб",
                case 
	                when stock <= stock_norm and orders < round(ifNull(pot_self, 0), 4) and no_activity_5d=0
	                then ((round(ifNull(pot_self, 0), 4) - orders) * round(ifNull(price_self, 0), 2))/NDS	
	                else 0
                end as "Упущенная выручка вне периодов без движения 5d, руб без НДС", 
                nds_table.nds as NDS               
             from
                result f
               	 left join 
               	(
               	    select distinct organization_name, nds, nds_start, nds_end
               		from `general`.cab_name_group_with_nds
               	) nds_table 
               	-- Связываем напрямую через замапленное имя организации и даты
               	on organization_name = nds_table.organization_name 
               	and f.date between nds_table.nds_start and nds_table.nds_end
             where
                f.date >= toDate('2025-01-01') 
                ;