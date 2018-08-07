if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_participants_by_role') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_participants_by_role
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_participants_by_role
 (@i_projectkey integer,
  @i_rolecode   integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_participants_by_role
**  Desc: This stored procedure gets the key participants of specified Role
**
**    Auth: Kate Wiewiora
**    Date: 5 April 2005
*******************************************************************************/
  
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT r.*
  FROM taqprojectcontactrole r, taqprojectcontact c
  WHERE r.taqprojectkey = c.taqprojectkey AND
    r.taqprojectcontactkey = c.taqprojectcontactkey AND
    r.taqprojectkey = @i_projectkey AND
    r.rolecode = @i_rolecode AND
    c.keyind = 1 ;  

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error accessing taqprojectreaderiteration: taqprojectkey = ' + cast(@i_projectkey AS VARCHAR)
  END
  
GO

GRANT EXEC ON qproject_get_participants_by_role TO PUBLIC
GO


