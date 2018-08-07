if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_misc_sortvalue') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qproject_get_misc_sortvalue
GO

CREATE FUNCTION dbo.qproject_get_misc_sortvalue
(
  @i_projectkey as integer,
  @i_misckey as integer
) 
RETURNS VARCHAR(255)

/*******************************************************************************************************
**  Name: qproject_get_misc_sortvalue
**  Desc: This function returns the miscellaneous item value for specific Project as an unformatted sortable string.
**
**  Auth: Colman
**  Date: June 6, 2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**	06/07/2016   Colman      38278 - Fix negative number sort order
**  11/14/2017   Colman      Performance
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_datacode INT,
    @v_floatvalue FLOAT,
    @v_sortvalue  VARCHAR(255),
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
  SELECT @v_misctype = misctype, @v_datacode = datacode
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
  BEGIN
    DECLARE @maxint int
    SET @maxint = 2147483647
    IF @v_longvalue < 0 BEGIN
      SET @v_longvalue = @v_longvalue + @maxint
      SET @v_sortvalue = '.' + REPLICATE('0', 9 - LEN(@v_longvalue)) + CAST(@v_longvalue AS varchar)
    END
    ELSE
      SET @v_sortvalue = REPLICATE('0', 10 - LEN(@v_longvalue)) + CAST(@v_longvalue AS varchar)
  END
  ELSE IF @v_misctype = 2 --Decimal
  BEGIN
    DECLARE @maxfloat FLOAT
    SET @maxfloat = 99999999999999
    IF @v_floatvalue < 0 BEGIN
      SET @v_floatvalue = @v_floatvalue + @maxfloat
      SET @v_sortvalue = '.' + REPLICATE('0', 17 - LEN(ltrim(str(@v_floatvalue,17,4)))) + ltrim(str(@v_floatvalue,17,4))
    END
    ELSE
      SET @v_sortvalue = REPLICATE('0', 18 - LEN(ltrim(str(@v_floatvalue,18,4)))) + ltrim(str(@v_floatvalue,18,4))
  END
  ELSE IF @v_misctype = 3 --Text
    SET @v_sortvalue = @v_textvalue  
  ELSE IF @v_misctype = 4 --Checkbox
    IF @v_longvalue = 1
      SET @v_sortvalue = 'Yes'
    ELSE
      SET @v_sortvalue = 'No'      
  ELSE IF @v_misctype = 5 --Gentable
    SELECT @v_sortvalue = datadesc
    FROM subgentables
    WHERE tableid = 525 AND
          datacode = @v_datacode AND
          datasubcode = @v_longvalue

  RETURN @v_sortvalue
  
END
GO

GRANT EXEC ON dbo.qproject_get_misc_sortvalue TO public
GO
