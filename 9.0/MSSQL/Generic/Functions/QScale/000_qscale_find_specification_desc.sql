if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_find_specification_desc') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qscale_find_specification_desc
GO

CREATE FUNCTION qscale_find_specification_desc
    ( @i_taqversionformatyearkey as integer,
      @i_itemcategorycode as integer,
      @i_itemcode as integer) 

RETURNS varchar(2000)

/******************************************************************************
**  File: qscale_find_specification_desc
**  Name: qscale_find_specification_desc
**  Desc: This returns the desc of a specification item. 
**
**
**    Auth: Alan Katzen
**    Date: 2 April 2012
*******************************************************************************/

BEGIN 
  DECLARE 
    @v_count          INT,
    @error_var        INT,
    @rowcount_var     INT,
    @v_scalevaluetype INT,
    @v_specdesc       varchar(2000)
   
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
    SELECT @v_specdesc = cast(COALESCE(s.quan,0) as varchar)
      FROM dbo.qproject_get_specitems_by_printingview(@i_taqversionformatyearkey) s
     WHERE s.itemcategorycode = @i_itemcategorycode
       AND s.itemcode = @i_itemcode
       
    RETURN @v_specdesc
  END
  ELSE IF @v_scalevaluetype = 2 BEGIN
    -- decimal
    SELECT @v_specdesc = cast(COALESCE(s.decimal,0) as varchar)
      FROM dbo.qproject_get_specitems_by_printingview(@i_taqversionformatyearkey) s
     WHERE s.itemcategorycode = @i_itemcategorycode
       AND s.itemcode = @i_itemcode
       
    RETURN @v_specdesc
  END
  ELSE IF @v_scalevaluetype = 5 BEGIN
    -- gentable
    SELECT @v_specdesc = CASE WHEN s.itemdetailcode > 0 THEN s.itemdetaildesc 
                         ELSE COALESCE(s.itemdesc,'') END
      FROM dbo.qproject_get_specitems_by_printingview(@i_taqversionformatyearkey) s
     WHERE s.itemcategorycode = @i_itemcategorycode
       AND s.itemcode = @i_itemcode
       
    RETURN @v_specdesc
  END
     
  return ''
END
GO

GRANT EXEC ON dbo.qscale_find_specification_desc TO public
GO
