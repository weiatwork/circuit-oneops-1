--Create SYSTEM account
IF NOT EXISTS (select 1 from sys.syslogins where name = 'NT AUTHORITY\SYSTEM')
  CREATE LOGIN [NT AUTHORITY\SYSTEM] FROM WINDOWS WITH DEFAULT_DATABASE=[master]

GRANT ALTER ANY AVAILABILITY GROUP TO [NT AUTHORITY\SYSTEM]
GRANT CONNECT SQL TO [NT AUTHORITY\SYSTEM]
GRANT VIEW SERVER STATE TO [NT AUTHORITY\SYSTEM]

--Create mirroring endpoint
IF NOT EXISTS (SELECT 1 FROM sys.endpoints WHERE name = 'Hadr_endpoint')
  CREATE ENDPOINT [Hadr_endpoint] 
    STATE=STARTED 
    AS TCP (LISTENER_PORT = $(port), LISTENER_IP = ALL)
    FOR DATA_MIRRORING (ROLE = ALL, AUTHENTICATION = WINDOWS NEGOTIATE
  , ENCRYPTION = REQUIRED ALGORITHM AES)

IF EXISTS (select 1 from sys.syslogins where name = 'sa')
  ALTER AUTHORIZATION ON ENDPOINT::Hadr_endpoint TO sa;

--Create a login for service account  
declare @service_account varchar(255)
declare @sSql varchar(1000)
select @service_account = service_account from sys.dm_server_services WHERE [filename] like '%sqlservr.exe%'

IF    @service_account LIKE '%\%' 
  AND @service_account NOT LIKE 'NT AUTHORITY\%'
BEGIN
  IF NOT EXISTS (SELECT name FROM sys.syslogins WHERE name = @service_account)
  BEGIN
    set @sSql = 'CREATE LOGIN ['  + @service_account + '] FROM WINDOWS WITH DEFAULT_DATABASE=[master]'
    EXEC (@sSql)
  END

   --Grant connect permissions to the service account
  set @sSql = 'GRANT CONNECT ON ENDPOINT::Hadr_endpoint TO [' + @service_account + ']' 
  EXEC (@sSql)
END
