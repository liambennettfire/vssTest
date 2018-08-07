if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getBookKeyFromItemNumber') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_getBookKeyFromItemNumber
GO

CREATE PROCEDURE [dbo].[WK_getBookKeyFromItemNumber]
@itemNumber varchar(100)
AS
DECLARE @bookKey					int,
		@inputNumberLength			int,
		@tempItemNumber				varchar(100)
BEGIN

set @tempItemNumber = replace(@itemNumber, '-', '')
set @inputNumberLength = LEN( @tempItemNumber )

IF ( @inputNumberLength = 10 ) 
	BEGIN
		set @bookKey = ( select top 1 bookkey from isbn where isbn10 = @tempItemNumber order by lastmaintdate desc )	
	END
ELSE IF ( @inputNumberLength = 13 ) 
	BEGIN
		set @bookKey = ( select top 1 bookkey from isbn where ean13 = @tempItemNumber order by lastmaintdate desc )
	END
ELSE
	BEGIN
		set @bookKey = ( select top 1 bookkey from isbn where itemnumber = @itemNumber order by lastmaintdate desc)	
	END

SELECT @bookKey as BookKey

END