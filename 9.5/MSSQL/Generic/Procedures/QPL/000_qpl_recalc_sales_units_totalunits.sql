if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_recalc_sales_units') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_recalc_sales_units
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_recalc_sales_units_totalunits') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_recalc_sales_units_totalunits
GO

CREATE PROCEDURE qpl_recalc_sales_units_totalunits (  
  @i_projectkey   INT,
  @i_plstage      INT,
  @i_plversion    INT,
  @i_totalunits   INT,
  @i_grossind     TINYINT,
  @i_userid       VARCHAR(30),
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_recalc_sales_units_totalunits
**  Desc: This stored procedure recalculates detail sales units for the given version
**        from Total Units and existing sales percentages.
**
**  Auth: Kate
**  Date: January 22 2008
*******************************************************************************************/

DECLARE
  @v_error  INT,
  @v_isopentrans TINYINT,  
  @v_saleskey INT,
  @v_yearcode INT,
  @v_return_percent FLOAT,
  @v_sales_percent  FLOAT,
  @v_gross_decimal  FLOAT,
  @v_net_decimal  FLOAT,
  @v_gross_units  INT,
  @v_net_units  INT
  
BEGIN

  SET @v_isopentrans = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  IF @i_projectkey IS NULL OR @i_projectkey <= 0 BEGIN
    SET @o_error_desc = 'Invalid projectkey.'
    GOTO RETURN_ERROR
  END
  
  IF @i_plversion IS NULL OR @i_plversion <= 0 BEGIN
    SET @o_error_desc = 'Invalid taqversionkey.'
    GOTO RETURN_ERROR
  END  

  IF @i_plstage IS NULL BEGIN
    SET @o_error_desc = 'Invalid plstagecode.'
    GOTO RETURN_ERROR
  END  
  
  -- ***** BEGIN TRANSACTION ****  
  BEGIN TRANSACTION
  SET @v_isopentrans = 1
  
  -- ***** TAQVERSIONSALESUNIT *****
  -- Loop through all sales unit records for this version (all formats) and recalculate Gross and Net Units based on new Total
  DECLARE salesunit_cur CURSOR FOR 
    SELECT u.taqversionsaleskey, u.yearcode, u.salespercent, c.returnpercent
    FROM taqversionsalesunit u, taqversionsaleschannel c
    WHERE u.taqversionsaleskey = c.taqversionsaleskey AND
        taqprojectkey = @i_projectkey AND
        plstagecode = @i_plstage AND
        taqversionkey = @i_plversion

  OPEN salesunit_cur
  
  FETCH salesunit_cur INTO @v_saleskey, @v_yearcode, @v_sales_percent, @v_return_percent

  WHILE @@fetch_status = 0
  BEGIN
    
    IF @v_sales_percent IS NULL
      SET @v_sales_percent = 0
    IF @v_return_percent IS NULl
      SET @v_return_percent = 0
          
    IF @i_grossind = 1  --passed Total Units value is Gross
      BEGIN
        SET @v_gross_decimal = (@v_sales_percent / 100) * @i_totalunits
        SET @v_net_decimal = (1 - (@v_return_percent / 100)) * @v_gross_decimal
      END
    ELSE  --passed Total Units value is Net
      BEGIN
        SET @v_net_decimal = (@v_sales_percent / 100) * @i_totalunits
        SET @v_gross_decimal = @v_net_decimal / (1 - (@v_return_percent / 100))
      END

    SET @v_gross_units = ROUND(@v_gross_decimal, 0)
    SET @v_net_units = ROUND(@v_net_decimal, 0)
  
    UPDATE taqversionsalesunit
    SET grosssalesunits = @v_gross_units, netsalesunits = @v_net_units,
        lastmaintdate = getdate(), lastuserid = @i_userid
    WHERE taqversionsaleskey = @v_saleskey AND
        yearcode = @v_yearcode
    
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_desc = 'Update to taqversionsalesunit table failed (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END
    
    FETCH salesunit_cur INTO @v_saleskey, @v_yearcode, @v_sales_percent, @v_return_percent
  END

  CLOSE salesunit_cur 
  DEALLOCATE salesunit_cur
  
  -- ***** TAQVERSION *****
  IF @i_plstage > 0
    UPDATE taqversion
    SET totalsalesunits = @i_totalunits, totalchangedind = 1
    WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion
  ELSE
    UPDATE taqversion
    SET totalsalesunits = @i_totalunits
    WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Update of totalsalesunits to taqversion table failed (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  IF @v_isopentrans = 1
    COMMIT
  
  RETURN  

  RETURN_ERROR:
    IF @v_isopentrans = 1
      ROLLBACK
  
    SET @o_error_code = -1
    RETURN
      
END
GO

GRANT EXEC ON qpl_recalc_sales_units_totalunits TO PUBLIC
GO
