if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qproject_run_misc_calc]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure [dbo].[qproject_run_misc_calc]
GO

/******************************************************************************
**  Name: qproject_run_misc_calc
**
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**	06/06/2016   Colman      38278 - Return sortable string value for numeric columns
**	06/07/2016   Colman      38278 - Fix negative number sort order
**  07/20/2016	 Uday        Case 38806 - Task 001
**  11/28/2016   Colman      41915 - fix date sorting
*******************************************************************************/

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dbo.qproject_run_misc_calc
  @i_taqprojectkey  INT,
  @i_misckey  INT,
  @i_userkey  INT,
  @i_userid   VARCHAR(30),
  @o_calcvalue	VARCHAR(255) OUTPUT,
  @o_sortvalue	VARCHAR(255) OUTPUT,
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT
AS

BEGIN
 DECLARE
    @v_quote  CHAR(1),
    @v_sql  VARCHAR(2000),
    @v_orglevel INT,
    @v_orgentrykey  INT,
    @v_misctype INT,
    @v_calcvalue  VARCHAR(255),
    @v_sortvalue  VARCHAR(255),
    @v_calc_dec	DECIMAL(18,4),
    @v_calc_int	INT,
    @error_var  INT,
    @rowcount_var INT,
    @v_gentext2 VARCHAR(255),
    @v_datetime_format_code VARCHAR(255),
    @v_calc_datetime DATETIME    

  SET @v_quote = CHAR(39)
  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_taqprojectkey IS NULL OR @i_misckey IS NULL BEGIN
    RETURN
  END
  
  SET @v_datetime_format_code = 101
  
  SELECT @v_datetime_format_code = dbo.qutl_get_dateformatcode(@i_userid)
  
  SELECT @error_var = @@ERROR
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no date format code found: userid = ' + cast(@i_userid AS VARCHAR)   
  END  
  
  SELECT @v_gentext2 = gentext2 
  FROM gentables_ext WHERE tableid = 607 AND datacode = @v_datetime_format_code
  
  IF ISNUMERIC(@v_gentext2) = 1 BEGIN
	SET @v_datetime_format_code = CONVERT(INT, @v_gentext2)
  END   

  -- find lowest orglevel that has the calculation 
  SELECT @v_orglevel = MAX(c.orglevelkey) 
  FROM miscitemcalc c, taqprojectorgentry o 
  WHERE c.orglevelkey = o.orglevelkey AND
        c.orgentrykey = o.orgentrykey AND
        o.taqprojectkey = @i_taqprojectkey AND
        c.misckey = @i_misckey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = 'max orglevel not found: taqprojectkey=' + cast(@i_taqprojectkey AS VARCHAR) + ', misckey=' + cast(@i_misckey AS VARCHAR)
    RETURN
  END 

  IF @v_orglevel IS NULL OR @v_orglevel <= 0 BEGIN
    RETURN
  END

  -- get orgentrykey at lowest level
  SELECT @v_orgentrykey = o.orgentrykey 
  FROM taqprojectorgentry o 
  WHERE o.taqprojectkey = @i_taqprojectkey AND
        o.orglevelkey = @v_orglevel

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = 'orgentrykey not found on taqprojectorgentry: taqprojectkey=' + cast(@i_taqprojectkey AS VARCHAR) + ', orglevel=' + cast(@v_orglevel AS VARCHAR)
    RETURN
  END 

  IF @v_orgentrykey IS NULL OR @v_orgentrykey <= 0 BEGIN
    RETURN
  END
  
  -- get calculation sql
  SELECT @v_sql = calcsql 
  FROM miscitemcalc
  WHERE misckey = @i_misckey AND
        orglevelkey = @v_orglevel AND
        orgentrykey = @v_orgentrykey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = 'calculation not found on miscitemcalc: misckey=' + cast(@i_misckey AS VARCHAR) + ', orglevelkey=' + cast(@v_orglevel AS VARCHAR) + ', orgentrykey=' + cast(@v_orgentrykey AS VARCHAR)
    RETURN
  END 

  -- Replace each parameter placeholder with corresponding value
  SET @v_sql = REPLACE(@v_sql, '@userkey', CONVERT(VARCHAR, @i_userkey))
  SET @v_sql = REPLACE(@v_sql, '@userid', @v_quote + @i_userid + @v_quote)
  SET @v_sql = REPLACE(@v_sql, '@projectkey', CONVERT(VARCHAR, @i_taqprojectkey))
  SET @v_sql = REPLACE(@v_sql, '@misckey', CONVERT(VARCHAR, @i_misckey))

  -- DEBUG
  --PRINT @v_sql

  SELECT @v_misctype = misctype 
  FROM bookmiscitems 
  WHERE misckey = @i_misckey
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = 'could not find misctype for misckey of ' + CAST(@i_misckey AS VARCHAR)
    RETURN
  END

  IF @v_misctype = 6 -- DECIMAL
  BEGIN
    DECLARE @maxfloat DECIMAL(18,4)
    SET @maxfloat = 99999999999999
    EXEC execute_calcsql @v_sql, @v_calc_dec OUTPUT
    SET @v_calcvalue = CONVERT(VARCHAR, @v_calc_dec)
    IF @v_calc_dec < 0 BEGIN
      SET @v_calc_dec = @v_calc_dec + @maxfloat
      SET @v_sortvalue = '.' + REPLICATE('0', 17 - LEN(ltrim(str(@v_calc_dec,17,4)))) + ltrim(str(@v_calc_dec,17,4))
    END
    ELSE
      SET @v_sortvalue = REPLICATE('0', 18 - LEN(ltrim(str(@v_calc_dec,18,4)))) + ltrim(str(@v_calc_dec,18,4))
  END
  ELSE IF @v_misctype = 8 -- INTEGER
  BEGIN
    DECLARE @maxint int
    SET @maxint = 2147483647
    EXEC execute_calcsql_integer @v_sql, @v_calc_int OUTPUT
    SET @v_calcvalue = CONVERT(VARCHAR, @v_calc_int)
    IF @v_calc_int < 0 BEGIN
      SET @v_calc_int = @v_calc_int + @maxint
      SET @v_sortvalue = '.' + REPLICATE('0', 9 - LEN(@v_calc_int)) + CAST(@v_calc_int AS varchar)
    END
    ELSE
      SET @v_sortvalue = REPLICATE('0', 10 - LEN(@v_calc_int)) + CAST(@v_calc_int AS varchar)
  END
  ELSE IF @v_misctype = 9 -- STRING
    EXEC execute_calcsql_string @v_sql, @v_calcvalue OUTPUT
	ELSE IF @v_misctype = 10 BEGIN -- DATE
		EXEC execute_calcsql_string @v_sql, @v_calcvalue OUTPUT
		
		IF @v_calcvalue IS NOT NULL AND ISNUMERIC(@v_calcvalue) = 0 BEGIN
		  SET @v_calc_datetime =  CONVERT(datetime, @v_calcvalue)
		  SET @v_calcvalue = CONVERT(VARCHAR(20), @v_calc_datetime, CONVERT(INT, @v_datetime_format_code))      
		  SET @v_sortvalue = CONVERT(VARCHAR(20), @v_calc_datetime, 20)     -- yyyy-mm-dd hh:mi:ss(24h) 
		END		
    END
    
  SET @o_calcvalue = @v_calcvalue
  IF @v_sortvalue IS NOT NULL
    SET @o_sortvalue = @v_sortvalue
  ELSE
    SET @o_sortvalue = @o_calcvalue
  
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

grant execute on qproject_run_misc_calc to public
go