if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_taskviewtrigger_daterange') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_taskviewtrigger_daterange
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_taskviewtrigger_daterange
 (@i_taskviewkey		   integer,
  @i_userid				   VARCHAR(30),
  @o_error_code			   integer output,
  @o_error_desc			   varchar(2000) output)
AS


/******************************************************************************
**  Name: qproject_get_taskviewtrigger_daterange
**  Desc: This stored procedure returns the date range for given taskviewkey
**        from the taskviewtrigger table. 
**
**    Auth: Uday A. Khisty
**    Date: 6/19/2015
**
*******************************************************************************/

  DECLARE @v_error_var      INT,
		  @v_rowcount_var   INT,
		  @v_datetime_offset_value INT,
		  @v_gentext2 VARCHAR(255),
		  @v_datetime_format_code VARCHAR(255)
  

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_datetime_format_code = 101
  
  SELECT @v_datetime_format_code = dbo.qutl_get_dateformatcode(@i_userid)
  
  SELECT @v_error_var = @@ERROR
  IF @v_error_var <> 0 or @v_rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no date format code found: userid = ' + cast(@i_userid AS VARCHAR)   
  END   
  
  SELECT @v_gentext2 = gentext2 
  FROM gentables_ext WHERE tableid = 607 AND datacode = @v_datetime_format_code
  
  IF ISNUMERIC(@v_gentext2) = 1 BEGIN
	SET @v_datetime_format_code = CONVERT(INT, @v_gentext2)
  END

  /** get all dates/tasks for this task group/view key **/
  
  SELECT
  t.taskviewtriggerkey,
  CASE
    WHEN t.fromdate IS NOT NULL OR t.fromdate <> '' THEN
      CASE
        WHEN t.fromdate <> t.todate THEN CONVERT(VARCHAR(20), t.fromdate, CONVERT(INT, @v_datetime_format_code)) + ' - ' +  CONVERT(VARCHAR(20), t.todate, CONVERT(INT, @v_datetime_format_code))
        ELSE CONVERT(VARCHAR(20), t.fromdate, CONVERT(INT, @v_datetime_format_code))
      END
    WHEN t.todate IS NOT NULL OR t.todate <> '' THEN CONVERT(VARCHAR(20), t.todate, CONVERT(INT, @v_datetime_format_code))      
    ELSE ''
  END AS daterange
  FROM taskviewtrigger t
  WHERE t.taskviewkey = @i_taskviewkey  

  -- Save the @@ERROR values in local 
  -- variables before they are cleared.
  SELECT @v_error_var = @@ERROR
  IF @v_error_var <> 0 or @v_rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'no data found: taskviewkey = ' + cast(@i_taskviewkey AS VARCHAR)   
  END 

GO

GRANT EXEC ON qproject_get_taskviewtrigger_daterange TO PUBLIC
GO
