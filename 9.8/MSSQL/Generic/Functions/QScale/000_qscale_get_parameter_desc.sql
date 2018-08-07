if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_parameter_desc') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qscale_get_parameter_desc
GO

CREATE FUNCTION qscale_get_parameter_desc
    ( @i_projectkey as integer,
      @i_itemcategorycode as integer,
      @i_itemcode as integer) 

RETURNS varchar(max)

/******************************************************************************
**  File: qscale_get_parameter_desc
**  Name: qscale_get_parameter_desc
**  Desc: This returns a string which gives a summary of the scale 
**        multiples allowed parameters - this will only return a summary
**        when more than one has been selected. 
**
**
**    Auth: Alan Katzen
**    Date: 20 February 2012
*******************************************************************************/

BEGIN 
  DECLARE @v_count INT,
    @error_var    INT,
    @rowcount_var INT,
    @v_projecttype INT,
    @summaryDesc  varchar(max),
    @currentDesc  varchar(200),
    @v_param_tableid INT,
    @v_parametervaluecode INT
   
  SET @summaryDesc = ''

  IF COALESCE(@i_projectkey,0) <= 0 BEGIN
    RETURN ''
  END
  
  SELECT @v_projecttype = COALESCE(taqprojecttype,0) 
    FROM taqproject 
   WHERE taqprojectkey= @i_projectkey
  
  IF @v_projecttype <= 0 BEGIN
    RETURN ''
  END
  
  SELECT @v_parametervaluecode = parametervaluecode
    FROM taqscaleadminspecitem
   WHERE parametertypecode = 1 --scale parameter
     AND scaletypecode = @v_projecttype
     AND itemcategorycode = @i_itemcategorycode
     AND itemcode = @i_itemcode
     
  IF @v_parametervaluecode = 3 BEGIN
    -- multiples allowed - see if more that 1 value has been selected
    SELECT @v_count = count(*)
      FROM taqprojectscaleparameters 
     WHERE taqprojectkey = @i_projectkey 
       AND itemcategorycode = @i_itemcategorycode 
       AND itemcode = @i_itemcode
     
    IF @v_count > 1 BEGIN
      -- multiples entered - create summary desc line
      SELECT @v_param_tableid = COALESCE(numericdesc1,0)
        FROM subgentables
       WHERE tableid = 616
         AND datacode = @i_itemcategorycode
         AND datasubcode = @i_itemcode
      
      IF @v_param_tableid > 0 BEGIN
        DECLARE param_cur CURSOR FOR
        SELECT dbo.get_gentables_desc(@v_param_tableid,p.value1,'long') 
          FROM taqprojectscaleparameters p
         WHERE p.taqprojectkey = @i_projectkey
           AND p.itemcategorycode = @i_itemcategorycode 
           AND p.itemcode = @i_itemcode
           AND p.value1 > 0           
      END
      ELSE BEGIN
        DECLARE param_cur CURSOR FOR
        SELECT datadesc 
          FROM sub2gentables g2, taqprojectscaleparameters p
         WHERE p.taqprojectkey = @i_projectkey
           AND p.itemcategorycode = g2.datacode 
           AND p.itemcode = g2.datasubcode
           AND p.value1 = g2.datasub2code 
           AND g2.tableid = 616
           AND g2.datacode = @i_itemcategorycode
           AND g2.datasubcode =  @i_itemcode       
      END
      
      OPEN param_cur

      -- Perform the first fetch.
      FETCH NEXT FROM param_cur INTO @currentDesc
        
      IF @@FETCH_STATUS = 0
      BEGIN
        SET @summaryDesc = @currentDesc
        FETCH NEXT FROM param_cur INTO @currentDesc
      END
        
      -- Check @@FETCH_STATUS to see if there are any more rows to fetch.
      WHILE @@FETCH_STATUS = 0
      BEGIN
        SET @summaryDesc = @summaryDesc + '<br>' + @currentDesc
        -- This is executed as long as the previous fetch succeeds.
        FETCH NEXT FROM param_cur INTO @currentDesc
      END

      CLOSE param_cur
      DEALLOCATE param_cur
    END
  END
  
  return @summaryDesc

END
GO

GRANT EXEC ON dbo.qscale_get_parameter_desc TO public
GO
