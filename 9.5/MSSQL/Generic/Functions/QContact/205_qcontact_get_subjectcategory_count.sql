if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_subjectcategory_count') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qcontact_get_subjectcategory_count
GO

CREATE FUNCTION qcontact_get_subjectcategory_count
    ( @i_contactkey as integer,@i_tableid as integer) 

RETURNS int

/******************************************************************************
**  File: 
**  Name: qcontact_get_subjectcategory_count
**  Desc: This function returns 1 if categories exist,0 if they don't exist,
**        and -1 for an error. 
**
**    Auth: Alan Katzen
**    Date: 15 August 2006
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
    FROM globalcontactcategory
   WHERE globalcontactkey = @i_contactkey and
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

GRANT EXEC ON dbo.qcontact_get_subjectcategory_count TO public
GO
