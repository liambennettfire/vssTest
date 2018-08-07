if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_update_production_quantities') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_update_production_quantities
GO

CREATE PROCEDURE qpl_update_production_quantities (  
  @i_projectkey   INT,
  @i_plstage      INT,
  @i_plversion    INT,
  @i_userid       VARCHAR(30),
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_update_production_quantities
**  Desc: This stored procedure recalculates detail production units (or percentages)
**        for the given version from Total Required Units and existing percentages.
**
**  Auth: Dustin Miller
**  Date: November 18 2011
*******************************************************************************************/

DECLARE
  @v_current_prtgnum  INT,
  @v_current_quantity INT,
  @v_entrytypecode  INT,
  @v_formatkey  INT,
  @v_formatyearkey  INT,
  @v_generatecostsind INT,
  @v_next_prtgnum INT,
  @v_printingnumber INT,
  @v_quantity INT,
  @v_set_prtgnum  INT,  
  @v_yearcode INT
    
BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT @v_entrytypecode = COALESCE(prodqtyentrytypecode,1)
  FROM taqversion
  WHERE taqprojectkey = @i_projectkey
	  AND plstagecode = @i_plstage 
	  AND taqversionkey = @i_plversion

  IF @v_entrytypecode = 4 --Generate from FG Component Qty - return
    RETURN

  ELSE IF @v_entrytypecode IN (2,3) --Generate from Required Qty By Year or Generate from Total Required Qty
  BEGIN
    EXEC qpl_recalc_prod_qty @i_projectkey, @i_plstage, @i_plversion, @i_userid, 0, @o_error_code OUTPUT, @o_error_desc OUTPUT
    IF @o_error_code <> 0 BEGIN
      SET @o_error_desc = 'Procedure qpl_recalc_prod_qty returned an error: ' + @o_error_desc
      GOTO RETURN_ERROR
    END
		
    /* Don't recalculate percentages - they should stay as they were copied from template
    EXEC qpl_recalc_prod_qty @i_projectkey, @i_plstage, @i_plversion, @i_userid, 1, @o_error_code OUTPUT, @o_error_desc OUTPUT
    IF @o_error_code <> 0 BEGIN
      SET @o_error_code = -1
      RETURN
    END
    */
		
    SELECT @v_generatecostsind = generatecostsautoind
    FROM taqversion
    WHERE taqprojectkey = @i_projectkey
    AND plstagecode = @i_plstage
    AND taqversionkey = @i_plversion
			
    IF @v_generatecostsind = 1
    BEGIN
      EXEC qpl_generate_cost_for_version @i_projectkey, @i_plstage, @i_plversion, 1, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
      IF @o_error_code <> 0 BEGIN
        SET @o_error_desc = 'Procedure qpl_generate_cost_for_version returned an error: ' + @o_error_desc
        GOTO RETURN_ERROR
      END
    END

  END
  ELSE  --Production Quantity Entry Type is "Enter Qty By Year"
  BEGIN

    -- Reset percentages
    UPDATE taqversionformatyear 
    SET percentage = NULL, lastuserid = @i_userid, lastmaintdate = getdate()
    WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion
		
    -- Loop through all formats, all years to recalculate printing numbers
    DECLARE formats_cur CURSOR FOR 
      SELECT taqprojectformatkey 
      FROM taqversionformat 
      WHERE taqprojectkey = @i_projectkey AND
        plstagecode = @i_plstage AND
        taqversionkey = @i_plversion

    OPEN formats_cur
  
    FETCH formats_cur INTO @v_formatkey

    WHILE @@fetch_status = 0
    BEGIN

      SET @v_next_prtgnum = 0

      DECLARE formatyear_cur CURSOR FOR 
        SELECT taqversionformatyearkey, yearcode, COALESCE(quantity,0), COALESCE(printingnumber,0)
        FROM taqversionformatyear 
        WHERE taqprojectkey = @i_projectkey AND 
          plstagecode = @i_plstage AND 
          taqversionkey = @i_plversion AND 
          taqprojectformatkey = @v_formatkey AND
          yearcode NOT IN (SELECT datacode FROM gentables WHERE tableid = 563 AND qsicode = 1)	--skip Pre-Pub year
        ORDER BY yearcode             
    
      OPEN formatyear_cur
    
      FETCH formatyear_cur INTO @v_formatyearkey, @v_yearcode, @v_current_quantity, @v_current_prtgnum

      WHILE @@fetch_status = 0
      BEGIN

        SET @v_set_prtgnum = 0
        IF @v_current_quantity > 0
        BEGIN
          SET @v_next_prtgnum = @v_next_prtgnum + 1
          SET @v_set_prtgnum = @v_next_prtgnum
        END
        ELSE
          SET @v_set_prtgnum = NULL

        IF @v_current_prtgnum <> COALESCE(@v_set_prtgnum,0)
          UPDATE taqversionformatyear
          SET printingnumber = @v_set_prtgnum, lastuserid = @i_userid, lastmaintdate = getdate()
          WHERE taqversionformatyearkey = @v_formatyearkey
      
        FETCH formatyear_cur INTO @v_formatyearkey, @v_yearcode, @v_current_quantity, @v_current_prtgnum
      END

      CLOSE formatyear_cur 
      DEALLOCATE formatyear_cur    
    
      FETCH formats_cur INTO @v_formatkey
    END

    CLOSE formats_cur 
    DEALLOCATE formats_cur
  END

  DECLARE printnum_cur CURSOR FOR
    SELECT DISTINCT taqversionformatyearkey, quantity, printingnumber 
    FROM taqversionformatyear
    WHERE taqprojectkey = @i_projectkey AND
      plstagecode = @i_plstage AND 
      taqversionkey = @i_plversion AND
      yearcode NOT IN (SELECT datacode FROM gentables WHERE tableid = 563 AND qsicode = 1)
					
  OPEN printnum_cur

  FETCH printnum_cur INTO @v_formatyearkey, @v_quantity, @v_printingnumber

  WHILE @@fetch_status = 0
  BEGIN
    --update costs w/ printingnumber
    EXEC qpl_update_prod_costs @v_formatyearkey, @v_quantity, 0, @v_printingnumber, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
    IF @o_error_code <> 0 BEGIN
      SET @o_error_code = -1
      RETURN
    END
				
    FETCH printnum_cur INTO @v_formatyearkey, @v_quantity, @v_printingnumber
  END
		  
  CLOSE printnum_cur 
  DEALLOCATE printnum_cur

  RETURN  

  RETURN_ERROR:  
    SET @o_error_code = -1
    RETURN

END
GO

GRANT EXEC ON qpl_update_production_quantities TO PUBLIC
GO
