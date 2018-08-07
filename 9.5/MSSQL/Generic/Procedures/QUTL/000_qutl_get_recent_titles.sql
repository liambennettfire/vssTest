if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_recent_titles') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qutl_get_recent_titles
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qutl_get_recent_titles
 (@i_userkey        integer,
  @i_usageclasscode integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  Name: qutl_get_recent_titles
**  Desc: This stored procedure returns all title information
**        from the coretitle table for the user's most recently 
**        used titles.
**              
**  Auth: Alan Katzen
**  Date: 28 May 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:              Description:
**    --------    -------------        -------------------------------------------
**    03/09/2016  Uday A. Khisty	   Case 36678
*******************************************************************************/

  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_usageclasscode > 0 BEGIN
    SELECT c.*, bd.csapprovalcode,
		   dbo.qutl_get_gentables_ext_gentext1(620, bd.csapprovalcode) iconfilename
    FROM coretitleinfo c, 
        qse_searchlist l, 
        qse_searchresults r,
        bookdetail bd
    WHERE c.bookkey = bd.bookkey and 
        c.bookkey = r.key1 and 
        c.printingkey = r.key2 and
        r.listkey = l.listkey and
        l.searchtypecode = 6 and 
        l.listtypecode = 5 and
        l.userkey = @i_userkey and
        c.itemtypecode = 1 and
        c.usageclasscode = @i_usageclasscode
    ORDER BY r.lastuse desc
  END
  ELSE BEGIN
    SELECT c.*, bd.csapprovalcode,
		   dbo.qutl_get_gentables_ext_gentext1(620, bd.csapprovalcode) iconfilename    
    FROM coretitleinfo c, 
        qse_searchlist l, 
        qse_searchresults r,
        bookdetail bd
    WHERE c.bookkey = bd.bookkey and 
        c.bookkey = r.key1 and 
        c.printingkey = r.key2 and
        r.listkey = l.listkey and
        l.searchtypecode = 6 and 
        l.listtypecode = 5 and
        l.userkey = @i_userkey 
    ORDER BY r.lastuse desc
  END
  

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error looking for recent titles: userkey = ' + cast(@i_userkey AS VARCHAR) 
  END 
GO

GRANT EXEC ON qutl_get_recent_titles TO PUBLIC
GO
