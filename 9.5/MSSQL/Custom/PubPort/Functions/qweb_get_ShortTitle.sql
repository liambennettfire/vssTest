SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_ShortTitle]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_ShortTitle]
GO




CREATE FUNCTION dbo.qweb_get_ShortTitle (
		@i_bookkey	INT)
	
	RETURNS VARCHAR(50)
	
AS
BEGIN
	DECLARE @RETURN			VARCHAR(50)
		

	SELECT @RETURN = ltrim(rtrim(shorttitle))
	FROM book
	WHERE bookkey = @i_bookkey


  RETURN @RETURN
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

