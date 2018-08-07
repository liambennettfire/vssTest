drop procedure load_file_to_text 
go

create procedure load_file_to_text (@Tblname varchar(50), @Colname varchar(50), @Txtpointer binary(16), @FileName varchar(255)) AS

  declare @objFSys int 
  declare @objFile int 
  declare @blnEndOfFile int
  declare @upd_offset int
  declare @strLine varchar(4000)
  declare @sql_block nvarchar(4000)

  set @upd_offset = 0
--  set @sql_block = 'WRITETEXT '+@Tblname+'.'+@Colname+' @Txtpointer "filler"' 
--  EXEC sp_executesql @sql_block, N'@Txtpointer binary(16)',@Txtpointer 

  exec sp_OACreate 'Scripting.FileSystemObject', @objFSys out 

  exec sp_OAMethod @objFSys, 'OpenTextFile', @objFile out, @FileName  , 1
  exec sp_OAMethod @objFile, 'AtEndOfStream', @blnEndOfFile out
  while @blnEndOfFile=0 begin
    exec sp_OAMethod @objFile, 'ReadLine', @strLine out
    select @strLine=@strLine
--    select @strLine=@strLine+char(13)+char(11)
-- Here you got one line from the file
    select @sql_block = 'UPDATETEXT '+@Tblname+'.'+@Colname+' @Txtpointer '+cast(@upd_offset as nvarchar(15))+' null @strLine'
    EXEC sp_executesql @sql_block,  N'@Txtpointer binary(16),@strLine nvarchar(4000)',@Txtpointer,@strLine
    set @upd_offset=@upd_offset+len(@strLine)
    exec sp_OAMethod @objFile, 'AtEndOfStream', @blnEndOfFile out
  end

  exec sp_OADestroy @objFile
  exec sp_OADestroy @objFSys 

go