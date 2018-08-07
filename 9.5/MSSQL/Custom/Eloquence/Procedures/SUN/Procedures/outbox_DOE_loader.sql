if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[outbox_DOE_loader]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[outbox_DOE_loader]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE [dbo].[outbox_DOE_loader]
  (@i_filename	VARCHAR(50))
AS

/*  GET File From FTP Site		*/
/* ftp now being done from D:\QSolution\feedin\ftpcmdmget.bat */
--EXEC ftp_GetCISPUBFile 	'128.135.234.144','tmmftp','qSieloq1','',@i_filename,'d:\',@i_filename,'d:\qsolution\feedin\temp'
--EXEC ftp_GetCISPUBFile 	'128.135.234.140','ucdcftp','ixm:8529','',@i_filename,'d:\',@i_filename,'d:\qsolution\feedin\temp'


/*  Bulk insert file into Feed in Stagging Table	*/

    DECLARE
    @quote		CHAR(1),
    @v_src_dir varchar(80),
    @v_arch_dir varchar(80),
    @command	VARCHAR(2000),
    @rows		INT,
    @v_elocustomernumber varchar(6),
	@v_dest_table varchar(255),
	@i_customerkey int

/* determine elo customer number */
select @i_customerkey = CONVERT(int, substring(@i_filename,2,6))

  SELECT @quote=CHAR(39)
  SELECT @v_elocustomernumber =  eloqcustomerid from customer where customerkey=@i_customerkey
  set  @v_src_dir = '\\maccoy\ftpsites\eloquenceweb\upload\DOE\' +  @v_elocustomernumber +'\'
  set  @v_arch_dir = '\\montag\eloprod\Imports\'  + @v_elocustomernumber + '\DOE\' 

  If @i_filename like '%.SET'
	begin
	 SET @v_dest_table = 'outbox_set_records'
	end
  Else if @i_filename like '%.CMT'
	begin
	 SET @v_dest_table = 'outbox_CMTISBNS'
	end

  Select @command = 'TRUNCATE TABLE ' + @v_dest_table

  exec (@command)


  select @command='
  BULK INSERT ' + @v_dest_table + '
    FROM '+@quote+@v_src_dir+@i_filename+@quote+'
    WITH
      (
        DATAFILETYPE = ''char'',
        FIRSTROW = 1,
        FIELDTERMINATOR = ''\t'',
        ROWTERMINATOR = ''\n''
       )'
  exec (@command)

  SELECT @rows = @@rowcount

  print @i_filename
  print @rows


/*  Run Update Procedure to Load Data	- pass elocustomer key , taken from file name	*/
 
  exec outbox_DOE_export_sets @i_customerkey

/*  Move File to History			*/
  set @command='move '+@v_src_dir+@i_filename+' '+@v_arch_dir
  EXEC MASTER..xp_cmdshell @command




