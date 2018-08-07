if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_project_active_readers') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_project_active_readers
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
    GO

CREATE PROCEDURE qproject_get_project_active_readers
 (@i_projectkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_project_active_readers
**  Desc: This stored procedure returns all readers on a project - active first.
**
**  Auth: Kate
**  Date: 10/10/05
*******************************************************************************/

  DECLARE @error_var      INT
  DECLARE @rowcount_var   INT
  
  SET @o_error_code = 0
  SET @o_error_desc = ''
 
  -- Return all readers for the given project (qsicode=3 on gentable 285 is Reader),
  -- active readers first
  SELECT tr.taqprojectcontactrolekey, tr.activeind,
    CASE
      WHEN gc.displayname IS NULL THEN
        CASE
          WHEN gc.groupname IS NOT NULL THEN gc.groupname
          ELSE gc.lastname
        END
      ELSE gc.displayname
    END AS displayname,
    gc.globalcontactkey
  FROM taqprojectcontact tc, globalcontact gc, taqprojectcontactrole tr, gentables g
  WHERE tc.globalcontactkey = gc.globalcontactkey AND
    tc.taqprojectcontactkey = tr.taqprojectcontactkey AND
    tr.rolecode = g.datacode AND
    g.tableid = 285 AND g.qsicode = 3 AND
    tc.taqprojectkey = @i_projectkey
  ORDER BY tr.activeind DESC, displayname ASC

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: projectkey = ' + cast(@i_projectkey AS VARCHAR)   
  END 

GO

GRANT EXEC ON qproject_get_project_active_readers TO PUBLIC
GO

