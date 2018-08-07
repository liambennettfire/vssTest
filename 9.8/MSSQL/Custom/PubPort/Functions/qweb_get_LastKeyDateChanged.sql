SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_LastKeyDateChanged]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_LastKeyDateChanged]
GO




CREATE FUNCTION dbo.qweb_get_LastKeyDateChanged(
			@i_bookkey INT,
			@i_datetypecode INT)

RETURNS DATETIME

AS
BEGIN
	DECLARE @RETURN DATETIME

	SELECT @RETURN = MAX(lastmaintdate)
	FROM	datehistory
	WHERE	@i_bookkey = bookkey
		AND @i_datetypecode = datetypecode

	RETURN @RETURN
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

