if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qutl_get_misc_calcsql]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure [dbo].[qutl_get_misc_calcsql]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Name: qutl_get_misc_calcsql
**  Desc: Get org filtered misccalc sql
**
**  Auth: Colman
**  Date: 1/11/2018
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
*******************************************************************************/

CREATE PROCEDURE dbo.qutl_get_misc_calcsql
  @i_misckey  INT,
  @i_userkey  INT,
  @i_userid   VARCHAR(30),
  @o_sql      VARCHAR(max) OUTPUT,
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT
AS

BEGIN
 DECLARE
    @v_error  INT,
    @v_misctype INT,
    @v_orgentrykey  INT,
    @v_orglevel INT,
    @v_orgsecfilter  VARCHAR(max),
    @v_quote  CHAR(1),
    @v_rowcount INT,    
    @v_sql  VARCHAR(max)

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
  SET @v_sql = REPLACE(@v_sql, '@misckey', CONVERT(VARCHAR, @i_misckey))


  SELECT @o_sql = @v_sql
  
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

grant execute on qutl_get_misc_calcsql to public
go