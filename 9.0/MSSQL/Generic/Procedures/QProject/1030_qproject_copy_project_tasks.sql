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

/*****************************************************************************************
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
*****************************************************************************************/

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
  @MediaTypeSubCode int

CREATE TABLE #TempFormatInformation 
  (OldTaqProjectFormatKey INT NULL, 
   NewTaqProjectFormatKey INT NULL,   
   MediaTypeCode INT NULL,
   MediaTypeSubCode INT NULL)

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

SET @v_copy_elementkey = NULL
SET @v_new_elementkey = NULL 

IF @i_copy_projectkey > 0 BEGIN
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
      EXEC get_next_key @i_userid, @newkey OUTPUT
      INSERT INTO #TempTaqprojectaskKeys (OldTaqtaskkey, NewTaqtaskkey) VALUES (@tobecopiedkey, @newkey)
    END
    ELSE BEGIN
      SELECT @newkey = NewTaqtaskkey FROM #TempTaqprojectaskKeys t WHERE t.OldTaqtaskkey = @tobecopiedkey
      SET @insert_in_taqprojecttask = 0
    END
    
    --PRINT '@insert_in_taqprojecttask=' + convert(varchar, @insert_in_taqprojecttask)
    --PRINT '@newkey=' + convert(varchar, @newkey)

    SET @o_returncode = 0
    SET @o_taqtaskkey = 0
    SET @datetypecode = NULL

    IF @i_copy_projectkey > 0 BEGIN
    
      SELECT @datetypecode = datetypecode, @keyind_var = keyind 
      FROM taqprojecttask
      WHERE taqprojectkey = @i_copy_projectkey AND
        taqtaskkey = @tobecopiedkey AND
        (taqelementkey = @i_copy_elementkey OR taqelementkey IS NULL)

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
          INSERT INTO taqprojecttask
            (taqtaskkey, taqprojectkey, taqelementkey, bookkey, printingkey, orgentrykey, 
            globalcontactkey, rolecode, globalcontactkey2, rolecode2, 
            scheduleind, stagecode, duration, datetypecode, keyind, 
            activedate, actualind, originaldate, 
            taqtasknote, decisioncode, paymentamt, taqtaskqty, sortorder, 
            taqprojectformatkey, lastuserid, lastmaintdate, lockind,
            startdate,startdateactualind,lag, transactionkey)
          SELECT @newkey, @i_new_projectkey, @v_new_elementkey, bookkey, printingkey, orgentrykey, 
            CASE WHEN @copycontacts = 'N' THEN NULL ELSE globalcontactkey END, rolecode, 
            CASE WHEN @copycontacts = 'N' THEN NULL ELSE globalcontactkey2 END, rolecode2, 
            scheduleind, stagecode, duration, datetypecode, keyind, 
            CASE WHEN @cleardata = 'Y' THEN NULL ELSE activedate END, 
            CASE WHEN @cleardata = 'Y' THEN NULL ELSE actualind END, 
            CASE WHEN @cleardata = 'Y' THEN NULL ELSE originaldate END,
            taqtasknote, decisioncode, paymentamt, taqtaskqty, sortorder, 
            case
              when COALESCE(taqprojectformatkey, 0) > 0 AND @titlerolecode IS NOT NULL THEN
              (SELECT COALESCE(NewTaqProjectFormatKey, NULL) FROM #TempFormatInformation t WHERE t.OldTaqProjectFormatKey = taqprojectformatkey)
              else NULL
            end,
            @i_userid, getdate(), lockind,
            startdate,startdateactualind,lag, transactionkey
          FROM taqprojecttask
          WHERE taqprojectkey = @i_copy_projectkey AND
            taqtaskkey = @tobecopiedkey AND
            (taqelementkey = @i_copy_elementkey OR taqelementkey IS NULL)

          SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
          IF @error_var <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'copy/insert into taqprojecttask failed (' + cast(@error_var AS VARCHAR) + '): taqtaskkey = ' + cast(@tobecopiedkey AS VARCHAR)   
            GOTO ExitHandler
          END 
        END --@insert_in_taqprojecttask=1

        SELECT @v_count = COUNT(*)
        FROM taqprojecttaskoverride
        WHERE taqtaskkey = @tobecopiedkey

        IF @v_count > 0 BEGIN
          INSERT INTO taqprojecttaskoverride
            (taqtaskkey, taqelementkey, scheduleind, lag, sortorder, lastuserid, lastmaintdate)
          SELECT 
            @newkey, taqelementkey, scheduleind, lag, sortorder, @i_userid, getdate()
          FROM taqprojecttaskoverride
          WHERE taqtaskkey = @tobecopiedkey

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
        WHERE taqtaskkey = @tobecopiedkey

        --PRINT 'override count=' + convert(varchar, @v_count)

        IF @v_count > 0 BEGIN
          INSERT INTO taqprojecttaskoverride
            (taqtaskkey, taqelementkey, scheduleind, lag, sortorder, lastuserid,lastmaintdate)
          SELECT 
            @newkey, taqelementkey, scheduleind, lag, sortorder, @i_userid, getdate()
          FROM taqprojecttaskoverride
          WHERE taqtaskkey = @tobecopiedkey

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
    SELECT @tobecopiedkey = MIN(q.taqtaskkey)
    FROM taqprojecttask q
    WHERE taqprojectkey = @i_copy_projectkey AND (taqelementkey = @i_copy_elementkey OR taqelementkey IS NULL) AND q.taqtaskkey > @tobecopiedkey

    SELECT @v_copy_elementkey = taqelementkey
    FROM taqprojecttask q
    WHERE taqprojectkey = @i_copy_projectkey AND q.taqtaskkey = @tobecopiedkey
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

------------
ExitHandler:
------------
  DROP TABLE #TempFormatInformation

RETURN