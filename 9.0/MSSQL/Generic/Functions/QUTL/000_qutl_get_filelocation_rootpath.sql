if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_filelocation_rootpath') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qutl_get_filelocation_rootpath
GO

CREATE FUNCTION dbo.qutl_get_filelocation_rootpath
(
  @i_filelocationkey as integer,
  @i_pathtypedesc as varchar(25)
) 
RETURNS VARCHAR(255)

/*******************************************************************************************************
**  Name: qutl_get_filelocation_rootpath
**  Desc: This function returns the logical or physical root path for a file location.
**
**  Auth: Alan Katzen
**  Date: June 12 2008
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count	INT,
    @v_desc   VARCHAR(255)
    
  IF @i_filelocationkey is null OR @i_filelocationkey <= 0 BEGIN
    RETURN ''
  END
   
  IF lower(@i_pathtypedesc) = 'physical' BEGIN
    SELECT @v_desc = physicaldesc
      FROM filelocationtable flt
     WHERE flt.filelocationkey = @i_filelocationkey
  END
  ELSE BEGIN
    SELECT @v_desc = logicaldesc
      FROM filelocationtable flt
     WHERE flt.filelocationkey = @i_filelocationkey
  END
    
  RETURN @v_desc
END
GO

GRANT EXEC ON dbo.qutl_get_filelocation_rootpath TO public
GO
