if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qutl_run_misc_calc]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure [dbo].[qutl_run_misc_calc]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dbo.qutl_run_misc_calc
  @i_misckey  INT,
  @i_userkey  INT,
  @i_userid   VARCHAR(30),
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT
AS

BEGIN
 DECLARE
    @v_calcvalue  VARCHAR(255),
    @v_error  INT,
    @v_fieldformat  VARCHAR(40),
    @v_misctype INT,
    @v_orgentrykey  INT,
    @v_orglevel INT,
    @v_orgsecfilter  VARCHAR(MAX),
    @v_quote  CHAR(1),
    @v_rowcount INT,    
    @v_sql  VARCHAR(2000)

  SET @v_quote = CHAR(39)
  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_misckey IS NULL BEGIN
    RETURN
  END

  -- find lowest orglevel that has the calculation 
  SELECT @v_orglevel = MAX(c.orglevelkey) 
  FROM miscitemcalc c, userprimaryorgentry o 
  WHERE c.orglevelkey = o.orglevelkey AND
        c.orgentrykey = o.orgentrykey AND
        o.userkey = @i_userkey AND
        c.misckey = @i_misckey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 or @v_rowcount = 0 BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = 'max orglevel not found: userkey=' + cast(@i_userkey AS VARCHAR) + ', misckey=' + cast(@i_misckey AS VARCHAR)
    RETURN
  END 

  IF @v_orglevel IS NULL OR @v_orglevel <= 0 BEGIN
    RETURN
  END

  -- get orgentrykey at lowest level
  SELECT @v_orgentrykey = o.orgentrykey 
  FROM userprimaryorgentry o 
  WHERE o.userkey = @i_userkey AND
        o.orglevelkey = @v_orglevel

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 or @v_rowcount = 0 BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = 'orgentrykey not found on userprimaryorgentry: userkey=' + cast(@i_userkey AS VARCHAR) + ', orglevel = ' + cast(@v_orglevel AS VARCHAR)
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
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 or @v_rowcount = 0 BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = 'calculation not found on miscitemcalc: misckey=' + cast(@i_misckey AS VARCHAR) + ', orglevelkey= ' + cast(@v_orglevel AS VARCHAR) + ', orgentrykey=' + cast(@v_orgentrykey AS VARCHAR)
    RETURN
  END
  
  SET @v_orgsecfilter = dbo.qutl_get_user_orgsecfilter(@i_userkey, 0, 7)
  
  -- Replace each parameter placeholder with corresponding value
  SET @v_sql = REPLACE(@v_sql, '@userkey', CONVERT(VARCHAR, @i_userkey))
  SET @v_sql = REPLACE(@v_sql, '@userid', @v_quote + @i_userid + @v_quote)
  SET @v_sql = REPLACE(@v_sql, '@orgentrykey', CONVERT(VARCHAR, @v_orgentrykey))
  SET @v_sql = REPLACE(@v_sql, '@userorgsecurityfilter', @v_orgsecfilter)

  -- DEBUG
  --PRINT @v_sql
  
  SELECT @v_misctype = misctype, @v_fieldformat = fieldformat
  FROM bookmiscitems 
  WHERE misckey = @i_misckey
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 or @v_rowcount = 0 BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = 'could not find misctype for misckey of ' + CAST(@i_misckey AS VARCHAR)
    RETURN
  END

	IF @v_misctype = 6 -- FLOAT
		EXEC execute_calcsql @v_sql, @v_calcvalue OUTPUT
	ELSE IF @v_misctype = 9 -- STRING
		EXEC execute_calcsql_string @v_sql, @v_calcvalue OUTPUT
  
  --declare @test varchar(max)
  --set @test = FORMAT(@v_calcvalue, '#,###')
  --print @test
  
  SELECT @v_calcvalue
  
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

grant execute on qutl_run_misc_calc to public
go