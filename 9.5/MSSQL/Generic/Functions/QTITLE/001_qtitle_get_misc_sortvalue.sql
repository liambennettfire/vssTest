if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_misc_sortvalue') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qtitle_get_misc_sortvalue
GO

CREATE FUNCTION dbo.qtitle_get_misc_sortvalue
(
  @i_bookkey as integer,
  @i_misc_colnum as integer
) 
RETURNS VARCHAR(255)

/******************************************************************************
**  Name: qtitle_get_misc_sortvalue
**  Desc: This function returns the miscellaneous item sortable value based on
**        Misc Item Admin Setup
**
**  Auth: Colman
**  Date: 06/06/2016
*******************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_datacode INT,
    @v_error  INT,
    @v_floatvalue FLOAT,
    @v_longvalue  INT,
    @v_misckey  INT,
    @v_misctype INT,
    @v_misc_name  VARCHAR(40),
    @v_misc_value VARCHAR(255),
    @v_rowcount INT,
    @v_textvalue  VARCHAR(255),
    @v_sortvalue  VARCHAR(255)
    
  /* First check if this misc results column is actually configured - i.e. mapped to a misc item */
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE coretitlemisccolnumber = @i_misc_colnum
  
  IF @v_count = 0
    RETURN NULL   /* this column is not configured - return NULL */
  
  /* Get the Misckey, Name, Type, and Gentable datacode value */
  /* associated with this misc results column */
  SELECT @v_misckey = misckey, @v_misc_name = miscname, @v_misctype = misctype, @v_datacode = datacode
  FROM bookmiscitems 
  WHERE coretitlemisccolnumber = @i_misc_colnum
  
  /* Get misc values for this misc item and title */
  SELECT @v_longvalue = longvalue, @v_floatvalue = floatvalue, @v_textvalue = textvalue
  FROM bookmisc
  WHERE bookkey = @i_bookkey AND misckey = @v_misckey
  
  /* Format value based on its type */
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
  ELSE IF @v_misctype = 2 OR @v_misctype = 6	--Float or Calculated
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

GRANT EXEC ON dbo.qtitle_get_misc_sortvalue TO public
GO
