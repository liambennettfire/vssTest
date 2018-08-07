if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_project_detail') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_project_detail
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_project_detail
 (@i_projectkey     integer,
  @o_error_code     integer       output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_project_detail
**  Desc: This gets the detail information needed for the Project Summary
**        screen and any other control which uses a subset of this information.
**
**    Auth: James P. Weber
**    Date: 11 May 2004
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT c.projectheaderorg1key, c.projectheaderorg1desc,
      c.projectheaderorg2key, c.projectheaderorg2desc, 
      p.taqprojectkey, p.taqprojectownerkey, p.taqprojecttitleprefix, p.taqprojecttitle, 
      p.taqprojectsubtitle, p.taqprojecttype, p.taqprojectstatuscode,
      p.taqprojecteditionnumcode, p.taqprojecteditiontypecode, p.taqprojecteditiondesc, 
      p.taqprojectseriescode, p.taqprojectvolumenumber, p.termsofagreement, p.subsidyind, p.templateind,
      u.firstname, u.lastname, p.searchitemcode, p.usageclasscode, p.idnumber, p.additionaleditioninfo,
      p.plenteredcurrency, p.plapprovalcurrency
  FROM taqproject p
  join coreprojectinfo c on p.taqprojectkey = c.projectkey
  left join qsiusers u on p.taqprojectownerkey = u.userkey  -- until we fix the cleanup of deleting qsiuser records, 
                                                            -- this will have to be an outer join
  WHERE p.taqprojectkey = @i_projectkey 

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: taqprojectkey = ' + cast(@i_projectkey AS VARCHAR)   
  END 

GO
GRANT EXEC ON qproject_get_project_detail TO PUBLIC
GO


