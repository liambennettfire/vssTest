if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc068') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc068
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_roy_exp') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_roy_exp
GO

CREATE PROCEDURE qpl_calc_ver_roy_exp (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @i_debugind	TINYINT,
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_roy_exp
**  Desc: P&L Item 68 - Version/Royalty Expense
**
**  Auth: Kate
**  Date: February 9 2010
*******************************************************************************************/

DECLARE
  @v_yearcode INT,
  @v_yeardesc VARCHAR(255),
  @v_yearsort INT,
  @v_version_royalty_expense  FLOAT,
  @v_year_royalty_expense FLOAT

BEGIN

  SET @o_result = NULL
  SET @v_version_royalty_expense = 0
  
  -- Loop through all years for the current Version and Format
  DECLARE ver_years_cur CURSOR FOR
    SELECT DISTINCT y.yearcode, g.sortorder, g.alternatedesc1
    FROM taqversionformatyear y, gentables g
    WHERE y.yearcode = g.datacode AND 
      g.tableid = 563 AND
      y.taqprojectkey = @i_projectkey AND
      y.plstagecode = @i_plstage AND
      y.taqversionkey = @i_plversion
    ORDER BY g.sortorder
     
  OPEN ver_years_cur

  FETCH ver_years_cur INTO @v_yearcode, @v_yearsort, @v_yeardesc

  WHILE (@@FETCH_STATUS=0)
  BEGIN

    -- Calculate Royalty Expense for the currently processed year
    EXEC qpl_calc_yr_roy_exp @i_projectkey, @i_plstage, @i_plversion, @v_yearcode, 0, @v_year_royalty_expense OUTPUT
    
    IF @v_year_royalty_expense IS NULL
      SET @v_year_royalty_expense = 0
         
    IF @i_debugind = 1
    BEGIN
      PRINT @v_yeardesc
      PRINT 'Royalty Expense = ' + CONVERT(VARCHAR, @v_year_royalty_expense)
    END
    
    -- Accumulate each year's value to arrive at total version royalty expense
    SET @v_version_royalty_expense = @v_version_royalty_expense + @v_year_royalty_expense
              
    FETCH ver_years_cur INTO @v_yearcode, @v_yearsort, @v_yeardesc
  END

  CLOSE ver_years_cur
  DEALLOCATE ver_years_cur      
  
  IF @i_debugind = 1
    PRINT 'TOTAL Royalty Expense = ' + CONVERT(VARCHAR, @v_version_royalty_expense)
  SET @o_result = @v_version_royalty_expense
  
END
GO

GRANT EXEC ON qpl_calc_ver_roy_exp TO PUBLIC
GO
