IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_nonelement_tasks]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_project_nonelement_tasks]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_nonelement_tasks]    Script Date: 07/16/2008 10:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project_nonelement_tasks]
		(@i_copy_projectkey     integer,
		@i_new_projectkey		integer,
		@i_userid				varchar(30),
		@i_copydatagroups_list	varchar(max),
		@i_cleardatagroups_list	varchar(max),
		@o_error_code			integer output,
		@o_error_desc			varchar(2000) output)
AS

/**********************************************************************************************************************
**  Name: [qproject_copy_project_nonelement_tasks]
**  Desc: This stored procedure copies all tasks that are not associated with an 
**        element to a new project being created with the template as a basis.
**
**  If you call this procedure from anyplace other than qproject_copy_project,
**  you must do your own transaction/commit/rollbacks on return from this procedure.
**
***********************************************************************************************************************
**    Change History
***********************************************************************************************************************
**    Date:       Author:      Case #:   Description:
**    --------    --------     -------   --------------------------------------
**   04/06/2016   Kusum        36178     Keys Table at S&S Getting Close to Max Value
**   05/09/2016   Uday		   37359     Allow "Copy from Project" to be a different class from project being created  
**   07/15/2016   Uday         39219     Error generated adding advanced title
**   01/26/2017   Uday         38699     Copy Printing Info When Creating a Transmittal Project
**   05/07/2018   Colman       51314     Copy tasks performance
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
	@taqprojecttaskoverride_rowcount int,
	@keyind_var int,
	@datetypecode int,
    @o_taqtaskkey   int,
    @o_returncode   int,
    @o_restrictioncode int,
	@v_restriction_value_title int,
	@v_restriction_value_work  int,
    @elementtypesubcode_var int,
	@titlerolecode int,
	@OldTaqProjectFormatKey int,
	@MediaTypeCode int,
	@MediaTypeSubCode int,
	@v_userkey  INT,
	@v_count  INT,
    @v_error  INT,
    @v_newprojectitemtype   INT,
    @v_newprojectusageclass	INT,
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

if @i_copy_projectkey is null or @i_copy_projectkey = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'copy project key not passed to copy tasks (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	GOTO ExitHandler
end

if @i_new_projectkey is null or @i_new_projectkey = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'new project key not passed to copy tasks (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	GOTO ExitHandler
end

IF @i_userid IS NULL
	SET @i_userid = 'qsiadmin'

-- Get the userkey for the passed User ID
SELECT @v_userkey = userkey
FROM qsiusers
WHERE userid = @i_userid

if @v_userkey is null
	select @v_userkey = clientdefaultvalue
	from clientdefaults
	where clientdefaultid = 48

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @v_userkey = -1
END 
  
--SELECT @v_error = @@ERROR, @v_count = @@ROWCOUNT
--IF @v_error <> 0 OR @v_count = 0
--  BEGIN
--   SET @o_error_code = -1
--   SET @o_error_desc = 'Could not get userkey from qsiusers table for UserID: ' + CONVERT(VARCHAR, @i_userid)
--   GOTO ExitHandler
--END

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

SET @v_isPrinting = 0   

SELECT @v_itemtypecode_printing = datacode, @v_usageclasscode_printing = datasubcode 
FROM subgentables
WHERE tableid = 550 AND qsicode = 40          
  
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

SET @titlerolecode = NULL
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

set @cleardata = dbo.find_integer_in_comma_delim_list (@i_cleardatagroups_list,8)
set @copycontacts = dbo.find_integer_in_comma_delim_list (@i_copydatagroups_list,9)

IF @v_isPrinting = 0 BEGIN
	select @newkeycount = count(*), @tobecopiedkey = min(q.taqtaskkey)
	from taqprojecttask q
	where taqprojectkey = @i_copy_projectkey
		and taqelementkey is null

	set @counter = 1
	while @counter <= @newkeycount
	begin

		select @taqprojecttaskoverride_rowcount = count(*)
		from taqprojecttaskoverride
		where taqtaskkey = @tobecopiedkey

		SET @o_returncode = 0
		SET @o_taqtaskkey = 0
		SET @datetypecode = NULL

		SELECT @datetypecode = datetypecode, @keyind_var = keyind 
			FROM taqprojecttask
			WHERE taqprojectkey = @i_copy_projectkey
				and taqtaskkey = @tobecopiedkey
				and taqelementkey is null

		SELECT @v_restriction_value_work = 1
		select @v_restriction_value_work = relateddatacode
		  from gentablesitemtype
		 where tableid = 323
		   and datacode = @datetypecode
		   and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
		   and itemtypecode = 9
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

		if (@taqprojecttaskoverride_rowcount = 0 AND @o_returncode = 0)
		begin
			exec get_next_key 'taqprojecttask', @newkey output

			insert into taqprojecttask
				(taqtaskkey, taqprojectkey, taqelementkey, bookkey, printingkey, orgentrykey, 
				globalcontactkey, 
				rolecode, 
				globalcontactkey2, 
				rolecode2, scheduleind, stagecode, duration, datetypecode, 
				activedate, 
 				actualind, 
				keyind, 
				originaldate, 
				taqtasknote, decisioncode, paymentamt, taqtaskqty, sortorder, taqprojectformatkey,
				lastuserid, lastmaintdate, lockind,
			startdate,startdateactualind,lag, transactionkey)
			select @newkey, @v_new_projectkey, null, @v_new_bookkey, @v_new_printingkey, orgentrykey, 
				case 
					when @copycontacts = 'N' then null
					else globalcontactkey
				end, 
				CASE
				  WHEN (COALESCE(rolecode, 0) = 0 OR rolecode NOT IN (SELECT datacode FROM @GentableItemTypeFiltering WHERE tableid = 285))
				  THEN NULL 
				  ELSE rolecode		  
				END as rolecode,			 
				case 
					when @copycontacts = 'N' then null
					else globalcontactkey2
				end, 
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
				duration, datetypecode, 
				case 
					when @cleardata = 'Y' then null
					else activedate
				end, 
 				case 
					when @cleardata = 'Y' then null
					else actualind
				end, 
					keyind, 
				case 
					when @cleardata = 'Y' then null
					else originaldate
				end, 
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
			from taqprojecttask
			where taqprojectkey = @i_copy_projectkey
				and taqtaskkey = @tobecopiedkey
				and taqelementkey is null
				and datetypecode IN (SELECT DISTINCT datetypecode FROM dbo.qutl_get_datetype_itemtype_filtering(@v_userkey, 'tasktracking', 0, 0, @v_newprojectitemtype, @v_newprojectusageclass))

			SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			IF @error_var <> 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'copy/insert into taqprojecttask failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
				GOTO ExitHandler
			END 
		end

		set @counter = @counter + 1

		select @tobecopiedkey = min(q.taqtaskkey)
		from taqprojecttask q
		where taqprojectkey = @i_copy_projectkey
			and taqelementkey is null
			and q.taqtaskkey > @tobecopiedkey
	end
END
ELSE IF @v_isPrinting = 1 BEGIN
	select @newkeycount = count(*), @tobecopiedkey = min(q.taqtaskkey)
	from taqprojecttask q
	where bookkey = @v_copy_bookkey
	    and printingkey = @v_copy_printingkey
		and taqelementkey is null

	set @counter = 1
	while @counter <= @newkeycount
	begin

		select @taqprojecttaskoverride_rowcount = count(*)
		from taqprojecttaskoverride
		where taqtaskkey = @tobecopiedkey

		SET @o_returncode = 0
		SET @o_taqtaskkey = 0
		SET @datetypecode = NULL

		SELECT @datetypecode = datetypecode, @keyind_var = keyind 
			FROM taqprojecttask
			WHERE bookkey = @v_copy_bookkey
				and printingkey = @v_copy_printingkey
				and taqtaskkey = @tobecopiedkey
				and taqelementkey is null

		SELECT @v_restriction_value_work = 1
		select @v_restriction_value_work = relateddatacode
		  from gentablesitemtype
		 where tableid = 323
		   and datacode = @datetypecode
		   and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
		   and itemtypecode = 9
		   and itemtypesubcode in (select usageclasscode from coreprojectinfo where projectkey = @i_new_projectkey)

		IF (@i_new_projectkey IS NOT NULL AND @i_new_projectkey > 0 AND @datetypecode IS NOT NULL) BEGIN
		   exec dbo.qutl_check_for_restrictions @datetypecode, @v_new_bookkey, @v_new_printingkey, @i_new_projectkey, NULL, NULL, NULL,
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

		if (@taqprojecttaskoverride_rowcount = 0 AND @o_returncode = 0)
		begin
			exec get_next_key 'taqprojecttask', @newkey output

			insert into taqprojecttask
				(taqtaskkey, taqprojectkey, taqelementkey, bookkey, printingkey, orgentrykey, 
				globalcontactkey, 
				rolecode, 
				globalcontactkey2, 
				rolecode2, scheduleind, stagecode, duration, datetypecode, 
				activedate, 
 				actualind, 
				keyind, 
				originaldate, 
				taqtasknote, decisioncode, paymentamt, taqtaskqty, sortorder, taqprojectformatkey,
				lastuserid, lastmaintdate, lockind,
			startdate,startdateactualind,lag, transactionkey)
			select @newkey, @v_new_projectkey, null, @v_new_bookkey, @v_new_printingkey, orgentrykey, 
				case 
					when @copycontacts = 'N' then null
					else globalcontactkey
				end, 
				CASE
				  WHEN (COALESCE(rolecode, 0) = 0 OR rolecode NOT IN (SELECT datacode FROM @GentableItemTypeFiltering WHERE tableid = 285))
				  THEN NULL 
				  ELSE rolecode		  
				END as rolecode,			 
				case 
					when @copycontacts = 'N' then null
					else globalcontactkey2
				end, 
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
				duration, datetypecode, 
				case 
					when @cleardata = 'Y' then null
					else activedate
				end, 
 				case 
					when @cleardata = 'Y' then null
					else actualind
				end, 
					keyind, 
				case 
					when @cleardata = 'Y' then null
					else originaldate
				end, 
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
			from taqprojecttask
			where bookkey = @v_copy_bookkey
				and printingkey = @v_copy_printingkey
				and taqtaskkey = @tobecopiedkey
				and taqelementkey is null
				and datetypecode IN (SELECT DISTINCT datetypecode FROM dbo.qutl_get_datetype_itemtype_filtering(@v_userkey, 'tasktracking', 0, 0, @v_newprojectitemtype, @v_newprojectusageclass))

			SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			IF @error_var <> 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'copy/insert into taqprojecttask from Printing failed (' + cast(@error_var AS VARCHAR) + '): boookkey = ' + cast(@v_copy_bookkey AS VARCHAR)   
				GOTO ExitHandler
			END 
		end

		set @counter = @counter + 1

		select @tobecopiedkey = min(q.taqtaskkey)
		from taqprojecttask q
		where bookkey = @v_copy_bookkey
			and printingkey = @v_copy_printingkey
			and taqelementkey is null
			and q.taqtaskkey > @tobecopiedkey
	end
END
------------
ExitHandler:
------------
  DROP TABLE #TempFormatInformation
RETURN
GO

GRANT EXEC ON qproject_copy_project_nonelement_tasks TO PUBLIC
GO

