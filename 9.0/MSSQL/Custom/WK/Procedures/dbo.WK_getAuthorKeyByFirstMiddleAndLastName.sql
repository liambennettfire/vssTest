if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getAuthorKeyByFirstMiddleAndLastName') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_getAuthorKeyByFirstMiddleAndLastName
GO

CREATE PROCEDURE dbo.WK_getAuthorKeyByFirstMiddleAndLastName
@firstName varchar(512),
@middleName varchar(512),
@lastName varchar(512)
AS

DECLARE	@authorKeysFound int

BEGIN

IF ( @middleName <> '' )
	BEGIN
	set @authorKeysFound = ( select count( authorkey ) from author where lastname like '%' + @lastName + '%' and firstname like '%' + @firstName + '%' and middlename like '%' + @middleName + '%' )

	IF ( @authorKeysFound = 1 )
		BEGIN 		
			select authorkey from author where lastname like '%' + @lastName + '%' and firstname like '%' + @firstName + '%' and middlename like '%' + @middleName + '%'
		END
	IF ( @authorKeysFound > 1 )
		BEGIN		
			select top 1 authorkey, count(*) as keyCount from bookauthor where authorkey in ( select authorkey from author where firstname like '%' + @firstName + '%' and lastname like '%' + @lastName + '%'  ) group by authorkey order by keyCount desc
		END
	END
IF ( @middleName = '' )
	BEGIN
		set @authorKeysFound = ( select count( authorkey ) from author where lastname like '%' + @lastName + '%' and firstname like '%' + @firstName + '%' )

		IF ( @authorKeysFound = 1 )
			BEGIN 		
				select authorkey from author where lastname like '%' + @lastName + '%' and firstname like '%' + @firstName + '%'
			END
		IF ( @authorKeysFound > 1 )
			BEGIN		
				select top 1 authorkey, count(*) as keyCount from bookauthor where authorkey in ( select authorkey from author where firstname like '%' + @firstName + '%' and lastname like '%' + @lastName + '%'  ) group by authorkey order by keyCount desc
			END
	END

END
