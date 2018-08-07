if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_subgentables_gen1ind]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function [dbo].[qweb_get_subgentables_gen1ind]
GO

CREATE FUNCTION [dbo].[qweb_get_subgentables_gen1ind]
    (@i_tableid as integer, @bookkey as integer) 

RETURNS varchar(255)
/*
This function is created  to get the subgen1ind value for e-book flavors.
*/

BEGIN 
  DECLARE @i_desc       VARCHAR(255)
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @mediatypecode smallint
  DECLARE @mediatypesubcode smallint

  SET @i_desc = ''

	Select @mediatypecode = mediatypecode, @mediatypesubcode = mediatypesubcode
	from cbd..bookdetail
	where bookkey = @bookkey

	If @mediatypecode <> 29  --if not ebook mediatype return nothing
		return ''

  IF @i_tableid is null OR @i_tableid <= 0 OR
     @mediatypecode is null OR @mediatypecode <= 0  OR
     @mediatypesubcode is null OR @mediatypesubcode <= 0 BEGIN
     RETURN ''
  END


    SELECT @i_desc = subgen1ind
      FROM cbd..subgentables
     WHERE tableid = @i_tableid and
           datacode = @mediatypecode and
           datasubcode = @mediatypesubcode


  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @i_desc = 'error'
    --SET @o_error_desc = 'no data found: datadesc on subgentables.'   
  END 

  RETURN @i_desc
END

GO
Grant execute on dbo.qweb_get_subgentables_gen1ind to Public
GO