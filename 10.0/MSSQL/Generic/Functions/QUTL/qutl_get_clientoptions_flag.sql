if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_clientoptions_flag') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qutl_get_clientoptions_flag
GO

CREATE FUNCTION qutl_get_clientoptions_flag
    (@i_optionname as varchar(30)) 

RETURNS int

/******************************************************************************
**  File: 
**  Name: qutl_get_clientoptions_flag
**  Desc: This function returns the clientoptions flag,0 if it doesn't exist,
**        and -1 for an error. 
**
**
**    Auth: Alan Katzen
**    Date: 23 July 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @clientoptions_flag_var INT

  IF @i_optionname IS NULL OR ltrim(rtrim(@i_optionname)) = '' BEGIN
    RETURN -1
  END 

  SET @clientoptions_flag_var = 0

  -- Get tmm actual trimsize flag from clientoptions
  SELECT @clientoptions_flag_var = o.optionvalue
    FROM clientoptions o
   WHERE lower(o.optionname) = @i_optionname

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @clientoptions_flag_var = -1
  END

  IF @clientoptions_flag_var IS NULL  BEGIN
    SET @clientoptions_flag_var = 0
  END 

  RETURN @clientoptions_flag_var
END
GO

GRANT EXEC ON dbo.qutl_get_clientoptions_flag TO public
GO
