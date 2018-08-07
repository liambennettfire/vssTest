if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_book_productdetail') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_book_productdetail
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_book_productdetail
 (@i_bookkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qtitle_get_book_productdetail
**  Desc: This stored procedure returns product detail information
**        from the bookproductdetail table. 
**
**    Auth: Uday Khisty
**    Date: 5/13/13
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

  SELECT DISTINCT g.tabledesclong, b.*        
    FROM bookproductdetail b, gentablesdesc g, coretitleinfo c
   WHERE b.tableid = g.tableid and
         b.bookkey = c.bookkey and
         b.bookkey = @i_bookkey 
ORDER BY b.tableid,b.sortorder,b.datacode,b.datasubcode,b.datasub2code

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: bookkey = ' + cast(@i_bookkey AS VARCHAR)   
  END 

GO
GRANT EXEC ON qtitle_get_book_productdetail TO PUBLIC
GO