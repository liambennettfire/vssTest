IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_filelocations]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_project_filelocations]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_filelocations]    Script Date: 07/16/2008 10:31:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project_filelocations]
  (@i_copy_projectkey integer,
  @i_copy2_projectkey	integer,
  @i_copy_bookkey     integer,
  @i_copy_printingkey integer,
  @i_new_projectkey		integer,
  @i_new_bookkey      integer,
  @i_new_printingkey  integer,
  @i_copy_elementkey  integer,
  @i_new_elementkey		integer,
  @i_userid           varchar(30),
  @i_cleardatagroups_list	varchar(max),
  @o_error_code			integer output,
  @o_error_desc			varchar(2000) output)
AS

/****************************************************************************************************************************
**  Name: [qproject_copy_project_filelocations]
**  Desc: This stored procedure copies the details of 1 or all elements to new elements.
**        this table has projectkey and elementkey.  If a record is at the element level,
**			the elementkey is filled in and the projectkey is null.  If it is at the project
**			level, the projectkey is filled in and the elementkey is null.
**
**			If you call this procedure from anyplace other than qproject_copy_project,
**			you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Jennifer Hurd
**    Date: 23 June 2008
**
**  7/28/09 - KW - Use same procedure for copy element in projects and in titles.
*****************************************************************************************************************************
**    Change History
*****************************************************************************************************************************
**    Date:        Author:         Description:
**    --------     --------        --------------------------------------------------------------------------------------
**    05/11/2016   Uday			   37359 Allow "Copy from Project" to be a different class from project being created 
*****************************************************************************************************************************/

SET @o_error_code = 0
SET @o_error_desc = ''

DECLARE @error_var    INT,
	@rowcount_var INT,
	@newkeycount	int,
	@tobecopiedkey	int,
	@newkey	int,
	@counter		int,
	@cleardata		char(1),
	@v_maxsort  int,
	@v_sortorder  int,
    @v_newprojectitemtype   INT,
    @v_newprojectusageclass	INT,
    @v_elementprojectkey INT,
    @v_elementprojectitemtype   INT,
    @v_elementnewprojectusageclass	INT,
    @v_filetypecode SMALLINT	

if (@i_copy_projectkey is null or @i_copy_projectkey = 0) and (@i_copy_bookkey is null or @i_copy_bookkey = 0)
begin
  SET @o_error_code = -1
  SET @o_error_desc = 'copy projectkey/bookkey not passed to copy filelocations (' + cast(@error_var AS VARCHAR) + ')'
  RETURN
end

if (@i_new_projectkey is null or @i_new_projectkey = 0) and (@i_new_bookkey is null or @i_new_bookkey = 0)
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'new projectkey/bookkey not passed to copy filelocations (' + cast(@error_var AS VARCHAR) + ')'  
	RETURN
end

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
END

if @i_copy_projectkey > 0
  set @cleardata = dbo.find_integer_in_comma_delim_list(@i_cleardatagroups_list, 14)
else
  set @cleardata = dbo.find_integer_in_comma_delim_list(@i_cleardatagroups_list, 16)

if @i_copy_elementkey is not null		--copying an element, not project
begin
	select @newkeycount = count(*), @tobecopiedkey = min(q.filelocationgeneratedkey)
	from filelocation q
	where taqelementkey = @i_copy_elementkey

	set @counter = 1	
	while @counter <= @newkeycount
	begin
		exec get_next_key @i_userid, @newkey output

    insert into filelocation
      (bookkey, printingkey, filetypecode, fileformatcode, filelocationkey, filestatuscode, 
      pathname, notes, lastuserid, lastmaintdate, sendtoeloquenceind, sortorder, filelocationgeneratedkey,
      taqprojectkey, taqelementkey, globalcontactkey, locationtypecode, stagecode, filedescription)
    select 
      case when bookkey is null then null else @i_new_bookkey end,
      case when printingkey is null then null else @i_new_printingkey end,
      filetypecode, fileformatcode, filelocationkey, filestatuscode, 
      case when @cleardata = 'Y' then null else pathname end,
      notes, @i_userid, getdate(), sendtoeloquenceind, sortorder, @newkey,
      case when taqprojectkey is null then null else @i_new_projectkey end, 
      @i_new_elementkey, globalcontactkey, locationtypecode, stagecode, filedescription
    from filelocation
    where taqelementkey = @i_copy_elementkey and 
      filelocationgeneratedkey = @tobecopiedkey

		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'copy/insert into filelocation failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
			RETURN
		END 

		set @counter = @counter + 1

		select @tobecopiedkey = min(q.filelocationgeneratedkey)
		from filelocation q
		where taqelementkey = @i_copy_elementkey
			and q.filelocationgeneratedkey > @tobecopiedkey
	end
end

else		--calling this for a project, not element level
begin
	select @newkeycount = count(*), @tobecopiedkey = min(q.filelocationgeneratedkey), @v_maxsort = max(sortorder)
	from filelocation q INNER JOIN qutl_get_gentable_itemtype_filtering(354, @v_newprojectitemtype, @v_newprojectusageclass) as f 
    ON q.filetypecode = f.datacode
	where taqprojectkey = @i_copy_projectkey
		and taqelementkey is null
		and q.filetypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(354, @v_newprojectitemtype, @v_newprojectusageclass))		

	set @counter = 1
	while @counter <= @newkeycount
	begin
		exec get_next_key @i_userid, @newkey output

    insert into filelocation
      (bookkey, printingkey, filetypecode, fileformatcode, filelocationkey, filestatuscode, 
      pathname, notes, lastuserid, lastmaintdate, sendtoeloquenceind, sortorder, filelocationgeneratedkey,
      taqprojectkey, taqelementkey, globalcontactkey, locationtypecode, stagecode, filedescription)
    select bookkey, printingkey, filetypecode, 
	  CASE
		   WHEN (COALESCE(fileformatcode, 0) = 0 OR fileformatcode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(355, @v_newprojectitemtype, @v_newprojectusageclass)))
		   THEN NULL 
		   ELSE fileformatcode		  
	  END as fileformatcode,    
      filelocationkey, 
	  CASE
		   WHEN (COALESCE(filestatuscode, 0) = 0 OR filestatuscode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(357, @v_newprojectitemtype, @v_newprojectusageclass)))
		   THEN NULL 
		   ELSE filestatuscode		  
	  END as filestatuscode,      
      case when @cleardata = 'Y' then null else pathname end,
      notes, @i_userid, getdate(), sendtoeloquenceind, sortorder, @newkey,
      @i_new_projectkey, taqelementkey, globalcontactkey, locationtypecode, stagecode, filedescription
    from filelocation
    where taqprojectkey = @i_copy_projectkey
      and taqelementkey is null
      and filelocationgeneratedkey = @tobecopiedkey

		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'copy/insert into filelocation failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy_projectkey AS VARCHAR)   
			RETURN
		END 

		set @counter = @counter + 1

		select @tobecopiedkey = min(q.filelocationgeneratedkey)
		from filelocation q
		where taqprojectkey = @i_copy_projectkey
			and taqelementkey is null
			and q.filelocationgeneratedkey > @tobecopiedkey
			and q.filetypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(354, @v_newprojectitemtype, @v_newprojectusageclass))
	end
end

/* 5/4/12 - KW - From case 17842:
File Locations (14):  copy from i_copy_projectkey; add non-existing file types from i_copy2_projectkey 
NOTE: Joining on filetypecode and pathname because there may be multiple file types per project with different pathnames ex: website file type */
IF @i_copy_elementkey > 0
  RETURN
  
ELSE IF @i_copy_projectkey > 0 AND @i_copy2_projectkey > 0
BEGIN
	SELECT @newkeycount = COUNT(*), @tobecopiedkey = MIN(f1.filelocationgeneratedkey)
	FROM filelocation f1
	WHERE f1.taqprojectkey = @i_copy2_projectkey AND
    f1.taqelementkey IS NULL AND
    NOT EXISTS (SELECT * FROM filelocation f2
                WHERE f1.filetypecode = f2.filetypecode AND 
                  f1.pathname = f2.pathname AND
                  f2.taqprojectkey = @i_copy_projectkey)

	SET @counter = 1
	SET @v_sortorder = @v_maxsort + 1
	
	WHILE @counter <= @newkeycount
	BEGIN
		EXEC get_next_key @i_userid, @newkey OUTPUT

    INSERT INTO filelocation
      (bookkey, printingkey, filetypecode, fileformatcode, filelocationkey, filestatuscode, 
      pathname, notes, lastuserid, lastmaintdate, sendtoeloquenceind, sortorder, filelocationgeneratedkey,
      taqprojectkey, taqelementkey, globalcontactkey, locationtypecode, stagecode, filedescription)
    SELECT bookkey, printingkey, filetypecode, fileformatcode, filelocationkey, filestatuscode, 
      CASE WHEN @cleardata = 'Y' THEN NULL ELSE pathname END,
      notes, @i_userid, getdate(), sendtoeloquenceind, @v_sortorder, @newkey,
      @i_new_projectkey, taqelementkey, globalcontactkey, locationtypecode, stagecode, filedescription
    FROM filelocation
    WHERE taqprojectkey = @i_copy2_projectkey AND
      taqelementkey IS NULL AND
      filelocationgeneratedkey = @tobecopiedkey

		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Copy/insert into filelocation failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy2_projectkey AS VARCHAR)   
			RETURN
		END 

		SET @counter = @counter + 1
		SET @v_sortorder = @v_sortorder + 1

	  SELECT @tobecopiedkey = MIN(f1.filelocationgeneratedkey)
	  FROM filelocation f1
	  WHERE f1.taqprojectkey = @i_copy2_projectkey AND
      f1.taqelementkey IS NULL AND
      f1.filelocationgeneratedkey > @tobecopiedkey AND
      NOT EXISTS (SELECT * FROM filelocation f2
                  WHERE f1.filetypecode = f2.filetypecode AND 
                    f1.pathname = f2.pathname AND
                    f2.taqprojectkey = @i_copy_projectkey)			
	END
END

RETURN
