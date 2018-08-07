if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcs_auto_cloud_outbox_process') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcs_auto_cloud_outbox_process
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcs_auto_cloud_outbox_process
 (@i_customerkey    integer,
  @i_userkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*************************************************************************************************************
**  Name: qcs_auto_cloud_outbox_process
**  Desc: 
** 
**  Auth: Kate Wiewiora
**  Date: 19 April 2013
*************************************************************************************************************/

DECLARE
  @v_assetkey INT,
  @v_batchkey INT,
  @v_bookkey  INT,
  @v_columnorderlist  VARCHAR(255),
  @v_curdatetime  VARCHAR(255),
  @v_error  INT,
  @v_errordesc  VARCHAR(2000),
  @v_jobdesc  VARCHAR(2000),
  @v_jobdescshort VARCHAR(255),
  @v_jobkey INT,
  @v_jobtype_autosend INT,
  @v_listkey  INT,
  @v_msgdesc  VARCHAR(255),
  @v_msgtype_started  INT,
  @v_msgtype_error  INT,
  @v_numrows  INT,
  @v_partnercontactkey  INT,
  @v_rowcount INT,
  @v_searchcriteria_xml VARCHAR(MAX),
  @v_status_ready INT,
  @v_stylelist  VARCHAR(2000),
  @v_userid VARCHAR(30),
  @v_clientdefaultvalue INT,
  @v_dateformat_value VARCHAR(40),
  @v_dateformat_conversionvalue INT,
  @v_datacode INT,
  @v_startpos INT     
  
BEGIN

  SELECT @v_userid = userid
  FROM qsiusers
  WHERE userkey = @i_userkey
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error getting User ID from qsiusers.'
    RETURN 
  END
  
  SELECT @v_msgtype_started = datacode
  FROM gentables
  WHERE tableid = 539 AND qsicode = 1
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error getting Message Type=Started from gentables 539.'
    RETURN 
  END
  
  SELECT @v_msgtype_error = datacode
  FROM gentables
  WHERE tableid = 539 AND qsicode = 2
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error getting Message Type=Error from gentables 539.'
    RETURN 
  END  
  
  SELECT @v_jobtype_autosend = datacode
  FROM gentables
  WHERE tableid = 543 AND qsicode = 9 --Cloud Outbox Auto Send
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error getting Job Type from gentables 543.'
    RETURN 
  END
    
  SELECT @v_status_ready = datacode
  FROM gentables
  WHERE tableid = 652 AND qsicode = 1 --Ready to Automatically Process
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error getting Cloud Send Process Status from gentables 652.'
    RETURN 
  END  
  
  -- Mimic the CS Outbox search
  SET @v_searchcriteria_xml = '<Search><UserKey>' + CONVERT(VARCHAR, @i_userkey) + '</UserKey><SearchType>26</SearchType><ListType>1</ListType><ReturnResults>0</ReturnResults>' +
    '<Criteria><CriteriaSequence>1::1</CriteriaSequence><CriteriaKey>89</CriteriaKey>' +
    '<Item><ComparisonOperator>1</ComparisonOperator><LogicalOperator>AND</LogicalOperator><Value>' + CONVERT(VARCHAR, @i_customerkey) + '</Value></Item></Criteria>' +
    '<Criteria><CriteriaSequence>2::1</CriteriaSequence><CriteriaKey>240</CriteriaKey>' + 
    '<Item><ComparisonOperator>1</ComparisonOperator><LogicalOperator>AND</LogicalOperator><Value>3</Value></Item></Criteria></Search>'

  EXEC qse_search_request @v_searchcriteria_xml, @v_listkey OUTPUT, @v_numrows OUTPUT, 
    @v_columnorderlist OUTPUT, @v_stylelist OUTPUT, @v_error OUTPUT, @v_errordesc OUTPUT

  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returned by qse_search_request procedure - could not find CS Outbox titles.'
    RETURN 
  END
  
  IF @v_numrows = 0 BEGIN --No CS Outbox titles found - nothing to process
    RETURN
  END
    
  -- Start the Cloud Outbox Auto Send job
  SELECT @v_clientdefaultvalue = COALESCE(CAST(clientdefaultvalue AS INT), 1) FROM clientdefaults WHERE clientdefaultid = 80		
  SELECT @v_dateformat_value = LTRIM(RTRIM(UPPER(datadesc))), @v_datacode = datacode FROM gentables WHERE tableid = 607 AND qsicode = @v_clientdefaultvalue
  SELECT @v_dateformat_conversionvalue = CAST(COALESCE(gentext2, '101') AS INT) FROM gentables_ext WHERE tableid = 607 AND datacode = @v_datacode								  	 
  SELECT @v_startpos = CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), -1) + 1  
  SELECT @v_curdatetime = REPLACE(STUFF(CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), @v_startpos), 3, ''), '  ', ' ')

  SET @v_jobdesc = 'Cloud Outbox Auto Send ' + @v_curdatetime
  SET @v_jobdescshort = 'Cloud Outbox - Auto ' + @v_curdatetime
  SET @v_msgdesc = 'Job Started ' + @v_curdatetime
  SET @v_jobkey = NULL
  SET @v_batchkey = NULL
  EXEC qutl_update_job @v_batchkey OUTPUT, @v_jobkey OUTPUT, @v_jobtype_autosend, 0, @v_jobdesc, @v_jobdescshort, @v_userid, 0, 0, 0,
    @v_msgtype_started, @v_msgdesc, 'Job Started', NULL, 1, @v_error OUTPUT, @v_errordesc OUTPUT

  IF @v_error = -1 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returned by qutl_update_job procedure - could not start Cloud Outbox Auto Send job.'
    RETURN 
  END

  CREATE TABLE #tmp_assetpartners(partnercontactkey int not null,bookkey int not null, assetkey int not null)

  INSERT INTO #tmp_assetpartners
    SELECT ep.partnercontactkey, ep.bookkey, ep.assetkey   
    FROM taqprojectelementpartner ep, taqprojectelement e, qse_searchresults r, book b, customerpartner cp
    WHERE ep.assetkey = e.taqelementkey AND 
      ep.bookkey = r.key1 AND
      ep.bookkey = b.bookkey AND
      b.elocustomerkey = cp.customerkey AND
      ep.partnercontactkey = cp.partnercontactkey AND
      r.listkey = @v_listkey AND
      ep.resendind = 1 AND
      ep.cspartnerstatuscode IN (SELECT datacode FROM gentables WHERE tableid = 639 AND qsicode = 5) AND
      e.elementstatus = (SELECT datacode FROM gentables WHERE tableid = 593 AND qsicode = 3)
    ORDER BY ep.partnercontactkey, ep.bookkey, ep.assetkey

  
   INSERT INTO cloudsendstaging
       (jobkey, bookkey, elementkey, csdisttemplatekey, partnercontactkey, processstatuscode, jobstartind, jobendind, lastuserid, lastmaintdate)
    SELECT @v_jobkey,bookkey,assetkey,NULL,partnercontactkey,@v_status_ready,0,0,@v_userid, getdate()
     FROM #tmp_assetpartners


   DROP TABLE #tmp_assetpartners
 
  -- Update qty processed on qsijob table = # of titles in the cs outbox
  UPDATE qsijob
  SET qtyprocessed = @v_numrows
  WHERE qsijobkey = @v_jobkey
  
  -- Write a Job End row for the Title List Auto Send Job to pass along to other processes so they know when to complete this job
  INSERT INTO cloudsendstaging
    (jobkey, processstatuscode, jobendind, lastuserid, lastmaintdate)
  VALUES
    (@v_jobkey, @v_status_ready, 1, @v_userid, getdate())  

END 
GO

GRANT EXEC ON qcs_auto_cloud_outbox_process TO PUBLIC
GO
