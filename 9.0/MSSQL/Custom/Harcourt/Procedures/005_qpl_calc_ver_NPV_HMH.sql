if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc073') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc073
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_NPV_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_NPV_HMH
GO

CREATE PROCEDURE qpl_calc_ver_NPV_HMH (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,  
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_NPV_HMH
**  Desc: Houghton Mifflin Item 73 - Version/NPV.
**
**  Auth: Kate
**  Date: March 2 2010
*******************************************************************************************/

DECLARE
  @v_count  INT,
  @v_net_cash FLOAT,
  @v_npv  FLOAT,
  @v_npv_rate FLOAT,
  @v_yearcode INT,
  @v_yearsort INT

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

  -- Get the NPV rate for this version
  SELECT @v_count = COUNT(*)
  FROM taqversionclientvalues 
  WHERE taqprojectkey = @i_projectkey AND 
      plstagecode = @i_plstage AND
      taqversionkey = @i_plversion AND
      clientvaluecode = 1 --NPV rate
  
  SET @v_npv_rate = 0
  IF @v_count > 0
    SELECT @v_npv_rate = clientvalue 
    FROM taqversionclientvalues
    WHERE taqprojectkey = @i_projectkey AND 
        plstagecode = @i_plstage AND
        taqversionkey = @i_plversion AND
        clientvaluecode = 1
  
  SET @v_npv_rate = @v_npv_rate / 100
 
  /* Test data from Sheff spreadsheet 
  SET @v_npv_rate = .18
  */
  
  SELECT @v_npv = wct.NPV(@v_npv_rate, cfamount, yearsort) FROM #temp_cashflow
  
  --PRINT CONVERT(MONEY, @v_npv)
  SET @o_result = @v_npv
  
END
GO

GRANT EXEC ON qpl_calc_ver_NPV_HMH TO PUBLIC
GO
