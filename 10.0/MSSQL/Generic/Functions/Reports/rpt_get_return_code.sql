
/****** Object:  UserDefinedFunction [dbo].[rpt_get_return_code]    Script Date: 03/24/2009 13:15:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_return_code') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_return_code
GO
CREATE FUNCTION [dbo].[rpt_get_return_code]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the rpt_get_return_code function is to return a specific description column from gentables for a Return Code

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_returncode		INT

	SELECT @v_desc = ''
	
	SELECT @i_returncode = returncode
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey
	

IF @i_returncode > 0
	BEGIN
	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 319
					AND datacode = @i_returncode
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	gentables  
			WHERE  tableid = 319
					AND datacode = @i_returncode
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	gentables  
			WHERE  tableid = 319
					AND datacode = @i_returncode
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 319
					AND datacode = @i_returncode
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 319
					AND datacode = @i_returncode
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 319
					AND datacode = @i_returncode
		END

	ELSE IF @v_column = 'T'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(eloquencefieldtag))
			FROM	gentables  
			WHERE  tableid = 319
					AND datacode = @i_returncode
		END
	END



	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END

go
Grant All on dbo.rpt_get_return_code to Public
go