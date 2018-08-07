if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_columnlabel_sortorder') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qscale_get_columnlabel_sortorder
GO

CREATE FUNCTION qscale_get_columnlabel_sortorder
    ( @i_parametervaluecode as integer,
      @i_fieldtype as integer,
      @i_itemcategorycode as integer,
      @i_itemcode as integer,
      @i_columnvalue1 as integer,
      @i_columnvalue2 as integer) 

RETURNS int

/******************************************************************************
**  File: qscale_get_columnlabel_sortorder
**  Name: qscale_get_columnlabel_sortorder
**  Desc: This returns the sortorder for the columnlabel for scale grid row. 
**
**
**    Auth: Alan Katzen
**    Date: 22 October 2012
*******************************************************************************/

BEGIN 
  DECLARE @v_count INT,
    @v_tableid     INT,
    @error_var     INT,
    @rowcount_var  INT,
    @v_sortorder   INT
     
  IF @i_fieldtype = 5 BEGIN
    -- fieldtype is 5 (gentable) if there is a value in numericdesc1 on subgentables
    SELECT @v_count = count(*)
      FROM subgentables
     WHERE tableid = 616
       AND datacode = @i_itemcategorycode
       AND datasubcode = @i_itemcode
       AND COALESCE(numericdesc1,0) > 0

    IF @v_count > 0 BEGIN
      SELECT @v_tableid = numericdesc1
        FROM subgentables
       WHERE tableid = 616
         AND datacode = @i_itemcategorycode
         AND datasubcode = @i_itemcode
         AND COALESCE(numericdesc1,0) > 0
         
      -- use sortorder for columnvalue1
      SELECT @v_sortorder = COALESCE(sortorder,999999) 
        FROM gentables
       WHERE tableid = @v_tableid
         AND datacode = @i_columnvalue1
               
      return @v_sortorder
    END

    -- fieldtype 5 is gentable - see if rows exist on sub2gentables
    SELECT @v_count = count(*)
      FROM sub2gentables
     WHERE tableid = 616
       AND datacode = @i_itemcategorycode
       AND datasubcode = @i_itemcode
    
    IF @v_count > 0 BEGIN
      SELECT @v_sortorder = COALESCE(sortorder,999999)  
        FROM sub2gentables 
       WHERE tableid = 616 
         AND datacode = @i_itemcategorycode 
         AND datasubcode = @i_itemcode 
         AND datasub2code = @i_columnvalue1
              
      return @v_sortorder
    END
  END
  ELSE IF @i_fieldtype = 1 BEGIN 
    -- numeric  
    return @i_columnvalue1    
  END

  return 999999
END
GO

GRANT EXEC ON dbo.qscale_get_columnlabel_sortorder TO public
GO
