if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_misc_text_value') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qproject_get_misc_text_value
GO

CREATE FUNCTION dbo.qproject_get_misc_text_value
(
  @i_projectkey as integer,
  @i_misckey as integer
) 
RETURNS VARCHAR(255)

/*******************************************************************************************************
**  Name: qproject_get_misc_text_value
**  Desc: This function returns the miscellaneous text value for specific Project as an varchar.
**
**  Auth: Uday A. Khisty
**  Date: April 10 2015
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_misctype INT,
    @v_textvalue  VARCHAR(255),
    @v_return_textvalue  VARCHAR(255)             
      
  SET @v_textvalue = NULL
  SET @v_return_textvalue = NULL
  -- First check if this misckey is valid
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE misckey = @i_misckey and activeind = 1
  
  IF @v_count = 0
    RETURN NULL   --this misckey doesn't exist - return NULL
  
  -- Get the Type associated with this misckey
  SELECT @v_misctype = misctype
  FROM bookmiscitems 
  WHERE misckey = @i_misckey and activeind = 1
  
  /* Get misc values for this misc item and project */
  IF EXISTS (SELECT * FROM taqprojectmisc WHERE taqprojectkey = @i_projectkey AND misckey = @i_misckey) BEGIN      
	  SELECT @v_textvalue = textvalue
	  FROM taqprojectmisc
	  WHERE taqprojectkey = @i_projectkey AND misckey = @i_misckey
	  
		 
	  IF @v_misctype = 3 BEGIN--Text
		SET @v_return_textvalue = @v_textvalue 
	  END  
  END
  ELSE BEGIN
	 IF EXISTS (SELECT * FROM bookmiscdefaults WHERE misckey = @i_misckey AND orgentrykey IN (SELECT orgentrykey FROM taqprojectorgentry WHERE taqprojectkey = @i_projectkey)) BEGIN
		  SELECT TOP(1) @v_textvalue = textvalue
		  FROM bookmiscdefaults d JOIN taqprojectorgentry t ON d.orgentrykey = t.orgentrykey AND d.misckey = @i_misckey 
		  WHERE d.orgentrykey IN (SELECT orgentrykey FROM taqprojectorgentry WHERE taqprojectkey = @i_projectkey)
		  ORDER BY d.orglevel DESC
		  
		  /* Format value based on its type */
		  IF @v_misctype = 3 BEGIN--Text
			SET @v_return_textvalue = @v_textvalue 
		  END  
	 END		  
  END  
	 
  RETURN @v_return_textvalue
  
END
GO

GRANT EXEC ON dbo.qproject_get_misc_text_value TO public
GO
