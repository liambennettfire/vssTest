IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_element]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_project_element]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_element]    Script Date: 07/16/2008 10:32:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project_element]
		(@i_copy_projectkey   integer,
		@i_copy2_projectkey   integer,
		@i_copy_bookkey       integer,
		@i_copy_printingkey   integer,
		@i_copy_elementkey		integer,
		@i_new_projectkey		  integer,
		@i_new_bookkey        integer,
		@i_new_printingkey    integer,
		@i_userid				varchar(30),
		@i_copydatagroups_list	varchar(max),
		@i_cleardatagroups_list	varchar(max),
		@o_new_elementkey		integer output,
		@o_error_code			integer output,
		@o_error_desc			varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_copy_project_element
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
	@newkey2	int,
	@counter2		int,
	@configobjkey_project	int,
	@configobjkey_journal	int,
	@copycontacts		char(1),
	@copycomments   char(1),
	@copyfileloc    char(1),
	@copymisc   char(1),
	@copytasks  char(1),
	@v_maxsort  int,
	@v_sortorder  int	

CREATE TABLE #TempTaqprojectaskKeys 
  (OldTaqtaskkey INT,    
	NewTaqtaskkey INT)

set @configobjkey_project = 15
set @configobjkey_journal = 126

if (@i_copy_projectkey is null or @i_copy_projectkey = 0) and (@i_copy_bookkey is null or @i_copy_bookkey = 0)
begin
  SET @o_error_code = -1
  SET @o_error_desc = 'copy projectkey/bookkey not passed to copy filelocations (' + cast(@error_var AS VARCHAR) + ')'
  GOTO ExitHandler
end

if (@i_new_projectkey is null or @i_new_projectkey = 0) and (@i_new_bookkey is null or @i_new_bookkey = 0)
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'new projectkey/bookkey not passed to copy filelocations (' + cast(@error_var AS VARCHAR) + ')'  
	GOTO ExitHandler
end

IF @i_copy_projectkey > 0
BEGIN
  SET @copycontacts = dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 9)
  SET @copycomments = dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 5)
  SET @copytasks = dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 8)
  SET @copymisc = dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 13)
  SET @copyfileloc = dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 14)
END
ELSE
BEGIN
  SET @copycontacts = dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 5)
  SET @copycomments = dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 13)
  SET @copytasks = dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 4)
  SET @copymisc = dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 12)
  SET @copyfileloc = dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 16)
END

-- do not copy digital assets elements (gen1ind = 1 for elementtypecode (tableid 287))
if @i_copy_elementkey is null	--means we're copying all elements
begin
  if @i_copy_projectkey > 0
  BEGIN
    -- If copying Contract Tasks, skip copying contract elements here - they will be copied while copying Contract Tasks
    IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list,21) = 'Y'  --Copy Contract Tasks (21)   
      SELECT @newkeycount = COUNT(*), @tobecopiedkey = MIN(taqelementkey), @v_maxsort = MAX(sortorder)
      FROM taqprojectelement
      WHERE taqprojectkey = @i_copy_projectkey AND
        taqelementtypecode IN (SELECT datacode FROM gentables WHERE tableid = 287 AND COALESCE(gen1ind,0) <> 1) AND
        taqelementkey NOT IN (SELECT DISTINCT taqelementkey FROM taqprojecttask
                              WHERE taqprojectkey = @i_copy_projectkey AND taqelementkey > 0 AND
                                datetypecode IN (SELECT datetypecode FROM taskviewdatetype 
                                                 WHERE taskviewkey = (SELECT taskviewkey FROM taskview WHERE qsicode = 5)))
    ELSE
      SELECT @newkeycount = COUNT(*), @tobecopiedkey = MIN(taqelementkey), @v_maxsort = MAX(sortorder)
      FROM taqprojectelement
      WHERE taqprojectkey = @i_copy_projectkey AND
        taqelementtypecode IN (SELECT datacode FROM gentables WHERE tableid = 287 AND COALESCE(gen1ind,0) <> 1)
  END
  else
  select @newkeycount = count(*), @tobecopiedkey = min(q.taqelementkey)
  from taqprojectelement q
  where bookkey = @i_copy_bookkey and printingkey = @i_copy_printingkey
  and q.taqelementtypecode in (select datacode from gentables where tableid = 287 and COALESCE(gen1ind,0) <> 1)
end
else  --means we're only copying the 1 element passed in the argument
begin
select @newkeycount = count(*), @tobecopiedkey = @i_copy_elementkey
from taqprojectelement q
where q.taqelementkey = @i_copy_elementkey
and q.taqelementtypecode in (select datacode from gentables where tableid = 287 and COALESCE(gen1ind,0) <> 1)
end

set @counter = 1
while @counter <= @newkeycount
begin
	exec get_next_key @i_userid, @newkey output

  if @i_copy_projectkey > 0 --project elements
    insert into taqprojectelement
      (taqelementkey, taqelementtypecode, taqelementtypesubcode, taqprojectkey, bookkey, printingkey,
      globalcontactkey, globalcontactkey2, taqelementnumber, taqelementdesc, addtlinfokey, sortorder, 
      rolecode1, rolecode2, elementstatus, lastuserid, lastmaintdate, startpagenumber, endpagenumber)
    select @newkey, taqelementtypecode, taqelementtypesubcode, @i_new_projectkey, null, null,
      case 
        when @copycontacts = 'N' then null
        else globalcontactkey
      end, 
      case 
        when @copycontacts = 'N' then null
        else globalcontactkey2
      end, 
      taqelementnumber, taqelementdesc,
      addtlinfokey, sortorder, rolecode1, rolecode2, elementstatus, 
      @i_userid, getdate(), startpagenumber, endpagenumber
    from taqprojectelement
    where taqprojectkey = @i_copy_projectkey and taqelementkey = @tobecopiedkey
    
  else  --title elements
    insert into taqprojectelement
      (taqelementkey, taqelementtypecode, taqelementtypesubcode, taqprojectkey, bookkey, printingkey,
      globalcontactkey, globalcontactkey2, taqelementnumber, taqelementdesc, addtlinfokey, sortorder, 
      rolecode1, rolecode2, elementstatus, lastuserid, lastmaintdate, startpagenumber, endpagenumber)
    select @newkey, taqelementtypecode, taqelementtypesubcode, null, @i_new_bookkey, @i_new_printingkey,
      case 
        when @copycontacts = 'N' then null
        else globalcontactkey
      end, 
      case 
        when @copycontacts = 'N' then null
        else globalcontactkey2
      end, 
      taqelementnumber, taqelementdesc,
      addtlinfokey, sortorder, rolecode1, rolecode2, elementstatus, 
      @i_userid, getdate(), startpagenumber, endpagenumber
    from taqprojectelement
    where bookkey = @i_copy_bookkey and printingkey = @i_copy_printingkey and taqelementkey = @tobecopiedkey
    
	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'copy/insert into taqprojectelement failed (' + cast(@error_var AS VARCHAR) + '): taqelementkey=' + cast(@tobecopiedkey AS VARCHAR)   
		GOTO ExitHandler
	END 

  -- Copy product numbers for @i_copy_projectkey and current taqelementkey
	exec qproject_copy_project_productnumber
    @i_copy_projectkey,
    null,
    @i_copy_bookkey,
    @i_copy_printingkey,
    @i_new_projectkey,
    @i_new_bookkey,
    @i_new_printingkey,
    @tobecopiedkey,		--copy_elementkey
    @newkey,			--new_elementkey
    @i_userid,
    @i_cleardatagroups_list,
    @o_error_code output,
    @o_error_desc output	

	IF @o_error_code <> 0 BEGIN
		GOTO ExitHandler
	END 
  
	if @copycomments = 'Y'
	begin
		insert into qsicomments
			(commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext,
			 commenthtml, commenthtmllite, lastuserid, lastmaintdate, invalidhtmlind, releasetoeloquenceind)
		select @newkey, commenttypecode, commenttypesubcode, parenttable, commenttext,
			 commenthtml, commenthtmllite, @i_userid, getdate(), invalidhtmlind, releasetoeloquenceind
		from qsicomments
		where commentkey = @tobecopiedkey

		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'copy/insert into qsicomments failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
			GOTO ExitHandler
		END 
	end

  -- Copy project element tasks for @i_copy_projectkey and current taqelementkey
	if @copytasks = 'Y'
	begin
		exec qproject_copy_project_tasks
      @i_copy_projectkey,
      @i_copy_bookkey,
      @i_copy_printingkey,
      @i_new_projectkey,
      @i_new_bookkey,
      @i_new_printingkey,
      @tobecopiedkey,		--copy_elementkey
      @newkey,			--new_elementkey
      @i_userid,
      @i_copydatagroups_list,
      @i_cleardatagroups_list,
      @o_error_code output,
      @o_error_desc output	

		IF @o_error_code <> 0 BEGIN
			GOTO ExitHandler
		END
	END

--  Can't do this here, we need to know the NEW taqprojectcontactrolekey that was created in another process.
--
--	if @copycontacts = 'Y' and @i_copy_projectkey > 0
--	begin
--		insert into taqprojectreaderiteration
--				(taqprojectkey, taqprojectcontactrolekey, taqelementkey, readitrecommendation,
--				 readitsummary, lastuserid, lastmaintdate)
--		select @i_new_projectkey, taqprojectcontactrolekey, @newkey, readitrecommendation,
--				readitsummary, @i_userid, getdate()
--		from taqprojectreaderiteration
--		where taqprojectkey = @i_copy_projectkey
--			and taqelementkey = @tobecopiedkey
--			
--	  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
--	  IF @error_var <> 0 BEGIN
--		  SET @o_error_code = -1
--		  SET @o_error_desc = 'copy/insert into taqprojectreaderiteration failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
--		  RETURN
--	  END
--	end

	if @copymisc = 'Y'
	begin
		insert into taqelementmisc 
		  (taqelementkey, misckey, longvalue, floatvalue, textvalue, lastuserid, lastmaintdate)
		select @newkey, misckey, longvalue, floatvalue, textvalue, @i_userid, getdate()
		from taqelementmisc
		where taqelementkey = @tobecopiedkey

		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'copy/insert into taqelementmisc failed (' + cast(@error_var AS VARCHAR) + '): taqelementkey=' + cast(@tobecopiedkey AS VARCHAR)   
			GOTO ExitHandler
		END 
	end
    
  -- Copy file locations for @i_copy_projectkey and current taqelementkey
	if @copyfileloc = 'Y'
	begin
		exec qproject_copy_project_filelocations
      @i_copy_projectkey,
      null,
      @i_copy_bookkey,
      @i_copy_printingkey,
      @i_new_projectkey,
      @i_new_bookkey,
      @i_new_printingkey,
      @tobecopiedkey,		--copy_elementkey
      @newkey,			--new_elementkey
      @i_userid,
      @i_cleardatagroups_list,
      @o_error_code output,
      @o_error_desc output	

		IF @o_error_code <> 0 BEGIN
			GOTO ExitHandler
		END
	END

	set @counter = @counter + 1

	if @newkeycount > 1
	begin
    if @i_copy_projectkey > 0
    BEGIN
      -- If copying Contract Tasks, skip copying contract elements here - they will be copied while copying Contract Tasks
      IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list,21) = 'Y'  --Copy Contract Tasks (21)
        SELECT @tobecopiedkey = MIN(taqelementkey)
        FROM taqprojectelement
        WHERE taqprojectkey = @i_copy_projectkey AND
          taqelementkey > @tobecopiedkey AND
          taqelementtypecode IN (SELECT datacode FROM gentables WHERE tableid = 287 AND COALESCE(gen1ind,0) <> 1) AND
          taqelementkey NOT IN (SELECT DISTINCT taqelementkey FROM taqprojecttask
                                WHERE taqprojectkey = @i_copy_projectkey AND taqelementkey > 0 AND
                                  datetypecode IN (SELECT datetypecode FROM taskviewdatetype 
                                                   WHERE taskviewkey = (SELECT taskviewkey FROM taskview WHERE qsicode = 5)))
      ELSE
        SELECT @tobecopiedkey = MIN(taqelementkey)
        FROM taqprojectelement
        WHERE taqprojectkey = @i_copy_projectkey AND
          taqelementkey > @tobecopiedkey AND
          taqelementtypecode IN (SELECT datacode FROM gentables WHERE tableid = 287 AND COALESCE(gen1ind,0) <> 1) 
    END       
    ELSE
      select @tobecopiedkey = min(q.taqelementkey)
      from taqprojectelement q
      where bookkey = @i_copy_bookkey and printingkey = @i_copy_printingkey and q.taqelementkey > @tobecopiedkey		
        and q.taqelementtypecode in (select datacode from gentables where tableid = 287 and COALESCE(gen1ind,0) <> 1)
	end
	else
	begin
		set @o_new_elementkey = @newkey
	end
end

/* 5/1/12 - KW - From case 17842:
Elements (7):  copy from i_copy_projectkey; add non-existing element type/subtypes from i_copy2_projectkey */
delete from #TempTaqprojectaskKeys

IF @i_copy_elementkey > 0
  GOTO ExitHandler
  
ELSE IF @i_copy_projectkey > 0 AND @i_copy2_projectkey > 0
BEGIN

  SELECT @newkeycount = COUNT(*), @tobecopiedkey = MIN(e1.taqelementkey)
  FROM taqprojectelement e1
  WHERE e1.taqprojectkey = @i_copy2_projectkey AND
    e1.taqelementtypecode IN (SELECT datacode FROM gentables WHERE tableid = 287 AND COALESCE(gen1ind,0) <> 1) AND
    NOT EXISTS (SELECT * FROM taqprojectelement e2 
                WHERE e1.taqelementtypecode = e2.taqelementtypecode AND 
                      e1.taqelementtypesubcode = e2.taqelementtypesubcode AND
                      e2.taqprojectkey = @i_copy_projectkey)
                      
  SET @counter = 1
  SET @v_sortorder = @v_maxsort + 1
  
  WHILE @counter <= @newkeycount
  BEGIN

    EXEC get_next_key @i_userid, @newkey OUTPUT

    INSERT INTO taqprojectelement
      (taqelementkey, taqelementtypecode, taqelementtypesubcode, taqprojectkey, globalcontactkey, globalcontactkey2, 
      taqelementnumber, taqelementdesc, addtlinfokey, sortorder, rolecode1, rolecode2, 
      elementstatus, lastuserid, lastmaintdate, startpagenumber, endpagenumber)
    SELECT @newkey, taqelementtypecode, taqelementtypesubcode, @i_new_projectkey, 
      CASE WHEN @copycontacts = 'N' THEN NULL ELSE globalcontactkey END,
      CASE WHEN @copycontacts = 'N' THEN NULL ELSE globalcontactkey2 END,
      taqelementnumber, taqelementdesc, addtlinfokey, @v_sortorder, rolecode1, rolecode2, 
      elementstatus, @i_userid, getdate(), startpagenumber, endpagenumber
    FROM taqprojectelement
    WHERE taqprojectkey = @i_copy2_projectkey AND taqelementkey = @tobecopiedkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Copy/insert into taqprojectelement failed (' + cast(@error_var AS VARCHAR) + '): taqelementkey=' + cast(@tobecopiedkey AS VARCHAR)   
      GOTO ExitHandler
    END 

    -- Copy product numbers for @i_copy2_projectkey and current taqelementkey
    EXEC qproject_copy_project_productnumber
      @i_copy2_projectkey,
      null,
      @i_copy_bookkey,
      @i_copy_printingkey,
      @i_new_projectkey,
      @i_new_bookkey,
      @i_new_printingkey,
      @tobecopiedkey,		--copy_elementkey
      @newkey,			--new_elementkey
      @i_userid,
      @i_cleardatagroups_list,
      @o_error_code output,
      @o_error_desc output	

    IF @o_error_code <> 0
      GOTO ExitHandler

    IF @copycomments = 'Y'
    BEGIN
      INSERT INTO qsicomments
        (commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext,
        commenthtml, commenthtmllite, lastuserid, lastmaintdate, invalidhtmlind, releasetoeloquenceind)
      SELECT @newkey, commenttypecode, commenttypesubcode, parenttable, commenttext,
        commenthtml, commenthtmllite, @i_userid, getdate(), invalidhtmlind, releasetoeloquenceind
      FROM qsicomments
      WHERE commentkey = @tobecopiedkey

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'copy/insert into qsicomments failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy2_projectkey AS VARCHAR)   
        GOTO ExitHandler
      END 
    END

    -- Copy project element tasks for @i_copy2_projectkey and current taqelementkey
    IF @copytasks = 'Y'
    BEGIN
      EXEC qproject_copy_project_tasks
        @i_copy2_projectkey,
        @i_copy_bookkey,
        @i_copy_printingkey,
        @i_new_projectkey,
        @i_new_bookkey,
        @i_new_printingkey,
        @tobecopiedkey,		--copy_elementkey
        @newkey,			--new_elementkey
        @i_userid,
        @i_copydatagroups_list,
        @i_cleardatagroups_list,
        @o_error_code output,
        @o_error_desc output	

      IF @o_error_code <> 0
        GOTO ExitHandler
    END

    IF @copymisc = 'Y'
    BEGIN
      INSERT INTO taqelementmisc 
        (taqelementkey, misckey, longvalue, floatvalue, textvalue, lastuserid, lastmaintdate)
      SELECT @newkey, misckey, longvalue, floatvalue, textvalue, @i_userid, getdate()
      FROM taqelementmisc
      WHERE taqelementkey = @tobecopiedkey

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'copy/insert into taqelementmisc failed (' + cast(@error_var AS VARCHAR) + '): taqelementkey=' + cast(@tobecopiedkey AS VARCHAR)   
        GOTO ExitHandler
      END 
    END

    -- Copy file locations for @i_copy2_projectkey and current taqelementkey
    IF @copyfileloc = 'Y'
    BEGIN
      EXEC qproject_copy_project_filelocations
        @i_copy2_projectkey,
        null,
        @i_copy_bookkey,
        @i_copy_printingkey,
        @i_new_projectkey,
        @i_new_bookkey,
        @i_new_printingkey,
        @tobecopiedkey,		--copy_elementkey
        @newkey,			--new_elementkey
        @i_userid,
        @i_cleardatagroups_list,
        @o_error_code output,
        @o_error_desc output	

      IF @o_error_code <> 0
        GOTO ExitHandler
    END

    SET @counter = @counter + 1
    SET @v_sortorder = @v_sortorder + 1
   
    SELECT @tobecopiedkey = MIN(e1.taqelementkey)
    FROM taqprojectelement e1
    WHERE e1.taqprojectkey = @i_copy2_projectkey AND e1.taqelementkey > @tobecopiedkey AND
      e1.taqelementtypecode IN (SELECT datacode FROM gentables WHERE tableid = 287 AND COALESCE(gen1ind,0) <> 1) AND
      NOT EXISTS (SELECT * FROM taqprojectelement e2 
                  WHERE e1.taqelementtypecode = e2.taqelementtypecode AND 
                        e1.taqelementtypesubcode = e2.taqelementtypesubcode AND
                        e2.taqprojectkey = @i_copy_projectkey)    
  END
END

------------
ExitHandler:
------------
  DROP TABLE #TempTaqprojectaskKeys

RETURN


