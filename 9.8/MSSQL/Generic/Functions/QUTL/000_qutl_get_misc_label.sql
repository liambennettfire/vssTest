if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_misc_label') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qutl_get_misc_label
GO

CREATE FUNCTION dbo.qutl_get_misc_label
(
  @i_misckey as integer
) 
RETURNS VARCHAR(255)

/*******************************************************************************************************
**  Name: qutl_get_misc_label
**  Desc: This function returns the miscellaneous item label for given misc item.
**
**  Auth: Kate Wiewiora
**  Date: April 1 2008
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count	INT,
    @v_misc_name  VARCHAR(40)
    
  SET @v_misc_name = NULL 
  /* First check if this misckey is valid */
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE misckey = @i_misckey and activeind = 1
  
  IF @v_count = 0
    RETURN NULL   /* this misckey doesn't exist - return NULL */
  
  /* Get the Misc Name (label) */
  SELECT @v_misc_name = COALESCE(misclabel, miscname)
  FROM bookmiscitems 
  WHERE misckey = @i_misckey and activeind = 1
  
  RETURN @v_misc_name
  
END
GO

GRANT EXEC ON dbo.qutl_get_misc_label TO public
GO
