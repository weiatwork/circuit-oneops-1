declare @AG sysname;
declare @Port nvarchar(6);
declare @MirroringPort nvarchar(6);
declare @Hostnames nvarchar(4000); --comma-separated list of nodes (hostname)
declare @Domain nvarchar(255);
declare @FailoverMode nvarchar(255)
declare @AvailabilityMode nvarchar(255)

declare @sSql nvarchar(max);
declare @Delimiter varchar(1) = ',';
declare @RoutingList nvarchar(4000);

SET @AG = $(ag_name);
SET @Port = $(tcp_port);
SET @MirroringPort = $(mirroring_port);
SET @Domain = $(domain);
SET @Hostnames = $(hostnames);
SET @FailoverMode = $(failover_mode)
SET @AvailabilityMode = $(availability_mode)

declare @nodes table (Name sysname PRIMARY KEY)

--split comma-separated list of nodes into a table
;WITH num AS (  SELECT top 4000 Number = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
                FROM       sys.all_objects AS s1
                CROSS JOIN sys.all_objects AS s2)
INSERT INTO @nodes (Name)
SELECT SUBSTRING(@Hostnames, Number, CHARINDEX(@Delimiter, @Hostnames + @Delimiter, Number) - Number)
FROM num
WHERE Number <= CONVERT(INT, LEN(@Hostnames))
    AND SUBSTRING(@Delimiter + @Hostnames, Number, LEN(@Delimiter)) = @Delimiter

SELECT @RoutingList = ISNULL(@RoutingList + ',','') + QUOTENAME(Name,char(39)) FROM @nodes

--Construct command to create availability group
select @sSql = ISNULL(@sSql,N'CREATE AVAILABILITY GROUP [' + @AG + ']
WITH (AUTOMATED_BACKUP_PREFERENCE = SECONDARY)
FOR
REPLICA ON') + char(13) + 'N' + QUOTENAME(Name,char(39)) + ' WITH (
  ENDPOINT_URL = N' + QUOTENAME('TCP://' + Name + '.' + @Domain + ':' + @MirroringPort,char(39)) + ',
  FAILOVER_MODE = ' + @FailoverMode + ',
  AVAILABILITY_MODE = ' + @AvailabilityMode + ',
  PRIMARY_ROLE(ALLOW_CONNECTIONS = ALL, READ_ONLY_ROUTING_LIST = (' + @RoutingList + ')), 
  SECONDARY_ROLE(ALLOW_CONNECTIONS = ALL, READ_ONLY_ROUTING_URL = ' + QUOTENAME('TCP://' + Name + '.' + @Domain + ':' + @Port,char(39)) +'), 
  SESSION_TIMEOUT = 30
                    ),'
from @nodes

SET @sSql = LEFT(@sSql,LEN(@sSql)-1);

EXEC (@sSql)
