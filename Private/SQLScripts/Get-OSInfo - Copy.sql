
;WITH potential_columns AS
(
  SELECT 
   --affinity_type               = CONVERT(int           , NULL),
   --virtual_machine_type        = CONVERT(int           , NULL),
   physical_memory_kb          = CONVERT(bigint        , NULL),
   sql_memory_model            = CONVERT(int           , NULL),
   softnuma_configuration      = CONVERT(int           , NULL),
   socket_count                = CONVERT(int           , NULL),
   cores_per_socket            = CONVERT(int           , NULL),
   numa_node_count             = CONVERT(int           , NULL),
    -- in case we do encounter the old columns:
   physical_memory_in_bytes    = CONVERT(bigint        , NULL)
)
SELECT m.cpu_count, m.hyperthread_ratio, m.physical_memory_kb, m.physical_memory_in_bytes, m.sqlserver_start_time, m.affinity_type, m.virtual_machine_type, m.softnuma_configuration, m.sql_memory_model, m.socket_count, m.cores_per_socket, m.numa_node_count
INTO #OSInfo
FROM potential_columns
CROSS APPLY 
(
  SELECT cpu_count, 
    /* ... other columns *not* in the list above... , */
	affinity_type,
	hyperthread_ratio,
	sqlserver_start_time,
    virtual_machine_type,
    physical_memory_kb,
    sql_memory_model,
    softnuma_configuration,
    socket_count,
    cores_per_socket,
    numa_node_count,
	physical_memory_in_bytes 
  FROM sys.dm_os_sys_info
) AS m;

DECLARE @COUNT int

SELECT @COUNT = COUNT(*)
FROM #OSInfo 
WHERE physical_memory_in_bytes is not null

IF (@COUNT = 0)
BEGIN
    SELECT cpu_count, hyperthread_ratio, physical_memory_kb, sqlserver_start_time, affinity_type, virtual_machine_type, softnuma_configuration, sql_memory_model, socket_count, cores_per_socket, numa_node_count  FROM #OSInfo 
	END
	ELSE
	BEGIN
	SELECT cpu_count, hyperthread_ratio, (physical_memory_in_bytes /1024) as physical_memory_kb, sqlserver_start_time, affinity_type, virtual_machine_type, softnuma_configuration, sql_memory_model, socket_count, cores_per_socket, numa_node_count  FROM #OSInfo
	END

Drop table #OSInfo