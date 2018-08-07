if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_misc_fieldformat') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qutl_get_misc_fieldformat
GO

CREATE FUNCTION dbo.qutl_get_misc_fieldformat
(
  @i_misckey as integer
) 
RETURNS VARCHAR(255)

/*******************************************************************************************************
**  Name: qutl_get_misc_fieldformat
**  Desc: This function returns the miscellaneous item field format value for specific Project.
**
**  Auth: Uday A. Khisty
**  Date: April 1 2008
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_fieldformat  VARCHAR(40)
    
  -- First check if this misckey is valid
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE misckey = @i_misckey
  
  IF @v_count = 0
    RETURN NULL   --this misckey doesn't exist - return NULL
  
  -- Get Field Format associated with this misckey
  SELECT @v_fieldformat = fieldformat
  FROM bookmiscitems 
  WHERE misckey = @i_misckey

  RETURN @v_fieldformat
  
END
GO

GRANT EXEC ON dbo.qutl_get_misc_fieldformat TO public
GO
