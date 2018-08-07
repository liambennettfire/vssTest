IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_project]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project]    Script Date: 07/16/2008 10:35:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project]
		(@i_copy_projectkey integer,
		@i_copy2_projectkey integer,
		@i_new_projectkey		integer,
		@i_copydatagroups_list	varchar(max),
		@i_cleardatagroups_list	varchar(max),
		@i_related_journalkey	integer,
		@i_related_volumekey	integer,
		@i_related_issuekey		integer,
		@i_userid				varchar(30),
		@i_new_projectname varchar(255),
		@o_new_projectkey		integer output,
		@o_error_code     integer output,
		@o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_copy_project
**  Desc: This stored procedure copies the details of 1 project into a new project.
**        The project key to copy and the data groups to copy are passed as arguments.
**
**    Auth: Jennifer Hurd
**    Date: 23 June 2008
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:        Case #:   Description:
**    --------    --------       -------   --------------------------------------
**   06/23/2014   Uday A.Khisty  27689     Copy Specification Templates
*******************************************************************************/
begin transaction

SET @o_error_code = 0
SET @o_error_desc = ''

DECLARE @error_var	INT,
  @v_rowcount INT,
	@newkeycount	int,
	@tobecopiedkey	int,
	@newkey			int,
	@counter		int,
	@newkeycount2	int,
	@tobecopiedkey2	int,
	@newkey2		int,
	@counter2		int,
	@elementkey		int,
	@itemtype_qsicode		int,
	@itemtypecode		int,
	@usageclass_qsicode		int,
	@usageclasscode		int,
	@loc  int,
	@request_projectkey int,
	@v_first_stage_pl_copied  tinyint,
	@v_warnings VARCHAR(2000),
	@v_initial_verification_status int,
	@v_taqprojectformatkey int,
	@v_cur_versionformatkey	INT,
  @v_cur_stage	INT,
  @v_cur_version	INT,
  @v_error  INT,
  @v_errordesc	VARCHAR(2000) 


SET @v_warnings = ''

if @i_copydatagroups_list is null	--default @i_copydatagroups_list to all(?) if it is blank - ask Susan
begin
	select @newkeycount = max(qsicode)
	from gentables
	where tableid = 598

	set @counter = 1
	set @i_copydatagroups_list = ''

	while @counter <= @newkeycount
	begin
		if @counter < @newkeycount
		begin
			set @i_copydatagroups_list = @i_copydatagroups_list + rtrim(convert(varchar,@counter)) + ','
		end
		else 
		begin
			set @i_copydatagroups_list = @i_copydatagroups_list + rtrim(convert(varchar,@counter))
		end

		set @counter = @counter + 1
	end
end

if @i_cleardatagroups_list is null
begin
	set @i_cleardatagroups_list = ''
end

-- For DWO projects, the request projectkey is passed in the @i_new_projectname argument - parse it out
if (@i_new_projectname is not null)
begin
  set @loc = CHARINDEX('DWORequestKey=', @i_new_projectname)
  if (@loc > 0)
  begin
    set @request_projectkey = CONVERT(int, SUBSTRING(@i_new_projectname, @loc + 14, 2000))
  end
  
  print '@request projectkey: ' + CONVERT(VARCHAR, @request_projectkey)
end

if (@o_new_projectkey is null or @o_new_projectkey = 0) AND (@i_new_projectkey > 0)
begin
	SET @o_new_projectkey = @i_new_projectkey
end
else
begin
	if dbo.find_integer_in_comma_delim_list (@i_copydatagroups_list,1) = 'Y'
	begin	
		exec qproject_copy_project_details
			@i_copy_projectkey,
			@i_copy2_projectkey,
			null,	--copy_bookkey
			null,	--copy_printingkey
			@o_new_projectkey,
			@i_userid,
			@i_copydatagroups_list,
			@i_cleardatagroups_list,
			@i_new_projectname,
			@o_new_projectkey output,
			@o_error_code output,
			@o_error_desc output	

		IF @o_error_code <> 0 BEGIN
			ROLLBACK
print 'detail'+@o_error_desc
			RETURN
		END
	end   
END
print 'details done'

if @o_new_projectkey is null or @o_new_projectkey = 0
begin
	set @o_error_code = -1
	set @o_error_desc = 'No new project key.  It must be passed or project details must be copied.  (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	ROLLBACK
print 'projkey'+@o_error_desc
	RETURN
end

select @itemtype_qsicode = g.qsicode, @usageclass_qsicode = sg.qsicode,
@itemtypecode = sg.datacode, @usageclasscode = sg.datasubcode 
from taqproject p
join gentables g
on p.searchitemcode = g.datacode
and g.tableid = 550
join subgentables sg
on p.searchitemcode = sg.datacode
and p.usageclasscode = sg.datasubcode
and sg.tableid = 550
where taqprojectkey = @o_new_projectkey

-- insert taqprojectverification rows for this itemtype/usageclass
SELECT @v_initial_verification_status = COALESCE(datacode,0)
  FROM gentables
 WHERE tableid = 513 AND qsicode = 1

SELECT @error_var = @@ERROR, @v_rowcount = @@ROWCOUNT
IF @error_var <> 0 or @v_rowcount = 0 BEGIN
  SET @v_initial_verification_status = 0
END 

INSERT INTO taqprojectverification 
       (taqprojectkey,verificationtypecode,verificationstatuscode,lastuserid,lastmaintdate)
SELECT @o_new_projectkey,g.datacode,@v_initial_verification_status,@i_userid,GETDATE()
  FROM gentables g, gentablesitemtype gi
 WHERE g.tableid = gi.tableid and
       g.datacode = gi.datacode and
       gi.itemtypecode = @itemtypecode and
       (gi.itemtypesubcode = @usageclasscode OR gi.itemtypesubcode = 0) and
       g.tableid = 628

SELECT @error_var = @@ERROR, @v_rowcount = @@ROWCOUNT
IF @error_var <> 0 BEGIN
		ROLLBACK
		SET @o_error_code = @error_var
		SET @o_error_desc = 'Unable to insert to taqprojectverification'
print 'verifcation '+@o_error_desc
		RETURN
END 
print 'verifcation done'

if dbo.find_integer_in_comma_delim_list (@i_copydatagroups_list,2) = 'Y'
begin
	exec qproject_copy_project_orglevel
		@i_copy_projectkey,
		@o_new_projectkey,
		@i_userid,
		@i_cleardatagroups_list,
		@o_error_code output,
		@o_error_desc output	

	IF @o_error_code <> 0 BEGIN
		ROLLBACK
print 'org'+@o_error_desc
		RETURN
	END 	
END
print 'org done'

if dbo.find_integer_in_comma_delim_list (@i_copydatagroups_list,4) = 'Y'
begin
	exec qproject_copy_project_formats
		@i_copy_projectkey,
		@i_copy2_projectkey,
		@o_new_projectkey,
		@i_userid,
		@i_cleardatagroups_list,
		@o_error_code output,
		@o_error_desc output	

	IF @o_error_code <> 0 BEGIN
		ROLLBACK
print 'format'+@o_error_desc
		RETURN
	END 
END

if dbo.find_integer_in_comma_delim_list (@i_copydatagroups_list,5) = 'Y'
begin
	exec qproject_copy_project_comments
		@i_copy_projectkey,
		@i_copy2_projectkey,
		@o_new_projectkey,
		@i_userid,
		@i_cleardatagroups_list,
		@o_error_code output,
		@o_error_desc output	

	IF @o_error_code <> 0 BEGIN
		ROLLBACK
print 'comment'+@o_error_desc
		RETURN
	END 
END

if dbo.find_integer_in_comma_delim_list (@i_copydatagroups_list,6) = 'Y'
begin
	exec qproject_copy_project_categories
		@i_copy_projectkey,
		@i_copy2_projectkey,
		@o_new_projectkey,
		@i_userid,
		@i_cleardatagroups_list,
		@o_error_code output,
		@o_error_desc output	

	IF @o_error_code <> 0 BEGIN
		ROLLBACK
print 'category'+@o_error_desc
		RETURN
	END 
END

if dbo.find_integer_in_comma_delim_list (@i_copydatagroups_list,7) = 'Y'
begin
	exec qproject_copy_project_element 
			@i_copy_projectkey,
			@i_copy2_projectkey,
			null,
			null,
			null,
			@o_new_projectkey,
			null,
			null,
			@i_userid,
			@i_copydatagroups_list,
			@i_cleardatagroups_list,
			@elementkey output,
			@o_error_code output,
			@o_error_desc output

	IF @o_error_code <> 0 BEGIN
		ROLLBACK
print 'element'+@o_error_desc
		RETURN
	END 
end

-- The above procedure qproject_copy_project_element will take care of creating the tasks
-- associated with an element.  The rest will be created here.
if dbo.find_integer_in_comma_delim_list (@i_copydatagroups_list,8) = 'Y'
begin
	exec qproject_copy_project_nonelement_tasks
		@i_copy_projectkey,
		@o_new_projectkey,
		@i_userid,
		@i_copydatagroups_list,
		@i_cleardatagroups_list,
		@o_error_code output,
		@o_error_desc output	

	IF @o_error_code <> 0 BEGIN
		ROLLBACK
print 'task'+@o_error_desc
		RETURN
	END 
END

/*moved above contacts to solve a comp copy trigger issue 3/25/10 BL*/

if dbo.find_integer_in_comma_delim_list (@i_copydatagroups_list,12) = 'Y'
begin
	exec qproject_copy_project_quantity
		@i_copy_projectkey,
		@i_copy2_projectkey,
		@o_new_projectkey,
		@i_userid,
		@i_cleardatagroups_list,
		@o_error_code output,
		@o_error_desc output	

	IF @o_error_code <> 0 BEGIN
		ROLLBACK
print 'quantity'+@o_error_desc
		RETURN
	END 
END


if dbo.find_integer_in_comma_delim_list (@i_copydatagroups_list,9) = 'Y'
begin
	exec qproject_copy_project_contacts
		@i_copy_projectkey,
		@i_copy2_projectkey,
		@o_new_projectkey,
		@i_userid,
		@i_cleardatagroups_list,
		@o_error_code output,
		@o_error_desc output	

	IF @o_error_code <> 0 BEGIN
		ROLLBACK
print 'contact'+@o_error_desc
		RETURN
	END 
END

IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 10) = 'Y'
  BEGIN
    EXEC qproject_copy_project_relatedprojects
    @i_copy_projectkey,
    @i_copy2_projectkey,
    @o_new_projectkey,
    @i_userid,
    @i_cleardatagroups_list,
    @o_error_code OUTPUT,
    @o_error_desc OUTPUT

    IF @o_error_code <> 0
      BEGIN
        ROLLBACK
        PRINT 'related projects' + @o_error_desc
        RETURN
      END
  END

-- copy formats (4) will copy all rows on taqprojecttitle, so no need to do this
if (dbo.find_integer_in_comma_delim_list (@i_copydatagroups_list,15) = 'Y')
begin
	exec qproject_copy_project_relatedtitles
		@i_copy_projectkey,
		@i_copy2_projectkey,
		@o_new_projectkey,
		0,
		0,
		@i_userid,
		@o_error_code output,
		@o_error_desc output	

	IF @o_error_code <> 0 BEGIN
		ROLLBACK
print 'related titles'+@o_error_desc
		RETURN
	END 
END

if dbo.find_integer_in_comma_delim_list (@i_copydatagroups_list,11) = 'Y'
begin
	exec qproject_copy_project_prices
		@i_copy_projectkey,
		@i_copy2_projectkey,
		@o_new_projectkey,
		@i_userid,
		@i_cleardatagroups_list,
		@o_error_code output,
		@o_error_desc output	

	IF @o_error_code <> 0 BEGIN
		ROLLBACK
print 'price'+@o_error_desc
		RETURN
	END 
END

/*moved qty copy up to solve a trigger issue*/

if dbo.find_integer_in_comma_delim_list (@i_copydatagroups_list,13) = 'Y'
begin
	exec qproject_copy_project_miscitems
		@i_copy_projectkey,
		@i_copy2_projectkey,
		@o_new_projectkey,
		@i_userid,
		@i_cleardatagroups_list,
		@o_error_code output,
		@o_error_desc output	

	IF @o_error_code <> 0 BEGIN
		ROLLBACK
print 'misc'+@o_error_desc
		RETURN
	END 
END

if dbo.find_integer_in_comma_delim_list (@i_copydatagroups_list,14) = 'Y'
begin
	exec qproject_copy_project_filelocations
		@i_copy_projectkey,
		@i_copy2_projectkey,
		null,     --copy_bookkey
		null,     --copy_printingkey
		@o_new_projectkey,
		null,     --new_bookkey
		null,     --new_printingkey
		null,			--copy_elementkey
		null,			--new_elementkey
		@i_userid,
		@i_cleardatagroups_list,
		@o_error_code output,
		@o_error_desc output	

	IF @o_error_code <> 0 BEGIN
		ROLLBACK	
		RETURN
	END
END

-- Copy selected P&L Version for the first stage
SET @v_first_stage_pl_copied = 0
IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list,16) = 'Y'
BEGIN
	EXEC qproject_copy_project_plversion @i_copy_projectkey, @i_copy2_projectkey, @o_new_projectkey, 1, 0, @i_userid, 
	  @o_error_code output, @o_error_desc output	

  IF @o_error_code = 100 BEGIN
    IF @v_warnings <> ''
      SET @v_warnings = @v_warnings + '<newline>'
    SET @v_warnings = @v_warnings + @o_error_desc
  END
  ELSE IF @o_error_code <> 0 BEGIN
		ROLLBACK
    PRINT 'First P&L version ' + @o_error_desc
		RETURN
	END
	
	SET @v_first_stage_pl_copied = 1
END

-- Copy selected P&L Version for the current stage
IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list,17) = 'Y'
BEGIN
  SET @o_error_desc = ''
	EXEC qproject_copy_project_plversion @i_copy_projectkey, @i_copy2_projectkey, @o_new_projectkey, 0, @v_first_stage_pl_copied, @i_userid, 
	  @o_error_code output, @o_error_desc output	

  IF @o_error_code = 100 BEGIN
    IF @v_warnings <> ''
      SET @v_warnings = @v_warnings + '<newline>'
    SET @v_warnings = @v_warnings + @o_error_desc
  END
	ELSE IF @o_error_code <> 0 BEGIN
		ROLLBACK
    PRINT 'Current P&L version ' + @o_error_desc
		RETURN
	END 
END

if dbo.find_integer_in_comma_delim_list (@i_copydatagroups_list,18) = 'Y'
begin
	exec qproject_copy_project_scale_orglevel
		@i_copy_projectkey,
		@o_new_projectkey,
		@i_userid,
		@i_cleardatagroups_list,
		@o_error_code output,
		@o_error_desc output	

	IF @o_error_code <> 0 BEGIN
		ROLLBACK
print 'scale org '+@o_error_desc
		RETURN
	END 	
END
print 'scale org done'

if dbo.find_integer_in_comma_delim_list (@i_copydatagroups_list,19) = 'Y'
begin
	exec qproject_copy_project_scale_parameters
		@i_copy_projectkey,
		@o_new_projectkey,
		@i_userid,
		@i_cleardatagroups_list,
		@o_error_code output,
		@o_error_desc output	

	IF @o_error_code <> 0 BEGIN
		ROLLBACK
print 'scale parameters '+@o_error_desc
		RETURN
	END 	
END
print 'scale parameters done'

if dbo.find_integer_in_comma_delim_list (@i_copydatagroups_list,20) = 'Y'
begin
	exec qproject_copy_project_scale_details
		@i_copy_projectkey,
		@o_new_projectkey,
		@i_userid,
		@i_cleardatagroups_list,
		@o_error_code output,
		@o_error_desc output	

	IF @o_error_code <> 0 BEGIN
		ROLLBACK
print 'scale details '+@o_error_desc
		RETURN
	END 	
END
print 'scale details done'

-- Copy Contract Tasks
IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list,21) = 'Y'
BEGIN
  SET @o_error_desc = ''
	EXEC qproject_copy_project_contract_tasks @i_copy_projectkey, @i_copy2_projectkey, @o_new_projectkey, @i_userid, 
		@i_copydatagroups_list, @i_cleardatagroups_list, @o_error_code OUTPUT, @o_error_desc OUTPUT  

  IF @o_error_code <> 0 BEGIN
		ROLLBACK
    PRINT 'Contract Tasks ' + @o_error_desc
		RETURN
	END 
END

-- Copy Contract Royalty Payment info
IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list,22) = 'Y'
BEGIN
  SET @o_error_desc = ''
	EXEC qproject_copy_project_contract_payments @i_copy_projectkey, @i_copy2_projectkey, @o_new_projectkey, @i_userid, 
		@o_error_code OUTPUT, @o_error_desc OUTPUT  

  IF @o_error_code <> 0 BEGIN
		ROLLBACK
    PRINT 'Contract Royalty Payment' + @o_error_desc
		RETURN
	END 
END

-- Copy Contract Royalty info
IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list,23) = 'Y'
BEGIN
  SET @o_error_desc = ''
	EXEC qproject_copy_project_contract_royalty @i_copy_projectkey, @i_copy2_projectkey, @o_new_projectkey, @i_userid, 
		@o_error_code OUTPUT, @o_error_desc OUTPUT  

  IF @o_error_code <> 0 BEGIN
		ROLLBACK
    PRINT 'Contract Royalty ' + @o_error_desc
		RETURN
	END 
END

-- Copy Contract Rights and Territory info
IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list,24) = 'Y'
BEGIN
  SET @o_error_desc = ''
	EXEC qproject_copy_project_contract_rights @i_copy_projectkey, @i_copy2_projectkey, @o_new_projectkey, @i_userid, 
		@o_error_code OUTPUT, @o_error_desc OUTPUT  

  IF @o_error_code <> 0 BEGIN
		ROLLBACK
    PRINT 'Contract Rights and Territory ' + @o_error_desc
		RETURN
	END 
END

-- Relate/Create New Related Projects during copy
IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 26) = 'Y'
  BEGIN
    EXEC qproject_copy_project_relatecreate_new_relatedprojects
    @i_copy_projectkey,
    @i_copy2_projectkey,
    @o_new_projectkey,
    @i_userid,
    @i_cleardatagroups_list,
    @o_error_code OUTPUT,
    @o_error_desc OUTPUT

    IF @o_error_code <> 0
      BEGIN
        ROLLBACK
        PRINT 'related projects' + @o_error_desc
        RETURN
      END
  END  

exec qproject_copy_project_additional @i_copy_projectkey, @i_copy2_projectkey, @o_new_projectkey,
    @i_userid, @i_copydatagroups_list, @i_cleardatagroups_list, 
    @i_related_journalkey, @i_related_volumekey, @i_related_issuekey,
    @itemtype_qsicode, @usageclass_qsicode, @o_error_code output, @o_error_desc output

IF @o_error_code <> 0 BEGIN
	ROLLBACK	
	RETURN
END 

COMMIT

IF @itemtype_qsicode = 3 BEGIN  --Project
  IF @usageclass_qsicode = 11 BEGIN --Journal Acquisition
    -- If we just created a new Journal Acquisition, we need to create a related Journal Record
    -- need call this after transaction ends because we are creating a new project
    -- which will start a new transaction
    
    begin transaction JournalAcquisition

    exec qproject_copy_project_create_related_journal @i_copy_projectkey, @o_new_projectkey, @i_userid, 
        @i_copydatagroups_list, @i_cleardatagroups_list, @itemtype_qsicode, @usageclass_qsicode, 
        @o_error_code output, @o_error_desc output 
    		
    IF @o_error_code <> 0 BEGIN
	    ROLLBACK transaction JournalAcquisition
	    RETURN
    END 

    COMMIT transaction JournalAcquisition
  END
  
  ELSE IF @usageclass_qsicode = 15 BEGIN --DWO
  
    PRINT 'creating dwo'
  
    BEGIN TRANSACTION DWOFromRequest
    
    EXEC qproject_create_dwo @request_projectkey, @o_new_projectkey, @i_userid,
        @o_error_code OUTPUT, @o_error_desc OUTPUT
        
    IF @o_error_code <> 0 BEGIN
	    ROLLBACK TRANSACTION DWOFromRequest
	    RETURN
    END 

    COMMIT TRANSACTION DWOFromRequest
  END        
END

IF @itemtype_qsicode = 11 --Scale
BEGIN
	IF @o_new_projectkey > 0
	BEGIN
		EXECUTE qscale_maintain_corescaleparameters @o_new_projectkey, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT  
		  
		IF @o_error_code < 0 BEGIN
			PRINT 'error in qscale_maintain_corescaleparameters: ' + @o_error_desc
			RETURN
		END
  END
END

-- Copy Production Specifications
IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list,25) = 'Y'
BEGIN
  -- Get the most recent active stage on this project that has a selected version
  SELECT @v_cur_stage = dbo.qpl_get_most_recent_stage(@o_new_projectkey)
  
  IF @v_cur_stage <= 0	--error occurred or no selected version exists for any active stage on this project
  BEGIN	
    -- Get the most recent stage existing on this project (regardless of whether it has a selected version)
    SELECT TOP(1) @v_cur_stage = g.datacode 
    FROM gentablesitemtype gi, gentables g, taqplstage p
    WHERE g.tableid = gi.tableid AND g.datacode = gi.datacode AND g.deletestatus = 'N'
      AND p.plstagecode = g.datacode AND p.taqprojectkey = @o_new_projectkey
      AND gi.tableid = 562 AND gi.itemtypecode = @itemtypecode 
      AND (gi.itemtypesubcode = @usageclasscode OR gi.itemtypesubcode = 0)
    ORDER BY gi.sortorder DESC, g.sortorder DESC
    
    IF @v_cur_stage <= 0	--no stages exist on this project
    BEGIN
      -- Get the first active stage for this project's Item Type and Usage Class
      SELECT TOP(1) @v_cur_stage = g.datacode FROM gentablesitemtype gi, gentables g
      WHERE g.tableid = gi.tableid AND g.datacode = gi.datacode AND g.deletestatus = 'N'
        AND gi.tableid = 562 AND gi.itemtypecode = @itemtypecode
        AND (gi.itemtypesubcode = @usageclasscode OR gi.itemtypesubcode = 0)
      ORDER BY gi.sortorder ASC, g.sortorder ASC
      
      IF @v_cur_stage IS NULL
        SET @v_cur_stage = 0
    END
  END
  
  -- Get the selected version for the most recent active stage on the project
  SELECT @v_cur_version = selectedversionkey 
  FROM taqplstage 
  WHERE taqprojectkey = @o_new_projectkey AND plstagecode = @v_cur_stage
  
  IF @v_cur_version IS NULL OR @v_cur_version = 0	--no selected version exist for any active stage on this project
  BEGIN
    -- Get the next versionkey to use for this stage
    SELECT @v_cur_version = COALESCE(MAX(taqversionkey),0) + 1 
    FROM taqversion 
    WHERE taqprojectkey = @o_new_projectkey
  END
  
  -- Call the stored procedure that will check if this version exists, and if not, it will add it.
  -- It will also add taqversionformat row if none exist for the version (in which case the generated taqversionformatkey will be passed out).
  EXEC qpl_check_taqversion @o_new_projectkey, @v_cur_stage, @v_cur_version, 
    @v_cur_versionformatkey OUTPUT, @v_error OUTPUT, @v_errordesc OUTPUT
  
  IF @v_error < 0 BEGIN
    SET @o_error_desc = @v_errordesc
    SET @o_error_code = @v_error
    return
  END

  SET @o_error_desc = ''	
  DECLARE taqversionformat_cursor CURSOR FOR
	SELECT taqprojectformatkey
	FROM taqversionformat
	WHERE taqprojectkey = @o_new_projectkey

	OPEN taqversionformat_cursor

	FETCH taqversionformat_cursor
	INTO @v_TaqProjectFormatKey

	WHILE (@@FETCH_STATUS = 0)
	BEGIN  			
	  EXEC qspec_apply_specificationtemplate @o_new_projectkey, @i_copy_projectkey
		,@v_TaqProjectFormatKey, @itemtypecode, @usageclasscode, @i_userid, 2, @o_error_code OUTPUT, @o_error_desc OUTPUT		

	  IF @o_error_code <> 0 BEGIN
			ROLLBACK
		PRINT 'Copy Production Specifications ' + @o_error_desc
			RETURN
		END 
		
		FETCH taqversionformat_cursor
		INTO @v_TaqProjectFormatKey
	END

	CLOSE taqversionformat_cursor
	DEALLOCATE taqversionformat_cursor 	
END


/* 12/2/10 - KW - Per Susan, don't display warnings because this procedure is used by "batch processes".
IF @v_warnings <> '' BEGIN
  SET @o_error_code = -2
  SET @o_error_desc = 'Warnings:<newline>' + @v_warnings
END
*/

RETURN
GO

set nocount off
GO

GRANT EXEC ON qproject_copy_project TO PUBLIC
GO

