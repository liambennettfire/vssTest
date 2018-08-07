if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_misc_value_text') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qproject_get_misc_value_text
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_misc_value') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qproject_get_misc_value
GO

CREATE FUNCTION dbo.qproject_get_misc_value
(
  @i_projectkey as integer,
  @i_misckey as integer
) 
RETURNS VARCHAR(255)

/*******************************************************************************************************
**  Name: qproject_get_misc_value
**  Desc: This function returns the miscellaneous item value for specific Project as a formatted string.
**
**  Auth: Kate Wiewiora
**  Date: April 1 2008
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:   Description:
**  --------  -------   -------------------------------------------
**  11/14/17  Colman    Performance
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_datacode INT,
    @v_fieldformat  VARCHAR(40),
    @v_floatvalue FLOAT,
    @v_formatted_value  VARCHAR(255),
    @v_longvalue  INT,
    @v_misctype INT,
    @v_textvalue  VARCHAR(255)
    
  -- First check if this misckey is valid
  -- SELECT @v_count = COUNT(*)
  -- FROM bookmiscitems
  -- WHERE misckey = @i_misckey
  
  -- IF @v_count = 0
    -- RETURN NULL   --this misckey doesn't exist - return NULL
  
  -- Get the Type, Field Format, and Gentable datacode value associated with this misckey
  SELECT @v_misctype = misctype, @v_fieldformat = fieldformat, @v_datacode = datacode
  FROM bookmiscitems 
  WHERE misckey = @i_misckey
  
  IF @@ROWCOUNT = 0
    RETURN NULL
    
  -- Get misc values for this misc item and title
  SELECT @v_longvalue = longvalue, @v_floatvalue = floatvalue, @v_textvalue = textvalue
  FROM taqprojectmisc
  WHERE taqprojectkey = @i_projectkey AND misckey = @i_misckey
  
  -- Format value based on its type
  IF @v_misctype = 1  --Numeric
    SET @v_formatted_value = dbo.qutl_format_string(@v_longvalue, @v_fieldformat)
  ELSE IF @v_misctype = 2 --Decimal
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

GRANT EXEC ON dbo.qproject_get_misc_value TO public
GO
