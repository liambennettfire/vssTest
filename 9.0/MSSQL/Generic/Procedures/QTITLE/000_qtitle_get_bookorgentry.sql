if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_bookorgentry') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_bookorgentry
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_bookorgentry
 (@i_bookkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  Name: qtitle_get_bookorgentry
**  Desc: This stored procedure returns all organizational levels
**        for a title, regardless if they are filled in or not. 
**
**    Auth: Alan Katzen
**    Date: 20 April 2004
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT o.*, b.*, dbo.qutl_get_orgentrydesc(COALESCE(b.orglevelkey, 0), COALESCE(b.orgentrykey,0), 'F') "orgentrydesc"
  FROM orglevel o 
    LEFT OUTER JOIN bookorgentry b ON o.orglevelkey = b.orglevelkey AND b.bookkey = @i_bookkey 
  ORDER BY o.orglevelkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: bookkey = ' + cast(@i_bookkey AS VARCHAR)   
  END 
GO

GRANT EXEC ON qtitle_get_bookorgentry TO PUBLIC
GO



