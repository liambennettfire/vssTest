if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_cdlist_desc') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qutl_get_cdlist_desc
GO

CREATE FUNCTION qutl_get_cdlist_desc
    ( @i_internalcode as integer,@i_desctype as varchar(255)) 

RETURNS varchar(255)

/******************************************************************************
**  File: 
**  Name: qutl_get_cdlist_desc
**  Desc: This function returns data from cdlist depending on
**        i_desctype. 
**
**        i_desctype = 'externalcode' --> return externalcode
**        i_desctype = 'externaldesc' --> return externaldesc
**
**    Auth: Alan Katzen
**    Date: 6 November 2007
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

  IF @i_desctype is null OR ltrim(rtrim(@i_desctype)) = '' OR
     @i_internalcode is null OR @i_internalcode <= 0 BEGIN
     RETURN ''
  END

  IF lower(rtrim(ltrim(@i_desctype))) = 'externaldesc' BEGIN
    -- get externaldesc
    SELECT @i_desc = externaldesc
      FROM cdlist
     WHERE internalcode = @i_internalcode
  END

  IF lower(rtrim(ltrim(@i_desctype))) = 'externalcode' BEGIN
    -- get externalcode
    SELECT @i_desc = externalcode
      FROM cdlist
     WHERE internalcode = @i_internalcode
  END

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @i_desc = 'error'
  END 

  RETURN rtrim(ltrim(@i_desc))
END
GO

GRANT EXEC ON dbo.qutl_get_cdlist_desc TO public
GO
