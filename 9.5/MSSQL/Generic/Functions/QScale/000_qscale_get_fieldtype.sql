if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_fieldtype') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qscale_get_fieldtype
GO

CREATE FUNCTION qscale_get_fieldtype
    ( @i_tableid as integer,
      @i_itemcategorycode as integer,
      @i_itemcode as integer) 

RETURNS int

/******************************************************************************
**  File: qscale_get_fieldtype
**  Name: qscale_get_fieldtype
**  Desc: This returns the field type for itemcategorycode/itemcode. 
**
**
**    Auth: Alan Katzen
**    Date: 24 February 2012
*******************************************************************************/

BEGIN 
  DECLARE @v_count INT,
    @error_var    INT,
    @rowcount_var INT
   
  IF COALESCE(@i_tableid,0) <= 0 BEGIN
    RETURN -1
  END
  
  -- fieldtype is 5 (gentable) if rows exist on sub2gentables
  SELECT @v_count = count(*)
    FROM sub2gentables
   WHERE tableid = @i_tableid
     AND datacode = @i_itemcategorycode
     AND datasubcode = @i_itemcode
  
  IF @v_count > 0 BEGIN
    return 5
  END
  
  -- fieldtype is 5 (gentable) if there is a value in numericdesc1 on subgentables
  SELECT @v_count = count(*)
    FROM subgentables
   WHERE tableid = @i_tableid
     AND datacode = @i_itemcategorycode
     AND datasubcode = @i_itemcode
     AND COALESCE(numericdesc1,0) > 0

  IF @v_count > 0 BEGIN
    return 5
  END
    
  -- default - return 1 for numeric  
  return 1

END
GO

GRANT EXEC ON dbo.qscale_get_fieldtype TO public
GO
