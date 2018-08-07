

CREATE FUNCTION [dbo].[get_gentables_desc_alt1]
    ( @i_tableid as integer,@i_datacode as integer,@i_desctype as varchar) 

RETURNS varchar(255)

/******************************************************************************
**  File: 
**  Name: get_gentables_desc
**  Desc: This function returns the datadesc or datadescshort depending on
**        i_desctype. 
**
**        i_desctype = 'long' or empty --> return datadesc
**        i_desctype = 'short' --> return datadescshort
**
**    Auth: Alan Katzen
**    Date: 25 August 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @i_desc       VARCHAR(255)
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @i_desc = ''

  IF @i_tableid is null OR @i_tableid <= 0 OR
     @i_datacode is null OR @i_datacode <= 0 BEGIN
     RETURN ''
  END

  IF lower(rtrim(ltrim(@i_desctype))) = 'short' BEGIN
    -- get datadescshort
    SELECT @i_desc = datadescshort
      FROM gentables
     WHERE tableid = @i_tableid and
           datacode = @i_datacode
  END
  ELSE BEGIN
    -- get datadesc
    SELECT @i_desc = CASE WHEN alternatedesc1 is not null THEN alternatedesc1 ELSE datadesc END
      FROM gentables
     WHERE tableid = @i_tableid and
           datacode = @i_datacode
  END

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @i_desc = 'error'
    --SET @o_error_desc = 'no data found: subjectcategories on gentablesdesc.'   
  END 

  RETURN @i_desc
END





