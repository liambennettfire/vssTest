
/****** Object:  UserDefinedFunction [dbo].[rpt_get_author_key]    Script Date: 03/24/2009 11:51:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_author_key') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_author_key
GO
CREATE FUNCTION [dbo].[rpt_get_author_key] 
			(@i_bookkey	INT,
			@i_order 	INT)


RETURNS	INT

/*  The purpose of the rpt_get_author_key function is to return a specific author key for the bookkey and order number specified.


	returns a 0 if there is no author for the order requested
*/
AS

BEGIN

	DECLARE @RETURN			INT
	DECLARE @i_count		INT		
	DECLARE @i_authorkey		INT
	DECLARE @i_sortorder		INT



/* FIND OUT HOW MANY AUTHORS THERE ARE */

	SELECT	@i_count=count(*)
			FROM bookauthor
			WHERE	bookkey = @i_bookkey
	IF @i_count< @i_order -- there are less authors than what is requested, return a 0
		BEGIN
			SELECT @RETURN = 0
		END
	ELSE
		BEGIN
			SELECT 	@i_authorkey = authorkey
					FROM bookauthor
					WHERE	bookkey = @i_bookkey
					AND sortorder = @i_order
					
			IF @i_authorkey > 0
				BEGIN
					SELECT @RETURN = @i_authorkey
				END
			ELSE
				BEGIN
					SELECT @RETURN = 0
				END
		END



RETURN @RETURN


END

go
Grant All on dbo.rpt_get_author_key to Public
go