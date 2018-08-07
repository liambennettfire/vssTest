if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qpl_run_pl_calcsql]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure [dbo].[qpl_run_pl_calcsql]
GO 

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dbo.qpl_run_pl_calcsql
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion  INT,
  @i_yearcode   INT,
  @i_itemkey    INT,
  @i_display_currency INT,
  @o_calcvalue  DECIMAL(18,4) OUTPUT, 
  @o_error_code INT OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
AS

/*****************************************************************************************************
**  Name: qpl_run_pl_calcsql
**  Desc: This stored procedure executes the calculation SQL for the given P&L Summary Item,
**        and selects the calculated value.
**
**  Auth: Kate
**  Date: November 8 2007
*****************************************************************************************************/

DECLARE
  @v_error  INT,
  @v_floatvalue FLOAT,
  @v_orglevel INT,
  @v_orgentrykey  INT,
  @v_quote  CHAR(1),  
  @v_rowcount INT,
  @v_sql  VARCHAR(2000)

BEGIN

  SET @v_quote = CHAR(39)
  SET @o_calcvalue = NULL
  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_projectkey IS NULL OR @i_projectkey <= 0 BEGIN
    SET @o_error_desc = 'Invalid projectkey.'
    GOTO RETURN_ERROR
  END

  IF @i_itemkey IS NULL OR @i_itemkey <= 0 BEGIN
    SET @o_error_desc = 'Invalid plsummaryitemkey.'
    GOTO RETURN_ERROR
  END

  -- Find the lowest orglevel that has the calculation 
  SELECT @v_orglevel = MAX(c.orglevelkey) 
  FROM plsummaryitemcalc c, taqprojectorgentry o 
  WHERE c.orglevelkey = o.orglevelkey AND
        c.orgentrykey = o.orgentrykey AND
        o.taqprojectkey = @i_projectkey AND
        c.plsummaryitemkey = @i_itemkey;

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
    SET @o_error_desc = 'Could not access plsummaryitemcalc/taqprojectorgentry tables to get Max Orglevel (taqprojectkey=' + cast(@i_projectkey AS VARCHAR) + ', plsummaryitemkey' + cast(@i_itemkey AS VARCHAR) + ')'
    GOTO RETURN_ERROR
  END
  
  -- NOTE: above SQL should always return a row - NULL value if no rows for this project/item
  IF @v_orglevel IS NULL OR @v_orglevel <= 0 BEGIN
    RETURN
  END

  -- Get orgentrykey at the lowest level found
  SELECT @v_orgentrykey = o.orgentrykey 
  FROM taqprojectorgentry o 
  WHERE o.taqprojectkey = @i_projectkey AND
        o.orglevelkey = @v_orglevel;

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
    SET @o_error_desc = 'Could not access taqprojectorgentry table to get Max Orgentry (taqprojectkey=' + cast(@i_projectkey AS VARCHAR) + ', orglevelkey' + cast(@v_orglevel AS VARCHAR) + ')'
    GOTO RETURN_ERROR
  END 

  IF @v_orgentrykey IS NULL OR @v_orgentrykey <= 0 BEGIN
    RETURN
  END
  
  -- Get calculation SQL
  SELECT @v_sql = calcsql 
  FROM plsummaryitemcalc
  WHERE plsummaryitemkey = @i_itemkey AND
        orglevelkey = @v_orglevel AND
        orgentrykey = @v_orgentrykey;

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Could not access plsummaryitemcalc to calculation SQL (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  IF @v_rowcount <= 0 BEGIN --not an error
    SET @o_error_code = 0
    SET @o_error_desc = 'Calculation not found on plsummaryitemcalc: plsummaryitemkey' + cast(@i_itemkey AS VARCHAR) + ', orgentrykey=' + cast(@v_orgentrykey AS VARCHAR)
    RETURN
  END 

  -- Replace each parameter placeholder with corresponding value
  SET @v_sql = REPLACE(@v_sql, '@projectkey', CONVERT(VARCHAR, @i_projectkey))
  SET @v_sql = REPLACE(@v_sql, '@plstagecode', CONVERT(VARCHAR, @i_plstage))
  SET @v_sql = REPLACE(@v_sql, '@versionkey', CONVERT(VARCHAR, @i_plversion))  
  SET @v_sql = REPLACE(@v_sql, '@yearcode', CONVERT(VARCHAR, @i_yearcode))
  SET @v_sql = REPLACE(@v_sql, '@displaycurrency', CONVERT(VARCHAR, @i_display_currency))

  -- DEBUG
  --PRINT @v_sql

  EXEC execute_calcsql @v_sql, @v_floatvalue OUTPUT
   
  SET @o_calcvalue = CAST(@v_floatvalue AS DECIMAL(18,4))
  RETURN  
  
RETURN_ERROR:  
  SET @o_error_code = -1
  RETURN
  
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXEC ON qpl_run_pl_calcsql TO PUBLIC
GO
