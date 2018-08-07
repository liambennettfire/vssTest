PRINT 'STORED PROCEDURE : qauthor_get_authorinfo'
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qauthor_get_authorinfo')
	BEGIN
		PRINT 'Dropping Procedure qauthor_get_authorinfo'
		DROP PROCEDURE  qauthor_get_authorinfo
	END

GO


PRINT 'Creating Procedure qauthor_get_authorinfo'
GO

CREATE PROCEDURE qauthor_get_authorinfo
(
  @i_AuthorKey		INT,
  @o_error_code		INT OUT,
  @o_error_desc		VARCHAR(2000) OUT 
)
AS


BEGIN
  DECLARE 
	@ErrorValue			INT,
	@SQLString			NVARCHAR(4000)

  SET NOCOUNT ON
  
  SET @o_error_desc = ''

  SELECT authorkey, displayname, lastname, firstname, middlename,
	nameabbrcode, corporatecontributorind, authorsuffix, authordegree
  FROM author
  WHERE authorkey = @i_AuthorKey
  
  Set @o_error_code = @@ERROR
  IF @@ERROR <> 0 BEGIN
    SET @o_error_desc = 'Error selecting an author from the database'
  END

END
GO

GRANT EXEC ON qauthor_get_authorinfo TO PUBLIC
GO

PRINT 'STORED PROCEDURE : qauthor_get_authorinfo'
GO
