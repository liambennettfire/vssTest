SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_updated_trigger_tasks')
BEGIN
  DROP  Procedure  qutl_get_updated_trigger_tasks
END
GO

CREATE PROCEDURE dbo.qutl_get_updated_trigger_tasks
  @i_listkey				INT,	
  @i_datetypecode			INT,
  @i_activedate				datetime = NULL,
  @i_searchitemtypecode		INT,
  @i_updatefirstprintingkey	INT,
  @i_userkey				INT,
  @o_error_code			    INT OUTPUT,
  @o_error_desc				VARCHAR(2000) OUTPUT
AS

/**********************************************************************************************
**  Name: qutl_get_updated_trigger_tasks
**  Desc: This stored procedure will determine taskviewkey  using datetype,  
**		  item type/class, org entry and user. It will then find the corresponding 
**        taskviewttriggerkey based on date
**
**  Auth: Uday A. Khisty
**  Date: 13 July 2015
**
**  @o_error_code -1 will be returned generally when error occurred that prevented generation
**  @o_error_code -2 will indicate a specific warning
**
**********************************************************************************************/

DECLARE		
  @v_cnt					INT,
  @v_rowcount				INT,	
  @v_error_var				INT,
  @v_count					INT,
  @v_taskviewkey			INT,
  @v_taskviewtriggerkey		INT,
  @v_userid					VARCHAR(30),
  @v_bookkey				INT,
  @v_printingkey			INT,
  @v_taqprojectkey			INT,
  @v_taqtaskkey				INT,
  @v_datetypecode			INT,
  @v_activedate				INT,
  @v_itemtypecodeTitle		INT,
  @v_usageclasscodeTitle	INT,
  @v_itemtypecodeProject	INT,
  @v_usageclasscodeProject	INT,
  @v_orgentrykeyTitle		INT,
  @v_orgentrykeyProject		INT,
  @v_ErrorVar				INT,  
  @v_RowcountVar			INT,
  @v_filterorglevelkey		INT,
  @v_title					VARCHAR(255),
  @v_projectname			VARCHAR(255)
  
BEGIN

  --initialize variables 
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_taskviewtriggerkey = 0
  SET @v_orgentrykeyTitle = 0
  SET @v_orgentrykeyProject = 0
  SELECT @v_filterorglevelkey = filterorglevelkey FROM filterorglevel WHERE filterkey = 32
  
  CREATE TABLE #triggertasks (
    rowstatus VARCHAR(10) NULL,
    taqtaskkey INT NULL,
    taqprojectkey INT NULL,
    datetypecode INT NULL,
    activedate datetime NULL,
    origactivedate datetime NULL,
    datelabel VARCHAR(30) NULL,    
	bookkey int NULL,
    printingkey int NULL,
    title VARCHAR(255) NULL,
    projectname VARCHAR(255) NULL,
    sortorder INT NULL,
    TaskViewTriggerKeyTitle INT NULL,
    TaskViewTriggerKeyProject INT NULL,
    ErrorMessageTitle VARCHAR (MAX) NULL,
    ErrorMessageProject  VARCHAR (MAX) NULL,
    itemtypecodeTitle INT NULL,
    usageclasscodeTitle INT NULL,
    itemtypecodeProject INT NULL,
    usageclasscodeProject INT NULL,
    triggerdateind INT NULL
    )
      
  IF @i_searchitemtypecode = 1 BEGIN  -- Title Search
    IF @i_updatefirstprintingkey = 1 BEGIN
		INSERT INTO #triggertasks
		SELECT 'original' as rowstatus, tpt.taqtaskkey, COALESCE(tpt.taqprojectkey, 0) as taqprojectkey, tpt.datetypecode, 
		@i_activedate as activedate, NULL as origactivedate, dt.datelabel, COALESCE(tpt.bookkey, 0) as bookkey, COALESCE(tpt.printingkey, 0) as printingkey,  
		LTRIM(RTRIM(COALESCE(ct.productnumber, '') + ' ' + ct.title)) as title, cp.projecttitle projectname, dt.sortorder, NULL as TaskViewTriggerKeyTitle, NULL as TaskViewTriggerKeyProject, 
		NULL as ErrorMessageTitle, NULL as ErrorMessageProject, ct.itemtypecode itemtypecodeTitle, 
		ct.usageclasscode usageclasscodeTitle, cp.searchitemcode itemtypecodeProject,  cp.usageclasscode as usageclasscodeProject, dt.triggerdateind 
		FROM taqprojecttask tpt 
		INNER JOIN qse_searchresults r
		ON r.key1 = tpt.bookkey AND
		   r.key2 = (SELECT printingkey FROM printing WHERE bookkey=r.key1 AND printingnum=1)  AND
		   r.listkey = @i_listkey	
		INNER JOIN datetype dt 
		ON tpt.datetypecode = dt.datetypecode AND dt.triggerdateind = 1 and dt.datetypecode = @i_datetypecode
		LEFT OUTER JOIN coreprojectinfo cp 
		ON tpt.taqprojectkey = cp.projectkey 
		LEFT OUTER JOIN coretitleinfo ct 
		ON tpt.bookkey = ct.bookkey AND tpt.printingkey = ct.printingkey 
		LEFT OUTER JOIN printing p 
		ON tpt.bookkey = p.bookkey AND tpt.printingkey = p.printingkey 	 
		WHERE NOT EXISTS (SELECT * FROM qse_updatefeedback u WHERE u.key1 = r.key1 AND u.key2 = r.key2 AND u.userkey = @i_userkey AND u.searchitemcode = @i_searchitemtypecode) AND
			  tpt.printingkey = (SELECT printingkey FROM printing WHERE bookkey=r.key1 AND printingnum=1) 
	END
	ELSE BEGIN
		INSERT INTO #triggertasks
		SELECT 'original' as rowstatus, tpt.taqtaskkey, COALESCE(tpt.taqprojectkey, 0) as taqprojectkey, tpt.datetypecode, 
		@i_activedate as activedate, NULL as origactivedate, dt.datelabel, COALESCE(tpt.bookkey, 0) as bookkey, COALESCE(tpt.printingkey, 0) as printingkey,  
		LTRIM(RTRIM(COALESCE(ct.productnumber, '') + ' ' + ct.title)) as title, cp.projecttitle projectname, dt.sortorder, NULL as TaskViewTriggerKeyTitle, NULL as TaskViewTriggerKeyProject, 
		NULL as ErrorMessageTitle, NULL as ErrorMessageProject, ct.itemtypecode itemtypecodeTitle, 
		ct.usageclasscode usageclasscodeTitle, cp.searchitemcode itemtypecodeProject,  cp.usageclasscode as usageclasscodeProject, dt.triggerdateind  
		FROM taqprojecttask tpt 
		INNER JOIN qse_searchresults r
		ON r.key1 = tpt.bookkey AND
		   r.key2 = tpt.printingkey AND
		   r.listkey = @i_listkey	
		INNER JOIN datetype dt 
		ON tpt.datetypecode = dt.datetypecode AND dt.triggerdateind = 1 and dt.datetypecode = @i_datetypecode
		LEFT OUTER JOIN coreprojectinfo cp 
		ON tpt.taqprojectkey = cp.projectkey 
		LEFT OUTER JOIN coretitleinfo ct 
		ON tpt.bookkey = ct.bookkey AND tpt.printingkey = ct.printingkey 
		LEFT OUTER JOIN printing p 
		ON tpt.bookkey = p.bookkey AND tpt.printingkey = p.printingkey 	
		WHERE NOT EXISTS (SELECT * FROM qse_updatefeedback u WHERE u.key1 = r.key1 AND u.key2 = r.key2 AND u.userkey = @i_userkey AND u.searchitemcode = @i_searchitemtypecode)				
	END
  END
  ELSE IF @i_searchitemtypecode = 3 BEGIN  -- Project Search
    INSERT INTO #triggertasks
	SELECT 'original' as rowstatus, tpt.taqtaskkey, COALESCE(tpt.taqprojectkey, 0) as taqprojectkey, tpt.datetypecode, 
	@i_activedate as activedate, NULL as origactivedate, dt.datelabel, COALESCE(tpt.bookkey, 0) as bookkey, COALESCE(tpt.printingkey, 0) as printingkey,  
	LTRIM(RTRIM(COALESCE(ct.productnumber, '') + ' ' + ct.title)) as title, cp.projecttitle projectname, dt.sortorder, NULL as TaskViewTriggerKeyTitle, NULL as TaskViewTriggerKeyProject, 
	NULL as ErrorMessageTitle, NULL as ErrorMessageProject, ct.itemtypecode itemtypecodeTitle, 
	ct.usageclasscode usageclasscodeTitle, cp.searchitemcode itemtypecodeProject,  cp.usageclasscode as usageclasscodeProject, dt.triggerdateind  
	FROM taqprojecttask tpt 
	INNER JOIN qse_searchresults r
	ON r.key1 = tpt.taqprojectkey AND
	   r.listkey = @i_listkey	
	INNER JOIN datetype dt 
	ON tpt.datetypecode = dt.datetypecode AND dt.triggerdateind = 1 and dt.datetypecode = @i_datetypecode
	INNER JOIN taqproject t ON t.taqprojectkey = tpt.taqprojectkey	
	LEFT OUTER JOIN coreprojectinfo cp 
	ON tpt.taqprojectkey = cp.projectkey 
    LEFT OUTER JOIN coretitleinfo ct 
    ON tpt.bookkey = ct.bookkey AND tpt.printingkey = ct.printingkey 
	LEFT OUTER JOIN printing p 
	ON tpt.bookkey = p.bookkey AND tpt.printingkey = p.printingkey 		
	WHERE t.taqprojectstatuscode NOT IN (select datacode FROM gentables WHERE tableid = 522 and gen2ind = 1)	
	AND NOT EXISTS (SELECT * FROM qse_updatefeedback u WHERE u.key1 = r.key1 AND u.userkey = @i_userkey AND u.searchitemcode = @i_searchitemtypecode)
  END
  
  IF EXISTS(SELECT * FROM #triggertasks) BEGIN
	  DECLARE triggertasks_cur CURSOR FOR
	  select taqtaskkey, taqprojectkey, bookkey, printingkey, datetypecode, 
	   itemtypecodeTitle, usageclasscodeTitle, itemtypecodeProject, usageclasscodeProject,
	   title, projectname
	  from #triggertasks
	  open triggertasks_cur
	  FETCH NEXT FROM triggertasks_cur into @v_taqtaskkey, @v_taqprojectkey, @v_bookkey, @v_printingkey,  @v_datetypecode, 
					  @v_itemtypecodeTitle, @v_usageclasscodeTitle, @v_itemtypecodeProject, @v_usageclasscodeProject,
					  @v_title, @v_projectname  
					  					  
	  WHILE (@@FETCH_STATUS <> -1) BEGIN
	    SET @v_orgentrykeyTitle = 0
		SET @v_orgentrykeyProject = 0
		
		IF @v_bookkey > 0  AND @v_printingkey > 0 BEGIN
		   SET @o_error_code = 0
		   SELECT TOP(1) @v_orgentrykeyTitle = COALESCE(b.orgentrykey, 0)
		   FROM orglevel o 
		   LEFT OUTER JOIN bookorgentry b ON o.orglevelkey = b.orglevelkey AND b.bookkey = @v_bookkey 
		   WHERE  b.orglevelkey = @v_filterorglevelkey
		   
		  EXECUTE qutl_determine_taskviewtriggerkey @i_datetypecode, @i_activedate, @i_userkey, @v_itemtypecodeTitle, @v_usageclasscodeTitle, @v_orgentrykeyTitle, 
			@v_taskviewtriggerkey OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

		  -- Check if search results were returned for the given listkey
		  SELECT @v_ErrorVar = @@ERROR, @v_RowcountVar = @@ROWCOUNT
		  IF @v_ErrorVar <> 0 BEGIN
			  SET @o_error_code = -1
			  SET @o_error_desc = 'Error trying to determing taskviewtriggerkey for listkey ' + CONVERT(VARCHAR, @i_listkey) + ' AND bookkey ='+ CONVERT(VARCHAR, @v_bookkey)  + ' AND printingkey ='+ CONVERT(VARCHAR, @v_printingkey)
			  GOTO ExitHandler			
		  END   
		  		  
		  IF @o_error_code < 0 AND @o_error_desc IS NOT NULL BEGIN
			  SET @o_error_desc = @v_title + ': ' + @o_error_desc	
			  UPDATE #triggertasks
			  SET ErrorMessageTitle = @o_error_desc WHERE taqtaskkey = @v_taqtaskkey
		  END	
		  ELSE IF @v_taskviewtriggerkey > 0 BEGIN
			 SELECT @v_count = COUNT(*) FROM datetype d INNER JOIN taqprojecttask t ON   t.datetypecode = d.datetypecode
				  INNER JOIN taskviewdatetype tvd ON tvd.datetypecode = t.datetypecode AND tvd.taskviewtriggerkey = @v_taskviewtriggerkey
				  LEFT OUTER JOIN coreprojectinfo cp ON t.taqprojectkey = cp.projectkey 
				  LEFT OUTER JOIN coretitleinfo ct ON t.bookkey = ct.bookkey AND t.printingkey = ct.printingkey 				
			 WHERE t.bookkey = @v_bookkey AND t.printingkey = @v_printingkey	

			  -- Check if search results were returned for the given listkey
			  SELECT @v_ErrorVar = @@ERROR, @v_RowcountVar = @@ROWCOUNT
			  
			  IF @v_ErrorVar <> 0 BEGIN
				  SET @o_error_code = -1
				  SET @o_error_desc = 'Error trying to determing taskviewtriggerkey for listkey ' + CONVERT(VARCHAR, @i_listkey) + ' AND bookkey ='+ CONVERT(VARCHAR, @v_bookkey)  + ' AND printingkey ='+ CONVERT(VARCHAR, @v_printingkey)
				  GOTO ExitHandler			
			  END				  
			  
			  IF @v_count > 0 BEGIN
				  UPDATE #triggertasks
				  SET TaskViewTriggerKeyTitle = @v_taskviewtriggerkey WHERE taqtaskkey = @v_taqtaskkey				  
			  END			 	  			 		 
		  END			   
		END	  
		
		IF @v_taqprojectkey > 0 BEGIN
		   SET @o_error_code = 0		
		   SELECT TOP(1) @v_orgentrykeyProject = COALESCE(po.orgentrykey, 0)
		   FROM orglevel o 
		     LEFT OUTER JOIN taqprojectorgentry po ON o.orglevelkey = po.orglevelkey AND po.taqprojectkey = @v_taqprojectkey
		     LEFT OUTER JOIN orgentry e ON po.orgentrykey = e.orgentrykey
		   WHERE o.orglevelkey = @v_filterorglevelkey		
		   
		  EXECUTE qutl_determine_taskviewtriggerkey @i_datetypecode, @i_activedate, @i_userkey, @v_itemtypecodeProject, @v_usageclasscodeProject, @v_orgentrykeyProject, 
			@v_taskviewtriggerkey OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

		  -- Check if search results were returned for the given listkey
		  SELECT @v_ErrorVar = @@ERROR, @v_RowcountVar = @@ROWCOUNT		  
		  IF @v_ErrorVar <> 0 BEGIN
			  SET @o_error_code = -1
			  SET @o_error_desc = 'Error trying to determing taskviewtriggerkey for listkey ' + CONVERT(VARCHAR, @i_listkey) + ' AND taqprojectkey ='+ CONVERT(VARCHAR, @v_taqprojectkey)
			  GOTO ExitHandler				
		  END	
		  		  		 
		  IF @o_error_code < 0 AND @o_error_desc IS NOT NULL BEGIN	
			  SET @o_error_desc = @v_projectname + ': ' + @o_error_desc	  
			  UPDATE #triggertasks
			  SET ErrorMessageProject = @o_error_desc WHERE taqtaskkey = @v_taqtaskkey
		  END	
		  ELSE IF @v_taskviewtriggerkey > 0 BEGIN				
			 SELECT @v_count = COUNT(*) FROM datetype d INNER JOIN taqprojecttask t ON   t.datetypecode = d.datetypecode
				  INNER JOIN taskviewdatetype tvd ON tvd.datetypecode = t.datetypecode AND tvd.taskviewtriggerkey = @v_taskviewtriggerkey
				  LEFT OUTER JOIN coreprojectinfo cp ON t.taqprojectkey = cp.projectkey 
				  LEFT OUTER JOIN coretitleinfo ct ON t.bookkey = ct.bookkey AND t.printingkey = ct.printingkey 				
			 WHERE t.taqprojectkey = @v_taqprojectkey	
			 	
			  -- Check if search results were returned for the given listkey
			  SELECT @v_ErrorVar = @@ERROR, @v_RowcountVar = @@ROWCOUNT
			  
			  IF @v_ErrorVar <> 0 BEGIN
				  SET @o_error_code = -1
				  SET @o_error_desc = 'Error trying to determing taskviewtriggerkey for listkey ' + CONVERT(VARCHAR, @i_listkey) + ' AND bookkey ='+ CONVERT(VARCHAR, @v_bookkey)  + ' AND printingkey ='+ CONVERT(VARCHAR, @v_printingkey)
				  GOTO ExitHandler			
			  END				  
			  
			  IF @v_count > 0 BEGIN
				  UPDATE #triggertasks
				  SET TaskViewTriggerKeyProject = @v_taskviewtriggerkey WHERE taqtaskkey = @v_taqtaskkey				  
			  END			  		  				 
		  END		  		   
		   		   
		END
		
	    FETCH NEXT FROM triggertasks_cur into @v_taqtaskkey, @v_taqprojectkey, @v_bookkey, @v_printingkey,  @v_datetypecode, 
					  @v_itemtypecodeTitle, @v_usageclasscodeTitle, @v_itemtypecodeProject, @v_usageclasscodeProject,
					  @v_title, @v_projectname 
	  END

	  close triggertasks_cur
	  deallocate triggertasks_cur
	  	  	
  END
  
  SELECT * FROM #triggertasks
  
  DROP TABLE #triggertasks
  
  ------------
ExitHandler:
------------
 -- Close criteria cursor if still valid
  IF CURSOR_STATUS('local', 'triggertasks_cur') >= 0 BEGIN
	CLOSE triggertasks_cur
	DEALLOCATE triggertasks_cur
  END

  
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

grant execute on qutl_get_updated_trigger_tasks  to public
go

