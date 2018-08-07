/****** Object:  UserDefinedFunction [dbo].[rpt_get_project_group_level_2]    Script Date: 08/12/2015 10:22:23 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_project_group_level_2]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_get_project_group_level_2]
GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_project_group_level_2]    Script Date: 08/12/2015 10:03:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[rpt_get_project_group_level_2]
		(@i_projectkey	INT,
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
	FROM	taqprojectorgentry
	WHERE	taqprojectkey = @i_projectkey
				AND orglevelkey = 2


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


GO


