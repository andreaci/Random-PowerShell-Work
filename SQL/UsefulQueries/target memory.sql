SELECT
sqlserver_start_time,
(committed_kb/1024) AS Total_Server_Memory_MB,
(committed_target_kb/1024)  AS Target_Server_Memory_MB
FROM sys.dm_os_sys_info;

SELECT *
FROM sys.dm_os_wait_stats dows
ORDER BY dows.wait_time_ms DESC;
 