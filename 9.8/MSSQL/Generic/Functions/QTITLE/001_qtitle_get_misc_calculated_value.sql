if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_misc_calculated_value') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qtitle_get_misc_calculated_value
GO

CREATE FUNCTION dbo.qtitle_get_misc_calculated_value
(
  @i_bookkey as integer,
  @i_misckey as integer
) 
RETURNS INT

/*******************************************************************************************************
**  Name: qtitle_get_misc_calculated_value
**  Desc: This function returns the miscellaneous calculated value for specific Title as a varchar.
**
**  Auth: Uday A. Khisty
**  Date: April 10 2015
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_datacode INT,
    @v_error  INT,
    @v_fieldformat  VARCHAR(40),
    @v_floatvalue FLOAT,
    @v_formatted_value  VARCHAR(255),
    @v_longvalue  INT,
    @v_misckey  INT,
    @v_misctype INT,
    @v_misc_name  VARCHAR(40),
    @v_misc_value VARCHAR(255),
    @v_rowcount INT,
    @v_textvalue  VARCHAR(255)
    
  SET @v_formatted_value = NULL  
  /* First check if this misc results column is actually configured - i.e. mapped to a misc item */
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE misckey = @i_misckey and activeind = 1
  
  IF @v_count = 0
    RETURN NULL   /* this column is not configured - return NULL */
  
  /* Get the Misckey, Name, Type, Field Format, and Gentable datacode value */
  /* associated with this misc results column */
  SELECT @v_misckey = misckey, @v_misc_name = miscname, @v_misctype = misctype, 
    @v_fieldformat = fieldformat, @v_datacode = datacode
  FROM bookmiscitems 
  WHERE misckey = @i_misckey and activeind = 1
  
  /* Get misc values for this misc item and title */
  IF EXISTS (SELECT * FROM bookmisc WHERE bookkey = @i_bookkey AND misckey = @i_misckey) BEGIN    
	  SELECT @v_longvalue = longvalue, @v_floatvalue = floatvalue, @v_textvalue = textvalue
	  FROM bookmisc
	  WHERE bookkey = @i_bookkey AND misckey = @v_misckey
	  
	  /* Format value based on its type */
	  IF @v_misctype = 8  --Calculated - Integer
		SET @v_formatted_value = dbo.qutl_format_string(@v_longvalue, @v_fieldformat)
	  ELSE IF @v_misctype = 6	--Calculated - Decimal
		SET @v_formatted_value = dbo.qutl_format_string(@v_floatvalue, @v_fieldformat)
	  ELSE IF @v_misctype = 9 --Text
		SET @v_formatted_value = @v_textvalue  
  END  
  ELSE BEGIN
	 IF EXISTS (SELECT * FROM bookmiscdefaults WHERE misckey = @i_misckey AND orgentrykey IN (SELECT orgentrykey FROM bookorgentry WHERE bookkey = @i_bookkey)) BEGIN
		  SELECT TOP(1) @v_longvalue = longvalue, @v_floatvalue = floatvalue, @v_textvalue = textvalue
		  FROM bookmiscdefaults d JOIN taqprojectorgentry t ON d.orgentrykey = t.orgentrykey AND d.misckey = @i_misckey 
		  WHERE d.orgentrykey IN (SELECT orgentrykey FROM bookorgentry WHERE bookkey = @i_bookkey)
		  ORDER BY d.orglevel DESC
		  
		  /* Format value based on its type */
		  IF @v_misctype = 8  --Calculated - Integer
			SET @v_formatted_value = dbo.qutl_format_string(@v_longvalue, @v_fieldformat)
		  ELSE IF @v_misctype = 6	--Calculated - Decimal
			SET @v_formatted_value = dbo.qutl_format_string(@v_floatvalue, @v_fieldformat)
		  ELSE IF @v_misctype = 9 --Text
			SET @v_formatted_value = @v_textvalue  
	 END		  
  END  

  RETURN @v_formatted_value
  
END
GO

GRANT EXEC ON dbo.qtitle_get_misc_calculated_value TO public
GO
