if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc071') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc071
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_IRR_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_IRR_HMH
GO

CREATE PROCEDURE qpl_calc_ver_IRR_HMH (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,  
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_IRR_HMH
**  Desc: Houghton Mifflin Item 71 - Version/IRR.
**
**  Auth: Kate
**  Date: March 1 2010
*******************************************************************************************/

DECLARE
  @v_yearcode INT,
  @v_yearsort INT,
  @v_net_cash FLOAT,
  @v_irr  FLOAT

BEGIN

  SET @o_result = NULL
  
  -- Create a temp table for year cash schedule
  CREATE TABLE #temp_cashflow (
    yearsort INT NOT NULL,
    cfamount FLOAT NOT NULL)

  -- Loop through all years for this version to populate the cash schedule temp table
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

    -- Calculate the Operating Profit (Net Cash) for the current year
    EXEC qpl_calc_yr_op_prof_HMH @i_projectkey, @i_plstage, @i_plversion, @v_yearcode, @v_net_cash OUTPUT

    IF @v_net_cash IS NULL
      SET @v_net_cash = 0

    /* Test data from Sheff spreadsheet 
    IF @v_yearsort = 0
      SET @v_net_cash = -507500
    ELSE IF @v_yearsort = 1
      SET @v_net_cash = 487500
    ELSE IF @v_yearsort = 2
      SET @v_net_cash = 953340
    ELSE IF @v_yearsort = 3
      SET @v_net_cash = 351530
    ELSE IF @v_yearsort = 4
      SET @v_net_cash = 374930
    */

    --PRINT 'YEAR ' + CONVERT(VARCHAR, @v_yearcode)
    --PRINT 'Net Cash: ' + CONVERT(VARCHAR,CONVERT(MONEY, @v_net_cash))

    -- Isert the Net Cash value for the current year into the temp cash flow table
    INSERT INTO #temp_cashflow VALUES (@v_yearsort, @v_net_cash)
    
    FETCH yearcode_cur INTO @v_yearcode, @v_yearsort
  END
  
  CLOSE yearcode_cur
  DEALLOCATE yearcode_cur

  SELECT @v_irr = wct.IRR(cfamount, yearsort, NULL) FROM #temp_cashflow
  
  --PRINT @v_irr
  SET @o_result = @v_irr
  
END
GO

GRANT EXEC ON qpl_calc_ver_IRR_HMH TO PUBLIC
GO
