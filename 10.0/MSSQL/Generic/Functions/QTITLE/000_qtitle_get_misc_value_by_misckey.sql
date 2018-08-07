if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_misc_value_by_misckey') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qtitle_get_misc_value_by_misckey
GO

CREATE FUNCTION dbo.qtitle_get_misc_value_by_misckey
(
  @i_bookkey as integer,
  @i_misckey as integer
) 
RETURNS VARCHAR(255)

/******************************************************************************
**  Name: qtitle_get_misc_value_by_misckey
**  Desc: This function returns the miscellaneous item value based on
**        Misc Item Admin Setup
**
**  Auth: Dustin Miller
**  Date: January 20 2017
*******************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_datacode INT,
    @v_error  INT,
    @v_fieldformat  VARCHAR(40),
    @v_floatvalue FLOAT,
    @v_formatted_value  VARCHAR(255),
    @v_longvalue  INT,
    @v_misctype INT,
    @v_misc_name  VARCHAR(40),
    @v_misc_value VARCHAR(255),
    @v_rowcount INT,
    @v_textvalue  VARCHAR(255)
    
  /* First check if this misc results column is actually configured - i.e. mapped to a misc item */
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE misckey = @i_misckey
  
  IF @v_count = 0
    RETURN NULL   /* this column is not configured - return NULL */
  
  /* Get the Misckey, Name, Type, Field Format, and Gentable datacode value */
  /* associated with this misc results column */
  SELECT @v_misc_name = miscname, @v_misctype = misctype, 
    @v_fieldformat = fieldformat, @v_datacode = datacode
  FROM bookmiscitems 
  WHERE misckey = @i_misckey
  
  /* Get misc values for this misc item and title */
  SELECT @v_longvalue = longvalue, @v_floatvalue = floatvalue, @v_textvalue = textvalue
  FROM bookmisc
  WHERE bookkey = @i_bookkey AND misckey = @i_misckey
  
  /* Format value based on its type */
  IF @v_misctype = 1  --Numeric
    SET @v_formatted_value = dbo.qutl_format_string(@v_longvalue, @v_fieldformat)
  ELSE IF @v_misctype = 2 OR @v_misctype = 6	--Float or Calculated
    SET @v_formatted_value = dbo.qutl_format_string(@v_floatvalue, @v_fieldformat)
  ELSE IF @v_misctype = 3 --Text
    SET @v_formatted_value = @v_textvalue  
  ELSE IF @v_misctype = 4 --Checkbox
    IF @v_longvalue = 1
      SET @v_formatted_value = 'Yes'
    ELSE
      SET @v_formatted_value = 'No'      
  ELSE IF @v_misctype = 5 --Gentable
    SELECT @v_formatted_value = datadesc
    FROM subgentables
    WHERE tableid = 525 AND
          datacode = @v_datacode AND
          datasubcode = @v_longvalue

  RETURN @v_formatted_value
  
END
GO

GRANT EXEC ON dbo.qtitle_get_misc_value_by_misckey TO public
GO
