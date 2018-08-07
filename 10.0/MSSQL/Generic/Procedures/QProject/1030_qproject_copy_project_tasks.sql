IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_tasks]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_project_tasks]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_tasks]    Script Date: 07/16/2008 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[qproject_copy_project_tasks]
  (@i_copy_projectkey   integer,
  @i_copy_bookkey       integer,
  @i_copy_printingkey   integer,
  @i_new_projectkey		integer,
  @i_new_bookkey      integer,
  @i_new_printingkey  integer,
  @i_copy_elementkey		integer,
  @i_new_elementkey		integer,
  @i_userid				varchar(30),
  @i_copydatagroups_list	varchar(max),
  @i_cleardatagroups_list	varchar(max),
  @o_error_code			integer output,
  @o_error_desc			varchar(2000) output)
AS

/***********************************************************************************************************************
**  Name: [qproject_copy_project_tasks]
**  Desc: This stored procedure copies the details of 1 or all elements to new elements.
**        The project key to copy and the data groups to copy are passed as arguments.
**
**			If you call this procedure from anyplace other than qproject_copy_project,
**			you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Jennifer Hurd
**    Date: 23 June 2008
**
**  7/28/09 - KW - Use same procedure for copy element in projects and in titles.
**  1/11/13 - UK - Changes for temporary table #TempTaqprojectaskKeys
**  3/29/16   Kusum        36178     Keys Table at S&S Getting Close to Max Value
**  05/13/16  Uday		   37359     Allow "Copy from Project" to be a different class from project being created 
**  07/01/16  Uday		   38975     Tasks not copied over to newly created title
**  11/04/16  Uday         41531
**  01/26/17  Uday         38699     Copy Printing Info When Creating a Transmittal Project
**  05/07/18  Colman     51314 Copy tasks performance
***********************************************************************************************************************/

SET @o_error_code = 0
SET @o_error_desc = ''

DECLARE @error_var    INT,
  @rowcount_var INT,
  @newkeycount	int,
  @tobecopiedkey	int,
  @newkey	int,
  @counter		int,
  @newkeycount2	int,
  @tobecopiedkey2	int,
  @newkey2		int,
  @counter2		int,
  @cleardata		char(1),
  @copycontacts	char(1),
  @v_count int,
  @v_copy_elementkey int,
  @v_new_elementkey int,
  @taqprojecttaskoverride_rowcount int,
  @insert_in_taqprojecttask bit,
  @datetypecode int,
  @o_taqtaskkey   int,
  @o_returncode   int,
  @o_restrictioncode int,
  @v_restriction_value_title int,
  @v_restriction_value_work  int,
  @elementtypesubcode_var int,
  @keyind_var int,
  @titlerolecode int,
  @OldTaqProjectFormatKey int,
  @MediaTypeCode int,
  @MediaTypeSubCode int,
  @v_userkey  INT,
  @v_error  INT,
  @v_newprojectitemtype   INT,
  @v_newprojectusageclass	INT	,
  @v_override_taqtaskkey INT,
  @v_override_newkey INT,
  @v_override_scheduleind  TINYINT,
  @v_override_lag INT,
  @v_override_sortorder INT,
  @v_itemtypecode_printing INT,
  @v_usageclasscode_printing INT,
  @v_itemtypecode_copyproject INT,
  @v_usageclasscode_copyproject INT,
  @v_isPrinting INT,
  @v_copy_bookkey INT,
  @v_copy_printingkey INT,
  @v_new_projectkey INT,
  @v_new_bookkey INT, 
  @v_new_printingkey INT	

CREATE TABLE #TempFormatInformation 
  (OldTaqProjectFormatKey INT NULL, 
   NewTaqProjectFormatKey INT NULL,   
   MediaTypeCode INT NULL,
   MediaTypeSubCode INT NULL)

CREATE TABLE #TempDateTypeCodes
  (datetype int null)

create index #TempDateTypeCodes_temp on #TempDateTypeCodes (datetype)

-- This procedure needs temporary table #TempTaqprojectaskKeys declared in the calling procedure 
-- OldTaqtaskkey INT - Corresponds to the value of taqprojecttask.taqtaskkey for the Project / Title
-- NewTaqtaskkey INT - Corresponds to the Newly generated taqtaskkey 
IF Object_id('tempdb..#TempTaqprojectaskKeys') IS NULL 
BEGIN 
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'qproject_copy_project_tasks requires a temporary table #TempTaqprojectaskKeys declared in the calling procedure'   
    GOTO ExitHandler
  END 
END 

if (@i_copy_projectkey is null or @i_copy_projectkey = 0) and (@i_copy_bookkey is null or @i_copy_bookkey = 0)
begin
  SET @o_error_code = -1
  SET @o_error_desc = 'copy projectkey/bookkey not passed to copy tasks (' + cast(@error_var AS VARCHAR) + ')'
  GOTO ExitHandler
end

if (@i_new_projectkey is null or @i_new_projectkey = 0) and (@i_new_bookkey is null or @i_new_bookkey = 0)
begin
  SET @o_error_code = -1
  SET @o_error_desc = 'new projectkey/bookkey not passed to copy tasks (' + cast(@error_var AS VARCHAR) + ')'  
  GOTO ExitHandler
end

-- Get the userkey for the passed User ID
SELECT @v_userkey = userkey
FROM qsiusers
WHERE userid = @i_userid
  
SELECT @v_error = @@ERROR, @v_count = @@ROWCOUNT
IF @v_error <> 0 OR @v_count = 0
  BEGIN
   SET @o_error_code = -1
   SET @o_error_desc = 'Could not get userkey from qsiusers table for UserID: ' + CONVERT(VARCHAR, @i_userid)
   GOTO ExitHandler
END

SET @v_new_projectkey = NULL
SET @v_new_bookkey = NULL
SET @v_new_printingkey = NULL

SELECT @v_itemtypecode_printing = datacode, @v_usageclasscode_printing = datasubcode 
FROM subgentables
WHERE tableid = 550 AND qsicode = 40

-- only want to copy items types that are defined for the new project
IF (@i_new_projectkey > 0)
BEGIN
  SELECT @v_newprojectitemtype = searchitemcode, @v_newprojectusageclass = usageclasscode
  FROM taqproject
  WHERE taqprojectkey = @i_new_projectkey

  IF @v_newprojectitemtype is null or @v_newprojectusageclass = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to copy elements because item type is not populated: taqprojectkey = ' + cast(@i_new_projectkey AS VARCHAR)   
    RETURN
  END
  
  IF @v_newprojectusageclass is null 
    SET @v_newprojectusageclass = 0

  SET @v_new_projectkey = @i_new_projectkey

  IF @v_itemtypecode_printing = @v_newprojectitemtype AND @v_usageclasscode_printing = @v_newprojectusageclass BEGIN
	SET @v_new_projectkey = NULL

	SELECT @v_new_bookkey = bookkey, @v_new_printingkey = printingkey  FROM taqprojectprinting_view WHERE taqprojectkey = @i_new_projectkey
  END
END

DECLARE @GentableItemTypeFiltering TABLE (
  tableid INT,
  datacode INT,
  UNIQUE NONCLUSTERED (tableid, datacode) 
)

INSERT INTO @GentableItemTypeFiltering
SELECT 285, datacode FROM dbo.qutl_get_gentable_itemtype_filtering(285, @v_newprojectitemtype, @v_newprojectusageclass)
INSERT INTO @GentableItemTypeFiltering
SELECT 587, datacode FROM dbo.qutl_get_gentable_itemtype_filtering(587, @v_newprojectitemtype, @v_newprojectusageclass)
INSERT INTO @GentableItemTypeFiltering
SELECT 533, datacode FROM dbo.qutl_get_gentable_itemtype_filtering(533, @v_newprojectitemtype, @v_newprojectusageclass)

if @i_copy_projectkey > 0
begin
  set @cleardata = dbo.find_integer_in_comma_delim_list (@i_cleardatagroups_list, 8)
  set @copycontacts = dbo.find_integer_in_comma_delim_list (@i_copydatagroups_list, 9)
end
else
begin
  set @cleardata = dbo.find_integer_in_comma_delim_list (@i_cleardatagroups_list, 4)
  set @copycontacts = dbo.find_integer_in_comma_delim_list (@i_copydatagroups_list, 5)
end

SET @v_isPrinting = 0   

IF @i_copy_projectkey > 0 BEGIN        
	SELECT @v_itemtypecode_copyproject = searchitemcode, @v_usageclasscode_copyproject = usageclasscode 
	FROM coreprojectinfo
	WHERE projectkey = @i_copy_projectkey
  
	IF @v_itemtypecode_printing = @v_itemtypecode_copyproject AND @v_usageclasscode_printing = @v_usageclasscode_copyproject BEGIN
	  SET @v_isPrinting = 1
	  SELECT  @v_copy_bookkey = bookkey, @v_copy_printingkey = printingkey FROM taqprojectprinting_view WHERE taqprojectkey = @i_copy_projectkey

	  if @v_copy_bookkey is null or @v_copy_bookkey = 0
	  begin
		SET @o_error_code = -1
		SET @o_error_desc = 'copy project key for printing not passed to copy tasks (' + cast(@error_var AS VARCHAR) + '): boookkey = ' + cast(@v_copy_bookkey AS VARCHAR)   
		GOTO ExitHandler
	  end
	END
END

SET @v_copy_elementkey = NULL
SET @v_new_elementkey = NULL 

IF @i_copy_projectkey > 0 BEGIN
  IF @v_isPrinting = 0 BEGIN
	  SELECT @newkeycount = COUNT(*), @tobecopiedkey = MIN(q.taqtaskkey)
	  FROM taqprojecttask q
	  WHERE taqprojectkey = @i_copy_projectkey AND (taqelementkey = @i_copy_elementkey OR taqelementkey IS NULL) 

	  SELECT @v_copy_elementkey = taqelementkey
	  FROM taqprojecttask q
	  WHERE taqprojectkey = @i_copy_projectkey AND q.taqtaskkey = @tobecopiedkey

	  SELECT @titlerolecode = datacode FROM gentables where tableid = 605 AND qsicode = 2 

	  IF EXISTS (SELECT * FROM taqprojecttitle WHERE taqprojectkey = @i_copy_projectkey AND titlerolecode = @titlerolecode) AND @titlerolecode IS NOT NULL BEGIN
		INSERT INTO #TempFormatInformation (OldTaqProjectFormatKey, NewTaqProjectFormatKey, MediaTypeCode, MediaTypeSubCode) 
		SELECT taqprojectformatkey, NULL, mediatypecode, mediatypesubcode FROM taqprojecttitle WHERE taqprojectkey = @i_copy_projectkey AND titlerolecode = @titlerolecode

		IF EXISTS (SELECT * FROM taqprojecttitle WHERE taqprojectkey = @i_new_projectkey AND titlerolecode = @titlerolecode) BEGIN
		  DECLARE #TempFormatInformation_cur CURSOR FOR
			SELECT OldTaqProjectFormatKey, MediaTypeCode, MediaTypeSubCode
			FROM #TempFormatInformation
		  OPEN #TempFormatInformation_cur
		  FETCH NEXT FROM #TempFormatInformation_cur into @OldTaqProjectFormatKey, @MediaTypeCode, @MediaTypeSubCode
		  WHILE (@@FETCH_STATUS <> -1) BEGIN
			IF EXISTS (SELECT * FROM taqprojecttitle WHERE taqprojectkey = @i_new_projectkey AND titlerolecode = @titlerolecode and mediatypecode = @MediaTypeCode and mediatypesubcode = @MediaTypeSubCode) BEGIN
			  UPDATE #TempFormatInformation SET NewTaqProjectFormatKey = (SELECT taqprojectformatkey FROM taqprojecttitle WHERE taqprojectkey = @i_new_projectkey AND titlerolecode = @titlerolecode and mediatypecode = @MediaTypeCode and mediatypesubcode = @MediaTypeSubCode)
			  WHERE OldTaqProjectFormatKey = @OldTaqProjectFormatKey
			END
			FETCH NEXT FROM #TempFormatInformation_cur into @OldTaqProjectFormatKey, @MediaTypeCode, @MediaTypeSubCode
		  END
		  CLOSE #TempFormatInformation_cur
		  DEALLOCATE #TempFormatInformation_cur
		END
	  END

	  INSERT INTO #TempDateTypeCodes
	  SELECT DISTINCT datetypecode FROM dbo.qutl_get_datetype_itemtype_filtering(@v_userkey, 'tasktracking', COALESCE(@i_new_bookkey, 0), COALESCE(@i_new_printingkey, 0), @v_newprojectitemtype, @v_newprojectusageclass)
  END
  ELSE IF @v_isPrinting = 1 BEGIN  -- copying from a Printing Project use bookkey & Printingkey
	  SELECT @newkeycount = COUNT(*), @tobecopiedkey = MIN(q.taqtaskkey)
	  FROM taqprojecttask q
	  WHERE bookkey = @v_copy_bookkey AND printingkey = @v_copy_printingkey AND (taqelementkey = @i_copy_elementkey OR taqelementkey IS NULL) 

	  SELECT @v_copy_elementkey = taqelementkey
	  FROM taqprojecttask q
	  WHERE bookkey = @v_copy_bookkey AND printingkey = @v_copy_printingkey AND q.taqtaskkey = @tobecopiedkey

	  SELECT @titlerolecode = datacode FROM gentables where tableid = 605 AND qsicode = 2 

	  IF EXISTS (SELECT * FROM taqprojecttitle WHERE taqprojectkey = @i_copy_projectkey AND titlerolecode = @titlerolecode) AND @titlerolecode IS NOT NULL BEGIN
		INSERT INTO #TempFormatInformation (OldTaqProjectFormatKey, NewTaqProjectFormatKey, MediaTypeCode, MediaTypeSubCode) 
		SELECT taqprojectformatkey, NULL, mediatypecode, mediatypesubcode FROM taqprojecttitle WHERE taqprojectkey = @i_copy_projectkey AND titlerolecode = @titlerolecode

		IF EXISTS (SELECT * FROM taqprojecttitle WHERE taqprojectkey = @i_new_projectkey AND titlerolecode = @titlerolecode) BEGIN
		  DECLARE #TempFormatInformation_cur CURSOR FOR
			SELECT OldTaqProjectFormatKey, MediaTypeCode, MediaTypeSubCode
			FROM #TempFormatInformation
		  OPEN #TempFormatInformation_cur
		  FETCH NEXT FROM #TempFormatInformation_cur into @OldTaqProjectFormatKey, @MediaTypeCode, @MediaTypeSubCode
		  WHILE (@@FETCH_STATUS <> -1) BEGIN
			IF EXISTS (SELECT * FROM taqprojecttitle WHERE taqprojectkey = @i_new_projectkey AND titlerolecode = @titlerolecode and mediatypecode = @MediaTypeCode and mediatypesubcode = @MediaTypeSubCode) BEGIN
			  UPDATE #TempFormatInformation SET NewTaqProjectFormatKey = (SELECT taqprojectformatkey FROM taqprojecttitle WHERE taqprojectkey = @i_new_projectkey AND titlerolecode = @titlerolecode and mediatypecode = @MediaTypeCode and mediatypesubcode = @MediaTypeSubCode)
			  WHERE OldTaqProjectFormatKey = @OldTaqProjectFormatKey
			END
			FETCH NEXT FROM #TempFormatInformation_cur into @OldTaqProjectFormatKey, @MediaTypeCode, @MediaTypeSubCode
		  END
		  CLOSE #TempFormatInformation_cur
		  DEALLOCATE #TempFormatInformation_cur
		END
	  END

	  INSERT INTO #TempDateTypeCodes
	  SELECT DISTINCT datetypecode FROM dbo.qutl_get_datetype_itemtype_filtering(@v_userkey, 'tasktracking', COALESCE(@i_new_bookkey, 0), COALESCE(@i_new_printingkey, 0), @v_newprojectitemtype, @v_newprojectusageclass)
  END
END
ELSE BEGIN
  SELECT @newkeycount = COUNT(*), @tobecopiedkey = MIN(q.taqtaskkey)
  FROM taqprojecttask q
  WHERE bookkey = @i_copy_bookkey AND printingkey = @i_copy_printingkey AND (taqelementkey = @i_copy_elementkey OR taqelementkey IS NULL) 

  SELECT @v_copy_elementkey = taqelementkey
  FROM taqprojecttask q
  WHERE bookkey = @i_copy_bookkey AND printingkey = @i_copy_printingkey AND q.taqtaskkey = @tobecopiedkey
END 

--PRINT '@i_copy_projectkey=' + convert(varchar, @i_copy_projectkey)
--PRINT '@i_copy_bookkey=' + convert(varchar, @i_copy_bookkey)
--PRINT '@i_new_projectkey=' + convert(varchar, @i_new_projectkey)
--PRINT '@i_new_bookkey=' + convert(varchar, @i_new_bookkey)
--PRINT '@i_copy_elementkey=' + convert(varchar, @i_copy_elementkey)
--PRINT '@i_new_elementkey=' + convert(varchar, @i_new_elementkey)
--PRINT '@tobecopiedkey=' + convert(varchar, @tobecopiedkey)
  
SET @counter = 1
WHILE @counter <= @newkeycount
BEGIN

  IF @v_copy_elementkey IS NULL    
    SET @v_new_elementkey = NULL
  ELSE
    SET @v_new_elementkey = @i_new_elementkey

  SET @insert_in_taqprojecttask = 1
  IF @v_copy_elementkey IS NOT NULL BEGIN
    IF NOT EXISTS (SELECT * FROM #TempTaqprojectaskKeys t WHERE t.OldTaqtaskkey = @tobecopiedkey) BEGIN
      EXEC get_next_key 'taqprojecttask', @newkey OUTPUT
      INSERT INTO #TempTaqprojectaskKeys (OldTaqtaskkey, NewTaqtaskkey) VALUES (@tobecopiedkey, @newkey)
    END
    ELSE BEGIN
      SELECT @newkey = NewTaqtaskkey FROM #TempTaqprojectaskKeys t WHERE t.OldTaqtaskkey = @tobecopiedkey
      SET @insert_in_taqprojecttask = 0

	  IF NOT EXISTS(SELECT * FROM taqprojecttask WHERE taqtaskkey = @newkey)
	  BEGIN
		SET @insert_in_taqprojecttask = 1
	  END
    END
    
    --PRINT '@insert_in_taqprojecttask=' + convert(varchar, @insert_in_taqprojecttask)
    --PRINT '@newkey=' + convert(varchar, @newkey)

    SET @o_returncode = 0
    SET @o_taqtaskkey = 0
    SET @datetypecode = NULL

    IF @i_copy_projectkey > 0 BEGIN
      IF @v_isPrinting = 0 BEGIN    
		  SELECT @datetypecode = datetypecode, @keyind_var = keyind 
		  FROM taqprojecttask
		  WHERE taqprojectkey = @i_copy_projectkey AND
			taqtaskkey = @tobecopiedkey AND
			(taqelementkey = @i_copy_elementkey OR taqelementkey IS NULL)
      END 
	  ELSE IF @v_isPrinting = 1 BEGIN  -- copying from a Printing Project use bookkey & Printingkey
		  SELECT @datetypecode = datetypecode, @keyind_var = keyind 
		  FROM taqprojecttask
		  WHERE bookkey = @v_copy_bookkey AND printingkey = @v_copy_printingkey AND
			taqtaskkey = @tobecopiedkey AND
			(taqelementkey = @i_copy_elementkey OR taqelementkey IS NULL)
	  END

      select @v_restriction_value_work = relateddatacode
      from gentablesitemtype
      where tableid = 323
        and datacode = @datetypecode
        and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
        and itemtypecode = (select searchitemcode from coreprojectinfo where projectkey = @i_new_projectkey)
        and itemtypesubcode in (select usageclasscode from coreprojectinfo where projectkey = @i_new_projectkey)

      IF (@i_new_projectkey IS NOT NULL AND @i_new_projectkey > 0 AND @datetypecode IS NOT NULL) BEGIN
        exec dbo.qutl_check_for_restrictions @datetypecode, NULL, NULL, @i_new_projectkey, NULL, NULL, NULL, 
          @o_taqtaskkey output, @o_returncode output, @o_restrictioncode output, @o_error_code output, @o_error_desc output
        IF @o_error_code <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Unable to check for title task restrictions: ' + @o_error_desc
          GOTO ExitHandler
        END
        IF (@o_returncode = 3 AND @v_restriction_value_work = 3 AND @keyind_var  = 0) BEGIN
          SET @o_returncode = 0
        END
      END 
    
      IF @o_returncode = 0 BEGIN 
        IF @insert_in_taqprojecttask = 1 BEGIN
		  IF @v_isPrinting = 0 BEGIN
			  INSERT INTO taqprojecttask
				(taqtaskkey, taqprojectkey, taqelementkey, bookkey, printingkey, orgentrykey, 
				globalcontactkey, rolecode, globalcontactkey2, rolecode2, 
				scheduleind, stagecode, duration, datetypecode, keyind, 
				activedate, actualind, originaldate, 
				taqtasknote, decisioncode, paymentamt, taqtaskqty, sortorder, 
				taqprojectformatkey, lastuserid, lastmaintdate, lockind,
				startdate,startdateactualind,lag, transactionkey)
			  SELECT @newkey, @v_new_projectkey, @v_new_elementkey, @v_new_bookkey, @v_new_printingkey, orgentrykey, 
				CASE WHEN @copycontacts = 'N' THEN NULL ELSE globalcontactkey END, 
					  CASE
						WHEN (COALESCE(rolecode, 0) = 0 OR rolecode NOT IN (SELECT datacode FROM @GentableItemTypeFiltering WHERE tableid = 285))
						THEN NULL 
						ELSE rolecode		  
					  END as rolecode,
					  CASE WHEN @copycontacts = 'N' THEN NULL ELSE globalcontactkey2 END, 
					  CASE
						WHEN (COALESCE(rolecode2, 0) = 0 OR rolecode2 NOT IN (SELECT datacode FROM @GentableItemTypeFiltering WHERE tableid = 285))
						THEN NULL 
						ELSE rolecode2				
					  END as rolecode2,  
					  scheduleind, 
					  CASE
						WHEN (COALESCE(stagecode, 0) = 0 OR stagecode NOT IN (SELECT datacode FROM @GentableItemTypeFiltering WHERE tableid = 587))
						THEN NULL 
						ELSE stagecode				
					  END as stagecode, 
					  duration, datetypecode, keyind, 
					  CASE WHEN @cleardata = 'Y' THEN NULL ELSE activedate END, 
					  CASE WHEN @cleardata = 'Y' THEN NULL ELSE actualind END, 
					  CASE WHEN @cleardata = 'Y' THEN NULL ELSE originaldate END,
					  taqtasknote, 
					  CASE
						WHEN (COALESCE(decisioncode, 0) = 0 OR decisioncode NOT IN (SELECT datacode FROM @GentableItemTypeFiltering WHERE tableid = 533))
						THEN NULL 
						ELSE decisioncode		  
					  END as decisioncode, 
				paymentamt, taqtaskqty, sortorder, 
				case
				  when COALESCE(taqprojectformatkey, 0) > 0 AND @titlerolecode IS NOT NULL THEN
				  (SELECT COALESCE(NewTaqProjectFormatKey, NULL) FROM #TempFormatInformation t WHERE t.OldTaqProjectFormatKey = taqprojectformatkey)
				  else NULL
				end,
				@i_userid, getdate(), lockind,
				startdate,startdateactualind,lag, transactionkey
			  FROM taqprojecttask, #TempDateTypeCodes
			  WHERE  taqprojecttask.datetypecode = #TempDateTypeCodes.datetype and 
				taqprojectkey = @i_copy_projectkey AND
				taqtaskkey = @tobecopiedkey AND
				(taqelementkey = @i_copy_elementkey OR taqelementkey IS NULL) 

			  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			  IF @error_var <> 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'copy/insert into taqprojecttask failed (' + cast(@error_var AS VARCHAR) + '): taqtaskkey = ' + cast(@tobecopiedkey AS VARCHAR)   
				GOTO ExitHandler
			  END 
		  END
		  ELSE IF @v_isPrinting = 1 BEGIN  -- copying from a Printing Project use bookkey & Printingkey
			  INSERT INTO taqprojecttask
				(taqtaskkey, taqprojectkey, taqelementkey, bookkey, printingkey, orgentrykey, 
				globalcontactkey, rolecode, globalcontactkey2, rolecode2, 
				scheduleind, stagecode, duration, datetypecode, keyind, 
				activedate, actualind, originaldate, 
				taqtasknote, decisioncode, paymentamt, taqtaskqty, sortorder, 
				taqprojectformatkey, lastuserid, lastmaintdate, lockind,
				startdate,startdateactualind,lag, transactionkey)
			  SELECT @newkey, @v_new_projectkey, @v_new_elementkey, @v_new_bookkey, @v_new_printingkey, orgentrykey, 
				CASE WHEN @copycontacts = 'N' THEN NULL ELSE globalcontactkey END, 
					  CASE
						WHEN (COALESCE(rolecode, 0) = 0 OR rolecode NOT IN (SELECT datacode FROM @GentableItemTypeFiltering WHERE tableid = 285))
						THEN NULL 
						ELSE rolecode		  
					  END as rolecode,
					  CASE WHEN @copycontacts = 'N' THEN NULL ELSE globalcontactkey2 END, 
					  CASE
						WHEN (COALESCE(rolecode2, 0) = 0 OR rolecode2 NOT IN (SELECT datacode FROM @GentableItemTypeFiltering WHERE tableid = 285))
						THEN NULL 
						ELSE rolecode2				
					  END as rolecode2,  
					  scheduleind, 
					  CASE
						WHEN (COALESCE(stagecode, 0) = 0 OR stagecode NOT IN (SELECT datacode FROM @GentableItemTypeFiltering WHERE tableid = 587))
						THEN NULL 
						ELSE stagecode				
					  END as stagecode, 
					  duration, datetypecode, keyind, 
					  CASE WHEN @cleardata = 'Y' THEN NULL ELSE activedate END, 
					  CASE WHEN @cleardata = 'Y' THEN NULL ELSE actualind END, 
					  CASE WHEN @cleardata = 'Y' THEN NULL ELSE originaldate END,
					  taqtasknote, 
					  CASE
						WHEN (COALESCE(decisioncode, 0) = 0 OR decisioncode NOT IN (SELECT datacode FROM @GentableItemTypeFiltering WHERE tableid = 533))
						THEN NULL 
						ELSE decisioncode		  
					  END as decisioncode, 
				paymentamt, taqtaskqty, sortorder, 
				case
				  when COALESCE(taqprojectformatkey, 0) > 0 AND @titlerolecode IS NOT NULL THEN
				  (SELECT COALESCE(NewTaqProjectFormatKey, NULL) FROM #TempFormatInformation t WHERE t.OldTaqProjectFormatKey = taqprojectformatkey)
				  else NULL
				end,
				@i_userid, getdate(), lockind,
				startdate,startdateactualind,lag, transactionkey
			  FROM taqprojecttask, #TempDateTypeCodes
			  WHERE  taqprojecttask.datetypecode = #TempDateTypeCodes.datetype and 
				bookkey = @v_copy_bookkey AND printingkey = @v_copy_printingkey AND
				taqtaskkey = @tobecopiedkey AND
				(taqelementkey = @i_copy_elementkey OR taqelementkey IS NULL) 

			  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			  IF @error_var <> 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'copy/insert into taqprojecttask failed (' + cast(@error_var AS VARCHAR) + '): taqtaskkey = ' + cast(@tobecopiedkey AS VARCHAR)   
				GOTO ExitHandler
			  END 
		  END
        END --@insert_in_taqprojecttask=1

        SELECT @v_count = COUNT(*)
        FROM taqprojecttaskoverride
        WHERE taqtaskkey = @tobecopiedkey AND COALESCE(taqelementkey, 0) = 0

        IF @v_count > 0 BEGIN
          INSERT INTO taqprojecttaskoverride
            (taqtaskkey, taqelementkey, scheduleind, lag, sortorder, lastuserid, lastmaintdate)
          SELECT 
            @newkey, NULL, scheduleind, lag, sortorder, @i_userid, getdate()
          FROM taqprojecttaskoverride
          WHERE taqtaskkey = @tobecopiedkey AND COALESCE(taqelementkey, 0) = 0

          SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
          IF @error_var <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'copy/insert into taqprojecttaskoverride failed (' + cast(@error_var AS VARCHAR) + '): taqtaskkey = ' + cast(@tobecopiedkey AS VARCHAR)   
            GOTO ExitHandler
          END 
        END 
      END	--IF @o_returncode = 0
    END -- @i_copy_projectkey > 0
    ELSE BEGIN

      SELECT @datetypecode = datetypecode, @keyind_var = keyind 
      FROM taqprojecttask
      WHERE bookkey = @i_copy_bookkey AND printingkey = @i_copy_printingkey AND
        taqtaskkey = @tobecopiedkey AND
        (taqelementkey = @i_copy_elementkey OR taqelementkey IS NULL)
      
      select @v_restriction_value_title = relateddatacode
      from gentablesitemtype
      where tableid = 323
        and datacode = @datetypecode
        and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
        and itemtypecode = 1
        and itemtypesubcode in (select usageclasscode from coretitleinfo where bookkey = @i_new_bookkey and printingkey = @i_new_printingkey)
      
      IF (@i_new_bookkey IS NOT NULL AND @i_new_bookkey > 0 AND @datetypecode IS NOT NULL) BEGIN
        exec dbo.qutl_check_for_restrictions @datetypecode, @i_new_bookkey, @i_new_printingkey, NULL, NULL, NULL, NULL, 
          @o_taqtaskkey output, @o_returncode output, @o_restrictioncode output, @o_error_code output, @o_error_desc output
        IF @o_error_code <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Unable to check for title task restrictions: ' + @o_error_desc
          GOTO ExitHandler
        END
        IF (@o_returncode = 2 AND @v_restriction_value_title = 3 AND @keyind_var  = 0) BEGIN
          SET @o_returncode = 0
        END
      END 

      --PRINT '@datetypecode=' + convert(varchar, @datetypecode)
      --PRINT '@v_restriction_value_title=' + convert(varchar, @v_restriction_value_title)
      --PRINT '@o_returncode=' + convert(varchar, @o_returncode)
      
      IF @o_returncode = 0 BEGIN 
        IF @insert_in_taqprojecttask = 1 BEGIN
          INSERT INTO taqprojecttask
            (taqtaskkey, taqprojectkey, taqelementkey, bookkey, printingkey, orgentrykey, 
            globalcontactkey, rolecode, globalcontactkey2, rolecode2, 
            scheduleind, stagecode, duration, datetypecode, keyind,
            activedate, actualind, originaldate, 
            taqtasknote, decisioncode, paymentamt, taqtaskqty, sortorder, 
            taqprojectformatkey, lastuserid, lastmaintdate, lockind,
            startdate,startdateactualind,lag, transactionkey)
          SELECT @newkey, taqprojectkey, @v_new_elementkey, @i_new_bookkey, @i_new_printingkey, orgentrykey, 
            CASE WHEN @copycontacts = 'N' THEN NULL ELSE globalcontactkey END, rolecode, 
            CASE WHEN @copycontacts = 'N' THEN NULL ELSE globalcontactkey2 END, rolecode2, 
            scheduleind, stagecode, duration, datetypecode, keyind,
            CASE WHEN @cleardata = 'Y' THEN NULL ELSE activedate END, 
            CASE WHEN @cleardata = 'Y' THEN NULL ELSE actualind END, 
            CASE WHEN @cleardata = 'Y' THEN NULL ELSE originaldate END,
            taqtasknote, decisioncode, paymentamt, taqtaskqty, sortorder, 
            taqprojectformatkey, @i_userid, getdate(), lockind,
            startdate,startdateactualind,lag, transactionkey
          FROM taqprojecttask
          WHERE bookkey = @i_copy_bookkey AND printingkey = @i_copy_printingkey AND
            taqtaskkey = @tobecopiedkey AND
            (taqelementkey = @i_copy_elementkey OR taqelementkey IS NULL)

          SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
          IF @error_var <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'copy/insert into taqprojecttask failed (' + cast(@error_var AS VARCHAR) + '): taqtaskkey = ' + cast(@tobecopiedkey AS VARCHAR)   
            GOTO ExitHandler
          END 
        END --IF @insert_in_taqprojecttask = 1

        SELECT @v_count = COUNT(*)
        FROM taqprojecttaskoverride
        WHERE taqtaskkey = @tobecopiedkey AND COALESCE(taqelementkey, 0) = 0

        --PRINT 'override count=' + convert(varchar, @v_count)

        IF @v_count > 0 BEGIN
          INSERT INTO taqprojecttaskoverride
            (taqtaskkey, taqelementkey, scheduleind, lag, sortorder, lastuserid,lastmaintdate)
          SELECT 
            @newkey, NULL, scheduleind, lag, sortorder, @i_userid, getdate()
          FROM taqprojecttaskoverride
          WHERE taqtaskkey = @tobecopiedkey AND COALESCE(taqelementkey, 0) = 0

          SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
          IF @error_var <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'copy/insert into taqprojecttaskoverride failed (' + cast(@error_var AS VARCHAR) + '): taqtaskkey = ' + cast(@tobecopiedkey AS VARCHAR)   
            GOTO ExitHandler
          END 
        END
      END --IF @o_returncode = 0
    END --IF @i_copy_projectkey = 0
  END --IF @v_copy_elementkey IS NOT NULL
  
  SET @counter = @counter + 1

  IF @i_copy_projectkey > 0 BEGIN
    IF @v_isPrinting = 0 BEGIN
		SELECT @tobecopiedkey = MIN(q.taqtaskkey)
		FROM taqprojecttask q
		WHERE taqprojectkey = @i_copy_projectkey AND (taqelementkey = @i_copy_elementkey OR taqelementkey IS NULL) AND q.taqtaskkey > @tobecopiedkey

		SELECT @v_copy_elementkey = taqelementkey
		FROM taqprojecttask q
		WHERE taqprojectkey = @i_copy_projectkey AND q.taqtaskkey = @tobecopiedkey
	END
	ELSE IF @v_isPrinting = 1 BEGIN
		SELECT @tobecopiedkey = MIN(q.taqtaskkey)
		FROM taqprojecttask q
		WHERE bookkey = @v_copy_bookkey AND printingkey = @v_copy_printingkey AND (taqelementkey = @i_copy_elementkey OR taqelementkey IS NULL) AND q.taqtaskkey > @tobecopiedkey

		SELECT @v_copy_elementkey = taqelementkey
		FROM taqprojecttask q
		WHERE bookkey = @v_copy_bookkey AND printingkey = @v_copy_printingkey AND q.taqtaskkey = @tobecopiedkey
	END
  END
  ELSE BEGIN
    SELECT @tobecopiedkey = MIN(q.taqtaskkey)
    FROM taqprojecttask q
    WHERE bookkey = @i_copy_bookkey AND printingkey = @i_copy_printingkey AND (taqelementkey = @i_copy_elementkey OR taqelementkey IS NULL) AND q.taqtaskkey > @tobecopiedkey

    SELECT @v_copy_elementkey = taqelementkey
    FROM taqprojecttask q
    WHERE bookkey = @i_copy_bookkey AND printingkey = @i_copy_printingkey AND q.taqtaskkey = @tobecopiedkey
  END

END --WHILE @counter <= @newkeycount

IF COALESCE(@i_new_elementkey, 0) > 0 BEGIN
	DECLARE taqprojecttaskoverride_cur CURSOR FOR 
		SELECT taqtaskkey, scheduleind,lag,sortorder
		FROM taqprojecttaskoverride
		WHERE taqelementkey = @i_copy_elementkey
		                           
		OPEN taqprojecttaskoverride_cur 
		FETCH taqprojecttaskoverride_cur INTO @v_override_taqtaskkey, @v_override_scheduleind,@v_override_lag,@v_override_sortorder

		WHILE @@fetch_status = 0 BEGIN

			IF NOT EXISTS (SELECT * FROM #TempTaqprojectaskKeys t WHERE t.OldTaqtaskkey = @v_override_taqtaskkey) BEGIN
				EXEC get_next_key 'taqprojecttask', @v_override_newkey OUTPUT
				INSERT INTO #TempTaqprojectaskKeys (OldTaqtaskkey, NewTaqtaskkey) VALUES (@v_override_taqtaskkey, @v_override_newkey)
			END
			ELSE BEGIN
				SELECT @v_override_newkey = NewTaqtaskkey FROM #TempTaqprojectaskKeys t WHERE t.OldTaqtaskkey = @v_override_taqtaskkey
			END

			insert into taqprojecttaskoverride
			(taqtaskkey, taqelementkey, scheduleind, lag, sortorder, lastuserid, lastmaintdate)
			values
			(@v_override_newkey, @v_new_elementkey, @v_override_scheduleind,@v_override_lag,@v_override_sortorder,@i_userid, getdate())

			SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			IF @error_var <> 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'copy/insert into taqprojecttaskoverride failed (' + cast(@error_var AS VARCHAR) + '): taqtaskkey = ' + cast(@v_override_taqtaskkey AS VARCHAR)   
				GOTO ExitHandler
			END 
				                                            
			FETCH taqprojecttaskoverride_cur INTO @v_override_taqtaskkey, @v_override_scheduleind,@v_override_lag,@v_override_sortorder      
		END
	CLOSE taqprojecttaskoverride_cur 
	DEALLOCATE taqprojecttaskoverride_cur
END

------------
ExitHandler:
------------
  DROP TABLE #TempFormatInformation
  DROP TABLE #TempDateTypeCodes

RETURN