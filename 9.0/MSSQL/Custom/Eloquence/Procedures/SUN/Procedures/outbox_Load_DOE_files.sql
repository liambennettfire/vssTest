if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[outbox_Load_DOE_files]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[outbox_Load_DOE_files]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE PROCEDURE [dbo].[outbox_Load_DOE_files] (@v_filetype varchar(3))
AS

Declare 
  @v_filename varchar(80),
  @v_src_dir varchar(80),
  @command VARCHAR(2000),
  @quote CHAR(1),
  @c_dbname varchar(25)

  SET @quote=CHAR(39)
  SElect @c_dbname= db_name()

-- * need to change directoy to generic 

  set @v_src_dir='\\maccoy\ftpsites\eloquenceweb\upload\DOE\000040\'

  set @command='dir /b ' + @v_src_dir + '*.' + @v_filetype + '>' + @v_src_dir+'process.list'

  EXEC MASTER..xp_cmdshell @command

  select @command='
    BULK INSERT ' + @C_dbname + '.dbo.outbox_DOE_files
      FROM '+@quote+@v_src_dir+'process.list'+@quote+'
      WITH
        (
          DATAFILETYPE = ''char'',
          FIELDTERMINATOR = ''\t'',
          ROWTERMINATOR = ''\n''
        )'

  TRUNCATE TABLE outbox_DOE_files
  exec (@command)
  declare c_files cursor for
    SELECT file_name
      FROM outbox_DOE_files
  open c_files 
  fetch next from c_files into @v_filename
  while @@FETCH_STATUS<>-1
    begin
	  print @v_filename
      exec outbox_DOE_loader @v_filename
      fetch next from c_files into @v_filename
    end
  close c_files 
  deallocate c_files






