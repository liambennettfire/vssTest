IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_details_to_work]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_project_details_to_work]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_details_to_work]    Script Date: 07/16/2008 10:32:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[qproject_copy_project_details_to_work]
		(@i_copy_projectkey     integer,
		@i_new_projectkey		integer,
		@i_userid				varchar(30),
		@i_new_projectname varchar(255),
		@o_new_projectkey		integer output,
		@o_error_code			integer output,
		@o_error_desc			varchar(2000) output)
AS

/******************************************************************************
**  Name: [qproject_copy_project_details_to_work]
**  Desc: This stored procedure copies the details of a title acquisition to a work.
**        The project key to copy is passed as an argument.
**
**			If you call this procedure from anyplace other than qproject_copy_project,
**			you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Alan Katzen
**    Date: 2 March 2011
**************************************************************************************************************************
**    Change History
**************************************************************************************************************************
**  Date:       Author:   Description:
**  --------    -------   --------------------------------------
**  06/21/2016  Colman    Case 38708 PL currency not copied over from Work Template to Work Project
**  06/24/16    Uday      Case 38798 Add season to the project details
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
	@userkey int,
	@new_projectname varchar(255),
	@work_itemtype int,
	@work_usageclass int,
	@work_project_statuscode int,
	@work_project_type int,
	@copy_from_project_type int

if @i_copy_projectkey is null or @i_copy_projectkey = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'copy project key not passed to copy project details (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
end

SELECT @work_itemtype = datacode
  FROM gentables
 WHERE tableid = 550
   and qsicode = 9

if @work_itemtype is null or @work_itemtype = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'Work Item Type could not be found (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
end

SELECT @work_usageclass = datasubcode
  FROM subgentables
 WHERE tableid = 550
   and datacode = @work_itemtype
   and qsicode = 28

if @work_usageclass is null or @work_usageclass = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'Work Usage Class could not be found (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
end

-- set initial status to "Active"
SELECT @work_project_statuscode = datacode
  FROM gentables
 WHERE tableid = 522
   and qsicode = 3

if @work_project_statuscode is null or @work_project_statuscode = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'Initial Work Project Status could not be found (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
end

-- see if there is a gentablesrelationship setup to translate the 
-- acq project project type to a work project type 
SELECT @copy_from_project_type = taqprojecttype
  FROM taqproject
 WHERE taqprojectkey = @i_copy_projectkey

-- "work" project type should exist if no relationship
if @copy_from_project_type > 0 begin
  SELECT @work_project_type = code2 
    FROM gentablesrelationshipdetail
   WHERE gentablesrelationshipkey = 17
     and code1 = @copy_from_project_type
end

if @work_project_type is null OR @work_project_type = 0 begin
  SELECT @work_project_type = datacode 
    FROM gentables
   WHERE tableid = 521
     and qsicode = 2
end

-- if not just use the acq project type     
if @work_project_type is null OR @work_project_type = 0 begin
  set @work_project_type = @copy_from_project_type
end

if (@i_new_projectkey is null or @i_new_projectkey = 0)
begin
  set @userkey = null
  select @userkey = userkey
    from qsiusers
   where userid = @i_userid

  if @userkey is null begin
	  select @userkey = clientdefaultvalue
	  from clientdefaults
	  where clientdefaultid = 48
	end

	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 OR @userkey is null BEGIN
		SET @userkey = -1
  END 
    
	EXEC get_next_key @i_userid, @o_new_projectkey OUTPUT

  SET @new_projectname = @i_new_projectname
  IF (@new_projectname is null OR @new_projectname = '') BEGIN
    SET @new_projectname = 'New Work'
  END
  
	insert into taqproject
		(taqprojectkey,taqprojectownerkey,taqprojecttitle,taqprojectsubtitle,taqprojecttype,taqprojecteditionnumcode,
		taqprojectseriescode,taqprojectstatuscode,templateind,lockorigdateind,lastuserid,lastmaintdate,
		taqprojecttitleprefix,taqprojecteditiontypecode,taqprojecteditiondesc,taqprojectvolumenumber,
		termsofagreement,subsidyind,idnumber,usageclasscode,searchitemcode,additionaleditioninfo,defaulttemplateind,autogeneratenameind,
		plenteredcurrency, plapprovalcurrency, seasoncode) 
	select @o_new_projectkey, @userkey, @new_projectname, taqprojectsubtitle,
		@work_project_type, taqprojecteditionnumcode, taqprojectseriescode, @work_project_statuscode, 
		0, lockorigdateind, @i_userid, getdate(),taqprojecttitleprefix, taqprojecteditiontypecode, 
		taqprojecteditiondesc, taqprojectvolumenumber, termsofagreement, subsidyind, 
		idnumber, @work_usageclass, @work_itemtype, additionaleditioninfo, 0, autogeneratenameind,
		plenteredcurrency, plapprovalcurrency, seasoncode
	from taqproject
	where taqprojectkey = @i_copy_projectkey

	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'copy/insert into taqproject failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
		RETURN
	END 

	exec qproject_copy_project_productnumber
		@i_copy_projectkey,
		null,   --@i_copy2_projectkey,
		null,   --@i_copy_bookkey,
		null,   --@i_copy_printingkey,
		@o_new_projectkey,
		null,   --new_bookkey
		null,   --new_printingkey
		null,		--copy_elementkey
		null,		--new_elementkey
		@i_userid,
		'',     --@i_cleardatagroups_list
		@o_error_code output,
		@o_error_desc output	

	IF @o_error_code <> 0 BEGIN
		RETURN
	END 

end
else begin
	set @o_new_projectkey = @i_new_projectkey
end

RETURN
