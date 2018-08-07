if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getAuthorTypeCodeByRole') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_getAuthorTypeCodeByRole
GO

CREATE PROCEDURE dbo.WK_getAuthorTypeCodeByRole
@Role varchar(512)
AS

DECLARE	@AuthorTypeCode int
DECLARE	@DefaultAuthorTypeCode int

SET @DefaultAuthorTypeCode = 12

BEGIN

set @AuthorTypeCode = ( select datacode from gentables where tableid = 134 and externalcode like '%' + @Role + '%' )


IF ( @AuthorTypeCode > 1 )
	BEGIN
		select @AuthorTypeCode as authorTypeCode
	END
ELSE
	BEGIN
		select @DefaultAuthorTypeCode as authorTypeCode
	END

END
