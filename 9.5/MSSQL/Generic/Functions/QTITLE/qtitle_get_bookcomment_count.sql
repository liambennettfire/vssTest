if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_bookcomment_count') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qtitle_get_bookcomment_count
GO

CREATE FUNCTION qtitle_get_bookcomment_count
    ( @i_bookkey as integer,
      @i_printingkey as integer,
      @i_commenttypecode as integer,
      @i_commenttypesubcode as integer) 

RETURNS int

/******************************************************************************
**  File: 
**  Name: qtitle_get_bookcomment_count
**  Desc: This function returns 1 if comments exist,0 if they don't exist,
**        and -1 for an error. 
**
**
**    Auth: Alan Katzen
**    Date: 28 April 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @i_count      INT
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @i_count = 0

  -- bookcomments
  SELECT @i_count = count(*)
    FROM bookcomments
   WHERE bookkey = @i_bookkey and
         printingkey = @i_printingkey and
         commenttypecode = @i_commenttypecode and
         commenttypesubcode = @i_commenttypesubcode

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @i_count = -1
    --SET @o_error_desc = 'no data found: commenttypecode on gentablesdesc.'   
  END 

  -- return 1 or 0 so that object can set params 
  IF @i_count > 0 BEGIN
    SET @i_count = 1
  END

  RETURN @i_count
END
GO

GRANT EXEC ON dbo.qtitle_get_bookcomment_count TO public
GO
