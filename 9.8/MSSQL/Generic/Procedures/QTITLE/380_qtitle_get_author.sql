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
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  
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


SELECT c.*,b.authortypecode,b.reportind,b.primaryind,d.fullauthordisplayname,b.history_order,b.sortorder
FROM bookauthor b, globalcontact c, bookdetail d
where c.globalcontactkey =  b.authorkey and 
      b.bookkey = d.bookkey and 
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


