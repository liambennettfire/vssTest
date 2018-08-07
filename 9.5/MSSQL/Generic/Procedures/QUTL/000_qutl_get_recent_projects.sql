if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_recent_projects') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qutl_get_recent_projects
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qutl_get_recent_projects
 (@i_userkey        integer,
  @i_usageclasscode integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_recent_projects
**  Desc: This stored procedure returns all project information
**        from the coreproject table for the user's most recently 
**        accessed projects.
**              
**  Auth: Alan Katzen
**  Date: 28 May 2004
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  IF @i_usageclasscode > 0 BEGIN
    SELECT c.* 
      FROM coreprojectinfo c, 
           qse_searchlist l, 
           qse_searchresults r
     WHERE c.projectkey = r.key1 and 
           r.listkey = l.listkey and
           l.searchtypecode = 7 and 
           l.listtypecode = 7 and
           l.userkey = @i_userkey and
           c.usageclasscode = @i_usageclasscode
    ORDER BY r.lastuse desc
  END
  ELSE BEGIN
    SELECT c.* 
      FROM coreprojectinfo c, 
           qse_searchlist l, 
           qse_searchresults r
     WHERE c.projectkey = r.key1 and 
           r.listkey = l.listkey and
           l.searchtypecode = 7 and 
           l.listtypecode = 7 and
           l.userkey = @i_userkey 
    ORDER BY r.lastuse desc
  END
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error looking for recent projects: userkey = ' + cast(@i_userkey AS VARCHAR) 
  END
  
GO

GRANT EXEC ON qutl_get_recent_projects TO PUBLIC
GO


