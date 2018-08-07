SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_determine_taskviewtriggerkey')
BEGIN
  DROP  Procedure  qutl_determine_taskviewtriggerkey
END
GO

CREATE PROCEDURE dbo.qutl_determine_taskviewtriggerkey
  @i_datetypecode        INT,
  @i_date                datetime = NULL,
  @i_userkey             INT,
  @i_itemtypecode	         INT,
  @i_usageclasscode			     INT,
  @i_orgentrykey            INT,
  @o_taskviewtriggerkey  INT OUTPUT,
  @o_error_code          INT OUTPUT,
  @o_error_desc          VARCHAR(2000) OUTPUT
AS

/**********************************************************************************************
**  Name: qutl_determine_taskviewtriggerkey
**  Desc: This stored procedure will determine taskviewkey  using datetype,  
**		  item type/class, org entry and user. It will then find the corresponding 
**        taskviewttriggerkey based on date
**
**  Auth: Uday A. Khisty
**  Date: 15 June 2015
**
**  @o_error_code -1 will be returned generally when error occurred that prevented generation
**  @o_error_code -2 will indicate a specific warning
**
**********************************************************************************************/

DECLARE		
  @v_cnt				INT,
  @v_rowcount			INT,	
  @v_error_var				INT,
  @v_count				INT,
  @v_taskviewkey		INT,
  @v_taskviewtriggerkey INT,
  @v_quote				VARCHAR(2),
  @v_gentext2			VARCHAR(255),
  @v_datetime_format_code VARCHAR(255),
  @v_userid				VARCHAR(30)

BEGIN

  --initialize variables 
  SET @v_quote = ''''
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_taskviewtriggerkey = 0
  SET @v_datetime_format_code = 101
  
  SELECT @v_userid = userid FROM qsiusers WHERE userkey = @i_userkey
  
  SELECT @v_datetime_format_code = dbo.qutl_get_dateformatcode(@v_userid)
  SELECT @v_error_var = @@ERROR
  IF @v_error_var <> 0 or @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no date format code found: userid = ' + cast(@v_userid AS VARCHAR)   
  END     
  
  SELECT @v_gentext2 = gentext2 
  FROM gentables_ext WHERE tableid = 607 AND datacode = @v_datetime_format_code
  
  IF ISNUMERIC(@v_gentext2) = 1 BEGIN
	SET @v_datetime_format_code = CONVERT(INT, @v_gentext2)
  END  
  
  SELECT TOP(1) @v_taskviewkey = tv.taskviewkey
  FROM taskview tv 
  WHERE tv.triggerdatetypecode = @i_datetypecode AND
		COALESCE(tv.orgentrykey, 0) IN (COALESCE(@i_orgentrykey, 0), 0) AND
		COALESCE(tv.userkey, -9999) IN (COALESCE(@i_userkey, -9999), -1) AND
		COALESCE(tv.itemtypecode, 0) IN (COALESCE(@i_itemtypecode, 0), 0) AND
 		COALESCE(tv.usageclasscode, 0) IN (COALESCE(@i_usageclasscode, 0), 0) AND
 		tv.taskgroupind = 1 
 ORDER BY tv.userkey, tv.itemtypecode, tv.usageclasscode DESC
 		
  
  IF @v_taskviewkey IS NOT NULL AND @v_taskviewkey <> 0 BEGIN
	IF EXISTS(SELECT * FROM taskviewtrigger tvg INNER JOIN taskviewdatetype td ON tvg.taskviewtriggerkey = td.taskviewtriggerkey AND tvg.taskviewkey = td.taskviewkey	
	 WHERE tvg.fromdate <= CONVERT(VARCHAR, @i_date) AND tvg.todate >= CONVERT(VARCHAR, @i_date) AND td.taskviewkey = @v_taskviewkey) BEGIN
	   SELECT TOP(1) @v_taskviewtriggerkey = taskviewtriggerkey
	   FROM taskviewtrigger tvg 
	   WHERE tvg.fromdate <= CONVERT(VARCHAR, @i_date) AND 
			 tvg.todate >= CONVERT(VARCHAR, @i_date) AND
			 tvg.taskviewkey = @v_taskviewkey
	   
	   SET @o_taskviewtriggerkey = @v_taskviewtriggerkey
	END
	ELSE BEGIN
	  SET @o_error_code = -2
	  SET @o_error_desc = 'A Trigger Task Group exists for <i>' + dbo.get_gentables_desc(323, @i_datetypecode, 'long') + '</i>
	   but ' + CONVERT (Varchar(20), @i_date, CONVERT(INT, @v_datetime_format_code)) + ' does not fall within any existing date values.'
	END		
  END   		
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

grant execute on qutl_determine_taskviewtriggerkey  to public
go

