SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_SubTitle]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_SubTitle]
GO




CREATE FUNCTION dbo.qweb_get_SubTitle (
		@i_bookkey	INT)
	
RETURNS VARCHAR(255)

	
AS
BEGIN
	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_subtitle 			VARCHAR(255)
		

	SELECT @v_subtitle = ltrim(rtrim(subtitle))
	FROM book
	WHERE bookkey = @i_bookkey
	
	IF LEN(@v_subtitle) > 0
		BEGIN	
			SELECT @RETURN = @v_subtitle
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

