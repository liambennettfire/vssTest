IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qutl_get_recent_journals]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qutl_get_recent_journals]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qutl_get_recent_journals]
 (@i_userkey        integer,
  @i_usageclasscode integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_recent_journals
**  Desc: This stored procedure returns all project information
**        from the coreproject table for the user's most recently 
**        accessed journals.  Cloned from qutl_get_recent_projects
**              
**  Auth: Lisa Cormier
**  Date: 26 Feb 2008
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
           l.searchtypecode = 18 and 
           l.listtypecode = 9 and
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
           l.searchtypecode = 18 and 
           l.listtypecode = 9 and
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

GRANT EXEC ON qutl_get_recent_journals TO PUBLIC
GO
