SELECT "stock_date",
"updated_at",
"warehouse_name",
"articul_seller",
"articul_mp",
case when "marketplace_source"='OZON' and "stock_date" > '2026-04-15' then 0
else "quantity_full"
end as "quantity_full",
case when "marketplace_source"='OZON' and "stock_date" > '2026-04-15' then 0
else "free_to_sell_amount"
end as "free_to_sell_amount",
case when "marketplace_source"='OZON' and "stock_date" > '2026-04-15' then 0
else "reserved"
end as "reserved",
"in_way_from_client",
"defect_type",
"expired_type",
"quarantine_type",
"utilization_type",
"partner_code",
"marketplace_source",
"cab_name_group"
FROM "bi"."vw_mp_stocks"
;