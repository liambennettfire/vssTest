IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_miscitems]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_project_miscitems]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_miscitems]    Script Date: 07/16/2008 10:29:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project_miscitems]
  (@i_copy_projectkey     integer,
  @i_copy2_projectkey		integer,
  @i_new_projectkey		integer,
  @i_userid				varchar(30),
  @i_cleardatagroups_list	varchar(max),
  @o_error_code			integer output,
  @o_error_desc			varchar(2000) output)
AS

/******************************************************************************
**  Name: [qproject_copy_project_miscitems]
**  Desc: This stored procedure copies the details of 1 or all elements to new elements.
**        The project key to copy and the data groups to copy are passed as arguments.
**
**			If you call this procedure from anyplace other than qproject_copy_project,
**			you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Jennifer Hurd
**    Date: 23 June 2008
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
  @itemtype  int,
  @usageclass int
  
if @i_copy_projectkey is null or @i_copy_projectkey = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'copy project key not passed to copy miscitems (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
end

if @i_new_projectkey is null or @i_new_projectkey = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'new project key not passed to copy miscitems (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
end

-- only want to copy misc items that are defined for the new project
select @itemtype = searchitemcode, @usageclass = usageclasscode
from taqproject
where taqprojectkey = @i_new_projectkey

if @itemtype is null or @itemtype = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'Unable to copy miscitems because item type is not populated: taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
end

if @usageclass is null 
begin
  set @usageclass = 0
end

insert into taqprojectmisc
	(taqprojectkey, misckey, longvalue, floatvalue, textvalue, lastuserid, lastmaintdate)
select distinct 
  @i_new_projectkey, tpm.misckey, longvalue, floatvalue, textvalue, @i_userid, getdate()
from taqprojectmisc tpm
  join miscitemsection mis on mis.misckey = tpm.misckey
where taqprojectkey = @i_copy_projectkey
and configobjectkey NOT IN (SELECT configobjectkey FROM qsiconfigobjects WHERE sectioncontrolname LIKE '%DetailsSection.ascx')
and mis.itemtypecode = @itemtype
and mis.usageclasscode in (@usageclass,0)
and not exists (select 1
				from taqprojectmisc tpm2
				where tpm2.taqprojectkey = @i_new_projectkey and tpm.misckey = tpm2.misckey)

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @o_error_code = -1
	SET @o_error_desc = 'Copy/insert into taqprojectmisc (2) failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
END 

/* 3/6/12 - KW - From case 17842:
Misc Items (13):  copy from i_copy_projectkey; add non-existing misc item types from i_copy2_projectkey */
IF @i_copy2_projectkey > 0
BEGIN
  INSERT INTO taqprojectmisc
	  (taqprojectkey, misckey, longvalue, floatvalue, textvalue, lastuserid, lastmaintdate)
  SELECT DISTINCT
    @i_new_projectkey, tpm.misckey, longvalue, floatvalue, textvalue, @i_userid, getdate()
  FROM taqprojectmisc tpm
    JOIN miscitemsection mis ON mis.misckey = tpm.misckey
  WHERE taqprojectkey = @i_copy2_projectkey AND
    configobjectkey NOT IN (SELECT configobjectkey FROM qsiconfigobjects WHERE sectioncontrolname LIKE '%DetailsSection.ascx') AND
    mis.itemtypecode = @itemtype AND
    mis.usageclasscode in (@usageclass,0) AND
    NOT EXISTS (SELECT * FROM taqprojectmisc tpm2
				        WHERE tpm2.taqprojectkey = @i_new_projectkey AND tpm.misckey = tpm2.misckey)

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Copy/insert into taqprojectmisc (2) failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy2_projectkey AS VARCHAR)   
	  RETURN
  END
END

RETURN