if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_autogenerate_productid') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_autogenerate_productid
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_autogenerate_productid
  (@i_projectkey    integer,
  @i_userid         varchar(30),
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qproject_autogenerate_productid
**  Desc: This stored procedure auto-generates andy Product ID that is set for Auto-generation
**
**  Auth: Uday A. Khisty
**  Date: June 4 2015
***********************************************************************************************/

DECLARE
  @v_error    INT,
  @v_rowcount INT,
  @v_count  INT,
  @v_itemtype INT,
  @v_usageclass INT,
  @v_errorcode	INT,
  @v_errordesc	VARCHAR(2000),
  @v_sortorder_temp INT,
  @v_alternatedesc2 VARCHAR(255),
  @v_gen1ind TINYINT,
  @v_gen2ind TINYINT,
  @v_datacode INT,
  @v_sortorder INT,
  @v_subgen_count INT,
  @v_sqlstring VARCHAR(4000)

BEGIN

	SET @o_error_code = 0
	SET @o_error_desc = ''
	SET @v_sortorder = 0
	
	IF @i_projectkey IS NULL OR @i_projectkey <= 0 BEGIN
		SET @o_error_desc = 'Invalid projectkey.'
		GOTO RETURN_ERROR  
	END
	
	SELECT @v_itemtype = searchitemcode, @v_usageclass = usageclasscode 
	FROM coreprojectinfo  
	WHERE projectkey = @i_projectkey	
	
	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
	 SET @o_error_desc = 'Could not access coreprojectinfo to get itemtype and usageclass.'
	 GOTO RETURN_ERROR
	END  	
		
	SELECT @v_sortorder_temp = COALESCE(MAX(sortorder), 0) + 1 FROM taqproductnumbers WHERE taqprojectkey = @i_projectkey

    DECLARE productnumbers_cur CURSOR FOR 
      SELECT g.alternatedesc2, g.gen1ind, g.gen2ind, p.sortorder, g.datacode,
        (SELECT COUNT(*) FROM subgentables WHERE tableid = 594 AND datacode = g.datacode) subgen_count 
     FROM gentablesitemtype gi, gentables g
          LEFT OUTER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode
          LEFT OUTER JOIN taqproductnumbers p ON  p.productidcode = g.datacode AND p.taqprojectkey = @i_projectkey AND p.elementkey IS NULL       
     WHERE gi.tableid = g.tableid AND
          gi.datacode = g.datacode AND
          g.deletestatus = 'N' AND
          gi.tableid = 594 AND
          gi.itemtypecode = @v_itemtype AND
         (gi.itemtypesubcode = @v_usageclass OR gi.itemtypesubcode = 0) AND
          g.gen2ind = 1 AND
          g.alternatedesc2 IS NOT NULL AND
          p.productnumber IS NULL

      OPEN productnumbers_cur 
    FETCH productnumbers_cur INTO @v_alternatedesc2, @v_gen1ind, @v_gen2ind, @v_sortorder, @v_datacode, @v_subgen_count

    WHILE @@fetch_status = 0 BEGIN 			   
	   IF @v_subgen_count > 0 BEGIN
		 FETCH productnumbers_cur INTO @v_alternatedesc2, @v_gen1ind, @v_gen2ind, @v_sortorder, @v_datacode, @v_subgen_count
		 CONTINUE 
	   END
	   
	   IF @v_sortorder IS NULL BEGIN
		  SET @v_sortorder = @v_sortorder_temp
		  SET @v_sortorder_temp = @v_sortorder_temp + 1
	   END 
	   
	  EXEC qproject_generate_productid @i_projectkey, 0, 0, @v_datacode,
			0, @v_sortorder, @v_alternatedesc2, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT	   
	   
	  IF @o_error_code <> 0 BEGIN
	 	 GOTO RETURN_ERROR
	  END 
	  
	  IF @v_gen1ind = 1 BEGIN
		SET @v_sqlstring = 'EXEC after_' + @v_alternatedesc2 + '@errorcode OUTPUT, @errordesc OUTPUT'
		EXEC qutl_execute_sql @v_SQLString, @o_error_code OUTPUT, @o_error_desc OUTPUT
		
		IF @o_error_code <> 0 BEGIN
	 	  GOTO RETURN_ERROR
		END 		
		
	  END
			   
     FETCH productnumbers_cur INTO @v_alternatedesc2, @v_gen1ind, @v_gen2ind, @v_sortorder, @v_datacode, @v_subgen_count

    END
    
    CLOSE productnumbers_cur 
    DEALLOCATE productnumbers_cur 	
	
RETURN

RETURN_ERROR:  
  SET @o_error_code = -1
  RETURN
        
END  
GO

GRANT EXEC ON qproject_autogenerate_productid TO PUBLIC
GO
