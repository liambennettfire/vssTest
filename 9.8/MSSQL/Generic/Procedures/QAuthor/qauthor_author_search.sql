PRINT 'STORED PROCEDURE : qauthor_author_search'
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qauthor_author_search')
	BEGIN
		PRINT 'Dropping Procedure qauthor_author_search'
		DROP PROCEDURE  qauthor_author_search
	END

GO


PRINT 'Creating Procedure qauthor_author_search'
GO

CREATE PROCEDURE qauthor_author_search
(
  @i_AuthorLastName	VARCHAR(75),
  @i_ActiveOnlyInd	BIT,
  @o_NumberOfRows		INT OUT,
  @o_error_code		INT OUT,
  @o_error_desc		VARCHAR(2000) OUT 
)
AS


BEGIN
  DECLARE 
	@ErrorValue			INT,
	@SQLString			NVARCHAR(4000)

  SET NOCOUNT ON

  -- Build and EXECUTE the dynamic SELECT statement
  SET @SQLString = N'SELECT author.authorkey,
	author.displayname,
	author.activeind
    FROM author
    WHERE author.lastname LIKE ''' + @i_AuthorLastName + '%''
    ORDER BY author.lastname, author.firstname, author.middlename'

  -- If return only active authors flag is set to TRUE (1), limit results to active authors only.
  IF @i_ActiveOnlyInd = 1
    SET @SQLString = @SQLString + N' AND author.activeind = 1'

  EXECUTE sp_executesql @SQLString

  SELECT @o_NumberOfRows = @@ROWCOUNT

END
GO

GRANT EXEC ON qauthor_author_search TO PUBLIC
GO

PRINT 'STORED PROCEDURE : qauthor_author_search'
GO
