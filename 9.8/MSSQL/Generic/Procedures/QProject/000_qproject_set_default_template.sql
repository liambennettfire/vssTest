if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_set_default_template') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_set_default_template
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_set_default_template
 (@i_new_template_projectkey  integer,
  @i_old_template_projectkey  integer,
  @i_userid                   varchar(30),
  @o_error_code               integer       output,
  @o_error_desc               varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_set_default_template
**  Desc: This sets the default Template indicator for a project/journal.
** 
**  NOTE: Use @i_old_template_projectkey to pass projectkey of current
**        default template.  We need this to reset the default indicator to 0.
**        Pass 0 if there currently is no default template.
**
**    Auth: Alan Katzen
**    Date: 14 August 2008
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  IF @i_old_template_projectkey > 0 BEGIN
    -- reset current default template to not be the default template
    UPDATE taqproject
       SET defaulttemplateind = 0,
           lastuserid = @i_userid,
           lastmaintdate = getdate()
     WHERE taqprojectkey = @i_old_template_projectkey
  
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to reset current default template: projectkey = ' + cast(@i_old_template_projectkey AS VARCHAR)
      return
    END 
  END
  
  IF @i_new_template_projectkey > 0 BEGIN
    -- set as default template
    UPDATE taqproject
       SET templateind = 1, 
           defaulttemplateind = 1,
           lastuserid = @i_userid,
           lastmaintdate = getdate()
     WHERE taqprojectkey = @i_new_template_projectkey
  
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to set default template: projectkey = ' + cast(@i_new_template_projectkey AS VARCHAR)
      return
    END 
  END

GO
GRANT EXEC ON qproject_set_default_template TO PUBLIC
GO


