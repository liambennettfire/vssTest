if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_misc_text_value') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qtitle_get_misc_text_value
GO

CREATE FUNCTION dbo.qtitle_get_misc_text_value
(
  @i_bookkey as integer,
  @i_misckey as integer
) 
RETURNS varchar(max)

/*******************************************************************************************************
**  Name: qtitle_get_misc_text_value
**  Desc: This function returns the miscellaneous text value for specific Title as an varchar.
**
**  Auth: Uday A. Khisty
**  Date: April 10 2015
** Auth: Jason Donovan
** Date September 11 2017
** Issue Fuinction was returning an integer and needs to return VARCHAR
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
  IF EXISTS (SELECT * FROM bookmisc WHERE bookkey = @i_bookkey AND misckey = @i_misckey) BEGIN   
	  SELECT @v_textvalue = textvalue
	  FROM bookmisc
	  WHERE bookkey = @i_bookkey AND misckey = @i_misckey
	  
		 
	  IF @v_misctype = 3 BEGIN--Text
		SET @v_return_textvalue = @v_textvalue 
	  END
  END  
  ELSE BEGIN
	 IF EXISTS (SELECT * FROM bookmiscdefaults WHERE misckey = @i_misckey AND orgentrykey IN (SELECT orgentrykey FROM bookorgentry WHERE bookkey = @i_bookkey)) BEGIN
		  SELECT TOP(1) @v_textvalue = textvalue
		  FROM bookmiscdefaults d JOIN taqprojectorgentry t ON d.orgentrykey = t.orgentrykey AND d.misckey = @i_misckey 
		  WHERE d.orgentrykey IN (SELECT orgentrykey FROM bookorgentry WHERE bookkey = @i_bookkey)
		  ORDER BY d.orglevel DESC
		  
		  IF @v_misctype = 3 BEGIN--Text
			SET @v_return_textvalue = @v_textvalue 
		  END
	 END		  
  END    
	 
  RETURN @v_return_textvalue
  
END
GO

GRANT EXEC ON dbo.qtitle_get_misc_text_value TO public
GO
