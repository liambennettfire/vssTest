if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qelement_get_filepath_by_filetype') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qelement_get_filepath_by_filetype
GO

CREATE FUNCTION dbo.qelement_get_filepath_by_filetype
(
  @i_elementkey as integer,
  @i_filetypecode as integer
) 
RETURNS VARCHAR(4000)

/*******************************************************************************************************
**  Name: qelement_get_filepath_by_filetype
**  Desc: This function returns the first file path for a specific filetype for an element.
**
**  Auth: Alan Katzen
**  Date: March 23 2009
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count	INT,
    @v_fullpathname  VARCHAR(4000)
    
  IF @i_filetypecode is null OR @i_filetypecode <= 0 BEGIN
    RETURN ''
  END
       
  SELECT TOP 1 @v_fullpathname = CASE WHEN fl.filelocationkey > 0 THEN
      '~\' + dbo.qutl_get_filelocation_rootpath(fl.filelocationkey,'logical') + '\' + pathname
      ELSE pathname
      END 
   FROM filelocation fl
  WHERE taqelementkey = @i_elementkey
    AND filetypecode = @i_filetypecode
ORDER BY fl.sortorder
    
  RETURN @v_fullpathname
END
GO

GRANT EXEC ON dbo.qelement_get_filepath_by_filetype TO public
GO
