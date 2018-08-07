if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_find_specification_value') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qscale_find_specification_value
GO

CREATE FUNCTION qscale_find_specification_value
    ( @i_taqversionformatyearkey as integer,
      @i_itemcategorycode as integer,
      @i_itemcode as integer) 

RETURNS numeric(15,4)

/******************************************************************************
**  File: qscale_find_specification_value
**  Name: qscale_find_specification_value
**  Desc: This returns the value of a specification item. 
**
**
**    Auth: Alan Katzen
**    Date: 21 March 2012
*******************************************************************************/

BEGIN 
  DECLARE 
    @v_count          INT,
    @error_var        INT,
    @rowcount_var     INT,
    @v_scalevaluetype INT,
    @v_specvalue      numeric(15,4)
   
  IF COALESCE(@i_taqversionformatyearkey,0) <= 0 BEGIN
    RETURN -1
  END

  -- make sure itemcategorycode/itemcode is on taqspecadmin
  SELECT @v_count = count(*)
    FROM taqspecadmin
   WHERE itemcategorycode = @i_itemcategorycode
     AND itemcode = @i_itemcode
  
  IF @v_count <= 0 BEGIN
    return -1
  END
  
  SELECT @v_scalevaluetype = scalevaluetype
    FROM taqspecadmin
   WHERE itemcategorycode = @i_itemcategorycode
     AND itemcode = @i_itemcode
     
  IF @v_scalevaluetype = 1 BEGIN
    -- numeric
    SELECT @v_specvalue = COALESCE(s.quan,0)
      FROM dbo.qproject_get_specitems_by_printingview(@i_taqversionformatyearkey) s
     WHERE s.itemcategorycode = @i_itemcategorycode
       AND s.itemcode = @i_itemcode
       
    RETURN @v_specvalue
  END
  ELSE IF @v_scalevaluetype = 2 BEGIN
    -- decimal
    SELECT @v_specvalue = COALESCE(s.decimal,0)
      FROM dbo.qproject_get_specitems_by_printingview(@i_taqversionformatyearkey) s
     WHERE s.itemcategorycode = @i_itemcategorycode
       AND s.itemcode = @i_itemcode
       
    RETURN @v_specvalue
  END
  ELSE IF @v_scalevaluetype = 5 BEGIN
    -- gentable
    SELECT @v_specvalue = CASE WHEN s.itemdetailcode > 0 THEN s.itemdetailcode 
                          ELSE COALESCE(s.itemcode,0) END
      FROM dbo.qproject_get_specitems_by_printingview(@i_taqversionformatyearkey) s
     WHERE s.itemcategorycode = @i_itemcategorycode
       AND s.itemcode = @i_itemcode
       
    RETURN @v_specvalue
  END
     
  return 0
END
GO

GRANT EXEC ON dbo.qscale_find_specification_value TO public
GO
