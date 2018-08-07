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

/******************************************************************************
**  Name: [qproject_copy_project_nonelement_tasks]
**  Desc: This stored procedure copies all tasks that are not associated with an 
**        element to a new project being created with the template as a basis.
**
**  If you call this procedure from anyplace other than qproject_copy_project,
**  you must do your own transaction/commit/rollbacks on return from this procedure.
**
*******************************************************************************/

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
	@MediaTypeSubCode int

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
		exec get_next_key @i_userid, @newkey output

		insert into taqprojecttask
			(taqtaskkey, taqprojectkey, taqelementkey, bookkey, orgentrykey, 
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
		select @newkey, @i_new_projectkey, null, bookkey, orgentrykey, 
			case 
				when @copycontacts = 'N' then null
				else globalcontactkey
			end, 
			rolecode, 
			case 
				when @copycontacts = 'N' then null
				else globalcontactkey2
			end, 
			rolecode2, scheduleind, stagecode, duration, datetypecode, 
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
			taqtasknote, decisioncode, paymentamt, taqtaskqty, sortorder, 
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

------------
ExitHandler:
------------
  DROP TABLE #TempFormatInformation
RETURN
GO

GRANT EXEC ON qproject_copy_project_nonelement_tasks TO PUBLIC
GO

