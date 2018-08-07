if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qproject_run_generate_prodid]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure [dbo].[qproject_run_generate_prodid]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dbo.qproject_run_generate_prodid
  @i_projectkey   INT,
  @i_orglevelkey  INT,
  @i_orgentrykey  INT,
  @i_userkey      INT,
  @i_sql          VARCHAR(2000),
  @o_new_value    VARCHAR(50) OUTPUT,
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT
AS

DECLARE
  @v_orgentrykey INT,
  @v_quote  CHAR(1),
  @v_sql  VARCHAR(4000),
  @v_userid VARCHAR(30),
  @v_result_value VARCHAR(255)   
    
BEGIN
  SET @v_quote = CHAR(39)
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT @v_userid = userid
  FROM qsiusers
  WHERE userkey = @i_userkey

  -- If orgentrykey was not passed in, get it off the database for the given orglevelkey
  IF @i_orgentrykey > 0
    SET @v_orgentrykey = @i_orgentrykey
  ELSE
  BEGIN
    SELECT @v_orgentrykey = orgentrykey
    FROM taqprojectorgentry
    WHERE taqprojectkey = @i_projectkey AND orglevelkey = @i_orglevelkey
  END

  -- Replace each parameter placeholder with corresponding value
  SET @v_sql = @i_sql
  SET @v_sql = REPLACE(@v_sql, '@userkey', CONVERT(VARCHAR, @i_userkey))
  SET @v_sql = REPLACE(@v_sql, '@userid', @v_quote + @v_userid + @v_quote)
  SET @v_sql = REPLACE(@v_sql, '@projectkey', CONVERT(VARCHAR, @i_projectkey))
  SET @v_sql = REPLACE(@v_sql, '@orglevelkey', CONVERT(VARCHAR, @i_orglevelkey))
  SET @v_sql = REPLACE(@v_sql, '@orgentrykey', CONVERT(VARCHAR, COALESCE(@v_orgentrykey,0)))

  -- DEBUG
  --PRINT @v_sql

  EXEC qutl_execute_prodidsql @v_sql, @v_result_value OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
    
  SET @o_new_value = @v_result_value
 
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

grant execute on qproject_run_generate_prodid to public
go