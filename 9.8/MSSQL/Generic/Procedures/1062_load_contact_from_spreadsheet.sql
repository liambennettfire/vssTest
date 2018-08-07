SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.load_contact_from_spreadsheet') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.load_contact_from_spreadsheet 
end
go



create PROCEDURE [dbo].[load_contact_from_spreadsheet]
  (@v_filename	VARCHAR(50), @v_src_dir varchar(200), @v_arch_dir varchar(200))
AS

/*  Bulk insert file into Feed in Stagging Table	*/
  DECLARE
    @quote		CHAR(1),
    @command	VARCHAR(2000),
    @rows		INT

  set  @quote=CHAR(39)
  

  select @command='
  BULK INSERT import_request_spreadsheet
    FROM '+@quote+@v_src_dir+@v_filename+@quote+'
    WITH
      (
        DATAFILETYPE = ''char'',
        FIRSTROW = 2,
        FIELDTERMINATOR = ''\t'',
        ROWTERMINATOR = ''
'' )'

  exec (@command)

  set @command='move '+@v_src_dir+@v_filename+' '+@v_arch_dir
  EXEC MASTER..xp_cmdshell @command

go

