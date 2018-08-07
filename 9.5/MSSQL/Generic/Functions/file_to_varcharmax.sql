if exists (select * from dbo.sysobjects where id = object_id(N'dbo.file_to_varcharmax') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.file_to_varcharmax
GO


create FUNCTION [dbo].[file_to_varcharmax]
 (@i_XMLfile varchar(500))

RETURNS varchar(max)

BEGIN

DECLARE
  @v_XMLload varchar(max),
  @v_XMLdoc xml

  set @v_XMLload=''

  declare @objFSys int 
  declare @objFile int 
  declare @blnEndOfFile int
  declare @upd_offset int
  declare @strLine varchar(4000)
  declare @sql_block nvarchar(4000)

  set @upd_offset = 0

  exec sp_OACreate 'Scripting.FileSystemObject', @objFSys out 

  exec sp_OAMethod @objFSys, 'OpenTextFile', @objFile out, @i_XMLfile  , 1
  exec sp_OAMethod @objFile, 'AtEndOfStream', @blnEndOfFile out
  while @blnEndOfFile=0 begin
    exec sp_OAMethod @objFile, 'Read(4000)', @strLine out
    set @v_XMLload=@v_XMLload+@strLine
    exec sp_OAMethod @objFile, 'AtEndOfStream', @blnEndOfFile out
  end

  exec sp_OADestroy @objFile
  exec sp_OADestroy @objFSys 

  return @v_XMLload

end
