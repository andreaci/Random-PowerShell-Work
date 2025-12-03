
SELECT *
FROM sys.dm_os_wait_stats dows
ORDER BY dows.wait_time_ms DESC;
 