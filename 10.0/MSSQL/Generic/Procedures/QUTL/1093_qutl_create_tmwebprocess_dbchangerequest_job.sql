IF EXISTS (
    SELECT *
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[qutl_create_tmwebprocess_dbchangerequest_job]')
      AND type IN (N'P', N'PC')
    )
  DROP PROCEDURE [dbo].[qutl_create_tmwebprocess_dbchangerequest_job]
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[qutl_create_tmwebprocess_dbchangerequest_job] (
  @i_jobtype_qsicode INTEGER,
  @i_webprocess_qsicode INTEGER,
  @i_request_xml VARCHAR(MAX),
  @i_userid VARCHAR(30),
  @o_error_code INTEGER OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS
/*************************************************************************************************************************
**  Name: qutl_create_tmwebprocess_dbchangerequest_job
**  Desc: This stored creates tmwebprocessinstance and qsijob records for a background dbchange request.
**        The webprocess will utilize the defined procedure for the web process (gentables_ext 669 - gentext2)
**
**    Auth: Colman
**    Date: 3/15/2018
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
  @v_msgtype_aborted INT,
  @v_msgtype_pending INT,
  @v_msglongdesc VARCHAR(4000),
  @v_msgshortdesc VARCHAR(255),
  @v_curdatetime VARCHAR(255),
  @v_jobdesc VARCHAR(255),
  @v_sp_name VARCHAR(MAX),
  @v_sql NVARCHAR(MAX)

 --exec qutl_trace 'qutl_create_tmwebprocess_dbchangerequest_job',
 --  '@i_jobtype_qsicode', @i_jobtype_qsicode, NULL,
 --  '@i_webprocess_qsicode', @i_webprocess_qsicode, NULL,
 --  '@i_request_xml', NULL, @i_request_xml
  
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

  SELECT @v_curdatetime = dbo.qutl_get_formatted_jobdate(GETDATE())

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

    INSERT INTO tmwebprocessinstanceitem (
      processinstancekey,
      sortorder,
      key1,
      key2,
      text1,
      lastuserid,
      lastmaintdate
      )
    VALUES (
      @v_processinstancekey,
      1,
      @v_jobkey,
      @v_batchkey,
      @i_request_xml,
      @i_userid,
      GETDATE()
      )
  SELECT @v_jobkey
END
GO

GRANT EXEC
  ON qutl_create_tmwebprocess_dbchangerequest_job
  TO PUBLIC
GO


