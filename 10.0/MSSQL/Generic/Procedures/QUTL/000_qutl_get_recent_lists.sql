if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_recent_lists') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qutl_get_recent_lists
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qutl_get_recent_lists
 (@i_userkey        integer,
  @i_listtype       integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/**********************************************************************************
**  Name: qutl_get_recent_lists
**  Desc: This stored procedure returns most recent list of lists of specific type.
**              
**  Auth: Kate W.
**  Date: 19 September 2006
**********************************************************************************/

  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT c.* 
  FROM qse_searchlist c, 
      qse_searchlist l, 
      qse_searchresults r
  WHERE c.listkey = r.key1 and 
      r.listkey = l.listkey and
      l.searchtypecode = 16 and 
      l.listtypecode = @i_listtype and
      l.userkey = @i_userkey 
  ORDER BY r.lastuse desc

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error looking for recent titles: userkey = ' + cast(@i_userkey AS VARCHAR) 
  END 
GO

GRANT EXEC ON qutl_get_recent_lists TO PUBLIC
GO
