if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_update_prod_costs') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_update_prod_costs
GO

CREATE PROCEDURE qpl_update_prod_costs (  
  @i_formatyearkey  integer,
  @i_new_quantity   integer,
  @i_new_percent    float,
  @i_printingnumber integer,
  @i_userid         varchar(30),
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/**********************************************************************************************************
**  Name: qpl_update_prod_costs
**  Desc: This stored procedure maintains production costs for the associated P&L Version/Format/Year
**        based on new production quantity or percentage.
**
**  Auth: Kate
**  Date: March 21 2008
**********************************************************************************************************/

BEGIN

  DECLARE
    @v_calctype INT,
    @v_chargecode INT,
    @v_count  INT,
    @v_error  INT,
    @v_formatkey  INT,
    @v_new_prodqty_dec  FLOAT,
    @v_new_prodqty INT,
    @v_new_totalcost  FLOAT,
    @v_new_unitcost FLOAT,
    @v_plstage  INT,
    @v_plversion  INT,
    @v_printingnumber INT,
    @v_projectkey INT,
    @v_total_required_qty INT,
    @v_totalcost  FLOAT,
    @v_unitcost FLOAT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  -- If there's no printing number associated with this Version/Format/Year, delete all associated production costs
  IF @i_printingnumber IS NULL OR @i_printingnumber = 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM taqversioncosts  
    WHERE taqversionformatyearkey = @i_formatyearkey AND 
      acctgcode IN (SELECT internalcode FROM cdlist WHERE placctgcategorycode = 2)
        
    IF @v_count > 0
      PRINT 'Deleting production taqversioncosts rows for taqversionformatyearkey=' + convert(varchar, @i_formatyearkey)

    DELETE FROM taqversioncosts  
    WHERE taqversionformatyearkey = @i_formatyearkey AND 
        acctgcode IN (SELECT internalcode FROM cdlist WHERE placctgcategorycode = 2)   

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Could not delete associated Production Costs from taqversioncosts table (taqversionformatyearkey=' + CAST(@i_formatyearkey AS VARCHAR) + ').'
    END
    
    RETURN
  END
  
  -- Get projectkey, stage, version and formatkey for the current formatyear record
  SELECT @v_projectkey = taqprojectkey, @v_plstage = plstagecode, 
    @v_plversion = taqversionkey, @v_formatkey = taqprojectformatkey
  FROM taqversionformatyear
  WHERE taqversionformatyearkey = @i_formatyearkey

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionformatyear table (taqversionformatyearkey=' + CAST(@i_formatyearkey AS VARCHAR) + ').'
  END
          
  -- If percentage, not quantity, is passed, new Production Quantity must be calculated 
  IF @i_new_quantity = 0 AND @i_new_percent > 0
    BEGIN
      -- Get the Total Required Quantity for this P&L Version/Format
      SET @v_total_required_qty = dbo.qpl_get_format_totalrequiredqty(@v_projectkey, @v_plstage, @v_plversion, @v_formatkey)
      
      -- Calculate Production Quantity as the percentage of Total Required Quantity
      SET @v_new_prodqty_dec = @v_total_required_qty * @i_new_percent / 100
      SET @v_new_prodqty = ROUND(@v_new_prodqty_dec, 0)
    END
  ELSE
    SET @v_new_prodqty = @i_new_quantity
  
  
  -- Get current list of Production Cost chargecodes for any year on this P&L Version/Format
  DECLARE prodchargecodes_cur CURSOR FOR 
    SELECT DISTINCT c.acctgcode, c.plcalccostcode
    FROM taqversioncosts c, cdlist cd 
    WHERE c.acctgcode = cd.internalcode AND
        cd.placctgcategorycode = 2 AND
        c.taqversionformatyearkey IN 
          (SELECT taqversionformatyearkey FROM taqversionformatyear
           WHERE taqprojectkey = @v_projectkey AND
              plstagecode = @v_plstage AND
              taqversionkey = @v_plversion AND
              taqprojectformatkey = @v_formatkey)

  OPEN prodchargecodes_cur
  
  FETCH prodchargecodes_cur INTO @v_chargecode, @v_calctype

  WHILE @@fetch_status = 0
  BEGIN
  
    -- Check if Production Cost row exists for this Version/Format/Year/Chargecode
    SELECT @v_count = COUNT(*)
    FROM taqversioncosts c, cdlist cd
    WHERE c.acctgcode = cd.internalcode AND
          c.taqversionformatyearkey = @i_formatyearkey AND
          cd.placctgcategorycode = 2 AND
          c.acctgcode = @v_chargecode       
    
    IF @v_count > 0 --existing production cost record - UPDATE costs
      BEGIN
        SELECT @v_totalcost = COALESCE(ROUND(versioncostsamount, 2),0), 
          @v_unitcost = COALESCE(ROUND(unitcost, 4),0), 
          @v_printingnumber = COALESCE(printingnumber,0)
        FROM taqversioncosts c, cdlist cd
        WHERE c.acctgcode = cd.internalcode AND
              c.taqversionformatyearkey = @i_formatyearkey AND
              cd.placctgcategorycode = 2 AND
              c.acctgcode = @v_chargecode
              
        IF @v_calctype = 2  --Calculate Total Cost
          BEGIN
            SET @v_new_totalcost = COALESCE(ROUND(@v_unitcost * @v_new_prodqty, 2),0)
            SET @v_new_unitcost = @v_unitcost
          END
        ELSE  --Calculate Unit Cost (default)
          BEGIN
            SET @v_new_totalcost = @v_totalcost
            SET @v_new_unitcost = 0
            IF @v_new_prodqty > 0
              SET @v_new_unitcost = ROUND(@v_totalcost / @v_new_prodqty, 4)
          END

        IF @v_new_totalcost <> @v_totalcost OR @v_new_unitcost <> @v_unitcost OR @v_printingnumber <> COALESCE(@i_printingnumber,0)
        BEGIN

          PRINT 'Updating taqversioncosts (taqversionformatyearkey=' + convert(varchar, @i_formatyearkey) + ', acctgcode=' + convert(varchar, @v_chargecode) + '):'
          IF @v_new_totalcost <> @v_totalcost
            PRINT ' versioncostsamount from ' + convert(varchar, @v_totalcost) + ' to ' + convert(varchar, @v_new_totalcost)
          IF @v_new_unitcost <> @v_unitcost
            PRINT ' unitcost from ' + convert(varchar, @v_unitcost) + ' to ' + convert(varchar, @v_new_unitcost)
          IF @v_printingnumber <> COALESCE(@i_printingnumber,0)
            IF @i_printingnumber IS NULL
              PRINT ' printingnumber from ' + convert(varchar, @v_printingnumber) + ' to NULL'
            ELSE
              PRINT ' printingnumber from ' + convert(varchar, @v_printingnumber) + ' to ' + convert(varchar, @v_printingnumber)
        
          UPDATE taqversioncosts
          SET versioncostsamount = @v_new_totalcost, unitcost = @v_new_unitcost, printingnumber = @i_printingnumber,
              templatechangedind = 1, lastuserid = @i_userid, lastmaintdate = getdate()
          WHERE taqversionformatyearkey = @i_formatyearkey AND
                acctgcode = @v_chargecode
          
          SELECT @v_error = @@ERROR
          IF @v_error <> 0 BEGIN
            CLOSE prodcosts_cur 
            DEALLOCATE prodcosts_cur    
            SET @o_error_code = -1
            SET @o_error_desc = 'Could not update Production Costs on taqversioncosts table (taqversionformatyearkey=' + 
              CAST(@i_formatyearkey AS VARCHAR) + ', acctgcode=' + CAST(@v_chargecode AS VARCHAR) + ').'
          END
        END              
      END
    ELSE  --production cost record doesn't exist - INSERT
      BEGIN

        PRINT 'Inserting taqversioncosts (taqversionformatyearkey=' + convert(varchar, @i_formatyearkey) + ', acctgcode=' + convert(varchar, @v_chargecode) + ')'

        INSERT INTO taqversioncosts
          (taqversionformatyearkey, acctgcode, plcalccostcode, versioncostsamount, unitcost, printingnumber, 
           templatechangedind, lastuserid, lastmaintdate)
        VALUES
          (@i_formatyearkey, @v_chargecode, @v_calctype, NULL, NULL, @i_printingnumber, 
           1, @i_userid, getdate())
      END
    
    FETCH prodchargecodes_cur INTO @v_chargecode, @v_calctype
  END

  CLOSE prodchargecodes_cur 
  DEALLOCATE prodchargecodes_cur

END
GO

GRANT EXEC ON qpl_update_prod_costs TO PUBLIC
GO
