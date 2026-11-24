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
                    case
                        when upper(marketplace_source) = 'OZON' then 'Ozon'
                        when upper(marketplace_source) = 'YM' then 'Яндекс'
                        when upper(marketplace_source) = 'WB' then 'Wildberries'
                        else marketplace_source
                    end as marketplace,
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
                    'Wildberries' as marketplace,
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
                    'Ozon' as marketplace,
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
                    'Яндекс' as marketplace,
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
            flagged as (
                select
                    *,
                    ((marketplace = 'Wildberries' and date >= toDate('2026-07-24') and date <= toDate('2026-07-26'))
                    or orders / nullif(avg(orders) over (partition by sku, marketplace, entity 
                    	order by toUInt32(date) range between 30 preceding and 1 preceding),0)) > 3.3 as is_anomaly
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
            healthy_rolling as (
                select
                    sku, marketplace, entity, date,
                    sum(ord) over w_excl / nullIf(count() over w_excl, 0) as pot_self,
                    sum(rev) over w_excl / nullIf(sum(ord) over w_excl, 0) as price_self,
                    count() over w_excl as days_self,
                    max(date) over w_excl as base_self,
                    sum(ord) over w_incl / nullIf(count() over w_incl, 0) as pot_next,
                    sum(rev) over w_incl / nullIf(sum(ord) over w_incl, 0) as price_next,
                    count() over w_incl as days_next,
                    max(date) over w_incl as base_next
                from
                    healthy
                    window
                        w_excl as (partition by sku, marketplace, entity order by hd_idx rows between 7 preceding and 1 preceding),
                        w_incl as (partition by sku, marketplace, entity order by hd_idx rows between 6 preceding and current row)
            ),
            joined as (
                select
                    n.*,
                    hr.pot_self as pot_self,
                    hr.price_self as price_self,
                    hr.days_self as days_self,
                    hr.base_self as base_self,
                    hr.pot_next as pot_next,
                    hr.price_next as price_next,
                    hr.days_next as days_next,
                    hr.base_next as base_next
                from
                    norm n
                    left join healthy_rolling hr on hr.sku = n.sku and hr.marketplace = n.marketplace and hr.entity = n.entity and hr.date = n.date
            ),
           grp as (
                select
                    *,
                    count(pot_next) over (partition by sku, marketplace, entity order by toUInt32(date) rows between unbounded preceding and current row) as ffill_grp
                from
                    joined
            ),
            filled as (
                select
                    *,
                    max(pot_next) over wg as pot_next_f,
                    max(price_next) over wg as price_next_f,
                    max(days_next) over wg as days_next_f,
                    max(base_next) over wg as base_next_f
                from
                    grp
                    window wg as (partition by sku, marketplace, entity, ffill_grp)
            ),
            result as (
                select
                    *,
                    if(is_healthy_day = 1, pot_self, pot_next_f) as pot_final,
                    if(is_healthy_day = 1, price_self, price_next_f) as price_final,
                    if(is_healthy_day = 1, days_self, days_next_f) as days_final,
                    if(is_healthy_day = 1, base_self, base_next_f) as base_final
                from
                    filled
            )
            select
                date as Date,
                sku as SKU,
                sku_base as SKU_Base,
                marketplace as Marketplace,
                entity as Entity,
                orders as Ordered,
                orders_rub as Revenue,
                stock as Stock,
                round(ifNull(avg_sales_30, 0), 4) as AvgSales30,
                days_in_avg_30 as DaysInAvg30,
                stock_norm as StockNorm,
                round(ifNull(pot_final, 0), 4) as PotentialSalesV2,
                round(ifNull(price_final, 0), 2) as PotentialPriceV2,
                ifNull(days_final, 0) as HealthyDaysUsed,
                base_final as PotentialBaseDate,
                dateDiff('day', base_final, date) as PotentialAgeDays,
                is_anomaly as IsAnomaly,
                no_activity_3d as NoActivity3d,
                no_activity_5d as NoActivity5d,
                no_activity_7d as NoActivity7d
            from
                result
            where
                date >= toDate('2025-01-01')