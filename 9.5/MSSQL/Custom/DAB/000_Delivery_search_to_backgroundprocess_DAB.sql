if exists (select * from dbo.sysobjects where id = object_id(N'dbo.DAB_Delivery_search_to_backgroundprocess') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.DAB_Delivery_search_to_backgroundprocess
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE DAB_Delivery_search_to_backgroundprocess
 (@i_userid         varchar(30),
  @i_datadesc       varchar(40),
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*************************************************************************************************************
**  Name: DAB_Delivery_search_to_backgroundprocess
**  Desc: 
** 
**  Auth: Kusum Basra
**  Date: 31 May 2016
*************************************************************************************************************/

DECLARE
  @v_batchkey INT,
  @v_bookkey  INT,
  @v_printingkey INT,
  @v_backgroundprocesskey INT,
  @v_columnorderlist  VARCHAR(255),
  @v_curdatetime  VARCHAR(255),
  @v_error  INT,
  @v_errordesc  VARCHAR(2000),
  @v_jobdesc  VARCHAR(2000),
  @v_jobdescshort VARCHAR(255),
  @v_jobkey INT,
  @v_jobtype_autoverify INT,
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
  @v_startpos INT,
  @v_userkey INT,
  @v_count INT,
  @v_sortorder INT,
  @v_firstkey TINYINT,
  @v_firstkey_value INT   
  
BEGIN
  
  SELECT @v_userkey = userkey FROM qsiusers where UPPER(userid) = UPPER(@i_userid)
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error getting User key from qsiusers.'
    RETURN 
  END
  
  SELECT @v_jobtype_autoverify = datacode FROM gentables WHERE tableid = 543 AND qsicode = 18 --Auto Title Verification Job
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error getting Job Type from gentables 543.'
    RETURN 
  END
  
  SELECT @v_count = COUNT(*) FROM gentables WHERE tableid = 417 AND datadesc = @i_datadesc
  
  IF @v_count = 1 BEGIN
	SELECT @v_datacode = datacode FROM gentables WHERE tableid = 417 AND datadesc = @i_datadesc
	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
	 SET @o_error_code = -1
	 SET @o_error_desc = 'Error getting Date value from gentables 417.'
	 RETURN 
	END
  END
  
  
  -- Mimic the Title search for DB Delivery
  -- '<Item><ComparisonOperator>1</ComparisonOperator><LogicalOperator>AND</LogicalOperator><Value>284</Value></Item></Criteria>'
  -- The value would need to be modified for value based on datacode FROM gentables tableid 417 (CUSTDD1) for date being searched on
  -- in this case datacode 284 corresponds to '1/31/2016'
  
  SET @v_searchcriteria_xml = '<Search><UserKey>' + CONVERT(VARCHAR, @v_userkey) + '</UserKey><SearchType>6</SearchType><ListType>1</ListType><ListDesc>Current Working List</ListDesc><ReturnResults>1</ReturnResults>' +
		'<ReturnResultsWithNoOrgentries>0</ReturnResultsWithNoOrgentries><TitleParticipantSearch>0</TitleParticipantSearch>' + 
		'<ResultsViewKey>0</ResultsViewKey>' +
		'<Criteria><CriteriaSequence>1::1</CriteriaSequence><CriteriaKey>30</CriteriaKey>' +
		'<Item><ComparisonOperator>1</ComparisonOperator><LogicalOperator>AND</LogicalOperator><Value>' + CONVERT(VARCHAR, @v_datacode)+ '</Value></Item></Criteria>' +
		'<Criteria><CriteriaSequence>4::1</CriteriaSequence><CriteriaKey>120</CriteriaKey>' +
		'<Item><ComparisonOperator>1</ComparisonOperator><LogicalOperator>AND</LogicalOperator><Value>1</Value></Item></Criteria>' + 
		'<Criteria><CriteriaSequence>5::1</CriteriaSequence><CriteriaKey>151</CriteriaKey><Item> ' +
		'<ComparisonOperator>1</ComparisonOperator><LogicalOperator>AND</LogicalOperator><Value>N</Value></Item></Criteria></Search>'

  EXEC qse_search_request @v_searchcriteria_xml, @v_listkey OUTPUT, @v_numrows OUTPUT, 
    @v_columnorderlist OUTPUT, @v_stylelist OUTPUT, @v_error OUTPUT, @v_errordesc OUTPUT

  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returned by qse_search_request procedure - could not find titles for DAB Delivery.'
    RETURN 
  END
  
  IF @v_numrows = 0 BEGIN --No  titles found - nothing to process
    RETURN
  END 
  ELSE BEGIN
	print 'Number of rows returned from search: ' + CONVERT(VARCHAR, @v_numrows)
  END    
  
  SET @v_firstkey = 1
  
  DECLARE qse_searchresults_cur CURSOR FOR 
	SELECT key1, key2, sortorder FROM qse_searchresults WHERE listkey = @v_listkey ORDER BY sortorder
	
  OPEN qse_searchresults_cur

  FETCH NEXT FROM qse_searchresults_cur INTO @v_bookkey, @v_printingkey, @v_sortorder
  
  WHILE (@@FETCH_STATUS = 0) 
  BEGIN
      
	EXEC get_next_key 'backgroundprocess', @v_backgroundprocesskey OUTPUT
	
	IF @v_firstkey = 1 BEGIN
		SET @v_firstkey_value = @v_backgroundprocesskey
		SET @v_firstkey = 0
    END
  
	INSERT INTO backgroundprocess(backgroundprocesskey, jobtypecode, storedprocname, reqforgetprodind,key1,integervalue1,
			rowlinkkey, rowlinksortorder,createdate,lastuserid,lastmaintdate)
	VALUES(@v_backgroundprocesskey, @v_jobtype_autoverify,'DAB_auto_title_verification_process',0,@v_bookkey,@v_printingkey,
			@v_firstkey_value,@v_sortorder,GETDATE(),@v_userid,GETDATE())
  
    FETCH NEXT FROM qse_searchresults_cur INTO @v_bookkey, @v_printingkey, @v_sortorder

  END	/* @@FETCH_STATUS=0 - qse_searchresults_cur cursor */
	
  CLOSE qse_searchresults_cur 
  DEALLOCATE qse_searchresults_cur

END 
GO

GRANT EXEC ON DAB_Delivery_search_to_backgroundprocess TO PUBLIC
GO
