SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_AuthorPrimaryKey]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_AuthorPrimaryKey]
GO






CREATE FUNCTION dbo.qweb_get_AuthorPrimaryKey 
			(@i_bookkey	INT,
			@i_order 	INT)


RETURNS	INT

/*  The purpose of the qweb_get_AuthorPrimaryKey function is to return a specific author key for the bookkey and order number specified.
	The use of this is to get the first primary authorkey or the second or so on so that other functions can call this one
	when they need to format names, types, etc.

	returns a 0 if there is no author for the order requested
*/
AS

BEGIN

	DECLARE @RETURN			INT
	DECLARE @i_count		INT		
	DECLARE @i_primarycount		INT		
	DECLARE @i_authorkey		INT
	DECLARE @i_sortorder		INT



/* FIND OUT HOW MANY PRIMARY AUTHORS THERE ARE */

	SELECT	@i_primarycount=count(*)
			FROM bookauthor
			WHERE	bookkey = @i_bookkey
			AND primaryind = 1
	IF @i_primarycount< @i_order -- there are less primary authors than what is requested, return a 0
		BEGIN
			SELECT @RETURN = 0
		END
	ELSE
		BEGIN

		/*  GET FIRST AUTHOR KEY 	the reason we order these descending is that the authorkey variable will be filled by the
						last in the list received
		*/
	
			SELECT 	@i_authorkey = authorkey, @i_sortorder=sortorder
					FROM bookauthor
					WHERE	bookkey = @i_bookkey
					AND primaryind = 1
					ORDER BY sortorder DESC

		
			IF @i_order =1 -- if we need to get the first author
				BEGIN
					SELECT @RETURN = @i_authorkey
		
				END
			ELSE -- if we need a subsequent author key, loop through them until you find the primary author you need
				BEGIN

					SELECT @i_count=1
					WHILE @i_count < @i_order
						BEGIN
							SELECT 	@i_authorkey = authorkey, @i_sortorder=sortorder
								FROM bookauthor
								WHERE	bookkey = @i_bookkey
								AND primaryind = 1
								AND sortorder>@i_sortorder
								ORDER BY sortorder DESC
							SELECT @i_count=@i_count+1
						END
					SELECT @RETURN = @i_authorkey

				END

		END



RETURN @RETURN


END







GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

