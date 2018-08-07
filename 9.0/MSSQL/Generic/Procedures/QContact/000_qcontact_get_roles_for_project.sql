if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_roles_for_project') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontact_get_roles_for_project
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qcontact_get_roles_for_project
 (@i_globalcontactkey     integer,
  @i_projectKey           integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qcontact_get_roles_for_project
**  Desc: This stored procedure returns role(s) for a contact under a project
**        for related projects.
**
**    Auth: Jon Hess
**    Date: 8/14/06
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @taqprojectcontactkey INT

  select @taqprojectcontactkey = taqprojectcontactkey from taqprojectcontact
  where globalcontactkey = @i_globalcontactkey
  and taqprojectkey = @i_projectKey

  select  dbo.qproject_participant_role_summary( @i_projectKey, @taqprojectcontactkey) as contactroles

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  --SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  --IF @error_var <> 0 or @rowcount_var = 0 BEGIN
  --  SET @o_error_code = 1
  --  SET @o_error_desc = 'no data found: contactkey = ' + cast(@i_globalcontactkey AS VARCHAR)   
  --END 

GO
GRANT EXEC ON qcontact_get_roles_for_project TO PUBLIC
GO


