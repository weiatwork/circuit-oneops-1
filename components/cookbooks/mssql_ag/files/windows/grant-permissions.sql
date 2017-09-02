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
