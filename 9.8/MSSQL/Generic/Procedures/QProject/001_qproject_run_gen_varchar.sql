if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qproject_run_gen_varchar]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure [dbo].[qproject_run_gen_varchar]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dbo.qproject_run_gen_varchar
  @i_projectkey         INT,
  @i_related_journalkey INT,
  @i_related_volumekey  INT,
  @i_bookkey            INT,
  @i_printingkey        INT,
  @i_userkey            INT,
  @i_sql                VARCHAR(2000),
  @o_error_code         INT OUTPUT,
  @o_error_desc         VARCHAR(2000) OUTPUT
AS

DECLARE
  @v_printingnum INT,
  @v_quote  CHAR(1),
  @v_sql  VARCHAR(2000),
  @v_userid VARCHAR(30),
  @v_result_value1  VARCHAR(255),
  @v_result_value2  VARCHAR(255),
  @v_result_value3  VARCHAR(255)    
    
BEGIN
  SET @v_quote = CHAR(39)
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT @v_userid = userid
  FROM qsiusers
  WHERE userkey = @i_userkey

  SET @v_printingnum = 0
  IF @i_bookkey > 0 AND @i_printingkey > 0
    SELECT @v_printingnum = printingnum
    FROM printing
    WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey

  -- Replace each parameter placeholder with corresponding value
  SET @v_sql = @i_sql
  SET @v_sql = REPLACE(@v_sql, '@userkey', CONVERT(VARCHAR, @i_userkey))
  SET @v_sql = REPLACE(@v_sql, '@userid', @v_quote + @v_userid + @v_quote)
  SET @v_sql = REPLACE(@v_sql, '@projectkey', CONVERT(VARCHAR, @i_projectkey))
  SET @v_sql = REPLACE(@v_sql, '@journalkey', CONVERT(VARCHAR, @i_related_journalkey))
  SET @v_sql = REPLACE(@v_sql, '@volumekey', CONVERT(VARCHAR, @i_related_volumekey))
  SET @v_sql = REPLACE(@v_sql, '@bookkey', CONVERT(VARCHAR, @i_bookkey))
  SET @v_sql = REPLACE(@v_sql, '@printingkey', CONVERT(VARCHAR, @i_printingkey))
  SET @v_sql = REPLACE(@v_sql, '@printingnum', CONVERT(VARCHAR, @v_printingnum))

  -- DEBUG
  --PRINT @v_sql

  EXEC qutl_execute_prodidsql2 @v_sql, @v_result_value1 OUTPUT, @v_result_value2 OUTPUT, @v_result_value3 OUTPUT,
    @o_error_code OUTPUT, @o_error_desc OUTPUT
  
  SELECT @v_result_value1, @v_result_value2, @v_result_value3
  
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

grant execute on qproject_run_gen_varchar to public
go