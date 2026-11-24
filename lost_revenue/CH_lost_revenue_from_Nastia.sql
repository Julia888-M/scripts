with base as (
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
                date, sku, sku_base, marketplace, entity
        ),
        avg_raw as (
            select
                *,
                (sum(if(stock > 0 or orders > 0, 1, 0)) over (partition by sku, marketplace, entity order by toUInt32(date) range between 5 preceding and 1 preceding) = 0) as no_activity_5d,
                avg(nullIf(orders, 0)) over (partition by sku, marketplace, entity order by toUInt32(date) range between 30 preceding and 1 preceding) as avg_raw30
            from
                agg
        ),
        flagged as (
            select
                a.*,
                v.vname as vname,
                v.k_thr as k_thr,
                v.w_days as w_days,
                v.cov as cov,
                (
                    (a.marketplace = 'Wildberries' and a.date >= toDate('2026-07-24') and a.date <= toDate('2026-07-26'))
                    or (a.avg_raw30 is not null and a.orders > v.k_thr * a.avg_raw30)
                ) as is_anomaly
            from
                avg_raw a
                cross join (
                select 'base' as vname, toFloat64(1000.0) as k_thr, toUInt32(100000) as w_days, toFloat64(5.0) as cov
                union all select 'a33w60', toFloat64(3.3), toUInt32(60), toFloat64(5.0)
                ) v
        ),
        avg30 as (
            select
                *,
                avg(nullIf(if(is_anomaly, 0, orders), 0)) over (partition by sku, marketplace, entity, vname order by toUInt32(date) range between 30 preceding and 1 preceding) as avg_clean30
            from
                flagged
        ),
        norm as (
            select
                *,
                ifNull(avg_clean30, 0) * cov as stock_norm,
                if(avg_clean30 is not null and stock > avg_clean30 * cov and not is_anomaly, 1, 0) as is_healthy
            from
                avg30
        ),
        healthy as (
            select
                sku, marketplace, entity, vname, date,
                orders as ord,
                orders_rub as rev,
                toInt64(row_number() over (partition by sku, marketplace, entity, vname order by date)) as hd_idx
            from
                norm
            where
                is_healthy = 1
        ),
        hd_prefix as (
            select
                sku, marketplace, entity, vname, hd_idx,
                sum(ord) over (partition by sku, marketplace, entity, vname order by hd_idx rows between unbounded preceding and current row) as cum_ord,
                sum(rev) over (partition by sku, marketplace, entity, vname order by hd_idx rows between unbounded preceding and current row) as cum_rev,
                max(date) over (partition by sku, marketplace, entity, vname order by hd_idx rows between unbounded preceding and current row) as cum_date,
                sum(if(ord > 0, 1, 0)) over (partition by sku, marketplace, entity, vname order by hd_idx rows between unbounded preceding and current row) as cum_nz
            from
                healthy
        ),
        bounds as (
            select
                n.*,
                toInt64(sum(is_healthy) over (partition by sku, marketplace, entity, vname order by toUInt32(date) rows between unbounded preceding and 1 preceding)) as hd_hi,
                toInt64(sum(is_healthy) over (partition by sku, marketplace, entity, vname order by toUInt32(date) range between unbounded preceding and 61 preceding)) as hd_b60
            from
                norm n
        ),
        ranged as (
            select
                b.*,
                greatest(
                    if(w_days = 60, hd_b60, toInt64(0)) + 1,
                    hd_hi - 6
                ) as hd_lo
            from
                bounds b
        ),
        calc as (
            select
                r.date as date,
                r.sku as sku,
                r.sku_base as sku_base,
                r.marketplace as marketplace,
                r.entity as entity,
                r.vname as vname,
                r.orders as orders,
                r.orders_rub as orders_rub,
                r.stock as stock,
                r.avg_clean30 as avg_clean30,
                r.stock_norm as stock_norm,
                r.is_anomaly as is_anomaly,
                r.no_activity_5d as no_activity_5d,
                ifNull(hi.cum_ord, 0) - ifNull(lo.cum_ord, 0) as sum_ord,
                ifNull(hi.cum_rev, 0) - ifNull(lo.cum_rev, 0) as sum_rev,
                hi.cum_date as base_date,
                greatest(r.hd_hi - r.hd_lo + 1, 0) as cnt_days,
                toInt64(ifNull(hi.cum_nz, 0)) - toInt64(ifNull(lo.cum_nz, 0)) as cnt_nz
            from
                ranged r
                left join hd_prefix hi on hi.sku = r.sku and hi.marketplace = r.marketplace and hi.entity = r.entity and hi.vname = r.vname and hi.hd_idx = r.hd_hi
                left join hd_prefix lo on lo.sku = r.sku and lo.marketplace = r.marketplace and lo.entity = r.entity and lo.vname = r.vname and lo.hd_idx = r.hd_lo - 1
        ),
        final as (
            select
                *,
                if(cnt_days > 0, sum_ord / cnt_days, null) as pot,
                if(cnt_nz > 0, sum_ord / cnt_nz, null) as pot_nz,
                if(cnt_days > 0 and sum_ord > 0, sum_rev / sum_ord, null) as price
            from
                calc
        )
        select
            date as Date,
            sku as SKU,
            any(sku_base) as SKU_Base,
            marketplace as Marketplace,
            entity as Entity,
            any(orders) as Ordered,
            any(orders_rub) as Revenue,
            any(stock) as Stock,
            any(no_activity_5d) as NoActivity5d,
            ifNull(maxIf(avg_clean30, vname = 'base'), 0) as AvgSales30,
            maxIf(stock_norm, vname = 'base') as StockNorm,
            maxIf(is_anomaly, vname = 'base') as IsAnomaly,
            ifNull(maxIf(pot, vname = 'base'), 0) as PotentialSalesV2,
            ifNull(maxIf(price, vname = 'base'), 0) as PotentialPriceV2,
            dateDiff('day', maxIf(base_date, vname = 'base'), date) as PotentialAgeDays,
            ifNull(maxIf(pot,    vname = 'a33w60'), 0) as Pot_a33w60,
            ifNull(maxIf(pot_nz, vname = 'a33w60'), 0) as Pot_a33w60_nz,
            ifNull(maxIf(price, vname = 'a33w60'), 0) as Price_a33w60,
            maxIf(stock_norm, vname = 'a33w60') as StockNorm_a33
        from
            final
        where
            date >= toDate('2026-01-01')
        group by
            date, sku, marketplace, entity
        having
            any(orders) > 0
            or any(stock) > 0
            or ifNull(max(pot), 0) > 0