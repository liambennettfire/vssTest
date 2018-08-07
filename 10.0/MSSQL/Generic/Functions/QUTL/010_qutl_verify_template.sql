if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_verify_template') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qutl_verify_template
GO

CREATE FUNCTION qutl_verify_template
    ( @i_bookkey as integer,
      @i_orglevelkey as integer) 

RETURNS int

/******************************************************************************
**  File: 
**  Name: qutl_verify_template
**  Desc: This function returns 1 for template with no orglevels filled in 
**        above the current level, 0 if there are orglevels filled in above
**        the current one, and -1 for an error.  This needs to be done to 
**        prevent the selection of another orgentries' template.
**
**    Auth: Alan Katzen
**    Date: 06 October 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:        Description:
**    --------    --------       -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @i_correct_template INT,
          @i_count            INT,
          @error_var          INT,
          @rowcount_var       INT

  SET @i_correct_template = 0
  SET @i_count = 1

  SELECT @i_count = count(*)
    FROM bookorgentry bo
   WHERE bo.bookkey = @i_bookkey and
         bo.orglevelkey > @i_orglevelkey 

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @i_correct_template = -1
    --SET @o_error_desc = 'no data found: bookorgentry.'  
    RETURN @i_correct_template 
  END 

  -- return 1 or 0 so that object can set params 
  IF @i_count = 0 BEGIN
    SET @i_correct_template = 1
  END 
  ELSE BEGIN
    SET @i_correct_template = 0
  END

  RETURN @i_correct_template
END
GO

GRANT EXEC ON dbo.qutl_verify_template TO public
GO
