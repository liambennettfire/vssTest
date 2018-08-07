IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_details]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_project_details]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_details]    Script Date: 07/16/2008 10:32:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project_details]
  (@i_copy_projectkey integer,
  @i_copy2_projectkey integer,
  @i_copy_bookkey     integer,
  @i_copy_printingkey integer,
  @i_new_projectkey		integer,
  @i_userid				varchar(30),
  @i_copydatagroups_list	varchar(max),
  @i_cleardatagroups_list	varchar(max),
  @i_new_projectname varchar(255),
  @o_new_projectkey		integer output,
  @o_error_code			integer output,
  @o_error_desc			varchar(2000) output)
AS

/****************************************************************************************************************************
**  Name: [qproject_copy_project_details]
**  Desc: This stored procedure copies the details of 1 or all elements to new elements.
**        The project key to copy and the data groups to copy are passed as arguments.
**
**			If you call this procedure from anyplace other than qproject_copy_project,
**			you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Jennifer Hurd
**    Date: 23 June 2008
*****************************************************************************************************************************
**    Change History
*****************************************************************************************************************************
**    Date:        Author:         Description:
**    --------     --------        ------------------------------------------------------------------------------------------
**    05/16/2016   Uday			   Case 37359 Allow "Copy from Project" to be a different class from project being created 
**    06/09/16     Kusum           Case 35718
**    06/24/16     Uday            Case 38798 Add season to the project details
**    11/10/16     Uday            Case 41641
**    01/30/17     Colman          Case 42639 - added rightsimpactcode column
**    05/25/18     Colman          Case 51542
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
	@newkey2		int,
	@counter2		int,
	@userkey int,
	@new_projectname varchar(255),
	@v_copy_projectkey  int,
    @v_newprojectitemtype INT,
    @v_newprojectusageclass INT,
	@v_copyprojectitemtype INT,
    @v_copyprojectusageclass INT,
	@v_templateind	INT

if @i_copy_projectkey is null or @i_copy_projectkey = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'copy project key not passed to copy project details (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
end

-- only want to copy elements types that are defined for the new project
IF (@i_new_projectkey > 0)
BEGIN
  SELECT @v_newprojectitemtype = searchitemcode, @v_newprojectusageclass = usageclasscode
  FROM taqproject
  WHERE taqprojectkey = @i_new_projectkey

  IF @v_newprojectitemtype is null or @v_newprojectitemtype = 0
  BEGIN
     SET @o_error_code = -1
     SET @o_error_desc = 'Unable to copy royaltyinfo because item type is not populated: taqprojectkey = ' + cast(@i_new_projectkey AS VARCHAR)   
     RETURN
  END

  IF @v_newprojectusageclass is null 
    SET @v_newprojectusageclass = 0
END 

/* 3/6/12 - KW - From case 17842:
Details (1): in this case, if only i_copy_projectkey exists, copy from this; otherwise copy from i_copy2_projectkey.
This is because this information should come from the template which will be sent as i_copy2_projectkey. */
IF @i_copy2_projectkey > 0
  SET @v_copy_projectkey = @i_copy2_projectkey
ELSE
  SET @v_copy_projectkey = @i_copy_projectkey

if @i_new_projectkey is null or @i_new_projectkey = 0
begin
  select @userkey = userkey
  from qsiusers
  where userid = @i_userid

  if @userkey is null
    select @userkey = clientdefaultvalue
    from clientdefaults
    where clientdefaultid = 48

	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 BEGIN
		SET @userkey = -1
  END 
    
	EXEC get_next_key @i_userid, @o_new_projectkey OUTPUT

  SET @new_projectname = @i_new_projectname
  IF (@new_projectname is null OR @new_projectname = '') BEGIN
    SET @new_projectname = 'New Project'
  END
  
	insert into taqproject
		(taqprojectkey,taqprojectownerkey,taqprojecttitle,taqprojectsubtitle,taqprojecttype,taqprojecteditionnumcode,
		taqprojectseriescode,taqprojectstatuscode,templateind,lockorigdateind,lastuserid,lastmaintdate,
		taqprojecttitleprefix,taqprojecteditiontypecode,taqprojecteditiondesc,taqprojectvolumenumber,
		termsofagreement,subsidyind,idnumber,usageclasscode,searchitemcode,additionaleditioninfo,defaulttemplateind,
		plenteredcurrency, plapprovalcurrency, exchangerate, seasoncode, rightsimpactcode) 
	select @o_new_projectkey, @userkey, @new_projectname, taqprojectsubtitle,
		CASE
		  WHEN (COALESCE(taqprojecttype, 0) = 0 OR taqprojecttype NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(521, @v_newprojectitemtype, @v_newprojectusageclass)))
		  THEN NULL 
		  ELSE taqprojecttype		  
		END as taqprojecttype,	   
		taqprojecteditionnumcode, 
		CASE
		  WHEN (COALESCE(taqprojectseriescode, 0) = 0 OR taqprojectseriescode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(327, @v_newprojectitemtype, @v_newprojectusageclass)))
		  THEN NULL 
		  ELSE taqprojectseriescode		  
		END as taqprojectseriescode,	
		CASE
		  WHEN (COALESCE(taqprojectstatuscode, 0) = 0 OR taqprojectstatuscode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(522, @v_newprojectitemtype, @v_newprojectusageclass)))
		  THEN NULL 
		  ELSE taqprojectstatuscode		  
		END as taqprojectstatuscode,			 
		0, lockorigdateind, @i_userid, getdate(),taqprojecttitleprefix, 
		CASE
		  WHEN (COALESCE(taqprojecteditiontypecode, 0) = 0 OR taqprojecteditiontypecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(200, @v_newprojectitemtype, @v_newprojectusageclass)))
		  THEN NULL 
		  ELSE taqprojecteditiontypecode		  
		END as taqprojecteditiontypecode,		 
		taqprojecteditiondesc, taqprojectvolumenumber, termsofagreement, subsidyind, 
		idnumber, 
		CASE
		  WHEN (COALESCE(usageclasscode, 0) = 0 OR usageclasscode NOT IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(550, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = COALESCE(searchitemcode, 0)))
		  THEN NULL 
		  ELSE usageclasscode		  
		END as usageclasscode,		
		CASE
		  WHEN (COALESCE(searchitemcode, 0) = 0 OR searchitemcode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(550, @v_newprojectitemtype, @v_newprojectusageclass)))
		  THEN NULL 
		  ELSE searchitemcode		  
		END as searchitemcode,				 
		additionaleditioninfo, 0, plenteredcurrency, plapprovalcurrency, exchangerate, seasoncode, rightsimpactcode
	from taqproject
	where taqprojectkey = @v_copy_projectkey

	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'copy/insert into taqproject failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@v_copy_projectkey AS VARCHAR)   
		RETURN
	END 

	select @v_templateind = COALESCE(templateind, 0), @v_copyprojectitemtype = searchitemcode , @v_copyprojectusageclass = usageclasscode 
	from taqproject
	where taqprojectkey = @v_copy_projectkey

	IF @i_copy2_projectkey > 0 OR @v_templateind = 1 BEGIN  -- copying from template so copy all misc items
		insert into taqprojectmisc
			(taqprojectkey, misckey, longvalue, floatvalue, textvalue, lastuserid, lastmaintdate)
		select distinct 
		  @o_new_projectkey, tpm.misckey, longvalue, floatvalue, textvalue, @i_userid, getdate()
		from taqprojectmisc tpm
		  join miscitemsection mis on mis.misckey = tpm.misckey
		where taqprojectkey = @v_copy_projectkey
		  and configobjectkey in (SELECT configobjectkey FROM qsiconfigobjects WHERE sectioncontrolname LIKE '%DetailsSection.ascx')
		  and itemtypecode = @v_newprojectitemtype AND usageclasscode IN (0, @v_newprojectusageclass)
	END
	ELSE BEGIN
		insert into taqprojectmisc
			(taqprojectkey, misckey, longvalue, floatvalue, textvalue, lastuserid, lastmaintdate)
		select distinct 
		  @o_new_projectkey, tpm.misckey, longvalue, floatvalue, textvalue, @i_userid, getdate()
		from taqprojectmisc tpm
		  join miscitemsection mis on mis.misckey = tpm.misckey
		  join bookmiscitems bm on tpm.misckey = bm.misckey
		where taqprojectkey = @v_copy_projectkey  
		  and COALESCE(bm.copymiscitemind,0) = 1 
		  and configobjectkey in (SELECT configobjectkey FROM qsiconfigobjects WHERE sectioncontrolname LIKE '%DetailsSection.ascx')
		  and itemtypecode = @v_newprojectitemtype AND usageclasscode IN (0, @v_newprojectusageclass)
	END	  

	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'copy/insert into taqprojectmisc failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@v_copy_projectkey AS VARCHAR)   
		RETURN
	END 

  if dbo.find_integer_in_comma_delim_list (@i_copydatagroups_list,3) = 'Y'
  begin
    exec qproject_copy_project_productnumber
      @i_copy_projectkey,
      @i_copy2_projectkey,
      @i_copy_bookkey,
      @i_copy_printingkey,
      @o_new_projectkey,
      null,   --new_bookkey
      null,   --new_printingkey
      null,		--copy_elementkey
      null,		--new_elementkey
      @i_userid,
      @i_cleardatagroups_list,
      @o_error_code output,
      @o_error_desc output	

    IF @o_error_code <> 0
	    RETURN
  END
end
else	--called from add project window or other location that already generates new projectkey & populates project data group tables
begin
	set @o_new_projectkey = @i_new_projectkey
end

RETURN
