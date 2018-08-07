SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_Audience]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_Audience]
GO




CREATE FUNCTION dbo.qweb_get_Audience
		(@i_bookkey	INT,
		@v_column	VARCHAR(1),
		@i_sortorder	INT)

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_Audience function is to return a specific description column from gentables for an Audience Code

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
	DECLARE @i_audiencecode		INT

	SELECT @v_desc = ''
	
	SELECT @i_audiencecode = audiencecode
	FROM	bookaudience
	WHERE	bookkey = @i_bookkey
	AND 	sortorder = @i_sortorder

IF @i_audiencecode > 0
	BEGIN
	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 460
					AND datacode = @i_audiencecode
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	gentables  
			WHERE  tableid = 460
					AND datacode = @i_audiencecode
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	gentables  
			WHERE  tableid = 460
					AND datacode = @i_audiencecode
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 460
					AND datacode = @i_audiencecode
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 460
					AND datacode = @i_audiencecode
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 460
					AND datacode = @i_audiencecode
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









GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

