if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_rowlabeldesc') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qscale_get_rowlabeldesc
GO

CREATE FUNCTION qscale_get_rowlabeldesc
    ( @i_parametervaluecode as integer,
      @i_fieldtype as integer,
      @i_itemcategorycode as integer,
      @i_itemcode as integer,
      @i_rowvalue1 as integer,
      @i_rowvalue2 as integer) 

RETURNS varchar(30)

/******************************************************************************
**  File: qscale_get_rowlabeldesc
**  Name: qscale_get_rowlabeldesc
**  Desc: This returns the rowlabeldesc for scale grid row. 
**
**
**    Auth: Alan Katzen
**    Date: 25 February 2012
*******************************************************************************/

BEGIN 
  DECLARE @v_count INT,
    @v_tableid     INT,
    @error_var     INT,
    @rowcount_var  INT,
    @v_rowvalue1_desc VARCHAR(40),
    @v_rowvalue2_desc VARCHAR(40)
     
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
         
      IF @i_parametervaluecode = 2 BEGIN
        -- range
        return dbo.get_gentables_desc(@v_tableid,@i_rowvalue1,'long') + ' to ' + dbo.get_gentables_desc(@v_tableid,@i_rowvalue2,'long')
      END
      
      return dbo.get_gentables_desc(@v_tableid,@i_rowvalue1,'long')
    END

    -- fieldtype 5 is gentable - see if rows exist on sub2gentables
    SELECT @v_count = count(*)
      FROM sub2gentables
     WHERE tableid = 616
       AND datacode = @i_itemcategorycode
       AND datasubcode = @i_itemcode
    
    IF @v_count > 0 BEGIN
      SELECT @v_rowvalue1_desc = datadesc 
        FROM sub2gentables 
       WHERE tableid = 616 
         AND datacode = @i_itemcategorycode 
         AND datasubcode = @i_itemcode 
         AND datasub2code = @i_rowvalue1
    
      IF @i_parametervaluecode = 2 BEGIN
        -- range
        SELECT @v_rowvalue2_desc = datadesc 
          FROM sub2gentables 
         WHERE tableid = 616 
           AND datacode = @i_itemcategorycode 
           AND datasubcode = @i_itemcode 
           AND datasub2code = @i_rowvalue2
           
        return @v_rowvalue1_desc + ' to ' + @v_rowvalue2_desc
      END
      
      return @v_rowvalue1_desc
    END
  END
  ELSE IF @i_fieldtype = 1 BEGIN 
    -- numeric  
    IF @i_parametervaluecode = 2 BEGIN
      -- range
      return cast(@i_rowvalue1 as varchar) + ' to ' + cast(@i_rowvalue2 as varchar)
    END
    
    return cast(@i_rowvalue1 as varchar)
  END

  return ''
END
GO

GRANT EXEC ON dbo.qscale_get_rowlabeldesc TO public
GO
