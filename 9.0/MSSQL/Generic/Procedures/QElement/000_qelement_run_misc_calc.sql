if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qelement_run_misc_calc') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure [dbo].qelement_run_misc_calc
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dbo.qelement_run_misc_calc
  @i_elementkey  INT,
  @i_misckey  INT,
  @i_userkey  INT,
  @i_userid   VARCHAR(30),  
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
    @v_projectkey  INT,
    @v_bookkey  INT,
    @error_var  INT,
    @rowcount_var INT

  SET @v_quote = CHAR(39)
  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT @v_bookkey = COALESCE(bookkey,0),
         @v_projectkey = COALESCE(taqprojectkey,0)
    FROM taqprojectelement
   WHERE taqelementkey = @i_elementkey
   
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqprojectelement (taqelementkey: ' + CONVERT(VARCHAR, @i_elementkey) + ').'
    return
  END

  IF (@v_projectkey <= 0 AND @v_bookkey <= 0) OR @i_misckey IS NULL BEGIN
    RETURN
  END

  -- find lowest orglevel that has the calculation 
  -- use the associated project's orgentries first
  IF @v_projectkey > 0 BEGIN
    SELECT @v_orglevel = MAX(c.orglevelkey) 
    FROM miscitemcalc c, taqprojectorgentry o 
    WHERE c.orglevelkey = o.orglevelkey AND
          c.orgentrykey = o.orgentrykey AND
          o.taqprojectkey = @v_projectkey AND
          c.misckey = @i_misckey;
  END
  ELSE BEGIN
    SELECT @v_orglevel = MAX(c.orglevelkey) 
    FROM miscitemcalc c, bookorgentry o 
    WHERE c.orglevelkey = o.orglevelkey AND
          c.orgentrykey = o.orgentrykey AND
          o.bookkey = @v_bookkey AND
          c.misckey = @i_misckey;
  END
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = 'max orglevel not found: elementkey=' + cast(@i_elementkey AS VARCHAR) + ', misckey=' + cast(@i_misckey AS VARCHAR)
    RETURN
  END 

  IF @v_orglevel IS NULL OR @v_orglevel <= 0 BEGIN
    RETURN
  END

  -- get orgentrykey at lowest level
  IF @v_projectkey > 0 BEGIN
    SELECT @v_orgentrykey = o.orgentrykey 
    FROM taqprojectorgentry o 
    WHERE o.taqprojectkey = @v_projectkey AND
          o.orglevelkey = @v_orglevel;
  END
  ELSE BEGIN
    SELECT @v_orgentrykey = o.orgentrykey 
    FROM bookorgentry o 
    WHERE o.bookkey = @v_bookkey AND
          o.orglevelkey = @v_orglevel;
  END
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = 'orgentrykey not found: elementkey=' + cast(@i_elementkey AS VARCHAR) + ', orglevel=' + cast(@v_orglevel AS VARCHAR)
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
        orgentrykey = @v_orgentrykey;

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
  SET @v_sql = REPLACE(@v_sql, '@projectkey', CONVERT(VARCHAR, @v_projectkey))
  SET @v_sql = REPLACE(@v_sql, '@bookkey', CONVERT(VARCHAR, @v_bookkey))
  SET @v_sql = REPLACE(@v_sql, '@elementkey', CONVERT(VARCHAR, @i_elementkey))

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

	IF @v_misctype = 6 -- FLOAT
		EXEC execute_calcsql @v_sql, @v_calcvalue OUTPUT
	ELSE IF @v_misctype = 8 -- INTEGER
		EXEC execute_calcsql_integer @v_sql, @v_calcvalue OUTPUT
	ELSE IF @v_misctype = 9 -- STRING
		EXEC execute_calcsql_string @v_sql, @v_calcvalue OUTPUT
  
  SELECT @v_calcvalue
  
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

grant execute on qelement_run_misc_calc to public
go