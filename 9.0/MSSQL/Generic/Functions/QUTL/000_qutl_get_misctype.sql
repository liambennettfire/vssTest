if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_misctype') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qutl_get_misctype
GO

CREATE FUNCTION dbo.qutl_get_misctype
(
  @i_misckey as integer
) 
RETURNS INT

/*******************************************************************************************************
**  Name: qutl_get_misctype
**  Desc: This function returns the miscellaneous itemtype value for specific misckey.
**
**  Auth: Uday A. Khisty
**  Date: April 10 2015
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_misctype INT
    
  SET @v_misctype = 0  
  -- First check if this misckey is valid
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE misckey = @i_misckey and activeind = 1
  
  IF @v_count = 0
    RETURN 0   --this misckey doesn't exist - return NULL
  
  -- Get the Type, Field Format, and Gentable datacode value associated with this misckey
  SELECT @v_misctype = COALESCE(misctype, 0)
  FROM bookmiscitems 
  WHERE misckey = @i_misckey and activeind = 1
	 
  RETURN @v_misctype
  
END
GO

GRANT EXEC ON dbo.qutl_get_misctype TO public
GO
