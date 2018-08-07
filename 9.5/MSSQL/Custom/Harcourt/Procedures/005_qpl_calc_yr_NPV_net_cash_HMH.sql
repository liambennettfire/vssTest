if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc090') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc090
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_NPV_net_cash_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_NPV_net_cash_HMH
GO

CREATE PROCEDURE qpl_calc_yr_NPV_net_cash_HMH (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,
  @i_yearcode   INT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_yr_NPV_net_cash_HMH
**  Desc: Houghton Mifflin Item 90 - Year/NPV Net Cash.
**
**  Auth: Kate
**  Date: March 2 2010
*******************************************************************************************/

DECLARE
  @v_count  INT,
  @v_netcash FLOAT,
  @v_npv_netcash FLOAT,
  @v_npv  FLOAT,
  @v_npv_rate FLOAT,
  @v_this_yearsort  INT,
  @v_total_npv_netcash  FLOAT,
  @v_yearcode INT,
  @v_yearsort INT  

BEGIN

  -- Create a temp table for year cash schedule
  CREATE TABLE #temp_cashflow (
    yearsort INT NOT NULL,
    cfamount FLOAT NOT NULL)

  -- Get the sortorder for the current year
  SELECT @v_this_yearsort = sortorder
  FROM gentables
  WHERE tableid = 563 AND
      datacode = @i_yearcode
       
  -- Loop through all previous years and current year to populate the cash schedule temp table
  DECLARE yearcode_cur CURSOR LOCAL FOR  
    SELECT DISTINCT y.yearcode, g.sortorder 
    FROM taqversionformatyear y, gentables g 
    WHERE y.yearcode = g.datacode AND 
      g.tableid = 563 AND 
      y.taqprojectkey = @i_projectkey AND 
      y.plstagecode = @i_plstage AND 
      y.taqversionkey = @i_plversion AND
      g.sortorder <= @v_this_yearsort
    ORDER BY g.sortorder

  OPEN yearcode_cur
  
  FETCH yearcode_cur INTO @v_yearcode, @v_yearsort

  SET @v_total_npv_netcash = 0
  WHILE (@@FETCH_STATUS=0)
  BEGIN  
  
    -- Calculate the Operating Profit (Net Cash) for the current year
    EXEC qpl_calc_yr_op_prof_HMH @i_projectkey, @i_plstage, @i_plversion, @v_yearcode, @v_netcash OUTPUT

    IF @v_netcash IS NULL
      SET @v_netcash = 0

    /* Test data from Sheff spreadsheet 
    IF @v_yearsort = 0
      SET @v_netcash = -507500
    ELSE IF @v_yearsort = 1
      SET @v_netcash = 487500
    ELSE IF @v_yearsort = 2
      SET @v_netcash = 953340
    ELSE IF @v_yearsort = 3
      SET @v_netcash = 351530
    ELSE IF @v_yearsort = 4
      SET @v_netcash = 374930
    */
    
    -- Isert the Net Cash value for the current year into the temp cash flow table
    INSERT INTO #temp_cashflow VALUES (@v_yearsort, @v_netcash)
    
    -- Calculate the NPV Net Cash for all previous years
    IF @v_yearsort < @v_this_yearsort
    BEGIN   
      SET @v_npv_netcash = -1   --suppress print messages coming from the called procedure
      EXEC qpl_calc_yr_NPV_net_cash_HMH @i_projectkey, @i_plstage, @i_plversion, @v_yearcode, @v_npv_netcash OUTPUT

      IF @v_npv_netcash IS NULL
        SET @v_npv_netcash = 0

      SET @v_total_npv_netcash = @v_total_npv_netcash + @v_npv_netcash  
    END
    
    /* IF @o_result IS NULL
    BEGIN
      PRINT 'YEAR ' + CONVERT(VARCHAR, @v_yearcode)
      PRINT 'Net Cash: ' + CONVERT(VARCHAR,CONVERT(MONEY, @v_netcash))
    END */
    
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
  
  /* IF @o_result IS NULL
  BEGIN
    PRINT 'NPV: ' + CONVERT(VARCHAR, @v_npv)
    PRINT 'Total NPV Net Cash to date: ' + CONVERT(VARCHAR, @v_total_npv_netcash)
    PRINT 'NPV:' + CONVERT(VARCHAR, @v_npv - @v_total_npv_netcash)
  END */
   
  SET @v_npv = @v_npv - @v_total_npv_netcash  
  SET @o_result = @v_npv
  
END
GO

GRANT EXEC ON qpl_calc_yr_NPV_net_cash_HMH TO PUBLIC
GO
