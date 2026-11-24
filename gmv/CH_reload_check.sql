SELECT event_time, query
FROM system.query_log
WHERE type = 'QueryFinish'
  AND query_kind = 'Insert'
  AND query LIKE '%revenue_and_profit%'
ORDER BY event_time DESC
LIMIT 1;

