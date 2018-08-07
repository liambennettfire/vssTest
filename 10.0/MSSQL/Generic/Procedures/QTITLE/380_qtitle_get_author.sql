if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_author') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_author
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_author
 (@i_bookkey                  integer,
  @o_fullauthordisplayname    varchar(255) output,
  @o_error_code               integer output,
  @o_error_desc               varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qtitle_get_author
**  Desc: This stored procedure returns all author information
**        from the author and bookauthor table. It is designed to be used 
**        in conjunction with a title author control.
**
**              
**
**    Auth: Alan Katzen
**    Date: 25 March 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:     Author:        Description:
**    --------  --------       -------------------------------------------
**    8/30/17   Alan           Added email and phone
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT, @v_author_rolecode INT
  
  SELECT @o_fullauthordisplayname = d.fullauthordisplayname
  FROM bookdetail d
  where d.bookkey = @i_bookkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 2
    SET @o_error_desc = 'no data found for full author display name: bookdetail (bookkey) = ' + cast(@i_bookkey AS VARCHAR)   
  END 

  -- use the author role as a default for any authortypecode that is not mapped to a rolecode
  select @v_author_rolecode = datacode 
    from gentables
   where tableid = 285 
     and qsicode = 4

  SELECT c.*,b.authortypecode,coalesce(b.reportind,0) reportind,coalesce(b.primaryind,0) primaryind,d.fullauthordisplayname,
         b.history_order,b.sortorder, cc.email, cc.phone,
         dbo.get_gentables_desc(134,b.authortypecode,'') as 'authortypedesc', coalesce(code2, @v_author_rolecode) relatedrolecode
  FROM bookauthor b
  LEFT OUTER JOIN gentablesrelationshipdetail r ON (r.code1 = b.authortypecode and r.gentablesrelationshipkey = 1),
  globalcontact c, bookdetail d, corecontactinfo cc
  where c.globalcontactkey =  b.authorkey and 
        b.bookkey = d.bookkey and 
        c.globalcontactkey = cc.contactkey and
        b.bookkey = @i_bookkey 
  order by  b.sortorder asc

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: bookkey = ' + cast(@i_bookkey AS VARCHAR)   
  END 

GO
GRANT EXEC ON qtitle_get_author TO PUBLIC
GO


