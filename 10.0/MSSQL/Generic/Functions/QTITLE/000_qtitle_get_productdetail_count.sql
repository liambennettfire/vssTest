if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_productdetail_count') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qtitle_get_productdetail_count
GO

CREATE FUNCTION qtitle_get_productdetail_count
    ( @i_bookkey as integer,@i_tableid as integer) 

RETURNS int

/******************************************************************************
**  File: 
**  Name: qtitle_get_productdetail_count
**  Desc: This function returns 1 if product detals exist,0 if they don't exist,
**
**    Auth: Uday Khisty
**    Date: 13 May 2014
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

  SELECT @i_count = count(*)
    FROM bookproductdetail
   WHERE bookkey = @i_bookkey and
         tableid = @i_tableid

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @i_count = -1
    --SET @o_error_desc = 'no data found: subjectcategories on gentablesdesc.'   
  END 

  -- return 1 or 0 so that object can set params 
  IF @i_count > 0 BEGIN
    SET @i_count = 1
  END

  RETURN @i_count
END
GO

GRANT EXEC ON dbo.qtitle_get_productdetail_count TO public
GO
