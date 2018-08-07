/****** Object:  UserDefinedFunction [dbo].[get_ship_method]    Script Date: 5/24/2016 10:56:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF EXISTS (SELECT * from sysobjects s WHERE s.name ='get_ship_method') begin 
/****** Object:  UserDefinedFunction [dbo].[get_ship_method]    Script Date: 5/24/2016 11:07:16 AM ******/
		DROP FUNCTION [dbo].[get_ship_method]
END
GO




CREATE FUNCTION [dbo].[get_ship_method](
			@i_shipmethodcode INT)

RETURNS CHAR(255)

AS
BEGIN
	DECLARE @RETURN CHAR(155)

	SELECT @RETURN = datadesc
	FROM		gentables
	WHERE	tableid = 1004 
		AND @i_shipmethodcode = datacode

	RETURN @RETURN
END

GO

GRANT all on [get_ship_method] to public
GO