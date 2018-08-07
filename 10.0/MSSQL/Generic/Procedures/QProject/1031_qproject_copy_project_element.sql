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

/****************************************************************************************************************************
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
*****************************************************************************************************************************
**    Change History
*****************************************************************************************************************************
**    Date:        Author:         Description:
**    --------     --------        --------------------------------------------------------------------------------------
**    05/09/2016   Uday			   37359 Allow "Copy from Project" to be a different class from project being created 
**    01/26/2017   Uday            38699 Copy Printing Info When Creating a Transmittal Project
**    02/16/2017   Uday            43315
*****************************************************************************************************************************/

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
	@v_sortorder  int,
	@v_newprojectitemtype int,
	@v_newprojectusageclass int,
	@v_newelementitemtype int,
	@v_newelementusageclass int,
    @v_itemtypecode_printing INT,
    @v_usageclasscode_printing INT,
	@v_itemtypecode_copyproject INT,
    @v_usageclasscode_copyproject INT,
    @v_isPrinting INT,
	@v_isPrinting2 INT,
    @v_copy_bookkey INT,
    @v_copy_printingkey INT,		
	@v_copy2_bookkey INT,
    @v_copy2_printingkey INT,
	@v_new_projectkey INT,
	@v_new_bookkey INT, 
	@v_new_printingkey INT						

CREATE TABLE #TempTaqprojectaskKeys 
  (OldTaqtaskkey INT,    
	NewTaqtaskkey INT)

set @configobjkey_project = 15
set @configobjkey_journal = 126

SELECT @v_newelementitemtype = dbo.qutl_get_gentables_datacode(550, 7, NULL)

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

SET @v_new_projectkey = NULL
SET @v_new_bookkey = NULL
SET @v_new_printingkey = NULL

SELECT @v_itemtypecode_printing = datacode, @v_usageclasscode_printing = datasubcode 
FROM subgentables
WHERE tableid = 550 AND qsicode = 40

-- only want to copy elements types that are defined for the new project
IF (@i_new_projectkey > 0)
BEGIN
  SELECT @v_newprojectitemtype = searchitemcode, @v_newprojectusageclass = usageclasscode
  FROM taqproject
  WHERE taqprojectkey = @i_new_projectkey

  IF @v_newprojectitemtype is null or @v_newprojectitemtype = 0
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

SET @v_isPrinting2 = 0 

IF @i_copy2_projectkey > 0 BEGIN  
	SELECT @v_itemtypecode_copyproject = searchitemcode, @v_usageclasscode_copyproject = usageclasscode 
	FROM coreprojectinfo
	WHERE projectkey = @i_copy2_projectkey
  
	IF @v_itemtypecode_printing = @v_itemtypecode_copyproject AND @v_usageclasscode_printing = @v_usageclasscode_copyproject BEGIN
	  SET @v_isPrinting2 = 1
	  SELECT  @v_copy2_bookkey = bookkey, @v_copy2_printingkey = printingkey FROM taqprojectprinting_view WHERE taqprojectkey = @i_copy2_projectkey

	  if @v_copy2_bookkey is null or @v_copy2_bookkey = 0
	  begin
		SET @o_error_code = -1
		SET @o_error_desc = 'copy project key for printing not passed to copy tasks (' + cast(@error_var AS VARCHAR) + '): boookkey = ' + cast(@v_copy2_bookkey AS VARCHAR)   
		GOTO ExitHandler
	  end
	END
END

-- do not copy digital assets elements (gen1ind = 1 for elementtypecode (tableid 287))
if @i_copy_elementkey is null	--means we're copying all elements
begin
  if @i_copy_projectkey > 0
  BEGIN
    IF @v_isPrinting = 0 BEGIN
		-- If copying Contract Tasks, skip copying contract elements here - they will be copied while copying Contract Tasks
		IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list,21) = 'Y'  --Copy Contract Tasks (21)   
		  SELECT @newkeycount = COUNT(*), @tobecopiedkey = MIN(q.taqelementkey), @v_maxsort = MAX(q.sortorder)
		  FROM taqprojectelement q
		  WHERE q.taqprojectkey = @i_copy_projectkey AND
		  (COALESCE(q.taqelementtypecode, 0) = 0 OR q.taqelementtypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(287, @v_newprojectitemtype, @v_newprojectusageclass))) AND		  
			q.taqelementtypecode IN (SELECT datacode FROM gentables WHERE tableid = 287 AND COALESCE(gen1ind,0) <> 1) AND
			q.taqelementkey NOT IN (SELECT DISTINCT taqelementkey FROM taqprojecttask
								  WHERE taqprojectkey = @i_copy_projectkey AND taqelementkey > 0 AND
									datetypecode IN (SELECT datetypecode FROM taskviewdatetype 
													 WHERE taskviewkey = (SELECT taskviewkey FROM taskview WHERE qsicode = 5)))
		ELSE
		  SELECT @newkeycount = COUNT(*), @tobecopiedkey = MIN(e.taqelementkey), @v_maxsort = MAX(e.sortorder)
		  FROM taqprojectelement e
		  WHERE taqprojectkey = @i_copy_projectkey AND
		  (COALESCE(e.taqelementtypecode, 0) = 0 OR e.taqelementtypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(287, @v_newprojectitemtype, @v_newprojectusageclass))) AND		  
			taqelementtypecode IN (SELECT datacode FROM gentables WHERE tableid = 287 AND COALESCE(gen1ind,0) <> 1)
    END
	ELSE IF @v_isPrinting = 1 BEGIN  -- copying from a Printing Project use bookkey & Printingkey
		-- If copying Contract Tasks, skip copying contract elements here - they will be copied while copying Contract Tasks
		IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list,21) = 'Y'  --Copy Contract Tasks (21)   
		  SELECT @newkeycount = COUNT(*), @tobecopiedkey = MIN(q.taqelementkey), @v_maxsort = MAX(q.sortorder)
		  FROM taqprojectelement q
		  WHERE q.bookkey = @v_copy_bookkey AND
		        q.printingkey = @v_copy_printingkey AND
		  (COALESCE(q.taqelementtypecode, 0) = 0 OR q.taqelementtypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(287, @v_newprojectitemtype, @v_newprojectusageclass))) AND		  
			q.taqelementtypecode IN (SELECT datacode FROM gentables WHERE tableid = 287 AND COALESCE(gen1ind,0) <> 1) AND
			q.taqelementkey NOT IN (SELECT DISTINCT taqelementkey FROM taqprojecttask
								  WHERE bookkey = @v_copy_bookkey AND printingkey = @v_copy_printingkey AND taqelementkey > 0 AND
									datetypecode IN (SELECT datetypecode FROM taskviewdatetype 
													 WHERE taskviewkey = (SELECT taskviewkey FROM taskview WHERE qsicode = 5)))
		ELSE
		  SELECT @newkeycount = COUNT(*), @tobecopiedkey = MIN(e.taqelementkey), @v_maxsort = MAX(e.sortorder)
		  FROM taqprojectelement e
		  WHERE bookkey = @v_copy_bookkey AND printingkey = @v_copy_printingkey AND
		  (COALESCE(e.taqelementtypecode, 0) = 0 OR e.taqelementtypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(287, @v_newprojectitemtype, @v_newprojectusageclass))) AND		  
			taqelementtypecode IN (SELECT datacode FROM gentables WHERE tableid = 287 AND COALESCE(gen1ind,0) <> 1)
	END
  END
  else
  select @newkeycount = count(*), @tobecopiedkey = min(q.taqelementkey)
  from taqprojectelement q
  where bookkey = @i_copy_bookkey and printingkey = @i_copy_printingkey AND
      (COALESCE(q.taqelementtypecode, 0) = 0 OR q.taqelementtypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(287, @v_newprojectitemtype, @v_newprojectusageclass))) AND      
      q.taqelementtypecode in (select datacode from gentables where tableid = 287 and COALESCE(gen1ind,0) <> 1)
end
else  --means we're only copying the 1 element passed in the argument
begin
select @newkeycount = count(*), @tobecopiedkey = @i_copy_elementkey
from taqprojectelement q
where q.taqelementkey = @i_copy_elementkey AND
  (COALESCE(q.taqelementtypecode, 0) = 0 OR q.taqelementtypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(287, @v_newprojectitemtype, @v_newprojectusageclass))) AND  
  q.taqelementtypecode in (select datacode from gentables where tableid = 287 and COALESCE(gen1ind,0) <> 1)
end

set @counter = 1
while @counter <= @newkeycount
begin
	exec get_next_key @i_userid, @newkey output

  if @i_copy_projectkey > 0 BEGIN --project elements
    IF @v_isPrinting = 0 BEGIN
		insert into taqprojectelement
		  (taqelementkey, taqelementtypecode, taqelementtypesubcode, taqprojectkey, bookkey, printingkey,
		  globalcontactkey, globalcontactkey2, taqelementnumber, taqelementdesc, addtlinfokey, sortorder, 
		  rolecode1, rolecode2, elementstatus, lastuserid, lastmaintdate, startpagenumber, endpagenumber)
		select @newkey, taqelementtypecode, taqelementtypesubcode, @v_new_projectkey, @v_new_bookkey, @v_new_printingkey,
		  case 
			when @copycontacts = 'N' then null
			else globalcontactkey
		  end, 
		  case 
			when @copycontacts = 'N' then null
			else globalcontactkey2
		  end, 
		  taqelementnumber, taqelementdesc,
		  addtlinfokey, sortorder,
		  CASE
			WHEN (COALESCE(rolecode1, 0) = 0 OR rolecode1 NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(285, @v_newprojectitemtype, @v_newprojectusageclass)))
			THEN NULL 
			ELSE rolecode1		  
		  END as rolecode1,     
		  CASE
			WHEN (COALESCE(rolecode2, 0) = 0 OR rolecode2 NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(285, @v_newprojectitemtype, @v_newprojectusageclass)))
			THEN NULL 
			ELSE rolecode2		  
		  END as rolecode2,	 
		  CASE
			WHEN (COALESCE(elementstatus, 0) = 0 OR elementstatus NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(593, @v_newprojectitemtype, @v_newprojectusageclass)))
			THEN NULL 
			ELSE elementstatus		  
		  END as elementstatus,	     
		  @i_userid, getdate(), startpagenumber, endpagenumber
		from taqprojectelement
		where taqprojectkey = @i_copy_projectkey and taqelementkey = @tobecopiedkey
	END
	ELSE IF @v_isPrinting = 1 BEGIN  -- copying from a Printing Project use bookkey & Printingkey
		insert into taqprojectelement
		  (taqelementkey, taqelementtypecode, taqelementtypesubcode, taqprojectkey, bookkey, printingkey,
		  globalcontactkey, globalcontactkey2, taqelementnumber, taqelementdesc, addtlinfokey, sortorder, 
		  rolecode1, rolecode2, elementstatus, lastuserid, lastmaintdate, startpagenumber, endpagenumber)
		select @newkey, taqelementtypecode, taqelementtypesubcode, @v_new_projectkey, @v_new_bookkey, @v_new_printingkey,
		  case 
			when @copycontacts = 'N' then null
			else globalcontactkey
		  end, 
		  case 
			when @copycontacts = 'N' then null
			else globalcontactkey2
		  end, 
		  taqelementnumber, taqelementdesc,
		  addtlinfokey, sortorder,
		  CASE
			WHEN (COALESCE(rolecode1, 0) = 0 OR rolecode1 NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(285, @v_newprojectitemtype, @v_newprojectusageclass)))
			THEN NULL 
			ELSE rolecode1		  
		  END as rolecode1,     
		  CASE
			WHEN (COALESCE(rolecode2, 0) = 0 OR rolecode2 NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(285, @v_newprojectitemtype, @v_newprojectusageclass)))
			THEN NULL 
			ELSE rolecode2		  
		  END as rolecode2,	 
		  CASE
			WHEN (COALESCE(elementstatus, 0) = 0 OR elementstatus NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(593, @v_newprojectitemtype, @v_newprojectusageclass)))
			THEN NULL 
			ELSE elementstatus		  
		  END as elementstatus,	     
		  @i_userid, getdate(), startpagenumber, endpagenumber
		from taqprojectelement
		where bookkey = @v_copy_bookkey AND printingkey = @v_copy_printingkey and taqelementkey = @tobecopiedkey
	END
  END  
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
      addtlinfokey, sortorder, 
	  CASE
	    WHEN (COALESCE(rolecode1, 0) = 0 OR rolecode1 NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(285, @v_newprojectitemtype, @v_newprojectusageclass)))
	    THEN NULL 
	    ELSE rolecode1		  
	  END as rolecode1,     
	  CASE
	    WHEN (COALESCE(rolecode2, 0) = 0 OR rolecode2 NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(285, @v_newprojectitemtype, @v_newprojectusageclass)))
	    THEN NULL 
	    ELSE rolecode2		  
	  END as rolecode2,	 
	  CASE
	    WHEN (COALESCE(elementstatus, 0) = 0 OR elementstatus NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(593, @v_newprojectitemtype, @v_newprojectusageclass)))
	    THEN NULL 
	    ELSE elementstatus		  
	  END as elementstatus,	      
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
		SET @v_newelementusageclass = 0
		SELECT @v_newelementusageclass = taqelementtypecode
		from taqprojectelement
		where taqelementkey = @tobecopiedkey

		insert into qsicomments
			(commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext,
			 commenthtml, commenthtmllite, lastuserid, lastmaintdate, invalidhtmlind, releasetoeloquenceind)
		select @newkey, commenttypecode, commenttypesubcode, parenttable, commenttext,
			 commenthtml, commenthtmllite, @i_userid, getdate(), invalidhtmlind, releasetoeloquenceind
		from qsicomments
		where commentkey = @tobecopiedkey AND
	     (COALESCE(commenttypecode, 0) = 0 OR commenttypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(284, @v_newelementitemtype, @v_newelementusageclass))) AND
	     (COALESCE(commenttypesubcode, 0) = 0 OR commenttypesubcode IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(284, @v_newelementitemtype, @v_newelementusageclass) WHERE datacode = commenttypecode)) 		

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
	  IF @v_isPrinting = 0 BEGIN
		  -- If copying Contract Tasks, skip copying contract elements here - they will be copied while copying Contract Tasks
		  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list,21) = 'Y'  --Copy Contract Tasks (21)
			SELECT @tobecopiedkey = MIN(q.taqelementkey)
			FROM taqprojectelement q
			WHERE q.taqprojectkey = @i_copy_projectkey AND
			  (COALESCE(q.taqelementtypecode, 0) = 0 OR q.taqelementtypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(287, @v_newprojectitemtype, @v_newprojectusageclass))) AND			  
			  q.taqelementkey > @tobecopiedkey AND
			  q.taqelementtypecode IN (SELECT datacode FROM gentables WHERE tableid = 287 AND COALESCE(gen1ind,0) <> 1) AND
			  q.taqelementkey NOT IN (SELECT DISTINCT taqelementkey FROM taqprojecttask
									WHERE taqprojectkey = @i_copy_projectkey AND taqelementkey > 0 AND
									  datetypecode IN (SELECT datetypecode FROM taskviewdatetype 
													   WHERE taskviewkey = (SELECT taskviewkey FROM taskview WHERE qsicode = 5)))
		  ELSE
			SELECT @tobecopiedkey = MIN(q.taqelementkey)
			FROM taqprojectelement q
			WHERE q.taqprojectkey = @i_copy_projectkey AND
			  (COALESCE(q.taqelementtypecode, 0) = 0 OR q.taqelementtypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(287, @v_newprojectitemtype, @v_newprojectusageclass))) AND			  
			  q.taqelementkey > @tobecopiedkey AND
			  q.taqelementtypecode IN (SELECT datacode FROM gentables WHERE tableid = 287 AND COALESCE(gen1ind,0) <> 1) 
	  END
	  ELSE IF @v_isPrinting = 1 BEGIN  -- copying from a Printing Project use bookkey & Printingkey
		  -- If copying Contract Tasks, skip copying contract elements here - they will be copied while copying Contract Tasks
		  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list,21) = 'Y'  --Copy Contract Tasks (21)
			SELECT @tobecopiedkey = MIN(q.taqelementkey)
			FROM taqprojectelement q
			WHERE q.bookkey = @v_copy_bookkey AND
				  q.printingkey = @v_copy_printingkey AND
			  (COALESCE(q.taqelementtypecode, 0) = 0 OR q.taqelementtypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(287, @v_newprojectitemtype, @v_newprojectusageclass))) AND			  
			  q.taqelementkey > @tobecopiedkey AND
			  q.taqelementtypecode IN (SELECT datacode FROM gentables WHERE tableid = 287 AND COALESCE(gen1ind,0) <> 1) AND
			  q.taqelementkey NOT IN (SELECT DISTINCT taqelementkey FROM taqprojecttask
									WHERE bookkey = @v_copy_bookkey AND printingkey = @v_copy_printingkey AND taqelementkey > 0 AND
									  datetypecode IN (SELECT datetypecode FROM taskviewdatetype 
													   WHERE taskviewkey = (SELECT taskviewkey FROM taskview WHERE qsicode = 5)))
		  ELSE
			SELECT @tobecopiedkey = MIN(q.taqelementkey)
			FROM taqprojectelement q
			WHERE q.bookkey = @v_copy_bookkey AND q.printingkey = @v_copy_printingkey AND
			  (COALESCE(q.taqelementtypecode, 0) = 0 OR q.taqelementtypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(287, @v_newprojectitemtype, @v_newprojectusageclass))) AND			  
			  q.taqelementkey > @tobecopiedkey AND
			  q.taqelementtypecode IN (SELECT datacode FROM gentables WHERE tableid = 287 AND COALESCE(gen1ind,0) <> 1) 
	  END
    END       
    ELSE
      select @tobecopiedkey = min(q.taqelementkey)
      from taqprojectelement q
      where bookkey = @i_copy_bookkey and printingkey = @i_copy_printingkey and q.taqelementkey > @tobecopiedkey AND		
      (COALESCE(q.taqelementtypecode, 0) = 0 OR q.taqelementtypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(287, @v_newprojectitemtype, @v_newprojectusageclass))) AND      
       q.taqelementtypecode in (select datacode from gentables where tableid = 287 and COALESCE(gen1ind,0) <> 1)
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

  IF @v_isPrinting = 0 AND @v_isPrinting2 = 0  BEGIN
	  SELECT @newkeycount = COUNT(*), @tobecopiedkey = MIN(e1.taqelementkey)
	  FROM taqprojectelement e1
	  WHERE e1.taqprojectkey = @i_copy2_projectkey AND
		e1.taqelementtypecode IN (SELECT datacode FROM gentables WHERE tableid = 287 AND COALESCE(gen1ind,0) <> 1) AND
	   (COALESCE(e1.taqelementtypecode, 0) = 0 OR e1.taqelementtypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(287, @v_newprojectitemtype, @v_newprojectusageclass))) AND	   
		NOT EXISTS (SELECT * FROM taqprojectelement e2 
					WHERE e1.taqelementtypecode = e2.taqelementtypecode AND 
						  e1.taqelementtypesubcode = e2.taqelementtypesubcode AND
						  e2.taqprojectkey = @i_copy_projectkey)
  END 
  ELSE IF @v_isPrinting = 1 AND @v_isPrinting2 = 1  BEGIN
	  SELECT @newkeycount = COUNT(*), @tobecopiedkey = MIN(e1.taqelementkey)
	  FROM taqprojectelement e1
	  WHERE e1.bookkey = @v_copy2_bookkey AND
		    e1.printingkey = @v_copy2_printingkey AND 
		e1.taqelementtypecode IN (SELECT datacode FROM gentables WHERE tableid = 287 AND COALESCE(gen1ind,0) <> 1) AND
	   (COALESCE(e1.taqelementtypecode, 0) = 0 OR e1.taqelementtypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(287, @v_newprojectitemtype, @v_newprojectusageclass))) AND	   
		NOT EXISTS (SELECT * FROM taqprojectelement e2 
					WHERE e1.taqelementtypecode = e2.taqelementtypecode AND 
						  e1.taqelementtypesubcode = e2.taqelementtypesubcode AND
						  e2.bookkey = @v_copy_bookkey AND
		                  e2.printingkey = @v_copy_printingkey)
  END
  ELSE IF @v_isPrinting = 0 AND @v_isPrinting2 = 1  BEGIN
	  SELECT @newkeycount = COUNT(*), @tobecopiedkey = MIN(e1.taqelementkey)
	  FROM taqprojectelement e1
	  WHERE e1.bookkey = @v_copy2_bookkey AND
		    e1.printingkey = @v_copy2_printingkey AND 
		e1.taqelementtypecode IN (SELECT datacode FROM gentables WHERE tableid = 287 AND COALESCE(gen1ind,0) <> 1) AND
	   (COALESCE(e1.taqelementtypecode, 0) = 0 OR e1.taqelementtypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(287, @v_newprojectitemtype, @v_newprojectusageclass))) AND	   
		NOT EXISTS (SELECT * FROM taqprojectelement e2 
					WHERE e1.taqelementtypecode = e2.taqelementtypecode AND 
						  e1.taqelementtypesubcode = e2.taqelementtypesubcode AND
						  e2.taqprojectkey = @i_copy_projectkey)
  END
  ELSE IF @v_isPrinting = 1 AND @v_isPrinting2 = 0  BEGIN
	  SELECT @newkeycount = COUNT(*), @tobecopiedkey = MIN(e1.taqelementkey)
	  FROM taqprojectelement e1
	  WHERE e1.taqprojectkey = @i_copy2_projectkey AND
		e1.taqelementtypecode IN (SELECT datacode FROM gentables WHERE tableid = 287 AND COALESCE(gen1ind,0) <> 1) AND
	   (COALESCE(e1.taqelementtypecode, 0) = 0 OR e1.taqelementtypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(287, @v_newprojectitemtype, @v_newprojectusageclass))) AND	   
		NOT EXISTS (SELECT * FROM taqprojectelement e2 
					WHERE e1.taqelementtypecode = e2.taqelementtypecode AND 
						  e1.taqelementtypesubcode = e2.taqelementtypesubcode AND
						  e2.bookkey = @v_copy_bookkey AND
		                  e2.printingkey = @v_copy_printingkey)
  END
                      
  SET @counter = 1
  SET @v_sortorder = @v_maxsort + 1
  
  WHILE @counter <= @newkeycount
  BEGIN

    EXEC get_next_key @i_userid, @newkey OUTPUT

	IF @v_isPrinting = 0 BEGIN
		INSERT INTO taqprojectelement
		  (taqelementkey, taqelementtypecode, taqelementtypesubcode, taqprojectkey, bookkey, printingkey, globalcontactkey, globalcontactkey2, 
		  taqelementnumber, taqelementdesc, addtlinfokey, sortorder, rolecode1, rolecode2, 
		  elementstatus, lastuserid, lastmaintdate, startpagenumber, endpagenumber)
		SELECT @newkey, taqelementtypecode, taqelementtypesubcode, @v_new_projectkey, @v_new_bookkey, @v_new_printingkey,  
		  CASE WHEN @copycontacts = 'N' THEN NULL ELSE globalcontactkey END,
		  CASE WHEN @copycontacts = 'N' THEN NULL ELSE globalcontactkey2 END,
		  taqelementnumber, taqelementdesc, addtlinfokey, @v_sortorder, 
		  CASE
			WHEN (COALESCE(rolecode1, 0) = 0 OR rolecode1 NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(285, @v_newprojectitemtype, @v_newprojectusageclass)))
			THEN NULL 
			ELSE rolecode1		  
		  END as rolecode1,     
		  CASE
			WHEN (COALESCE(rolecode2, 0) = 0 OR rolecode2 NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(285, @v_newprojectitemtype, @v_newprojectusageclass)))
			THEN NULL 
			ELSE rolecode2		  
		  END as rolecode2,	 
		  CASE
			WHEN (COALESCE(elementstatus, 0) = 0 OR elementstatus NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(593, @v_newprojectitemtype, @v_newprojectusageclass)))
			THEN NULL 
			ELSE elementstatus		  
		  END as elementstatus,	     
		  @i_userid, getdate(), startpagenumber, endpagenumber
		FROM taqprojectelement
		WHERE taqprojectkey = @i_copy2_projectkey AND taqelementkey = @tobecopiedkey

		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Copy/insert into taqprojectelement failed (' + cast(@error_var AS VARCHAR) + '): taqelementkey=' + cast(@tobecopiedkey AS VARCHAR)   
		  GOTO ExitHandler
		END 
	END
	BEGIN
		INSERT INTO taqprojectelement
		  (taqelementkey, taqelementtypecode, taqelementtypesubcode, taqprojectkey, bookkey, printingkey, globalcontactkey, globalcontactkey2, 
		  taqelementnumber, taqelementdesc, addtlinfokey, sortorder, rolecode1, rolecode2, 
		  elementstatus, lastuserid, lastmaintdate, startpagenumber, endpagenumber)
		SELECT @newkey, taqelementtypecode, taqelementtypesubcode, @v_new_projectkey, @v_new_bookkey, @v_new_printingkey,
		  CASE WHEN @copycontacts = 'N' THEN NULL ELSE globalcontactkey END,
		  CASE WHEN @copycontacts = 'N' THEN NULL ELSE globalcontactkey2 END,
		  taqelementnumber, taqelementdesc, addtlinfokey, @v_sortorder, 
		  CASE
			WHEN (COALESCE(rolecode1, 0) = 0 OR rolecode1 NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(285, @v_newprojectitemtype, @v_newprojectusageclass)))
			THEN NULL 
			ELSE rolecode1		  
		  END as rolecode1,     
		  CASE
			WHEN (COALESCE(rolecode2, 0) = 0 OR rolecode2 NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(285, @v_newprojectitemtype, @v_newprojectusageclass)))
			THEN NULL 
			ELSE rolecode2		  
		  END as rolecode2,	 
		  CASE
			WHEN (COALESCE(elementstatus, 0) = 0 OR elementstatus NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(593, @v_newprojectitemtype, @v_newprojectusageclass)))
			THEN NULL 
			ELSE elementstatus		  
		  END as elementstatus,	     
		  @i_userid, getdate(), startpagenumber, endpagenumber
		FROM taqprojectelement
		WHERE bookkey = @v_copy2_bookkey AND printingkey = @v_copy2_printingkey AND taqelementkey = @tobecopiedkey

		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Copy/insert into taqprojectelement failed (' + cast(@error_var AS VARCHAR) + '): taqelementkey=' + cast(@tobecopiedkey AS VARCHAR)   
		  GOTO ExitHandler
		END 
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
	  SET @v_newelementusageclass = 0
	  SELECT @v_newelementusageclass = taqelementtypecode
	  from taqprojectelement
	  where taqelementkey = @tobecopiedkey

      INSERT INTO qsicomments
        (commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext,
        commenthtml, commenthtmllite, lastuserid, lastmaintdate, invalidhtmlind, releasetoeloquenceind)
      SELECT @newkey, commenttypecode, commenttypesubcode, parenttable, commenttext,
        commenthtml, commenthtmllite, @i_userid, getdate(), invalidhtmlind, releasetoeloquenceind
      FROM qsicomments
      WHERE commentkey = @tobecopiedkey AND
	   (COALESCE(commenttypecode, 0) = 0 OR commenttypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(284, @v_newelementitemtype, @v_newelementusageclass))) AND
	   (COALESCE(commenttypesubcode, 0) = 0 OR commenttypesubcode IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(284, @v_newelementitemtype, @v_newelementusageclass) WHERE datacode = commenttypecode)) 

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
   
    IF @v_isPrinting = 0 AND @v_isPrinting2 = 0  BEGIN
		SELECT @tobecopiedkey = MIN(e1.taqelementkey)
		FROM taqprojectelement e1
		WHERE e1.taqprojectkey = @i_copy2_projectkey AND e1.taqelementkey > @tobecopiedkey AND
		  (COALESCE(e1.taqelementtypecode, 0) = 0 OR e1.taqelementtypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(287, @v_newprojectitemtype, @v_newprojectusageclass))) AND		  
		  e1.taqelementtypecode IN (SELECT datacode FROM gentables WHERE tableid = 287 AND COALESCE(gen1ind,0) <> 1) AND
		  NOT EXISTS (SELECT * FROM taqprojectelement e2 
					  WHERE e1.taqelementtypecode = e2.taqelementtypecode AND 
							e1.taqelementtypesubcode = e2.taqelementtypesubcode AND
							e2.taqprojectkey = @i_copy_projectkey) 
	END
    ELSE IF @v_isPrinting = 1 AND @v_isPrinting2 = 1  BEGIN		
		SELECT @tobecopiedkey = MIN(e1.taqelementkey)
		FROM taqprojectelement e1
		WHERE e1.bookkey = @v_copy2_bookkey AND e1.printingkey = @v_copy2_printingkey AND e1.taqelementkey > @tobecopiedkey AND
		  (COALESCE(e1.taqelementtypecode, 0) = 0 OR e1.taqelementtypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(287, @v_newprojectitemtype, @v_newprojectusageclass))) AND		  
		  e1.taqelementtypecode IN (SELECT datacode FROM gentables WHERE tableid = 287 AND COALESCE(gen1ind,0) <> 1) AND
		  NOT EXISTS (SELECT * FROM taqprojectelement e2 
					  WHERE e1.taqelementtypecode = e2.taqelementtypecode AND 
							e1.taqelementtypesubcode = e2.taqelementtypesubcode AND
							e2.bookkey = @v_copy_bookkey AND
							e2.printingkey = @v_copy_printingkey) 
	END
	ELSE IF @v_isPrinting = 0 AND @v_isPrinting2 = 1  BEGIN	
		SELECT @tobecopiedkey = MIN(e1.taqelementkey)
		FROM taqprojectelement e1
		WHERE e1.bookkey = @v_copy2_bookkey AND e1.printingkey = @v_copy2_printingkey AND e1.taqelementkey > @tobecopiedkey AND
		  (COALESCE(e1.taqelementtypecode, 0) = 0 OR e1.taqelementtypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(287, @v_newprojectitemtype, @v_newprojectusageclass))) AND		  
		  e1.taqelementtypecode IN (SELECT datacode FROM gentables WHERE tableid = 287 AND COALESCE(gen1ind,0) <> 1) AND
		  NOT EXISTS (SELECT * FROM taqprojectelement e2 
					  WHERE e1.taqelementtypecode = e2.taqelementtypecode AND 
							e1.taqelementtypesubcode = e2.taqelementtypesubcode AND
							e2.taqprojectkey = @i_copy_projectkey)
	END
	ELSE IF @v_isPrinting = 1 AND @v_isPrinting2 = 0  BEGIN
		SELECT @tobecopiedkey = MIN(e1.taqelementkey)
		FROM taqprojectelement e1
		WHERE e1.taqprojectkey = @i_copy2_projectkey AND e1.taqelementkey > @tobecopiedkey AND
		  (COALESCE(e1.taqelementtypecode, 0) = 0 OR e1.taqelementtypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(287, @v_newprojectitemtype, @v_newprojectusageclass))) AND		  
		  e1.taqelementtypecode IN (SELECT datacode FROM gentables WHERE tableid = 287 AND COALESCE(gen1ind,0) <> 1) AND
		  NOT EXISTS (SELECT * FROM taqprojectelement e2 
					  WHERE e1.taqelementtypecode = e2.taqelementtypecode AND 
							e1.taqelementtypesubcode = e2.taqelementtypesubcode AND
							e2.bookkey = @v_copy_bookkey AND
							e2.printingkey = @v_copy_printingkey) 			
	END			   
  END
END

------------
ExitHandler:
------------
  DROP TABLE #TempTaqprojectaskKeys

RETURN


