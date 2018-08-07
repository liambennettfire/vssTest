/****** Object:  UserDefinedFunction [dbo].[rpt_get_project_misc_value]    Script Date: 07/06/2014 16:06:26 ******/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_project_misc_value]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_get_project_misc_value]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[rpt_get_project_misc_value]
(
  @i_projectkey as integer,
  @v_misckey as integer,
  @c_desctype as varchar (10)
) 
RETURNS VARCHAR(255)

/******************************************************************************
**  Name: rpt_get_misc_value
**  Desc: This function returns the miscellaneous item value based on
**        Bookkey and MiscKey passed
**        Field Type is only used for gentables values - which column is desired
**        c_desctype = 'long' or empty --> return datadesc
**        c_desctype = 'short' --> return datadescshort
**        c_desctype = 'altdesc1' --> return alternatedesc1
**        c_desctype = 'altdesc2' --> return alternatedesc2

**
**  Auth: Kate Wiewiora
**  Date: 2 February 2007
*******************************************************************************/

/******************************************************************************
**  Name: rpt_get_misc_value
**  Desc: This function returns the miscellaneous item value based on
**        Bookkey and MiscKey passed
**        Field Type is only used for gentables values - which column is desired
**        c_desctype = 'long' or empty --> return datadesc
**        c_desctype = 'short' --> return datadescshort
**        c_desctype = 'external' --> return externalcode
**        c_desctype = 'altdesc1' --> return alternatedesc1
**        c_desctype = 'altdesc2' --> return alternatedesc2

**
**  Auth: Kate Wiewiora
**  Date: 2 February 2007
**  Modified 7/7/2009 by DSL to include External Code
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
  WHERE misckey = @v_misckey
  
  IF @v_count = 0
    RETURN NULL   /* this column is not configured - return NULL */
  
  /* Get the Misckey, Name, Type, Field Format, and Gentable datacode value */
  /* associated with this misc results column */
  SELECT  @v_misc_name = miscname, @v_misctype = misctype, 
    @v_fieldformat = fieldformat, @v_datacode = datacode
  FROM bookmiscitems 
 WHERE misckey = @v_misckey
  
  /* Get misc values for this misc item and title */
  SELECT @v_longvalue = longvalue, @v_floatvalue = floatvalue, @v_textvalue = textvalue
  FROM taqprojectmisc
  WHERE taqprojectkey = @i_projectkey AND misckey = @v_misckey
  
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
	begin
		if @c_desctype = 'long' or @c_desctype = '' or @c_desctype is null
		begin
			SELECT @v_formatted_value = datadesc
			FROM subgentables
			WHERE tableid = 525 AND
		     datacode = @v_datacode AND
	       datasubcode = @v_longvalue
		end
		if @c_desctype = 'short'
		begin
			SELECT @v_formatted_value = datadescshort
			FROM subgentables
			WHERE tableid = 525 AND
			  datacode = @v_datacode AND
			  datasubcode = @v_longvalue
		end
		if @c_desctype = 'external'
		begin
			SELECT @v_formatted_value = externalcode
			FROM subgentables
			WHERE tableid = 525 AND
			  datacode = @v_datacode AND
			  datasubcode = @v_longvalue
		end
		if @c_desctype = 'altdesc1'
		begin
			SELECT @v_formatted_value = alternatedesc1
			FROM subgentables
			WHERE tableid = 525 AND
			  datacode = @v_datacode AND
			  datasubcode = @v_longvalue
		end          
	    
		if @c_desctype = 'altdesc2'
		begin
			SELECT @v_formatted_value = alternatedesc2
			FROM subgentables
			WHERE tableid = 525 AND
			  datacode = @v_datacode AND
			  datasubcode = @v_longvalue
		end  
          
	end /*end for ELSE IF @v_misctype = 5*/
  RETURN @v_formatted_value
  
END

GO

grant execute on dbo.[rpt_get_project_misc_value] to public
go
