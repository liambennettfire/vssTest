if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_item_desc_by_adminspeckey') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qscale_get_item_desc_by_adminspeckey
GO

CREATE FUNCTION qscale_get_item_desc_by_adminspeckey
    (@i_scaleadminspeckey as integer) 

RETURNS varchar(100)

/******************************************************************************
**  File: qscale_get_item_desc_by_adminspeckey
**  Name: qscale_get_item_desc_by_adminspeckey
**  Desc: This returns the desc for an itemcategorycode/itemcode
**        for a scaleadminspeckey. 
**
**    Auth: Alan Katzen
**    Date: 24 February 2012
*******************************************************************************/

BEGIN 
  DECLARE 
    @v_count            INT,
    @error_var          INT,
    @rowcount_var       INT,
    @v_desc             VARCHAR(50)
   
  IF COALESCE(@i_scaleadminspeckey,0) <= 0 BEGIN
    RETURN ''
  END
  
  SELECT @v_count = count(*) 
    FROM taqscaleadminspecitem
   WHERE scaleadminspeckey = @i_scaleadminspeckey
     AND itemcategorycode > 0
     AND itemcode > 0
     
  IF @v_count > 0 BEGIN
    SELECT @v_desc = dbo.get_subgentables_desc(616,itemcategorycode,itemcode,'long')
      FROM taqscaleadminspecitem
     WHERE scaleadminspeckey = @i_scaleadminspeckey
  
    return @v_desc
  END
      
  return ''

END
GO

GRANT EXEC ON dbo.qscale_get_item_desc_by_adminspeckey TO public
GO
