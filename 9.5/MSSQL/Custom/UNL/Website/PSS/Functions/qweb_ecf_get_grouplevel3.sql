
/****** Object:  UserDefinedFunction [dbo].[qweb_get_GroupLevel3]    Script Date: 09/21/2007 13:31:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

drop function qweb_get_GroupLevel3
go

CREATE FUNCTION [dbo].[qweb_get_GroupLevel3]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_Series function is to return a specific description column from gentables for a series

	Parameter Options
		F = Group Level Description
		S = Group Level Short Description
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_orgentrykey		INT	


	SELECT @i_orgentrykey = orgentrykey
	FROM	bookorgentry
	WHERE	bookkey = @i_bookkey
				AND orglevelkey = 3


	IF @v_column = 'F'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(orgentrydesc))
			FROM	orgentry
			WHERE	orgentrykey = @i_orgentrykey
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END
	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(orgentryshortdesc))
			FROM	orgentry
			WHERE	orgentrykey = @i_orgentrykey
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
			
			
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(altdesc1))
			FROM	orgentry
			WHERE	orgentrykey = @i_orgentrykey
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			
			ELSE --  do NOT get the full description and return that
				BEGIN
					SELECT @v_desc = ltrim(rtrim(orgentrydesc))
						FROM	orgentry
						WHERE	orgentrykey = @i_orgentrykey
			
						IF datalength(@v_desc) > 0
							BEGIN
								SELECT @RETURN = ''
							END
						ELSE
							BEGIN
								SELECT @RETURN = ''
							END
			        END
			
			
		END

		ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(altdesc2))
			FROM	orgentry
			WHERE	orgentrykey = @i_orgentrykey
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
			
			
		END

RETURN @RETURN


END






