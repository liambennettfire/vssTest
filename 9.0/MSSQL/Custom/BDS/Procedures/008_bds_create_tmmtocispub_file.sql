set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'create_tmmtocispub_file')
BEGIN
  DROP  Procedure  dbo.create_tmmtocispub_file
END
GO

CREATE 
PROCEDURE create_tmmtocispub_file (@databasename	VARCHAR(100),
				@tablename	VARCHAR(100),
				@filename	VARCHAR(100),
				@path		VARCHAR(250),
				@servername	VARCHAR(100),
				@userid		VARCHAR(100),
				@pwd		VARCHAR(100))
AS
BEGIN
	DECLARE @datestamp	VARCHAR(20)
	DECLARE @cmd		VARCHAR(200)
	DECLARE @string		VARCHAR(200)

	SELECT @datestamp = REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(20),GETDATE(),20),'-',''),' ',''),':','')

	SET @string = @databasename+'..'+@tablename+' OUT '+@path+@filename+'_'+@datestamp+'.txt -S'+@servername+' -U'+@userid+' -P'+@pwd+' -c -t"^|" -r"||\n"' 
	SET @cmd = 'bcp '+@string
print '@cmd'
print @cmd
	EXECUTE master..xp_cmdshell @cmd
END
go
