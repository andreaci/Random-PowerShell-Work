

sp_configure 'show advanced options', '1'
RECONFIGURE
GO
sp_configure 'xp_cmdshell', '1' 
RECONFIGURE
GO

CREATE PROCEDURE usp_backup  
	@path VARCHAR(400), @retentionperiod TINYINT 
AS 
SET NOCOUNT ON 
DECLARE @date VARCHAR(100)  
DECLARE @dbname VARCHAR(50)  
DECLARE @bkup VARCHAR(500)  
DECLARE @retention VARCHAR(500)  

--Adding backslash  
IF SUBSTRING(REVERSE(@path),1,1) <> '\'  
	SET @path=@path + '\'  

--Retention  
SET @date= CONVERT(VARCHAR(10),GETDATE()-@retentionperiod,112)  
SET @retention='EXEC master.dbo.xp_cmdshell ''dir /b "' +@path+'*'+@date+'*.bak"''' 
EXEC (@retention)  

SET @retention='EXEC master.dbo.xp_cmdshell ''del /Q "' +@path+'*'+@date+'*.bak"'''  
EXEC (@retention)  

--Backup Script  
SET @date= CONVERT(VARCHAR(10),GETDATE(),112)  

DECLARE bkup_cursor CURSOR FOR 
	SELECT NAME FROM master.dbo.sysdatabases WHERE dbid <> 2 and DATABASEPROPERTYEX(name,'status') = 'ONLINE'  
	and name NOT IN ('master','model','msdb','tempdb','ReportServer','ReportServerTempDB')

OPEN bkup_cursor  
FETCH NEXT FROM bkup_cursor INTO @dbname  
	
	IF @@FETCH_STATUS <> 0  
		PRINT 'No database to backup...!!'  
		
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		SET @bkup='BACKUP DATABASE ['+@dbname+'] TO DISK = '''+@path+@dbname+'_'+@date+'.bak'' WITH INIT'  
		PRINT 'Processing '+@dbname+' Backup... **'  
		EXEC (@bkup)  
		PRINT 'Backed up to ' + @path+@dbname+'_'+@date+'.bak'  
		PRINT ''  
	
		FETCH NEXT FROM bkup_cursor INTO @dbname  
	END  

CLOSE bkup_cursor  
DEALLOCATE bkup_cursor  
