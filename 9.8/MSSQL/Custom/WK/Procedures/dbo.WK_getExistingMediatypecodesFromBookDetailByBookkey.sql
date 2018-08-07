
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getExistingMediatypecodesFromBookDetailByBookkey') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_getExistingMediatypecodesFromBookDetailByBookkey
GO

CREATE PROCEDURE dbo.WK_getExistingMediatypecodesFromBookDetailByBookkey
@bookKey varchar(512)
AS

BEGIN

select top 1 mediatypecode, mediatypesubcode from bookdetail where bookkey = @bookKey

END
