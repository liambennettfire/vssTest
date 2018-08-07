
/****** Object:  UserDefinedFunction [dbo].[rpt_get_group_level_3]    Script Date: 03/24/2009 13:09:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_group_level_3') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_group_level_3
GO
CREATE FUNCTION [dbo].[rpt_get_group_level_3]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the rpt_get_group_level_3 function is to return a specific description column from orgentry
for Group Level 3 for the requested column.

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
			ELSE
				BEGIN
					SELECT @RETURN = ''
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
go
Grant All on dbo.rpt_get_group_level_3 to Public
go