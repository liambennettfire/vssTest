IF EXISTS (
    SELECT *
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[qutl_create_tmwebprocess_titlelist_job]')
      AND type IN (N'P', N'PC')
    )
  DROP PROCEDURE [dbo].[qutl_create_tmwebprocess_titlelist_job]
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[qutl_create_tmwebprocess_titlelist_job] (
  @i_jobtype_qsicode INTEGER,
  @i_webprocess_qsicode INTEGER,
  @i_title_listkey INTEGER,
  @i_custom_data1 INTEGER,
  @i_custom_data2 INTEGER,
  @i_userid VARCHAR(30),
  @o_error_code INTEGER OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS
/*************************************************************************************************************************
**  Name: qutl_create_tmwebprocess_titlelist_job
**  Desc: This stored creates tmwebprocessinstance and qsijob records based off a title list.
**        The webprocess will utilize the defined procedure for the web process
**
**    Auth: Colman
**    Date: 3/1/2018
**************************************************************************************************************************
**    Change History
**************************************************************************************************************************
**  Date:       Author:   Description:
**  --------    -------   ------------------------------------------------------------------------------------------------
**  
**************************************************************************************************************************/
DECLARE @v_userkey INT,
  @v_jobkey INT,
  @v_batchkey INT,
  @v_processinstancekey INT,
  @v_processcode INT,
  @v_processdesc VARCHAR(MAX),
  @v_bookkey INT,
  @v_printingkey INT,
  @v_jobtypecode INT,
  @v_msgtype_started INT,
  @v_msgtype_error INT,
  @v_msgtype_warning INT,
  @v_msgtype_info INT,
  @v_msgtype_aborted INT,
  @v_msgtype_pending INT,
  @v_msglongdesc VARCHAR(4000),
  @v_msgshortdesc VARCHAR(255),
  @v_clientdefaultvalue INT,
  @v_dateformat_value VARCHAR(40),
  @v_dateformat_conversionvalue INT,
  @v_curdatetime VARCHAR(255),
  @v_datacode INT,
  @v_startpos INT,
  @v_jobdesc VARCHAR(255),
  @v_sp_name VARCHAR(MAX),
  @v_sql NVARCHAR(MAX)

-- exec qutl_trace 'qutl_create_tmwebprocess_titlelist_job',
  -- '@i_jobtype_qsicode', @i_jobtype_qsicode, NULL,
  -- '@i_webprocess_qsicode', @i_webprocess_qsicode, NULL,
  -- '@i_title_listkey', @i_title_listkey, NULL,
  -- '@i_custom_data1', @i_custom_data1, NULL,
  -- '@i_custom_data2', @i_custom_data2, NULL
  
BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT @v_userkey = userkey
  FROM qsiusers
  WHERE userid = @i_userid

  SELECT @v_msgtype_started = datacode
  FROM gentables
  WHERE tableid = 539
    AND qsicode = 1

  SELECT @v_msgtype_error = datacode
  FROM gentables
  WHERE tableid = 539
    AND qsicode = 2

  SELECT @v_msgtype_warning = datacode
  FROM gentables
  WHERE tableid = 539
    AND qsicode = 3

  SELECT @v_msgtype_info = datacode
  FROM gentables
  WHERE tableid = 539
    AND qsicode = 4

  SELECT @v_msgtype_aborted = datacode
  FROM gentables
  WHERE tableid = 539
    AND qsicode = 5

  SELECT @v_msgtype_pending = datacode
  FROM gentables
  WHERE tableid = 539
    AND qsicode = 7

  SELECT @v_jobtypecode = datacode
  FROM gentables
  WHERE tableid = 543
    AND qsicode = @i_jobtype_qsicode

  SELECT @v_processcode = g.datacode, @v_processdesc = g.datadesc, @v_sp_name = x.gentext2
  FROM gentables g, gentables_ext x
  WHERE g.tableid = 669
    AND x.tableid = g.tableid
    AND qsicode = @i_webprocess_qsicode

  SELECT @v_clientdefaultvalue = COALESCE(CAST(clientdefaultvalue AS INT), 1)
  FROM clientdefaults
  WHERE clientdefaultid = 80

  SELECT @v_dateformat_value = LTRIM(RTRIM(UPPER(datadesc))),
    @v_datacode = datacode
  FROM gentables
  WHERE tableid = 607
    AND qsicode = @v_clientdefaultvalue

  SELECT @v_dateformat_conversionvalue = CAST(COALESCE(gentext2, '101') AS INT)
  FROM gentables_ext
  WHERE tableid = 607
    AND datacode = @v_datacode

  SELECT @v_startpos = CHARINDEX(':', CONVERT(VARCHAR(25), CONVERT(VARCHAR(25), GETDATE(), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), - 1) + 1

  SELECT @v_curdatetime = REPLACE(STUFF(CONVERT(VARCHAR(25), CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), CHARINDEX(':', CONVERT(VARCHAR(25), CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), @v_startpos), 3, ''), '  ', ' ')

  SET @v_msglongdesc = 'Job Created ' + @v_curdatetime
  SET @v_msgshortdesc = 'Job Created'
  SET @v_jobdesc = @v_processdesc + ' ' + @v_curdatetime

  EXEC qutl_update_job @v_batchkey OUTPUT,
    @v_jobkey OUTPUT,
    @v_jobtypecode,
    NULL,
    @v_jobdesc,
    @v_processdesc,
    @i_userid,
    0,
    0,
    0,
    @v_msgtype_pending,
    @v_msglongdesc,
    @v_msgshortdesc,
    NULL,
    7,
    @o_error_code OUTPUT,
    @o_error_desc OUTPUT

  EXECUTE get_next_key @i_userid,
    @v_processinstancekey OUTPUT

  INSERT INTO tmwebprocessinstance (
    processinstancekey,
    processcode,
    lastuserid,
    lastmaintdate
    )
  VALUES (
    @v_processinstancekey,
    @v_processcode,
    @i_userid,
    GETDATE()
    )

  DECLARE @bookTable TABLE (bookkey INT, printingkey INT)

  INSERT INTO @bookTable
  SELECT key1, key2
  FROM qse_searchresults 
  WHERE listkey = @i_title_listkey

  DECLARE title_cur CURSOR FAST_FORWARD
  FOR
  SELECT DISTINCT bookkey, printingkey
  FROM @bookTable

  OPEN title_cur

  FETCH NEXT
  FROM title_cur
  INTO @v_bookkey, @v_printingkey

  WHILE (@@FETCH_STATUS = 0)
  BEGIN
    INSERT INTO tmwebprocessinstanceitem (
      processinstancekey,
      sortorder,
      key1,
      key2,
      key3,
      key4,
      key5,
      lastuserid,
      lastmaintdate
      )
    VALUES (
      @v_processinstancekey,
      1,
      @v_jobkey,
      @v_batchkey,
      @v_bookkey,
      @v_printingkey,
      @i_custom_data1,
      @i_userid,
      GETDATE()
      )

    FETCH NEXT
    FROM title_cur
    INTO @v_bookkey, @v_printingkey
  END

  CLOSE title_cur
  DEALLOCATE title_cur

  SELECT @v_jobkey
END
GO

GRANT EXEC
  ON qutl_create_tmwebprocess_titlelist_job
  TO PUBLIC
GO


