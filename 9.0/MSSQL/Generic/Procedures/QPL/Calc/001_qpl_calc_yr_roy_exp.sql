if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc069') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc069
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_yr_roy_exp') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_yr_roy_exp
GO

CREATE PROCEDURE qpl_calc_yr_roy_exp (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @i_yearcode   INT,
  @i_debugind	TINYINT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_yr_roy_exp
**  Desc: P&L Item 69 - Year/Royalty Expense
**
**  Auth: Kate
**  Date: February 9 2010
*******************************************************************************************/

DECLARE
  @v_LTD_royalty_expense  FLOAT,
  @v_LTD_royalty_earned FLOAT,
  @v_prior_yearcode INT,
  @v_prior_yearsort INT,
  @v_prior_royalty_earned  FLOAT,
  @v_prior_royalty_expense  FLOAT,
  @v_unearned_advances  FLOAT,
  @v_curyear_royalty_advance FLOAT,
  @v_curyear_royalty_earned  FLOAT,
  @v_curyear_royalty_paid  FLOAT,
  @v_yeardesc	VARCHAR(255),
  @v_yearsort	INT 

BEGIN
 
  -- Get the sortorder for the passed yearcode
  SELECT @v_yearsort = sortorder, @v_yeardesc = alternatedesc1
  FROM gentables
  WHERE tableid = 563 AND datacode = @i_yearcode  
  
  -- Get the Royalty Advance for the Year
  EXEC qpl_calc_yr_roy_adv @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, @v_curyear_royalty_advance OUTPUT

  -- Get the Royalty Earned for the Year
  EXEC qpl_calc_yr_roy_ern @i_projectkey, @i_plstage, @i_plversion, @i_yearcode, 0, @v_curyear_royalty_earned OUTPUT
  
  IF @v_curyear_royalty_advance IS NULL
    SET @v_curyear_royalty_advance = 0
  IF @v_curyear_royalty_earned IS NULL
    SET @v_curyear_royalty_earned = 0
  
  IF @i_debugind = 1
  BEGIN
    PRINT @v_yeardesc
    PRINT 'Current Year Royalty Advance = ' + CONVERT(VARCHAR, @v_curyear_royalty_advance)
    PRINT 'Current Year Royalty Earned = ' + CONVERT(VARCHAR, @v_curyear_royalty_earned)
  END

  IF @v_curyear_royalty_advance > @v_curyear_royalty_earned
  BEGIN
    IF @i_debugind = 1
      PRINT 'Current Year Royalty Expense = ' + CONVERT(VARCHAR, @v_curyear_royalty_advance)
    SET @o_result = @v_curyear_royalty_advance
    RETURN
  END
  ELSE  
  BEGIN --@v_curyear_royalty_advance <= @v_curyear_royalty_earned
       
    SET @v_LTD_royalty_expense = 0
    SET @v_LTD_royalty_earned = 0
    
    IF @i_debugind = 1
    BEGIN
      PRINT ''
      PRINT 'Accumulate prior years Royalty Expense and Royalty Earned:'
    END
       
    -- Loop through all years prior to the current year to calculate the life-to-date (LTD) Royalty Expense and Royalty Earned
    -- for the current Version and Format
    DECLARE years_cur CURSOR LOCAL FOR
      SELECT DISTINCT y.yearcode, g.sortorder
      FROM taqversionformatyear y, gentables g
      WHERE y.yearcode = g.datacode AND 
        g.tableid = 563 AND
        y.taqprojectkey = @i_projectkey AND
        y.plstagecode = @i_plstage AND
        y.taqversionkey = @i_plversion AND 
        g.sortorder < @v_yearsort
      ORDER BY g.sortorder
      
    OPEN years_cur
    
    FETCH years_cur INTO @v_prior_yearcode, @v_prior_yearsort

    WHILE (@@FETCH_STATUS=0)
    BEGIN
    
      -- Calculate Royalty Expense for the currently processed prior year
      EXEC qpl_calc_yr_roy_exp @i_projectkey, @i_plstage, @i_plversion, @v_prior_yearcode, 0, @v_prior_royalty_expense OUTPUT
      
      IF @v_prior_royalty_expense IS NULL
        SET @v_prior_royalty_expense = 0
      
      -- Calculate Royalty Eearned for the currently processed prior year
      EXEC qpl_calc_yr_roy_ern @i_projectkey, @i_plstage, @i_plversion, @v_prior_yearcode, 0, @v_prior_royalty_earned OUTPUT
      
      IF @v_prior_royalty_earned IS NULL
        SET @v_prior_royalty_earned = 0
      
      IF @i_debugind = 1
      BEGIN
        PRINT ' *** Year ' + CONVERT(VARCHAR, @v_prior_yearsort) + ':'
        PRINT ' Royalty Expense = ' + CONVERT(VARCHAR, @v_prior_royalty_expense)
        PRINT ' Royalty Earned = ' + CONVERT(VARCHAR, @v_prior_royalty_earned)
      END
      
      -- Accumulate LTD values
      SET @v_LTD_royalty_expense = @v_LTD_royalty_expense + @v_prior_royalty_expense
      SET @v_LTD_royalty_earned = @v_LTD_royalty_earned + @v_prior_royalty_earned
                
      FETCH years_cur INTO @v_prior_yearcode, @v_prior_yearsort
    END
    
    CLOSE years_cur
    DEALLOCATE years_cur      
  
  END  --@v_curyear_royalty_advance <= @v_curyear_royalty_earned
    
  -- Calculate the previous years unearned royalty value
  SET @v_unearned_advances = @v_LTD_royalty_expense - @v_LTD_royalty_earned   
  
  -- Calculate the royalty paid in the current year
  SET @v_curyear_royalty_paid = @v_curyear_royalty_earned - (@v_unearned_advances + @v_curyear_royalty_advance)
  
  -- Payment would never be negative
  IF @v_curyear_royalty_paid < 0
    SET @v_curyear_royalty_paid = 0
  
  IF @i_debugind = 1
  BEGIN
    PRINT ''
    PRINT 'LTD Royalty Expense = ' + CONVERT(VARCHAR, @v_LTD_royalty_expense)
    PRINT 'LTD Royalty Earned = ' + CONVERT(VARCHAR, @v_LTD_royalty_earned)
    PRINT 'Unearned Advances (LTD Royalty Expense - LTD Royalty Earned) = ' + CONVERT(VARCHAR, @v_unearned_advances)
    PRINT 'Current Year Royalty Paid (Current Year Royalty Earned - (Unearned Advances + Current Year Royalty Advances)) = ' + CONVERT(VARCHAR, @v_curyear_royalty_paid)
    PRINT 'Current Year Royalty Expense (Current Year Royalty Advance + Current Year Royalty Paid) = ' + CONVERT(VARCHAR, @v_curyear_royalty_advance + @v_curyear_royalty_paid)
  END
  
  -- Royalty Expense is always the Current Year Advance (which is paid regardless of what happens)
  -- plus the Current Year Royalty Paid 
  SET @o_result = @v_curyear_royalty_advance + @v_curyear_royalty_paid
  
END
GO

GRANT EXEC ON qpl_calc_yr_roy_exp TO PUBLIC
GO
