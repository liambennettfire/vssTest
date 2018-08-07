DECLARE
  @v_current_percent FLOAT,
  @v_current_prtgnum INT,
  @v_current_quantity INT,
  @v_current_units INT,
  @v_error_code INT,
  @v_error_desc VARCHAR(2000),
  @v_formatkey INT,
  @v_formatyearkey INT,
  @v_next_prtgnum INT,
  @v_num_prodcosts INT,
  @v_plstage INT,
  @v_plversion INT,
  @v_prod_units FLOAT,
  @v_prodqtyentrytype INT,
  @v_projectkey	INT,
  @v_set_prtgnum  INT,
  @v_totalcount	INT,
  @v_totalqty INT
  
BEGIN

  SET @v_totalcount = 0

  -- Loop through all versions that may need printingnumber adjustments (i.e. printingnumbers exist on taqversionformatyear for rows with no quantity)
  -- NOTE: Must loop through versions first, then formats, because if production costs exist for at least one format, we want to preserve these costs 
  -- by changing the Production Quantity Entry Type from "Enter" to "Generate from Total Qty" for the version
  DECLARE version_cur CURSOR FOR
    SELECT DISTINCT y.taqprojectkey, y.plstagecode, y.taqversionkey, v.prodqtyentrytypecode,
      (SELECT COUNT(*) FROM taqversioncosts c, taqversionformatyear y2 
       WHERE y2.taqprojectkey = y.taqprojectkey AND y2.plstagecode = y.plstagecode AND y2.taqversionkey = y.taqversionkey
         AND c.taqversionformatyearkey = y2.taqversionformatyearkey AND c.printingnumber > 0) num_prodcosts
    FROM taqversionformatyear y, taqversion v, taqproject p
    WHERE v.taqprojectkey = y.taqprojectkey and v.plstagecode = y.plstagecode and v.taqversionkey = y.taqversionkey
      AND v.taqprojectkey = p.taqprojectkey
      --AND p.taqprojectstatuscode NOT IN (SELECT datacode FROM gentables WHERE tableid = 522 AND qsicode = 1)	--EXCLUDE Acquisition Approved versions from cleanup
      AND (quantity IS NULL OR quantity = 0)
      AND printingnumber > 0

  OPEN version_cur 

  FETCH NEXT FROM version_cur 
  INTO @v_projectkey, @v_plstage, @v_plversion, @v_prodqtyentrytype, @v_num_prodcosts

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN

    IF @v_prodqtyentrytype = 1  --Enter Qty By Year
    BEGIN

      SET @v_totalcount = @v_totalcount + 1
      PRINT '---'

      -- If at least one cost exists with printingnumber > 0, we want to preserve these costs rather than deleting them.
      -- Change the Production Quantity entry type code from "Enter" to "Generate from Total Quantity",
      -- and calculate format/year quantity from the existing percentage
      IF @v_num_prodcosts > 0
      BEGIN          
        PRINT 'Updating taqversion (taqprojectkey=' + convert(varchar, @v_projectkey) + ', plstagecode=' + convert(varchar, @v_plstage) + ', taqversionkey=' + convert(varchar, @v_plversion) + '):'
        PRINT ' prodqtyentrytypecode from 1 to 3'
		
        UPDATE taqversion
        SET prodqtyentrytypecode = 3
        WHERE taqprojectkey = @v_projectkey AND plstagecode = @v_plstage AND taqversionkey = @v_plversion
      END
  
      -- Loop through all formats for this version
      DECLARE format_cur CURSOR FOR
        SELECT DISTINCT taqprojectformatkey, 
          dbo.qpl_get_format_totalrequiredqty(taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey) totalqty
        FROM taqversionformatyear 
        WHERE taqprojectkey = @v_projectkey AND plstagecode = @v_plstage AND taqversionkey = @v_plversion
          AND (quantity IS NULL OR quantity = 0)
          AND printingnumber > 0

      OPEN format_cur 

      FETCH NEXT FROM format_cur INTO @v_formatkey, @v_totalqty

      WHILE (@@FETCH_STATUS <> -1)
      BEGIN

        -- If the Total Qty for this format is > 0, then calculate format/year quantity from the existing percentage
        IF @v_num_prodcosts > 0 AND @v_totalqty > 0
        BEGIN
                    
          SET @v_next_prtgnum = 0

          -- Get all format/year rows that have printingnumber filled in for 0 or NULL quantity
          DECLARE formatyear_cur CURSOR FOR
            SELECT taqversionformatyearkey, COALESCE(printingnumber,0), COALESCE(percentage,0), COALESCE(quantity,0)
            FROM taqversionformatyear 
            WHERE taqprojectkey = @v_projectkey 
              AND plstagecode = @v_plstage 
              AND taqversionkey = @v_plversion 
              AND taqprojectformatkey = @v_formatkey 
              AND printingnumber > 0

          OPEN formatyear_cur 

          FETCH NEXT FROM formatyear_cur 
          INTO @v_formatyearkey, @v_current_prtgnum, @v_current_percent, @v_current_units

          WHILE (@@FETCH_STATUS <> -1)
          BEGIN

            SET @v_prod_units = @v_totalqty * @v_current_percent / 100
            SET @v_prod_units = ROUND(@v_prod_units, 0)
          
            SET @v_set_prtgnum = 0
            IF @v_current_percent > 0
            BEGIN
              SET @v_next_prtgnum = @v_next_prtgnum + 1
              SET @v_set_prtgnum = @v_next_prtgnum
            END
            ELSE
              SET @v_set_prtgnum = NULL
          
            IF @v_current_units <> COALESCE(@v_prod_units,0) OR @v_current_prtgnum <> COALESCE(@v_set_prtgnum,0)
            BEGIN
              PRINT 'Updating taqversionformatyear (taqversionformatyearkey=' + convert(varchar, @v_formatyearkey) + '):'
              IF @v_current_units <> COALESCE(@v_prod_units,0)
                PRINT ' quantity from ' + convert(varchar, @v_current_units) + ' to ' + convert(varchar, @v_prod_units)
              IF @v_current_prtgnum <> COALESCE(@v_set_prtgnum,0)
                PRINT ' printingnumber from ' + convert(varchar, @v_current_prtgnum) + ' to ' + convert(varchar, @v_set_prtgnum)

              UPDATE taqversionformatyear
              SET quantity = @v_prod_units, printingnumber = @v_set_prtgnum, lastuserid = 'FIREBRAND_prtgnum', lastmaintdate = GETDATE()
              WHERE taqversionformatyearkey = @v_formatyearkey

              EXEC qpl_update_prod_costs @v_formatyearkey, @v_prod_units, 0, @v_set_prtgnum, 'FIREBRAND_prtgnum', @v_error_code OUTPUT, @v_error_desc OUTPUT
              IF @v_error_code <> 0 BEGIN
                PRINT 'Error occurred inside qpl_update_prod_costs stored procedure for formatyearkey ' + CONVERT(VARCHAR, @v_formatyearkey) + ': ' + @v_error_desc
              END
            END

            FETCH NEXT FROM formatyear_cur 
            INTO @v_formatyearkey, @v_current_prtgnum, @v_current_percent, @v_current_units
          END

          CLOSE formatyear_cur
          DEALLOCATE formatyear_cur
        END
        ELSE  --No production costs exist
        BEGIN
          -- Clear the percentages and recalculate printing numbers
          PRINT 'Clearing percentages on taqversionformatyear for taqprojectformatkey=' + convert(varchar, @v_formatkey) + ' (no production costs exist, or production costs exist but total format required quantity is 0)'

          -- Reset percentages
          UPDATE taqversionformatyear 
          SET percentage = NULL, lastuserid = 'FIREBRAND_prtgnum', lastmaintdate = getdate()
          WHERE taqprojectkey = @v_projectkey AND plstagecode = @v_plstage AND taqversionkey = @v_plversion AND taqprojectformatkey = @v_formatkey
            ANd percentage IS NOT NULL
		
          -- Loop through current format years to recalculate printing numbers
          SET @v_next_prtgnum = 0

          DECLARE formatyear_cur CURSOR FOR 
            SELECT taqversionformatyearkey, COALESCE(quantity,0), COALESCE(printingnumber,0)
            FROM taqversionformatyear 
            WHERE taqprojectkey = @v_projectkey AND 
              plstagecode = @v_plstage AND 
              taqversionkey = @v_plversion AND 
              taqprojectformatkey = @v_formatkey AND
              yearcode NOT IN (SELECT datacode FROM gentables WHERE tableid = 563 AND qsicode = 1)	--skip Pre-Pub year
            ORDER BY yearcode             
    
          OPEN formatyear_cur
    
          FETCH formatyear_cur INTO @v_formatyearkey, @v_current_quantity, @v_current_prtgnum

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
            BEGIN
              PRINT 'Updating taqversionformatyear (taqversionformatyearkey=' + convert(varchar, @v_formatyearkey) + '):'
              IF @v_set_prtgnum IS NULL
                PRINT ' printingnumber from ' + convert(varchar, @v_current_prtgnum) + ' to NULL'
              ELSE
                PRINT ' printingnumber from ' + convert(varchar, @v_current_prtgnum) + ' to ' + convert(varchar, @v_set_prtgnum)
            		
              UPDATE taqversionformatyear
              SET printingnumber = @v_set_prtgnum, lastuserid = 'FIREBRAND_prtgnum', lastmaintdate = getdate()
              WHERE taqversionformatyearkey = @v_formatyearkey
            END
      
            FETCH formatyear_cur INTO @v_formatyearkey, @v_current_quantity, @v_current_prtgnum
          END

          CLOSE formatyear_cur 
          DEALLOCATE formatyear_cur

          DECLARE printnum_cur CURSOR FOR
            SELECT DISTINCT taqversionformatyearkey, quantity, printingnumber 
            FROM taqversionformatyear
            WHERE taqprojectkey = @v_projectkey AND
              plstagecode = @v_plstage AND 
              taqversionkey = @v_plversion AND
              taqprojectformatkey = @v_formatkey AND
              yearcode NOT IN (SELECT datacode FROM gentables WHERE tableid = 563 AND qsicode = 1)
					
          OPEN printnum_cur

          FETCH printnum_cur INTO @v_formatyearkey, @v_current_quantity, @v_current_prtgnum

          WHILE @@fetch_status = 0
          BEGIN
            --update costs w/ printingnumber
            EXEC qpl_update_prod_costs @v_formatyearkey, @v_current_quantity, 0, @v_current_prtgnum, 'FIREBRAND_prtgnum', @v_error_code OUTPUT, @v_error_desc OUTPUT
            IF @v_error_code <> 0 BEGIN
              PRINT 'Error occurred inside qpl_update_prod_costs stored procedure for formatyearkey ' + CONVERT(VARCHAR, @v_formatyearkey) + ': ' + @v_error_desc
            END
				
            FETCH printnum_cur INTO @v_formatyearkey, @v_current_quantity, @v_current_prtgnum
          END
		  
          CLOSE printnum_cur 
          DEALLOCATE printnum_cur
        END

        FETCH NEXT FROM format_cur INTO @v_formatkey, @v_totalqty
      END

      CLOSE format_cur 
      DEALLOCATE format_cur

    END --IF @v_prodqtyentrytype = 1

    FETCH NEXT FROM version_cur 
    INTO @v_projectkey, @v_plstage, @v_plversion, @v_prodqtyentrytype, @v_num_prodcosts
  END

  CLOSE version_cur
  DEALLOCATE version_cur

  IF @v_totalcount > 0
    PRINT 'Total Version records fixed: ' + CONVERT(VARCHAR, @v_totalcount)
  ELSE
    PRINT 'There were no records on this database that needed to be fixed.'

END
GO
