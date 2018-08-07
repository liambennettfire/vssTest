if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_miscname') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qutl_get_miscname
GO

CREATE FUNCTION dbo.qutl_get_miscname
(
  @i_misckey as integer
) 
RETURNS VARCHAR(50)

/*******************************************************************************************************
**  Name: qutl_get_miscname
**  Desc: This function returns the miscellaneous itemtype value for specific misckey.
**
**  Auth: Uday A. Khisty
**  Date: April 10 2015
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_miscname VARCHAR(50)
    
  SET @v_miscname = NULL  
  -- First check if this misckey is valid
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE misckey = @i_misckey and activeind = 1
  
  IF @v_count = 0
    RETURN @v_miscname   --this misckey doesn't exist - return NULL
  
  -- Get the Type, Field Format, and Gentable datacode value associated with this misckey
  SELECT @v_miscname = miscname
  FROM bookmiscitems 
  WHERE misckey = @i_misckey and activeind = 1
	 
  RETURN @v_miscname
  
END
GO

GRANT EXEC ON dbo.qutl_get_miscname TO public
GO
