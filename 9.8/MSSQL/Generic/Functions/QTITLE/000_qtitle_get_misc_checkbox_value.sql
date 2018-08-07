if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_misc_checkbox_value') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qtitle_get_misc_checkbox_value
GO

CREATE FUNCTION dbo.qtitle_get_misc_checkbox_value
(
  @i_bookkey as integer,
  @i_misckey as integer
) 
RETURNS INT

/*******************************************************************************************************
**  Name: qtitle_get_misc_checkbox_value
**  Desc: This function returns the miscellaneous checkbox value for specific title as an integer.
**
**  Auth: Uday A. Khisty
**  Date: April 10 2015
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_misctype INT,
    @v_longvalue  INT,    
    @v_checkbox_value INT
    
  SET @v_checkbox_value = 0  
  -- First check if this misckey is valid
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE misckey = @i_misckey and activeind = 1
  
  IF @v_count = 0
    RETURN 0   --this misckey doesn't exist - return NULL
  
  -- Get the Type, associated with this misckey
  SELECT @v_misctype = misctype
  FROM bookmiscitems 
  WHERE misckey = @i_misckey and activeind = 1
  
  /* Get misc values for this misc item and project */
  IF EXISTS (SELECT * FROM bookmisc WHERE bookkey = @i_bookkey AND misckey = @i_misckey) BEGIN    
	  SELECT @v_longvalue = COALESCE(longvalue, 0)
		 FROM bookmisc
		 WHERE bookkey = @i_bookkey AND misckey = @i_misckey	
	  
		 
	  IF @v_misctype = 4 BEGIN--Checkbox
		IF @v_longvalue = 1
		  SET @v_checkbox_value = 1
		ELSE
		  SET @v_checkbox_value = 0
	  END 
  END 
  ELSE BEGIN
	 IF EXISTS (SELECT * FROM bookmiscdefaults WHERE misckey = @i_misckey AND orgentrykey IN (SELECT orgentrykey FROM bookorgentry WHERE bookkey = @i_bookkey)) BEGIN
		  SELECT TOP(1) @v_longvalue = COALESCE(longvalue, 0)
		  FROM bookmiscdefaults d JOIN taqprojectorgentry t ON d.orgentrykey = t.orgentrykey AND d.misckey = @i_misckey 
		  WHERE d.orgentrykey IN (SELECT orgentrykey FROM bookorgentry WHERE bookkey = @i_bookkey)
		  ORDER BY d.orglevel DESC
		  
		  IF @v_misctype = 4 BEGIN--Checkbox
			IF @v_longvalue = 1
			  SET @v_checkbox_value = 1
			ELSE
			  SET @v_checkbox_value = 0
		  END 
	 END		  
  END    
	 
  RETURN @v_checkbox_value
  
END
GO

GRANT EXEC ON dbo.qtitle_get_misc_checkbox_value TO public
GO
