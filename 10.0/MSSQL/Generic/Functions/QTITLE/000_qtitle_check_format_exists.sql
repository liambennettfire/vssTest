if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_check_format_exists') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qtitle_check_format_exists
GO

CREATE FUNCTION dbo.qtitle_check_format_exists
(
  @i_workkey as integer,
  @i_mediatypecode as integer,
  @i_mediatypesubcode as integer
) 
RETURNS FLOAT

/*******************************************************************************************************
**  Name: qtitle_check_format_exists
**  Desc: This function returns 1 if a format exists for a work, 0 if it doesn't.
**
**  Auth: Alan Katzen
**  Date: August 2, 2010
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT
    
  SELECT @v_count = COUNT(*)
    FROM coretitleinfo
   WHERE workkey = @i_workkey 
     AND mediatypecode = @i_mediatypecode 
     AND mediatypesubcode = @i_mediatypesubcode
  
  IF @v_count > 0 BEGIN
    RETURN 1   
  END
      
  RETURN 0
END
GO

GRANT EXEC ON dbo.qtitle_check_format_exists TO public
GO
