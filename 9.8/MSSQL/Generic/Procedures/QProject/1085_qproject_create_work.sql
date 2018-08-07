IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_create_work]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_create_work]
/****** Object:  StoredProcedure [dbo].[qproject_create_work]    Script Date: 07/16/2008 10:35:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_create_work]
		(@i_copy_projectkey     integer,
		@i_new_projectkey		integer,
		@i_userid				varchar(30),
		@i_skip_orgentry		tinyint,
		@i_new_projectname varchar(255),
		@o_new_projectkey		integer output,
		@o_error_code     integer output,
		@o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_create_work
**  Desc: This stored procedure copies the details of a title acquisition project 
**        into a work.
**        The project key to copy is passed as an argument.
**
**    Auth: Alan Katzen
**    Date: 2 March 2011
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:   Description:
**  -----     ------    -------------------------------------------
**  06/08/16  Colman    Case 38497 - Newly created Work is related to the Work Template
**  06/22/16  Colman    Case 38708   Tasks and elements not copied over to Work Project
**  07/15/16  Uday      Case 39219   Error generated adding advanced title
**  05/11/17  Colman    Case 44464 - Bug fix
*******************************************************************************/

SET @o_error_code = 0
SET @o_error_desc = ''

DECLARE @error_var	INT,
	@newkeycount	int,
	@tobecopiedkey	int,
	@newkey			int,
	@counter		int,
	@newkeycount2	int,
	@tobecopiedkey2	int,
	@newkey2		int,
	@counter2		int,
	@v_warnings VARCHAR(2000),
	@acq_project_relationshipcode int,
	@work_relationshipcode int,
  @copydatagroups_list VARCHAR(100),
  @o_elementkey int,
  @v_work_itemtype int,
  @v_work_usageclass int,
  @v_datagroup int

SET @v_warnings = ''
SET @copydatagroups_list = ''

IF @i_userid IS NULL
	SET @i_userid = 'qsiadmin'

SELECT @v_work_itemtype = datacode, @v_work_usageclass = datasubcode FROM subgentables WHERE qsicode = 28

DECLARE work_datagroups_cur CURSOR FOR
SELECT datacode FROM gentablesitemtype WHERE tableid=598 AND itemtypecode=@v_work_itemtype AND itemtypesubcode IN (@v_work_usageclass,0)
OPEN work_datagroups_cur
FETCH work_datagroups_cur INTO @v_datagroup
WHILE @@fetch_status = 0 BEGIN
  SET @copydatagroups_list = @copydatagroups_list + ',' + CAST(@v_datagroup AS VARCHAR)
  FETCH work_datagroups_cur INTO @v_datagroup
END
CLOSE work_datagroups_cur
DEALLOCATE work_datagroups_cur

if (@o_new_projectkey is null or @o_new_projectkey = 0) AND (@i_new_projectkey > 0)
begin
	SET @o_new_projectkey = @i_new_projectkey
end
else
begin
	exec qproject_copy_project_details_to_work
		@i_copy_projectkey,
		@o_new_projectkey,
		@i_userid,
		@i_new_projectname,
		@o_new_projectkey output,
		@o_error_code output,
		@o_error_desc output	

	IF @o_error_code <> 0 BEGIN
    print 'detail'+@o_error_desc
		RETURN
	END
END
print 'details done'

if @o_new_projectkey is null or @o_new_projectkey = 0
begin
	set @o_error_code = -1
	set @o_error_desc = 'No new project key.  It must be passed or project details must be copied.  (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
print 'projkey'+@o_error_desc
	RETURN
end

--select @itemtype_qsicode = g.qsicode, @usageclass_qsicode = sg.qsicode
--from taqproject p
--join gentables g
--on p.searchitemcode = g.datacode
--and g.tableid = 550
--join subgentables sg
--on p.searchitemcode = sg.datacode
--and p.usageclasscode = sg.datasubcode
--and sg.tableid = 550
--where taqprojectkey = @o_new_projectkey

IF COALESCE(@i_skip_orgentry, 0) = 0
BEGIN
	exec qproject_copy_project_orglevel
		@i_copy_projectkey,
		@o_new_projectkey,
		@i_userid,
		'',  --@i_cleardatagroups_list,
		@o_error_code output,
		@o_error_desc output	

	IF @o_error_code <> 0 BEGIN
	print 'org'+@o_error_desc
		RETURN
	END 	
	print 'org done'
END

IF dbo.find_integer_in_comma_delim_list (@copydatagroups_list,5) = 'Y'
BEGIN
  exec qproject_copy_project_comments
    @i_copy_projectkey,
      null,
    @o_new_projectkey,
    @i_userid,
    '',
    @o_error_code output,
    @o_error_desc output	

  IF @o_error_code <> 0 BEGIN
    print 'comment '+@o_error_desc
    RETURN
  END 
END

IF dbo.find_integer_in_comma_delim_list (@copydatagroups_list,6) = 'Y'
BEGIN
	exec qproject_copy_project_categories
    @i_copy_projectkey,
    0,
    @o_new_projectkey,
    @i_userid,
    '',
    @o_error_code output,
    @o_error_desc output	

	IF @o_error_code <> 0 BEGIN
    print 'category '+@o_error_desc
		RETURN
	END 
END

/*moved above contacts to solve a comp copy trigger issue 3/25/10 BL*/

IF dbo.find_integer_in_comma_delim_list (@copydatagroups_list,9) = 'Y'
BEGIN
  exec qproject_copy_project_contacts
    @i_copy_projectkey,
      null,
    @o_new_projectkey,
    @i_userid,
    '',
    @o_error_code output,
    @o_error_desc output	

  IF @o_error_code <> 0 BEGIN
    print 'contact '+@o_error_desc
    RETURN
  END 
END

IF dbo.find_integer_in_comma_delim_list (@copydatagroups_list,7) = 'Y'
BEGIN
  EXEC qproject_copy_project_element 
    @i_copy_projectkey,
    null,
    null,
    null,
    null,
    @o_new_projectkey,
    null,
    null,
    @i_userid,
    @copydatagroups_list,
    '',
    @o_elementkey output,
    @o_error_code output,
    @o_error_desc output

  IF @o_error_code <> 0 BEGIN
    print 'element '+@o_error_desc
    RETURN
  END 
END

IF dbo.find_integer_in_comma_delim_list (@copydatagroups_list,8) = 'Y'
BEGIN
  EXEC qproject_copy_project_nonelement_tasks
    @i_copy_projectkey,
    @o_new_projectkey,
    @i_userid,
    @copydatagroups_list,
    '',
    @o_error_code output,
    @o_error_desc output	

  IF @o_error_code <> 0 BEGIN
    print 'tasks '+@o_error_desc
    RETURN
  END 
END

IF dbo.find_integer_in_comma_delim_list (@copydatagroups_list,10) = 'Y'
BEGIN
  exec qproject_copy_project_relatedprojects
    @i_copy_projectkey,
    null,
    @o_new_projectkey,
    @i_userid,
    '',
    @o_error_code output,
    @o_error_desc output	

  IF @o_error_code <> 0 BEGIN
    print 'related projects '+@o_error_desc
    RETURN
  END 
END

IF dbo.find_integer_in_comma_delim_list (@copydatagroups_list,13) = 'Y'
BEGIN
  exec qproject_copy_project_miscitems
    @i_copy_projectkey,
      null,
    @o_new_projectkey,
    @i_userid,
    '',
    @o_error_code output,
    @o_error_desc output	

  IF @o_error_code <> 0 BEGIN
    print 'misc '+@o_error_desc
    RETURN
  END 
END

IF dbo.find_integer_in_comma_delim_list (@copydatagroups_list,14) = 'Y'
BEGIN
  exec qproject_copy_project_filelocations
    @i_copy_projectkey,
    null,
    null,     --copy_bookkey
    null,     --copy_printingkey
    @o_new_projectkey,
    null,     --new_bookkey
    null,     --new_printingkey
    null,			--copy_elementkey
    null,			--new_elementkey
    @i_userid,
    '',
    @o_error_code output,
    @o_error_desc output	

  IF @o_error_code <> 0 BEGIN
    print 'filelocations '+@o_error_desc
    RETURN
  END 
END

-- Copy P&L Versions 
SET @o_error_desc = ''
IF dbo.find_integer_in_comma_delim_list (@copydatagroups_list,16) = 'Y' OR dbo.find_integer_in_comma_delim_list (@copydatagroups_list,17) = 'Y'
BEGIN
  EXEC qproject_copy_project_plversion_to_work @i_copy_projectkey, @o_new_projectkey, @i_userid, 
    @o_error_code output, @o_error_desc output	

  IF @o_error_code = 100 BEGIN
    IF @v_warnings <> ''
      SET @v_warnings = @v_warnings + '<newline>'
    SET @v_warnings = @v_warnings + @o_error_desc
  END
  ELSE IF @o_error_code <> 0 BEGIN
    PRINT 'Current P&L version ' + @o_error_desc
    RETURN
  END 
END

-- Create a Project Relationship between the Acq Project and the Work
declare @v_from_is_taq int, @v_to_is_work int
select @v_from_is_taq = COUNT(*) from taqproject t join subgentables s on s.datacode = t.searchitemcode and s.datasubcode = t.usageclasscode where t.taqprojectkey=@i_copy_projectkey and s.qsicode=1
select @v_to_is_work = COUNT(*) from taqproject t join subgentables s on s.datacode = t.searchitemcode and s.datasubcode = t.usageclasscode where t.taqprojectkey=@o_new_projectkey and s.qsicode=28

IF @v_from_is_taq > 0 AND @v_to_is_work > 0
BEGIN
  select @acq_project_relationshipcode = datacode
  from gentables
  where tableid = 582
  and qsicode = 14

  select @work_relationshipcode = datacode
  from gentables
  where tableid = 582
  and qsicode = 15

  exec qproject_copy_project_insert_relationship @o_new_projectkey, @i_copy_projectkey, @acq_project_relationshipcode, 
    @work_relationshipcode, @i_userid, @o_error_code output, @o_error_desc output

  IF @o_error_code <> 0 BEGIN
    RETURN
  END 	
END

-- Auto Generates any Product ID that are set to autogenerate
exec qproject_autogenerate_productid @o_new_projectkey, @i_userid, @o_error_code output, @o_error_desc output

IF @o_error_code <> 0 BEGIN
	RETURN
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

GRANT EXEC ON qproject_create_work TO PUBLIC
GO

