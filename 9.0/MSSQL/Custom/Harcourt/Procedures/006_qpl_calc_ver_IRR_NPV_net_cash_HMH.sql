if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc072') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc072
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_IRR_NPV_net_cash_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_IRR_NPV_net_cash_HMH
GO

CREATE PROCEDURE qpl_calc_ver_IRR_NPV_net_cash_HMH (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,  
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_IRR_NPV_net_cash_HMH
**  Desc: Houghton Mifflin Item 72 - Version/IRR – NPV Net Cash.
**
**  Auth: Kate
**  Date: March 2 2010
*******************************************************************************************/

DECLARE
  @v_yearcode INT,
  @v_yearsort INT,
  @v_npv_netcash FLOAT,
  @v_irr  FLOAT

BEGIN

  SET @o_result = NULL
  
  CREATE TABLE #temp_cashflow (
    yearsort INT NOT NULL,
    cfamount FLOAT NOT NULL)

  DECLARE yearcode_cur CURSOR FOR  
    SELECT DISTINCT y.yearcode, g.sortorder 
    FROM taqversionformatyear y, gentables g 
    WHERE y.yearcode = g.datacode AND 
      g.tableid = 563 AND 
      y.taqprojectkey = @i_projectkey AND 
      y.plstagecode = @i_plstage AND 
      y.taqversionkey = @i_plversion
    ORDER BY g.sortorder

  OPEN yearcode_cur
  
  FETCH yearcode_cur INTO @v_yearcode, @v_yearsort

  WHILE (@@FETCH_STATUS=0)
  BEGIN  

    -- Calculate the NPV Net Cash for the current year
    SET @v_npv_netcash = -1 --suppress print messages from the procedure called below
    EXEC qpl_calc_yr_NPV_net_cash_HMH @i_projectkey, @i_plstage, @i_plversion, @v_yearcode, @v_npv_netcash OUTPUT

    IF @v_npv_netcash IS NULL
      SET @v_npv_netcash = 0

    /* Test data from Sheff spreadsheet 
    IF @v_yearsort = 0
      SET @v_npv_netcash = -430085
    ELSE IF @v_yearsort = 1
      SET @v_npv_netcash = 350115
    ELSE IF @v_yearsort = 2
      SET @v_npv_netcash = 580232
    ELSE IF @v_yearsort = 3
      SET @v_npv_netcash = 181315
    ELSE IF @v_yearsort = 4
      SET @v_npv_netcash = 163885
    */

    --PRINT 'YEAR ' + CONVERT(VARCHAR, @v_yearcode)
    --PRINT 'NPV Net Cash: ' + CONVERT(VARCHAR,CONVERT(MONEY, @v_npv_netcash))

    -- Isert the Net Cash value for the current year into the temp cash flow table
    INSERT INTO #temp_cashflow VALUES (@v_yearsort, @v_npv_netcash)
    
    FETCH yearcode_cur INTO @v_yearcode, @v_yearsort
  END
  
  CLOSE yearcode_cur
  DEALLOCATE yearcode_cur

  SELECT @v_irr = wct.IRR(cfamount, yearsort, NULL) FROM #temp_cashflow
  
  --PRINT @v_irr
  SET @o_result = @v_irr
  
END
GO

GRANT EXEC ON qpl_calc_ver_IRR_NPV_net_cash_HMH TO PUBLIC
GO
