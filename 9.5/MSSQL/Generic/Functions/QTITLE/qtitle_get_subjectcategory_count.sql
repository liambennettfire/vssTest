if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_subjectcategory_count') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qtitle_get_subjectcategory_count
GO

CREATE FUNCTION qtitle_get_subjectcategory_count
    ( @i_bookkey as integer, @i_printingkey as integer, @i_tableid as integer) 
RETURNS int

/******************************************************************************
**  Name: qtitle_get_subjectcategory_count
**  Desc: This function returns 1 if categories exist, 0 if they don't exist,
**        and -1 for an error. 
**
**        tableid 317 = book category
**        tableid 339 = bisac subject
**        tableid 412-414,431-437 = subject categories 
**
**    Auth: Alan Katzen
**    Date: 9 April 2004
*******************************************************************************/

BEGIN 
  DECLARE @i_count      INT
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @i_count = 0

  IF @i_tableid = 317 BEGIN
    -- book category
    SELECT @i_count = count(*)
    FROM bookcategory
    WHERE bookkey = @i_bookkey  
  END
  ELSE IF @i_tableid = 339 BEGIN
    -- bisac subject category
    SELECT @i_count = count(*)
    FROM bookbisaccategory
    WHERE bookkey = @i_bookkey and
        printingkey = @i_printingkey
  END
  ELSE BEGIN
    -- book subject categories
    SELECT @i_count = count(*)
    FROM booksubjectcategory
    WHERE bookkey = @i_bookkey and
        categorytableid = @i_tableid
  END

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @i_count = -1
  END 

  -- return 1 or 0 so that object can set params 
  IF @i_count > 0 BEGIN
    SET @i_count = 1
  END

  RETURN @i_count
END
GO

GRANT EXEC ON dbo.qtitle_get_subjectcategory_count TO public
GO
